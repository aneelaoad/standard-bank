/**
 * Selector layer class for CurrencyType
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		March 2021
*/
public with sharing class SEL_CurrencyTypes extends fflib_SObjectSelector {

    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public Schema.SObjectType getSObjectType(){
        return CurrencyType.SObjectType;
    }

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
    */
    public static SEL_CurrencyTypes newInstance() {
        return (SEL_CurrencyTypes) ORG_Application.selector.newInstance(CurrencyType.SObjectType);
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                CurrencyType.Id,
                CurrencyType.IsoCode,
                CurrencyType.IsActive,
                CurrencyType.ConversionRate
        };
    }

    /**
     * This is used to retrieve CurrencyType records filtered by IsoCode
     *
     * @param isoSet set of IsoCode values
     * @return List of CurrencyType
    */
    public List<CurrencyType> selectByIsoCodes(Set<String> isoSet) {
        return (List<CurrencyType>) Database.query(
                newQueryFactory()
                .setCondition('IsoCode IN :isoSet AND IsActive = TRUE')
                .toSOQL());
    }
}