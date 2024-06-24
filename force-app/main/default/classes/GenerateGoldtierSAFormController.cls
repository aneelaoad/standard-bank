/**
 * Created by mjaznicki on 09.07.2018.
 */

public with sharing class GenerateGoldtierSAFormController {

    private static Map<PicklistEntry, List<PicklistEntry>> picklistentry2DependEntries {
        get {
            if (picklistentry2DependEntries == null) {
                picklistentry2DependEntries = UTL_Picklist.getControllingToDependentMap(Account.fields.Client_Type_OnBoard__c, Account.fields.Business_Classification__c);
            }
            return picklistentry2DependEntries;
        }
        set;
    }


    @AuraEnabled
    public static Account getAccount(String accId) {
        return [
                SELECT OwnerId, KYC_Contact__c, Source_of_Wealth__c,Source_of_Funds__c, Anticipated_Level_Volume_of_Activity__c, Nature_of_business_activity__c,
                        RecordType.Name, Expected_Income__c, Industry_Code__c, SA_Industry_Description__c,Client_Type_OnBoard__c,Business_Classification__c
                FROM Account
                WHERE Id = :accId
        ];
    }

    @AuraEnabled
    public static Boolean isAccessGiven() {
        return SRV_ProfileConfiguration.checkIfCurrentUserHasAccess('GenerateGoldtierSAForm');
    }

    @AuraEnabled
    public static List<String> bussinessClassificationValues(String entityTypeValue){
        List<String> picklistValues = new List<String>();
        List<PicklistEntry> bussinessEntries = new List<PicklistEntry>();
        Set<PicklistEntry> pes = picklistentry2DependEntries.keySet();
        for(PicklistEntry pe: pes){
            if(pe.value==entityTypeValue){
                 bussinessEntries = picklistentry2DependEntries.get(pe);
            }
        }
        for(PicklistEntry pee : bussinessEntries){
            picklistValues.add(pee.value);
        }
        return picklistValues;
    }

    @AuraEnabled
    public static List<String> getEntityTypeValues(){
        List<String> entityTypes = new List<String>();
       for (PicklistEntry pe: Account.fields.Client_Type_OnBoard__c.getDescribe().getPicklistValues()){
            entityTypes.add(pe.value);
       }
        return entityTypes;
    }

    @AuraEnabled
    public static List<DTO_SelectOption> getSourceOfWealthValues() {
        return DTO_SelectOption.fetchOptions(Account.Source_of_Wealth__c);
    }

    @AuraEnabled
    public static Contact getKycContact(String Id){
        return [SELECT Name, Phone, Title FROM Contact WHERE Id = :Id];
    }


}