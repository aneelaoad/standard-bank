/**
*@Author         :   Naveen B
*@Create Date    :   07-02-2023
*@description    :   Onboarding Bulk Manged Fund
*@JIRA Tickets   :   SFP-21873
*/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public without sharing class OMF_OnboardBulkManagedFundController {
    @AuraEnabled
    /**
     * @description Create managed fund record (Single record) 
     * @param accountId The asset manager ID
     * @return The managed fund ID
     */
    public static String onboardBulkMangedFund(String accountId) {
        Id recordTypeId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByDeveloperName().get('Bulk_Onboarding').getRecordTypeId();
        OMF_ManagedFund__c objManagedFund = new OMF_ManagedFund__c(AssetManager__c =accountId, RecordTypeId =recordTypeId );
        insert objManagedFund;
        return objManagedFund.Id;
    }
}