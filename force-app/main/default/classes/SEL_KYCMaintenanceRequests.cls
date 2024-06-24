/**
 * Selector layer class for KYC_Maintenance_Request__c SObject
 *
 * @author Caro Reinecke
 * @date 2018-01-08
 */
public class SEL_KYCMaintenanceRequests extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                KYC_Maintenance_Request__c.Id,
                KYC_Maintenance_Request__c.Account_Application__c,
                KYC_Maintenance_Request__c.Status__c,
                KYC_Maintenance_Request__c.Annual_Turnover__c,
                KYC_Maintenance_Request__c.Entity_Registration_Number__c,
                KYC_Maintenance_Request__c.Registered_Address_Line_1__c,
                KYC_Maintenance_Request__c.Registered_Address_Line_2__c,
                KYC_Maintenance_Request__c.Registered_City__c,
                KYC_Maintenance_Request__c.Registered_Name__c,
                KYC_Maintenance_Request__c.Registered_Postal_Code__c,
                KYC_Maintenance_Request__c.Registered_Province__c,
                KYC_Maintenance_Request__c.Telephone_Number__c,
                KYC_Maintenance_Request__c.TradingAs__c,
                KYC_Maintenance_Request__c.Type_of_Entity__c
            };
    }

    public Schema.SObjectType getSObjectType() {
        return KYC_Maintenance_Request__c.sObjectType;
    }

    public List<KYC_Maintenance_Request__c> selectById(Set<ID> idSet) {
        return (List<KYC_Maintenance_Request__c>) selectSObjectsById(idSet);
    }

    public List<KYC_Maintenance_Request__c> selectByAccountApplicationId(Set<Id> iDSet) {
        return (List<KYC_Maintenance_Request__c>) Database.query(
                newQueryFactory().
                        setCondition('Account_Application__c in :IdSet').
                        toSOQL());
    }
}