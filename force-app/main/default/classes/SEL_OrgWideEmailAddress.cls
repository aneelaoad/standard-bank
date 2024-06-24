/*****************************************************************************************
 *@Name of the Class: SEL_OrgWideEmailAddress
 *@Description      : SFP-30097 Added Methods on SEL_OrgWideEmailAddress
 *@Author           : Likhitha Karusala
 *@Created Date     : Feb 2024
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
public without sharing class SEL_OrgWideEmailAddress extends fflib_SObjectSelector {

    /**
    * @description getSObjectFieldList
    * @author TCK | 06-14-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            OrgWideEmailAddress.Id,
            OrgWideEmailAddress.Address,
            OrgWideEmailAddress.DisplayName
        };
    }

    /**
    * @description getSObjectType
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return OrgWideEmailAddress.sObjectType;
    }

    /**
    * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	* and inject a mock instead of this class or to switch out this class for a new version.
    * @author TCK | 06-14-2022 
    * @return SEL_OrgWideEmailAddress 
    **/
    public static SEL_OrgWideEmailAddress newInstance() {
        return(SEL_OrgWideEmailAddress) ORG_Application.selector.newInstance(OrgWideEmailAddress.SObjectType);
    }

    /**
    * @description selectByAddress
    * @author TCK | 06-14-2022 
    * @param address 
    * @return List<OrgWideEmailAddress> 
    **/
    public List<OrgWideEmailAddress> selectByAddress(String address) {
        return (List<OrgWideEmailAddress>) Database.query(
                        newQueryFactory()
                        .setCondition('Address =: address')
                        .toSOQL());
    }

    /**
    * @description selectByDisplayName
    * @author Likhitha Karusala | 12-06-2023
    * @param displayName 
    * @return OrgWideEmailAddress
    **/
    public OrgWideEmailAddress selectByDisplayName(String displayName) {
        return (OrgWideEmailAddress) Database.query(
                        newQueryFactory()
                        .setCondition('DisplayName =: displayName')
                        .toSOQL());
    }
}