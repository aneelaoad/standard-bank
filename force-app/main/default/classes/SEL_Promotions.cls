/**
 * @description       : SEL_Promotions
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : Ankit Kumar
**/
public without sharing class SEL_Promotions extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Promotion__c.Id,
            Promotion__c.Name,
            Promotion__c.Action__c,
            Promotion__c.Apply_Colour_Contrast_Inversion__c,
            Promotion__c.Button_Label__c,
            Promotion__c.Button_Title__c,
            Promotion__c.Custom_Background_Colour__c,
            Promotion__c.Custom_Banner_Styles__c,
            Promotion__c.Destination_Url__c,
            Promotion__c.Disabled__c,
            Promotion__c.IsCarousel__c,
            Promotion__c.IsOnline__c,
            Promotion__c.Show_Button__c,
            Promotion__c.SubText__c,
            Promotion__c.Variant__c,
            Promotion__c.WClass__c,
            Promotion__c.Link__c,
            Promotion__c.Publishing_Unit__c,
            Promotion__c.Provider__c,
            Promotion__c.Rank__c,
            Promotion__c.Image_Path__c,
            Promotion__c.Image_Path_Desktop__c,
            Promotion__c.Image_Path_Tablet__c,
            Promotion__c.Small_Title__c,
            Promotion__c.Large_Title__c,
            Promotion__c.Provider__c,
            Promotion__c.Rank__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Promotion__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_Promotions 
    **/
    public static SEL_Promotions newInstance() {
        return(SEL_Promotions) ORG_Application.selector.newInstance(Promotion__c.SObjectType);
    }

    /**
     * @description select promotions based on custom filter condition
     * @param condition String
     * @return List<Promotion__c> - with query results
     */
    public List<Promotion__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Provider__r.Name')
            .selectField('Link__r.Desktop_url__c')
            .selectField('Link__r.Mobile_url__c')
            .selectField('Link__r.Guest_url__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select promotions based ids
     * @param ids List<Id>
     * @return List<Promotion__c> - with query results
     */
    public List<Promotion__c> selectByIds(List<Id> ids) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Provider__r.Name')
            .selectField('Link__r.Desktop_url__c')
            .selectField('Link__r.Mobile_url__c')
            .selectField('Link__r.Guest_url__c')
            .setCondition('Id in : ids')
            .toSOQL());
    } 
}