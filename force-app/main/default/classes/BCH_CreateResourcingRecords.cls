/**
 * @description Batch for creating
 *
 * @author Konrad Bruszewski
 * @date June 2021
 */
public with sharing class BCH_CreateResourcingRecords implements Database.Batchable<SObject>, Database.Stateful {

    private static final String
        RESULT_HEADERS                    = '"Opportunity__c","Resource__c","Time_Spent__c","Intensity_Forecast__c","Resourcing_Type__c","OwnerId","Week_End_Date__c","Opportunity_Type__c","Errors"\n',
        RESULT_ROW_TEMPLATE               = '"{0}","{1}","{2}","{3}","{4}","{5}","{6}","{7}","{8}"\n',
        RESULT_FILE_NAME                  = 'Batch_Job_{0}_Failed_Records.csv',
        RESULT_CONTENT_TYPE               = 'text/csv',
        CRM_HELPDESK_SB_PARAMETER_NAME    = 'CRMHelpdeskEmail',
        EMAIL_SUBJECT                     = 'Batch BCH_CreateResourcingRecords failures',
        EMAIL_BODY_TEMPLATE               = 'Attached to this email are Resourcing__c records for which creation has failed during the batch process.<br/>Batch job Id: {0}<br/>ORG Id: {1}',
        CORP_FINANCE_BUSINESS_UNIT        = 'Corporate Finance',
        PERM_SET_ASSIGN_QUERY_CONDITION   = 'PermissionSet.Name = \'Resourcing\' AND Assignee.IsActive = true',
        OPPORTUNITY_TYPE                  = 'Opportunity';

    private static final Set<String> OPP_STAGE_NAMES = new Set<String> {
        '1 - Lead',
        '2 - Develop'
    };

    private Date lastWeekFriday {
        get {
            if (lastWeekFriday == null) {
                lastWeekFriday = UTL_Resourcing.getLastWeekFridayDate();
            }
            return lastWeekFriday;
        }
        set;
    }

    @TestVisible
    private List<String> resourcingTypePicklistValues {
        get {
            if (resourcingTypePicklistValues == null) {
                resourcingTypePicklistValues = getResourcingTypePicklistValues();
            }
            return resourcingTypePicklistValues;
        }
        set;
    }

    private Map<Resourcing__c, List<String>> failedRec2ErrorMessage = new Map<Resourcing__c, List<String>>();

    /**
     * Overridden start Batchable method
     *
     * @param bcContext default reference to Database.BatchableContext
     * @return QueryLocator object for a SELECT query
     */
    public Database.QueryLocator start(Database.BatchableContext bcContext) {
        SEL_PermissionSetAssignments selPermSetAssignment = (SEL_PermissionSetAssignments) ORG_Application.selector.newInstance(PermissionSetAssignment.SObjectType);
        return Database.getQueryLocator(selPermSetAssignment.getQueryWithCustomCondition(PERM_SET_ASSIGN_QUERY_CONDITION));
    }

    /**
     * Overridden execute Batchable method
     *
     * @param bcContext default reference to Database.BatchableContext
     * @param permSetAsignments list of PermissionSetAssignment records
     */
    public void execute(Database.BatchableContext bcContext, List<PermissionSetAssignment> permSetAsignments) {
        Set<Id> userIds = new Set<Id>();
        List<Resourcing__c> resourcingRecordsToInsert = new List<Resourcing__c>();

        getUserIds(permSetAsignments, userIds);
        createNonOpportunityRecords(resourcingRecordsToInsert, userIds);

        Set<Id> opportunityIds = new Set<Id>();
        Map<String, Resourcing__c> opportunityAndResource2Resourcing = new Map<String, Resourcing__c>();
        SEL_OpportunityTeamMembers selOppTeamMembers = (SEL_OpportunityTeamMembers) ORG_Application.selector.newInstance(OpportunityTeamMember.SObjectType);
        List<OpportunityTeamMember> oppMembers = selOppTeamMembers.getOppTeamMembersByUserIdsOppStagesAndBusUnit(userIds, OPP_STAGE_NAMES, CORP_FINANCE_BUSINESS_UNIT);

        getOpportunityIds(oppMembers, opportunityIds);
        SEL_Resourcing resourcingSelector = (SEL_Resourcing) ORG_Application.selector.newInstance(Resourcing__c.SObjectType);
        List<Resourcing__c> lastWeekResourcingRecords = resourcingSelector.selectByOpportunityAndWeekEndDate(opportunityIds, lastWeekFriday.addDays(-7));
        populateOpportunityAndResource2ResourcingMap(lastWeekResourcingRecords, opportunityAndResource2Resourcing);
        createOppRecords(resourcingRecordsToInsert, oppMembers, opportunityAndResource2Resourcing);

        List<Database.SaveResult> saveResults = Database.insert(resourcingRecordsToInsert, false);
        handleSaveResults(resourcingRecordsToInsert, saveResults);
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

    /**
     * Gets values from the Resourcing_Type__c picklist field.
     *
     * @return The list of values from the Resourcing_Type__c picklist field
     */
    public List<String> getResourcingTypePicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult initiativeField = Resourcing__c.Resourcing_Type__c.getDescribe();
        for (Schema.PicklistEntry pickListVal : initiativeField.getPicklistValues()) {
            picklistValues.add(pickListVal.getValue());
        }

        return picklistValues;
    }

    private void handleSaveResults(List<Resourcing__c> resourcingRecordsToInsert, List<Database.SaveResult> saveResults) {
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults.get(i).isSuccess()) {
                List<String> errorMessages = new List<String>();
                for (Database.Error err : saveResults.get(i).getErrors()) {
                    errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
                }
                failedRec2ErrorMessage.put(resourcingRecordsToInsert.get(i), errorMessages);
            }
        }
    }

    private void createNonOpportunityRecords(List<Resourcing__c> resourcingRecordsToInsert, Set<Id> userIds) {
        for (Id userId : userIds) {
            for (String resourcingTypePicklistValue : resourcingTypePicklistValues) {
                if (resourcingTypePicklistValue != OPPORTUNITY_TYPE) {
                    resourcingRecordsToInsert.add(new Resourcing__c(
                        Resource__c = userId,
                        Time_Spent__c = 0,
                        Intensity_Forecast__c = 'Inactive',
                        Resourcing_Type__c = resourcingTypePicklistValue,
                        OwnerId = userId,
                        Week_End_Date__c = lastWeekFriday
                    ));
                }
            }
        }
    }

    private void createOppRecords(List<Resourcing__c> resourcingRecordsToInsert, List<OpportunityTeamMember> oppMembers, Map<String, Resourcing__c> opportunityAndResource2Resourcing) {
        Set<Id> userIds = new Set<Id>();
        for (OpportunityTeamMember teamMember : oppMembers) {
            userIds.add(teamMember.UserId);
        }
        for (OpportunityTeamMember oppTeamMember : oppMembers) {
            resourcingRecordsToInsert.add(new Resourcing__c(
                Opportunity__c = oppTeamMember.OpportunityId,
                Resource__c = oppTeamMember.UserId,
                Time_Spent__c = 0,
                Intensity_Forecast__c = 'Inactive',
                Resourcing_Type__c = OPPORTUNITY_TYPE,
                OwnerId = oppTeamMember.UserId,
                Week_End_Date__c = lastWeekFriday,
                Opportunity_Type__c = opportunityAndResource2Resourcing.get('' + oppTeamMember.OpportunityId + oppTeamMember.UserId)?.Opportunity_Type__c
            ));
        }
    }

    private void getOpportunityIds(List<OpportunityTeamMember> oppMembers, Set<Id> opportunityIds) {
        for (OpportunityTeamMember oppMember : oppMembers) {
            opportunityIds.add(oppMember.OpportunityId);
        }
        opportunityIds.remove(null);
    }

    private void getUserIds(List<PermissionSetAssignment> permSetAsignments, Set<Id> userIds) {
        for (PermissionSetAssignment permSetAsignment : permSetAsignments) {
            userIds.add(permSetAsignment.AssigneeId);
        }
        userIds.remove(null);
    }

    private void populateOpportunityAndResource2ResourcingMap(List<Resourcing__c> lastWeekResourcingRecords, Map<String, Resourcing__c> opportunityAndResource2Resourcing) {
        for (Resourcing__c resourcing : lastWeekResourcingRecords) {
            String compoundKey = '' + resourcing.Opportunity__c + resourcing.Resource__c;
            opportunityAndResource2Resourcing.put(compoundKey, resourcing);
        }
    }

    private List<Messaging.SingleEmailMessage> createEmail(Database.BatchableContext bcContext) {
        SB_Parameters__c crmHelpdeskEmail = SB_Parameters__c.getValues(CRM_HELPDESK_SB_PARAMETER_NAME);
        String toAddress;
        if (crmHelpdeskEmail != null) {
            toAddress = crmHelpdeskEmail.Value__c;
        }
        String subject = EMAIL_SUBJECT;
        String body = String.format(EMAIL_BODY_TEMPLATE, new List<String>{
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
            res.Opportunity__c,
            res.Resource__c,
            String.valueOf(res.Time_Spent__c),
            res.Intensity_Forecast__c,
            res.Resourcing_Type__c,
            res.OwnerId,
            String.valueOf(res.Week_End_Date__c),
            res.Opportunity_Type__c,
            errorMessages
        });
    }
}