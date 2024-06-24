/**
* @description  Partner Portal Change Password Controller 
* User Story : SFP-5296
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
public with sharing class PP_Support_CTRL {

     /**
     * @description Used to Create Case from Partner Portal
     * User Story : SFP-5296
     * @param newCase 
     * @return 
     */
    @AuraEnabled
    public static string createCase(Case newCase){  
        newCase.Status = DMN_Case.STATUS_NEW;
        newCase.Priority = DMN_Case.PRIORITY_LOW;
        newCase.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CROSS_BORDER);
        
        UTL_Security.xssSanitize(newCase, new List<String> { 'SuppliedName', 'Description', 'SuppliedPhone', 'Subject'});
       
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Case.SObjectType });
        PP_SRV_NewCase.newInstance().saveCases(new List<Case>{newCase},uow);
        
        return 'Success'; 
    }
    
    /**
     * @description Used to Create Case from Partner Portal
     * User Story : SFP-5296
     * @param contactId 
     * @return User
     */
    @AuraEnabled
    public static User getParnerRecordOnwer(String contactId){

        User usr = new User();
        List<PP_PartnerApplication__c> partners = SEL_PartnerApplication.newInstance().selectByPrimaryContactId(new Set<Id>{contactId}); 
        List<User> usrList = SEL_Users.newInstance().selectByIdWoSharing(new Set<Id>{partners[0].OwnerId});

        if(!usrList.isEmpty()) {
            usr = usrList.get(0);
        } 

        return usr;
    }
}