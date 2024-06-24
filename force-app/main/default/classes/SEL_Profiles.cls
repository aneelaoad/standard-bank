/**
 * Selector layer class for Profile SObject
 *
 * @author Michal Pesko (mpesko@deloittece.com)
 * @date October 2021
 */
public with sharing class SEL_Profiles extends fflib_SObjectSelector{

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
     */
    public static SEL_Profiles newInstance() {
        return (SEL_Profiles) ORG_Application.selector.newInstance(Profile.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
     */
    public SObjectType getSObjectType() {
        return Profile.SObjectType;
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Profile.Id,
                Profile.Name
        };
    }

    /**
     * Selecting Revenues by Global Client Id and year ordered by Reporting Month descending
     * @param profileIds set of Profile Ids
     * @param names List of Profile Names
     * @return List of Profiles
    */
    public List<Profile> selectByIdAndNames(Set<Id> profileIds, List<String> names){
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
                .setCondition('Id IN :profileIds AND Name IN :names');
        return Database.query(factory.toSOQL());
    }
    /**
     * Selecting profiles by list of names
     * @param names List of Profile Names
     * @return List of Profiles
    */
    public List<Profile> selectByNames( List<String> names){
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
                .setCondition('Name IN :names');
        return Database.query(factory.toSOQL());
    }
}