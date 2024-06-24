/**
* @FuncArea PBB Lifestyle
* @Author Mykhailo Reznyk
* @Date 22.11.2019
* @UserStory US-4468
* @description APEX Controller class for PBB_Lifestyle_Account_Types component.
*/
public without sharing class PBB_Lifestyle_Account_TypesController {

    /**
    * @description Retrieves current Client(Account) object with the list of the related Account Information objects. Returns null if no Client with such Id was found.
    *
    * @param clientId Current Client Id
    *
    * @return Account recordData Current Client with list of related Account Information objects
    */
    @AuraEnabled
    public static Account fetchData(Id clientId){
        Account[] recordData = [SELECT Id, (SELECT Id, Product_Category__c FROM Client_Accounts__r)
                                FROM Account
                                WHERE Id =: clientId];

        if(recordData.size() == 0){
            return null;
        }
        else {
            return recordData[0];
        }

    }

}