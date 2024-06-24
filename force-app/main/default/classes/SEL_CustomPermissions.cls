/**
 * @description Selector class for Custom Permission object
 *
 * @author Konrad Bruszewski
 * @date March 2022
 */
public with sharing class SEL_CustomPermissions extends fflib_SObjectSelector {
    public static final String CIB_EDIT_CST_VISIBLE_TO_CLIENT = 'CIB_Edit_CST_Visible_To_Client';

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     * @return SEL_CustomPermissions
     */
    public static SEL_CustomPermissions newInstance() {
        return (SEL_CustomPermissions) ORG_Application.selector.newInstance(CustomPermission.SObjectType);
    }

    /**
     * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     * @return SObjectType
     */
    public SObjectType getSObjectType() {
        return CustomPermission.SObjectType;
    }

    /**
     * @description Returns the list of SObject type for the selector.
     * @return List<SObjectField>
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                CustomPermission.Id,
                CustomPermission.DeveloperName
        };
    }

    /**
     * Select custom permission by the Developer Name. Returns null if permission is not found.
     *
     * @param devName
     *
     * @return CustomPermission
     */
    public CustomPermission selectByDeveloperName(String devName){
        List<CustomPermission> customPermissions = (List<CustomPermission>) Database.query(newQueryFactory(false, false, true)
                .setCondition('DeveloperName = :devName')
                .toSOQL()
        );
        return !customPermissions.isEmpty() ? customPermissions.get(0) : null;
    }
}