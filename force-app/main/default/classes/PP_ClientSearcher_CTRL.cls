/**
* @description  : Client Searcher LWC Controler
* User Story : SFP-11652
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date March 2022
*/
public with sharing class PP_ClientSearcher_CTRL {
    
    /**
    * @description Get Matching Client Records
    * User Story : SFP-11652
    * @param companyName
    * @param regNo
    * @return List<Account>
    **/
    @AuraEnabled
    public static List<Account> getMatchingClients(String companyName, String regNo){
        
        String searchString = regNo.replaceAll('//', '')+' OR *'+companyName+'*';
        List<List<sObject>> searchList = [FIND :searchString IN ALL FIELDS RETURNING Account(Id,Name,Registration_Number__c) LIMIT 10];
        
        List<Account> clientlist = (List<Account>) searchList[0];        
        return clientlist;
    }
    
    /**
    * @description Link the client with Partner Application
    * User Story : SFP-11652
    * @param recordId
    * @param clientId
    **/
    @AuraEnabled
    public static void linkClient(String recordId, String clientId){
        try {
            PP_PartnerApplication__c partner = new PP_PartnerApplication__c();
            partner.Id = recordId;
            partner.PP_Account__c = clientId;
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { PP_PartnerApplication__c.SObjectType });
            uow.registerDirty(partner);
            uow.commitWork();
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}