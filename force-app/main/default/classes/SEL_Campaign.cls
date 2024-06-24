/**
 * @description       : US: SFP-11298 Add to calendar from email functionality
 * @author            : TCK
 * @group             : 
 * @last modified on  : 09-01-2022
 * @last modified by  : TCK
**/
public inherited sharing class SEL_Campaign extends fflib_SObjectSelector {
    /**
    * @description getSObjectFieldList
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Campaign.Id,
            Campaign.Name,
            Campaign.Campaign_Category__c,
            Campaign.Email_Header_Image_URL__c,
            Campaign.EAP_Event_End_Date__c,
            Campaign.EAP_Event_End_Date_Local_Time__c,
            Campaign.EAP_Event_End_Time__c,
            Campaign.EAP_Event_GMT_Timezone__c,
            Campaign.EAP_Event_Start_Date__c,
            Campaign.EAP_Event_Start_Date_Local_Time__c,
            Campaign.EAP_Event_Start_Time__c,
            Campaign.Type
        };
    }

    /**
    * @description getSObjectType
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Campaign.sObjectType;
    }

    /**
    * @description newInstance
    * @author TCK | 06-13-2022 
    * @return SEL_Campaign 
    **/
    public static SEL_Campaign newInstance() {
        return (SEL_Campaign) ORG_Application.selector.newInstance(Campaign.SObjectType);
    }

    /**
    * @description selectByIdAndCampaignCategory
    * @author TCK | 06-13-2022 
    *
    * @param campaignIdList 
    * @param category 
    * @return List<Campaign> 
    **/
    public List<Campaign> selectByIdAndCampaignCategory(List<Id> campaignIdList, String category) {
        return (List<Campaign>) Database.query(
                        newQueryFactory()
                        .setCondition('Id IN: campaignIdList AND Campaign_Category__c =: category')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-15-2022 
    * @param campaignIdList 
    * @param categories 
    * @return List<Campaign> 
    **/
    public List<Campaign> selectByIdAndCampaignCategory(List<Id> campaignIdList, List<String> categories) {
        return (List<Campaign>) Database.query(
                        newQueryFactory()
                        .setCondition('Id IN: campaignIdList AND Campaign_Category__c IN: categories')
                        .toSOQL());
    }

    /**
    * @description selectById
    * @author TCK | 06-13-2022 
    * @param id
    * @return List<Campaign> 
    **/
    public List<Campaign> selectById(Id id) {
        return (List<Campaign>) Database.query(
                        newQueryFactory()
                        .setCondition('Id =: id')
                        .toSOQL());
    }

    /**
    * @description selectByIds
    * @author Dzianiosik Maksim
    * @param ids Set<Id>
    * @return List<Campaign>
    **/
    public List<Campaign> selectByIds(Set<Id> ids) {
        return (List<Campaign>) Database.query(
                newQueryFactory()
                        .setCondition('Id IN: ids')
                        .toSOQL());
    }

}