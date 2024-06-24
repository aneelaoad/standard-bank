/**
 * Consent Configuration Selector Layer class.
 *
 * @author Emmanuel Mulea Nocks
 * @date Feb 2021
 */
public with sharing class SEL_ConsentConfiguration extends fflib_SObjectSelector {
    /**
    * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
    * and inject a mock instead of this class or to switch out this class for a new version.
    * @return SEL_ConsentConfiguration
    */
    public static SEL_ConsentConfiguration newInstance() {
        return(SEL_ConsentConfiguration) ORG_Application.selector.newInstance(Consent_Configuration__c.SObjectType);
    }
    /**
    * @description get SObject Field List
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                Consent_Configuration__c.Type__c,
                Consent_Configuration__c.Value__c,
                Consent_Configuration__c.Description__c,
                Consent_Configuration__c.ToolTip__c,
                Consent_Configuration__c.Order__c,
                Consent_Configuration__c.Label__c,
                Consent_Configuration__c.Heading__c,
                Consent_Configuration__c.Confirmation_Type__c,
                Consent_Configuration__c.DependsOn__c
        };
    }
    /**
    * @description Gets SObject Type
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return Consent_Configuration__c.sObjectType;
    }
    /**
    * @description Get records by ConfirmationType
    * @param  confirmType Set of String
    * @return List<Consent_Configuration__c>
    */
    public List<Consent_Configuration__c> selectByConfirmationType(Set<String> confirmType) {
        return Database.query(
                newQueryFactory()
                        .setCondition('Confirmation_Type__c IN :confirmType')
                        .toSOQL()
        );
    }
}