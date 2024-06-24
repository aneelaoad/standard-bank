/**
 * @description       : Seelctor class for the OTP Request sObject.
 * @author            : Peter Guest
 * @last modified on  : 03-08-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
 **/
public inherited sharing class SEL_OTPRequest extends fflib_SObjectSelector {
    /**
     * @description Identifies the sObject for selector.
     * @author Peter Guest | 03-03-2023
     * @return Schema.SObjectType
     **/
    public Schema.SObjectType getSObjectType() {
        return OTPRequest__c.sObjectType;
    }

    /**
     * @description Default query fields.
     * @author Peter Guest | 03-03-2023
     * @return List<Schema.SObjectField>
     **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OTPRequest__c.Attempts__c,
            OTPRequest__c.Code__c,
            OTPRequest__c.CodeExpiresAt__c,
            OTPRequest__c.CustomField1__c,
            OTPRequest__c.CustomField2__c,
            OTPRequest__c.CustomField3__c,
            OTPRequest__c.Id,
            OTPRequest__c.Locked__c,
            OTPRequest__c.LockExpiresAt__c,
            OTPRequest__c.Name,
            OTPRequest__c.RecipientEmailAddress__c,
            OTPRequest__c.RelatedRecordID__c,
            OTPRequest__c.Requests__c,
            OTPRequest__c.Send__c
        };
    }

    /**
     * @description Singleton approach.
     * @author Peter Guest | 03-03-2023
     * @return SEL_OTPRequest
     **/
    public static SEL_OTPRequest newInstance() {
        return (SEL_OTPRequest) ORG_Application.selector.newInstance(OTPRequest__c.SObjectType);
    }

    /**
     * @description Retrieves the timestamp of the last locked record.
     * @author Peter Guest | 11-02-2023
     * @param String relatedRecordId
     * @return List<AggregateResult>
     **/
    public List<OTPRequest__c> selectByRelatedRecordId(String relatedRecordId) {
        return (List<OTPRequest__c>) Database.query(newQueryFactory().setCondition('RelatedRecordID__c = :relatedRecordId').setLimit(1).toSOQL());
    }
}