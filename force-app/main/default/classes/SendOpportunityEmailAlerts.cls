/**

@ Author        : Youssef Ibrahim
@ Date          : 14/06/2019
@ Test Class    : SendOpportunityEmailAlerts_Test
@ Description   : US-3918 & US-3917 - Generic class with invocable method (That is invoked form the opportunity process builder on auto close criteria).
The invocable method handles multiple requests that have the appropriate inputs each (The inner class for the request skeleton is at the bottom).

*/

global without sharing class SendOpportunityEmailAlerts {

    @InvocableMethod(Label='Send Email to OppTeam')
    global static void sendEmailAlertForOpportunity(List<emCDateReq> emSendReqs) {
        // --------Map OpportunityId (input) to list of Ids belonging to OpporunityTeam--------
        Map<Id, Set<Id>> oppRecipients = new Map<Id, Set<Id>>();

        // --------Iterate over all incoming requests and fill the two above mentioned maps for each request--------
        for (emCDateReq request : emSendReqs ) {
            oppRecipients.put(request.opportunityId, new Set<Id>());
        }
        //The following lines are only needed to send emails from a certain org-wide email address.
        //The email should be verified and available to either 'All profiles' OR select all profiles that may actually use this Apex class for sending email alerts.
        Id orgWideEmailAddress;
        // --------Query to get the appropriate org-wide email address to specify as from in the email--------
        List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'cibsacrmitproductionsuppo@standardbank.co.za'];
        if ( orgWideEmailAddresses.size() > 0 ) {
           orgWideEmailAddress = orgWideEmailAddresses.get(0).Id;
        }
        // --------List to hold all Opportunities to be cancelled
        List<Opportunity> cancelledOpportunities = new List<Opportunity>();
        // --------Query to get all Opportunities and their corresponding teamMembers--------
        Map<Id, Opportunity> allOpportunities = new Map<Id, Opportunity>([SELECT Id, CloseDate, EmailAlertSent_90DAYS__c, EmailAlertSent_14DAYS__c, EmailAlertSent_7DAYS__c,
                                                                                (SELECT Id, UserId
                                                                                 FROM OpportunityTeamMembers)
                                                                          FROM Opportunity
                                                                          WHERE Id IN :oppRecipients.keySet()]);
        // --------Iterate over all opportunities--------
        for (emCDateReq req : emSendReqs) {
            Opportunity opp = allOpportunities.get(req.opportunityId);
            Integer OppMode = req.mode;
            Date DateFieldSending;
            // --------Check which mode----------
            if (OppMode == 7) {
                DateFieldSending = opp.EmailAlertSent_7DAYS__c;
            } else if (OppMode == 14) {
                DateFieldSending = opp.EmailAlertSent_14DAYS__c;
            } else {
                DateFieldSending = opp.EmailAlertSent_90DAYS__c;
            }
            // --------First thing, double check that the CloseDate is MORE THAN 7 Days, 14 Days or 90 Days from today.
            // To avoid sending emails for Opps at inapproriate times.--------
            if (opp.CloseDate.addDays(-(OppMode)) >= System.today()
                    && (DateFieldSending == null || DateFieldSending != System.today())) {
                // --------Iterate over teamMembers for that opportunity--------
                for (OpportunityTeamMember member : opp.OpportunityTeamMembers) {
                        // --------Add all members 'userId' to the list--------
                        (oppRecipients.get(opp.Id)).add(member.UserId);
                }
                // --------Send The teamMembers 'Users' the appropriate email template (input)--------
                sendEmail(oppRecipients.get(opp.Id), opp.Id, req.teamETemplateId, orgWideEmailAddress);
                if (OppMode == 7) {
                    opp.EmailAlertSent_7DAYS__c = System.today();
                } else if (OppMode == 14) {
                    opp.EmailAlertSent_14DAYS__c = System.today();
                } else {
                    opp.EmailAlertSent_90DAYS__c = System.today();
                }
            }
        }
        //Update all opportunities to save the new values for the EmailAlertSent_XDays custom fields
        update allOpportunities.values();

		if (cancelledOpportunities.size() > 0) {
            update cancelledOpportunities;
        }
        return;
    }

    // --------Method for sending emails (INCLUDE OrgWideEmail IF NEEDED)--------
    public static void sendEmail(Set<Id> oppTeams, Id opportunityId, Id emailTemplate, Id orgWideEmailAddressId) {
        // --------Send email alert with the appropriate email template to the appropriate recipients--------
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (Id memberId : oppTeams) {

            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate, memberId, opportunityId);

            String emailSubject = email.getSubject();
            String emailTextBody = email.getPlainTextBody();
            //This line belongs to the OrgWideEmail functionality. It should only be uncommented if the above lines are uncommented.
            email.setOrgWideEmailAddressId(orgWideEmailAddressId);
            email.setSubject(emailSubject);
            email.setPlainTextBody(emailTextBody);
            email.saveAsActivity = false;
            messages.add(email);
        }

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(messages);
        }
    }


    // --------Inner class to handle all incoming requests consisting of 3 attributes,
    // OpportunityID, Team EmailTemplateID, ClientCoordinator EmailTemplateID--------
    global class emCDateReq {
        @InvocableVariable(label='Opportunity Id' required=true)
        global Id opportunityId;
        @InvocableVariable(label='Team Email Template Id' required=true)
        global Id teamETemplateId;
        @InvocableVariable(label='Number of days for email alert' required=true)
        global Integer mode;
    }
}