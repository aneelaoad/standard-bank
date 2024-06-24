/**
 *
 * @author vipeen Sarode
 * @date 08 OCT 2021
 * @description Insight API Metadata Selector Layer class.
 */
public with sharing class SEL_AkiliInsightApiMetadatas extends fflib_SObjectSelector {
    /**
     * getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AKILI_Insights_API__mdt.Id,
            AKILI_Insights_API__mdt.MasterLabel, 
            AKILI_Insights_API__mdt.DeveloperName, 
            AKILI_Insights_API__mdt.Certificate_Key__c, 
            AKILI_Insights_API__mdt.Client_ID__c, 
            AKILI_Insights_API__mdt.Client_Secret__c, 
            AKILI_Insights_API__mdt.Endpoint__c, 
            AKILI_Insights_API__mdt.Grant_Type__c, 
            AKILI_Insights_API__mdt.Scope__c, 
            AKILI_Insights_API__mdt.x_fapi_interaction_id__c, 
            AKILI_Insights_API__mdt.x_apigw_api_id__c, 
            AKILI_Insights_API__mdt.x_api_type__c
        };
    }

     /**
     * getSObjectType
     * @return Schema.SObjectType
     */
    public Schema.SobjectType getSObjectType(){
        return AKILI_Insights_API__mdt.SobjectType;
    }


    /**
     * selectInsightApiByDeveloperName
     * @param devName set of ids
     * @return AKILI_Insights_API__mdt
     */
    public AKILI_Insights_API__mdt selectInsightApiByDeveloperName(String devName) {
       return (AKILI_Insights_API__mdt)Database.query(newQueryFactory().setCondition('DeveloperName =: devName').setLimit(1).toSOQL());      
    }
}