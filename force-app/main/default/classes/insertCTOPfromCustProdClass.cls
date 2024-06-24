/*************************************************************************\
    @ Author        : Amjad Khan 
    @ Date          : Nov, 2010
    @ Test File     : 
    @ Description   : This class is called from the Trigger insertSTPfromCustProd. 
    @                 This class maintains the Junction object everytime a Product is associated/de-associated from an Opportunity.
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Anurag Jain
    @ Last Modified On  :   Dec, 2010
    @ Last Modified Reason  :   Comments and formatting

    @ Last Modified By  :   Charles Mutsu
    @ Last Modified On  :   Jan, 2013
    @ Last Modified Reason  :   Implemented Error Log Utility for capturing the errors, comments and formatting
                                Changed the API version to 27.
    
****************************************************************************/
public class insertCTOPfromCustProdClass {

    public List < Id > cpId = new List < Id > ();
    public List < Id > oppId = new List < Id > ();
    public List < Id > accId = new List < Id > ();
    public List < ClientTeamOpportunity_Products__c > ctopList = new List < ClientTeamOpportunity_Products__c > ();

    /*********************************************************************************************************************
   Method : insertCTOP
   Input  : List<SB_Product__c> 
   Return Type : null 
   Desc   :Every time a Product is inserted the corresponding entry is inserted in Client Team Junction object.
   ********************************************************************************************************************/
    public void insertCTOP(List < SB_Product__c > sp) {
        for (SB_Product__c sp1: sp) {
            oppId.add(sp1.Opportunity__c);
        }

        If(oppId.size() > 0) {
            List < Opportunity > opp1 = [Select Id, AccountId from Opportunity where Id in : oppId];
            for (Opportunity opp_obj: opp1) {
                accId.add(opp_obj.AccountId);
            }
        }

        If(accId.size() > 0) {
            List < Custom_Client_Team__c > cct_list = [select Id from Custom_Client_Team__c where Account__c in : accId];
            if (cct_list.size() > 0) {
                for (Custom_Client_Team__c cct_obj: cct_list) {
                    for (SB_Product__c sp1: sp) {
                        ClientTeamOpportunity_Products__c ctop = new ClientTeamOpportunity_Products__c(Product__c = sp1.Id, Opportunity__c = sp1.Opportunity__c, Custom_Client_Team__c = cct_obj.Id, ClientTeamId__c = cct_obj.Id);
                        ctopList.add(ctop);
                    }
                }
            }
        }

        if (ctopList.size() > 0) {
            Database.SaveResult[] lsrSave = Database.Insert(ctopList, False);
            String errorDetails = '';

            for (Database.SaveResult srSave: lsrSave) { //Begin of For
                if (!srSave.isSuccess()) {
                    Database.Error err = srSave.getErrors()[0];
                    errorDetails = errorDetails + err.getMessage() + ', ';
                }
            } //End of For   

            If(errorDetails <> '') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {
                    'CIBSACRMITProductionSuppo@standardbank.co.za'
                };
                mail.setToAddresses(toAddresses);
                mail.setSubject('Error Encountered while Inserting records to the Client Team Junction Object');
                mail.setPlainTextBody('Error Encountered:: insertCTOPfromCustProdClass.insertCTOP: ' + errorDetails);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                    mail
                });
            }

        } //End of If

    }


    /*********************************************************************************************************************
   Method : deleteCTOP
   Input  : List<SB_Product__c> 
   Return Type : null 
   Desc   : Every time any Product is deleted the corresponding entry is deleted from Client Team Junction object.
   ********************************************************************************************************************/
    public void deleteCTOP(List < SB_Product__c > sp_del) {

        for (SB_Product__c sp1: sp_del) {
            cpId.add(sp1.Id);
        }

        if (cpId.size() > 0) {
            ctopList = [Select Id from ClientTeamOpportunity_Products__c where Product__c in : cpId];
        }

        if (ctopList.size() > 0) {
            Database.DeleteResult[] lsrDel = Database.Delete(ctopList, False);
            for (Database.DeleteResult sr: lsrDel) { //Begin of For
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {
                        'CIBSACRMITProductionSuppo@standardbank.co.za'
                    };
                    mail.setToAddresses(toAddresses);
                    mail.setSubject('Error Encountered while deleting the Client Team Junction Object Records');
                    mail.setPlainTextBody('Error Encountered:: insertCTOPfromCustProdClass.deleteCTOP: ' + err.getMessage());
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                        mail
                    });
                }
            } //End of For

        }

    }

}