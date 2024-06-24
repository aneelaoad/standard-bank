/*************************************************************************
    @ Author        : Youssef Ibrahim
    @ Date          : July 2019
    @description   : Test Class for SendOpportunityEmailAlerts class
    @ User Stories  : Us-3918, US-3917

*************************************************************************/

@isTest
private class SendOpportunityEmailAlerts_Test {

    @isTest
    static void testHandlingReqest(){

        // Retrieve the ids of the email templates that are needed to send the email alerts
        List<List<EmailTemplate>> allEmailTemplates = new List<List<EmailTemplate>>();
        List<EmailTemplate> x7DaysEmails = [SELECT Id FROM EmailTemplate WHERE Name = '7Days Alert-OpportunityTeam'];
        List<EmailTemplate> x14DaysEmails = [SELECT Id FROM EmailTemplate WHERE Name = '14Days Alert-OpportunityTeam'];
        List<EmailTemplate> x90DaysEmails = [SELECT Id FROM EmailTemplate WHERE Name = 'Opportunity Cancelled - OpportunityTeam'];
        allEmailTemplates.add(x7DaysEmails);
        allEmailTemplates.add(x14DaysEmails);
        allEmailTemplates.add(x90DaysEmails);

        // Create common test Client
        Account onlyClient = new Account(Name = 'Testing Account');
        insert onlyClient;

        // Create common test Opportunities
        List<Opportunity> allOpportunities = new List<Opportunity>();
        Opportunity x7Opp = new Opportunity(StageName = '1 - Lead', AccountId = onlyClient.Id, Name = 'Opportunity For Testing 7 Days Email Alerts', CloseDate = System.today().addDays(7));
        Opportunity x14Opp = new Opportunity(StageName = '1 - Lead', AccountId = onlyClient.Id, Name = 'Opportunity For Testing 14 Days Email Alerts', CloseDate = System.today().addDays(14));
        Opportunity x90Opp = new Opportunity(StageName = '1 - Lead', AccountId = onlyClient.Id, Name = 'Opportunity For Testing 90 Days Email Alerts', CloseDate = System.today().addDays(-90));
        allOpportunities.add(x7Opp);
        allOpportunities.add(x14Opp);
        allOpportunities.add(x90Opp);
        insert allOpportunities;

        // List of modes
        List<Integer> modes = new List<Integer>{7, 14, -90};

        // 3 different requests needed for the three types of email alerts, 7 days before, 14 days before and 90 days after
        List<SendOpportunityEmailAlerts.emCDateReq> requests = new List<SendOpportunityEmailAlerts.emCDateReq>();

        for (Integer i = 0; i < 3; i++) {
            SendOpportunityEmailAlerts.emCDateReq request = new SendOpportunityEmailAlerts.emCDateReq();
            request.mode = modes[i];
            request.teamETemplateId = allEmailTemplates[i].get(0).Id;
            request.opportunityId = allOpportunities[i].Id;
            requests.add(request);
        }

        Test.startTest();
        try {
            SendOpportunityEmailAlerts.sendEmailAlertForOpportunity(requests);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();

    }
}