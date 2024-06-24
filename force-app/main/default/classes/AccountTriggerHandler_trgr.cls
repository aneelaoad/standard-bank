/*************************************************************************
@ Author        : Nitish Kumar
@ Date          : 10-Jan-2013
@ Test File     : AccountTriggerHandler_trgr_test
@ Description   : Trigger Helper class which takes the 2 digit ISO Code and converts the BillingCounty
with the names of the country
@ Enhancement   : EN -- 0004

@ Audit Trial   : Repeating block for each change to the code
-----------------------------------------------------------------------------
@ Last Modified By  :   Nitish Kumar
@ Last Modified On  :   17/01/13
@ Last Modified Reason  : Updated API Version to 27

@ Last Modified By  :   Nitish Kumar        
@ Last Modified On  :   August 2013
@ Last Modified Reason  : EN-212 , Custom Client Team Issues
Updated API Version to 28

@ Last Modified By  :   Nitish Kumar        
@ Last Modified On  :   January 2014
@ Last Modified Reason  : EN-226 , Client Sector Update
Updated API Version to 29

@ Last Modified By  :   Nitish Kumar        
@ Last Modified On  :   April 2014
@ Last Modified Reason  : EN-337 , CC Feed From CDG

@ Last Modified By  :   Nitish Kumar        
@ Last Modified On  :   Febb 2015
@ Last Modified Reason  : En 590 and En 611

@ Last Modified By  :   Petr Roubal        
@ Last Modified On  :   Jun 2015
@ Last Modified Reason  : EN-751 , Reject New CIF Client - Invalid CC 

@ Last Modified By  :   Sandeep Dharwar        
@ Last Modified On  :   July 2015
@ Last Modified Reason  : DEF- 001340

@ Last Modified By  :   Abhishek Vaideeswaran        
@ Last Modified On  :   July 2015
@ Last Modified Reason  : DEF- 001352 : Replacement of Client Hierarchy Level rename to Client Relationship Hierarchy

@ Last Modified By  :   Sandeep Dharwar        
@ Last Modified On  :   Aug 2015
@ Last Modified Reason  : EN-802, Onboarding: Client Coordinator Role on CST on Client Creation

@ Last Modified By  :   Petr Svestka
@ Last Modified On  :   Sep 2015
@ Last Modified Reason  : EN-791 added a check for Email Deliverability to prevent an exception

@ Last Modified By  :   Manoj Gupta
@ Last Modified On  :   Sep 2015
@ Last Modified Reason  : EN-839 added checks for CC update against profiles 
                                              (i.e if CCs User Division is Client Coverage Role should be 'Manager Client Coverage' else 'Business Dev Manager' with profile checks)

@ Last Modified By  : Petr Svestka
@ Last Modified On  : Oct 1, 2015
@ Modification Description : EN-865 - upon upsert, share CSI records with users in the client team


@ Last Modified By  :   Manoj Gupta       
@ Last Modified On  :   Oct 2015
@ Last Modified Reason  : Added Salesforce to Salesforce sharing method (Moving Jorel Naidu code from ServoCloud org)

@ Last Modified By  : Petr Svestka
@ Last Modified On  : Nov 19, 2015
@ Modification Description : EN-912 - enforcing CST team roles when creating/updating based on user's division

@ Last Modified By  :   Manoj Gupta       
@ Last Modified On  :   Dec 2015
@ Last Modified Reason  : EN:0838 - Replacing Corporate Banking references to Client Coverage

@ Last Modified By  :   Manoj Gupta       
@ Last Modified On  :   Jan 2016
@ Last Modified Reason  : EN:0967 - Replacing 'CB Relationship Manager' with 'CommB Relationship Manager' 

@ Last Modified By  :   Manoj Gupta        
@ Last Modified On  :   Jan 2016
@ Last Modified Reason  : EN:1015 Added Connectionstatus = 'Accepted' in connection record SOQL query.This is to refer Active connection only

@ Last Modified By  :   Jana Cechova    
@ Last Modified On  :   Jul 2016
@ Last Modified Reason  : US-1420 - OB - Update "Notify CC of Secto/Hierarchy or CC changes" email template

****************************************************************************/

public  class AccountTriggerHandler_trgr {
    
    public static boolean afterUpdateCCCalled = false;

    /**
* @author :- Anurag Jain
* @date  :-  25 March 2011 
* @description :-  To handle the deletion of Client Team Junction object records on the deletion of Account records
* @param :- Map<Id,Account>
*/
    
    public static void deleteClientTeamJunctionObject(Map < Id, Account > oldMapAccount) {

        //Find the Custom Client Team records associated to all the Accounts that are being deleted.
        List < Custom_Client_Team__c > lstCCT = [select Id, Account__c from Custom_Client_Team__c where Account__c in : oldMapAccount.keySet()];
        
        if (lstCCT.size() > 0) {
            List < Id > lstCCTIDs = new List < Id > ();
            for (Custom_Client_Team__c objCCT: lstCCT) {
                lstCCTIDs.add(objCCT.Id);
            }
            
            //Delete the records from the Junction object where there is a matching Custom Client Team Id.
            List < ClientTeamOpportunity_Products__c > ctop_to_del = [select Id, Custom_Client_Team__c from ClientTeamOpportunity_Products__c where Custom_Client_Team__c in : lstCCTIDs];

            if (ctop_to_del.size() > 0) {
                Database.DeleteResult[] sr = Database.delete(ctop_to_del, false);
            }
        }
        
        //Case#7818 - Email to be send when a Client is Deleted - Calling the clientDeleteNotificationEmail Apex Class
        If(!(Environment_Variable__c.getInstance().Deactivate_Client_Delete_Email_Alert__c))
            ClientDeleteEmailAlert.clientDeleteNotificationEmail(oldMapAccount.values());
        
    }

}