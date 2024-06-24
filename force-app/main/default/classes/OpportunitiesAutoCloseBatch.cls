/**
 * A batch to autoclose opportunities 1 month after expiry.
 * <br/>US-4657 - SGPRT-827
 *
 * @author Youssef Ibrahim(yibrahim@deloittece.com)
 * @date November 2019
 */
global class OpportunitiesAutoCloseBatch implements Database.Batchable<SObject> {

    private String queryString;
    private static Date expDate = System.today().addDays(-30);    
    private static String SUPPORT_EMAIL = 'cibsacrmitproductionsuppo@standardbank.co.za';
    private Id SUPPORT_EMAIL_ID;

    global OpportunitiesAutoCloseBatch() {
        try {
            SUPPORT_EMAIL_ID = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :SUPPORT_EMAIL].get(0).Id;
            queryString = 'SELECT RecordTypeId, StageName,CloseDate, Actual_Close_Date__c, ReasonForWinLossPickList__c, Reason_Won_Lost_Comments__c, ' +
                    '(SELECT Id, UserId ' +
                    'FROM OpportunityTeamMembers) ' +
                    'FROM Opportunity ' +
                    'WHERE CloseDate <= :expDate AND ( StageName = \'1 - Lead\' OR StageName = \'2 - Develop\') AND RecordType.Name != \'Africa Regions Opportunity\'';
        } catch (Exception ex) {
            System.debug('***An Unexpected Exception occurred. Please contact your System Admin. ' + ex.getMessage());
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> Opportunities) {
        try {           
            for (Opportunity opp : Opportunities) {
                if (System.today() >= opp.CloseDate + 30) {
                    opp.Actual_Close_Date__c = System.today();
                    opp.ReasonForWinLossPickList__c = 'Captured in Error / Duplicate / Expired';                                        
                    opp.Reason_Won_Lost_Comments__c = 'Auto closed';
                    opp.StageName = 'Cancel';
                    sendEmail(opp.Id, opp.OpportunityTeamMembers);
                }
            }
            update Opportunities;
        } catch (Exception ex) {
            System.debug('Exception' + ex);
        }
    }

    private void sendEmail(Id oppId, List<OpportunityTeamMember> opportunityTeamMembers) {
        Id templateId = UTL_EmailTemplate.getTemplateId(DCN_EmailTemplate.OPP_AUTOCLOSED);
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (OpportunityTeamMember member : opportunityTeamMembers) {
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, member.UserId, oppId);
            String emailSubject = email.getSubject();
            String emailTextBody = email.getPlainTextBody();
            email.setOrgWideEmailAddressId(SUPPORT_EMAIL_ID);
            email.setSubject(emailSubject);
            email.setPlainTextBody(emailTextBody);
            email.saveAsActivity = false;
            messages.add(email);
        }

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(messages);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}