/**
 * Selector class for CustomNotificationType
 *
 * @author Emmanuel Mulea Nocks (BlueSky)
 * @date July 2021
 */
public with sharing class SEL_CustomNotificationTypes extends fflib_SObjectSelector {

    /**
    * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
    * and inject a mock instead of this class or to switch out this class for a new version.
    *@return SEL_CustomNotificationTypes
    */
    public static SEL_CustomNotificationTypes newInstance() {
        return (SEL_CustomNotificationTypes) ORG_Application.selector.newInstance(CustomNotificationType.SObjectType);
    }
    /**
     *@description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *@return SObjectType
     */
    public SObjectType getSObjectType() {
        return CustomNotificationType.SObjectType;
    }
    /**
     *@description Returns the list of SObject type for the selector.
     *@return List<SObjectField>
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                CustomNotificationType.Id,
                CustomNotificationType.DeveloperName
        };
    }
    /**
    * Select CustomNotificationType by Developer Names
    * @param developerNames - - set of searched DeveloperNames
    * @return list of documents
    */
    public List<CustomNotificationType> selectByDeveloperName(Set<String> developerNames) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('DeveloperName IN :developerNames')
                        .toSOQL()
        );
    }

}