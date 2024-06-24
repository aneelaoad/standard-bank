/**
 * @description Batch for deleting resourcing records
 *
 * @author Nikita Haruk
 * @date October 2022
 */
public with sharing class BCH_DeleteResourcingRecords implements Database.Batchable<SObject>, Database.Stateful {

    private static final String
        RESULT_HEADERS                    = '"Name","Resource__c","Resourcing_Type__c","OwnerId","Week_End_Date__c","Errors"\n',
        RESULT_ROW_TEMPLATE               = '"{0}","{1}","{2}","{3}","{4}","{5}","{6}"\n',
        RESULT_FILE_NAME                  = 'Batch_Job_{0}_Failed_Records.csv',
        RESULT_CONTENT_TYPE               = 'text/csv',
        CRM_HELPDESK_SB_PARAMETER_NAME    = 'CRMHelpdeskEmail',
        EMAIL_SUBJECT                     = 'Batch BCH_DeleteResourcingRecords failures',
        EMAIL_BODY_TEMPLATE               = 'Attached to this email are Resourcing__c records for which deletion has failed during the batch process.<br/>Batch job Id: {0}<br/>ORG Id: {1}',
        QUERY_CONDITION                   = 'Week_End_Date__c < LAST_N_DAYS:30';

    private Map<Resourcing__c, List<String>> failedRec2ErrorMessage = new Map<Resourcing__c, List<String>>();

    /**
     * Overridden start Batchable method
     *
     * @param bcContext default reference to Database.BatchableContext
     * @return QueryLocator object for a SELECT query
     */
    public Database.QueryLocator start(Database.BatchableContext bcContext) {
        SEL_Resourcing selResourcing = (SEL_Resourcing) ORG_Application.selector.newInstance(Resourcing__c.SObjectType);
        return Database.getQueryLocator(selResourcing.getQueryWithCustomCondition(QUERY_CONDITION));
    }

    /**
     * Overridden execute Batchable method
     *
     * @param bcContext default reference to Database.BatchableContext
     * @param permSetAsignments list of PermissionSetAssignment records
     */
    public void execute(Database.BatchableContext bcContext, List<Resourcing__c> resources) {
        List<Resourcing__c> resourcingRecordsToDelete = new List<Resourcing__c>();

        for (Resourcing__c  resource : resources) {
            if (resource.CreatedDate == resource.LastModifiedDate &&
                resource.CreatedById == resource.LastModifiedById)
            {
                resourcingRecordsToDelete.add(resource);
            }
        }

        List<Database.DeleteResult> deleteResults = Database.delete(resourcingRecordsToDelete, false);
        handleDeleteResults(resourcingRecordsToDelete, deleteResults);
    }

    private void handleDeleteResults(List<Resourcing__c> resourcingRecordsToInsert, List<Database.DeleteResult> deleteResults) {
        for (Integer i = 0; i < deleteResults.size(); i++) {
            if (!deleteResults.get(i).isSuccess()) {
                List<String> errorMessages = new List<String>();
                for (Database.Error err : deleteResults.get(i).getErrors()) {
                    errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
                }
                failedRec2ErrorMessage.put(resourcingRecordsToInsert.get(i), errorMessages);
            }
        }
    }

    /**
     * Overridden finish Batchable method
     *
     * @param bcContext
     */
    public void finish(Database.BatchableContext bcContext) {
        if (failedRec2ErrorMessage.size() > 0) {
            sendEmails(bcContext);
        }
    }

    private void sendEmails(Database.BatchableContext bcContext) {
        List<Messaging.SingleEmailMessage> emails = createEmail(bcContext);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
    }

    private List<Messaging.SingleEmailMessage> createEmail(Database.BatchableContext bcContext) {
        SB_Parameters__c crmHelpdeskEmail = SB_Parameters__c.getValues(CRM_HELPDESK_SB_PARAMETER_NAME);
        String toAddress;
        if (crmHelpdeskEmail != null) {
            toAddress = crmHelpdeskEmail.Value__c;
        }
        String subject = EMAIL_SUBJECT;
        String body = String.format(EMAIL_BODY_TEMPLATE, new List<String> {
            bcContext?.getJobId(), UserInfo.getOrganizationId()
        });
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
            UTL_Email.createEmails(subject, body, new List<String> {
                toAddress
            })
        };
        emails.get(0).setFileAttachments(new List<Messaging.EmailFileAttachment> {
            createEmailAttachment(bcContext)
        });
        return emails;
    }

    private Messaging.EmailFileAttachment createEmailAttachment(Database.BatchableContext bcContext) {
        String fileBody = RESULT_HEADERS;
        for (Resourcing__c res : failedRec2ErrorMessage.keySet()) {
            fileBody += createRow(res);
        }
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setBody(Blob.valueOf(fileBody));
        attachment.setContentType(RESULT_CONTENT_TYPE);
        attachment.setFileName(String.format(RESULT_FILE_NAME, new List<String> {
            bcContext?.getJobId()
        }));
        return attachment;
    }

    private String createRow(Resourcing__c res) {
        String errorMessages = '';
        for (String errorMsg : failedRec2ErrorMessage.get(res)) {
            errorMessages += errorMsg + '       ';
        }
        return String.format(RESULT_ROW_TEMPLATE, new List<String> {
            res.Name,
            res.Resourcing_Type__c,
            res.OwnerId,
            String.valueOf(res.Week_End_Date__c),
            errorMessages
        });
    }
}