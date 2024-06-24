/**
 * This class was not deleting news articles. so we needed to rework it
 * C-00003017
 *
 * @author		Olebogeng Ntechane/Nokcs Mulea
 * @date		November 2019
 */
public class CI_NewsCacheRemover implements Database.Batchable<SObject>, Database.Stateful {

    public final String newsCacheList;
    public final String articlesToRemove;
    public final String objectName;
    private Map<Id, String> failedRecId2ErrorMessage = new Map<Id, String>();
    public static final String CRM_HELPDESK_SB_PARAMETER_NAME = 'CRMHelpdeskEmail';

    /**
    * Constructor to construct the query based on the SObject passed as param
    *
    * @param objectName String representing with SObject is this instance dealing with
    */
    public CI_NewsCacheRemover(String objectName) {
        String monthAgo = '\'' + String.valueOf(System.today().addDays(-30)) + '\'';
        newsCacheList = 'SELECT Id FROM CI_News_Cache__c WHERE CreatedDate < LAST_N_DAYS:30';
        articlesToRemove = 'SELECT Id FROM ArticleNews__c WHERE Publication_Date__c < ' + monthAgo;
        this.objectName = objectName;
    }

    /**
    * Overridden start Batchable method
    *
    * @param bc default reference to Database.BatchableContext
     * @return QueryLocator object for a SELECT query
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (this.objectName == DMN_ArticleNews.OBJ_NAME) {
            return Database.getQueryLocator(articlesToRemove);
        } else {
            return Database.getQueryLocator(newsCacheList);
        }
    }

    /**
    * Overridden execute Batchable method
    *
    * @param bc default reference to Database.BatchableContext
    * @param records list of SObject records (ArticleNews__c or CI_News_Cache__c)
    */
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<SObject> sObjectOfArticleNewsList = new List<ArticleNews__c>();

        if (this.objectName == DMN_ArticleNews.OBJ_NAME) {
            List<NewsBookmark__c> newBookListRelated = [SELECT ArticleNews__c, ArticleNews__r.Publication_Date__c FROM NewsBookmark__c WHERE ArticleNews__c NOT IN :records];
            if (newBookListRelated.size() == 0) {
                deleteAndProcessErrors(records);
            } else {
                Map<String, String> mappedNewsBook = new Map<String, String>();

                for (NewsBookmark__c newBook : newBookListRelated) {
                    if (Date.valueOf(newBook.ArticleNews__r.Publication_Date__c) >= System.today().addDays(-90)) {
                        mappedNewsBook.put(newBook.ArticleNews__c, 'true');
                    }
                }
                for (SObject an : records) {
                    if (mappedNewsBook.get(String.valueOf(an.get('id'))) == null) {
                        //add it for delete
                        sObjectOfArticleNewsList.add(an);
                    }
                }

                if (sObjectOfArticleNewsList.size() > 0) {
                    deleteAndProcessErrors(sObjectOfArticleNewsList);
                }
            }
        } else {
            deleteAndProcessErrors(records);
        }
    }

    /**
    * Overridden finish Batchable method to send emails to CRM HelpDesk
    *
    * @param bc default reference to Database.BatchableContext
    */
    public void finish(Database.BatchableContext bc) {
        if (failedRecId2ErrorMessage.size() > 0) {
            sendEmails();
        }
    }

    private void deleteAndProcessErrors(List<SObject> recordsToDelete) {
        Database.DeleteResult[] srList = Database.delete(recordsToDelete, false);
        String errorMessage = '';
        for (Integer i = 0, j = srList.size(); i < j; i++) {
            if (!(srList[i].isSuccess())) {
                for (Database.Error err : srList[i].getErrors()) {
                    errorMessage = err.getStatusCode() + ': ' + err.getMessage();
                    failedRecId2ErrorMessage.put(recordsToDelete.get(i).Id, errorMessage);
                }
            }
        }
    }

    private void sendEmails() {
        SB_Parameters__c crmHelpdeskEmail = SB_Parameters__c.getValues(CRM_HELPDESK_SB_PARAMETER_NAME);
        String toAddress;
        if (crmHelpdeskEmail != null) {
            toAddress = crmHelpdeskEmail.Value__c;
        }
        String subject = 'Batch CI_NewsCacheRemover failures';
        String body = '';
        for (Id objectId : failedRecId2ErrorMessage.keySet()) {
            body += '<b>ID:</b> '+ objectId + ', <b>ERROR_MESSAGE:</b> ' + failedRecId2ErrorMessage.get(objectId) + '<br /><br />';
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
                UTL_Email.createEmails(subject, body, new List<String> { toAddress })
        };
        Messaging.sendEmail(emails);
    }
}