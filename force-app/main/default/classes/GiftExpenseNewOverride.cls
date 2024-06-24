/*************************************************************************\
    @ Author:       Caro Reinecke
    @ Date:         18 November 2011
    @ Test File:    
    @ Description:  This class is an extension to the standard Gift/Expense Log controller to allow for the bank contact field to be 
                    defaulted to the record creator's bank contact record
                              
    @ Last Modified By  : 
    @ Last Modified On  : 
    @ Last Modified Reason  : 
                             
****************************************************************************/ 
public with sharing class GiftExpenseNewOverride {
   
    
    public Gift_Expense_Log__c GiftExpenseLog{get; private set;}
    public Contact theContact {get; private set;}
    
    public GiftExpenseNewOverride(ApexPages.StandardController controller) {
        this.GiftExpenseLog = (Gift_Expense_Log__c)controller.getRecord();
        if (GiftExpenseLog.Client_Contact_Name__c != null){
            this.theContact = [select Name,Id from contact where id = :GiftExpenseLog.Client_Contact_Name__c];
        }
    }
    
    public PageReference defaultFields(){
        String usrId = UserInfo.getUserId();
        User theBankContactUser = [Select Contact_Sync_ID__c,Name from User where id = :usrId];
        String theBankContactId = theBankContactUser.Contact_Sync_ID__c;
        String theBankContactName = theBankContactUser.Name;
        String objectPrefix = Schema.getGlobalDescribe().get('Gift_Expense_Log__c').getDescribe().getKeyPrefix();
        String serverURL = Environment_Variable__c.getInstance().serverURL__c;
        PageReference newPage = new PageReference(serverURL+'/'+objectPrefix+'/e');
        String theBankContactField = Gift_Expense_Log_Variables__c.getInstance().Bank_Contact_Field_Id__c;
        if (theBankContactField == null) {
            newPage.getParameters().put('nooverride', '1');
            newPage.getParameters().put('cancelURL', objectPrefix);
            return newPage.setRedirect(true);
        }
        String theClientContactField = Gift_Expense_Log_Variables__c.getInstance().Client_Contact_Field_Id__c;
        
        newPage.getParameters().put(theBankContactField+'_lkid', theBankContactId);
        newPage.getParameters().put(theBankContactField +'_lkold', theBankContactName );
        newPage.getParameters().put(theBankContactField, theBankContactName );
        if ((theContact != null) && (theClientContactField != null)){
            newPage.getParameters().put(theClientContactField+'_lkid', theContact.Id);
            newPage.getParameters().put(theClientContactField+'_lkold', theContact.Name);
            newPage.getParameters().put(theClientContactField, theContact.Name);
        }
        newPage.getParameters().put('nooverride', '1');
        newPage.getParameters().put('cancelURL', objectPrefix);
        return newPage.setRedirect(true);
    }

}