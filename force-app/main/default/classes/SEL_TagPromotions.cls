/**
 * @description       : SEL_TagPromotions
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_TagPromotions extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Tag_Promotion__c.Id,
            Tag_Promotion__c.Name,
            Tag_Promotion__c.Promotion__c,
            Tag_Promotion__c.Tag__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Tag_Promotion__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_TagPromotions 
    **/
    public static SEL_TagPromotions newInstance() {
        return(SEL_TagPromotions) ORG_Application.selector.newInstance(Tag_Promotion__c.SObjectType);
    }

    /**
     * @description select Tag promotions based on custom filter condition
     * @param condition String
     * @return List<Tag_Promotion__c> - with query results
     */
    public List<Tag_Promotion__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Promotion__r.isOnline__c')
            .selectField('Promotion__r.Provider__c')
            .selectField('Promotion__r.Provider__r.Name')
            .selectField('Promotion__r.Link__c')
            .selectField('Promotion__r.Action__c')
            .selectField('Promotion__r.Apply_Colour_Contrast_Inversion__c')
            .selectField('Promotion__r.Button_Label__c')
            .selectField('Promotion__r.Button_Title__c')
            .selectField('Promotion__r.Custom_Background_Colour__c')
            .selectField('Promotion__r.Custom_Banner_Styles__c')
            .selectField('Promotion__r.Destination_Url__c')
            .selectField('Promotion__r.Disabled__c')
            .selectField('Promotion__r.IsCarousel__c')
            .selectField('Promotion__r.Rank__c')
            .selectField('Promotion__r.Show_Button__c')
            .selectField('Promotion__r.SubText__c')
            .selectField('Promotion__r.Variant__c')
            .selectField('Promotion__r.WClass__c')
            .selectField('Promotion__r.Image_Path__c')
            .selectField('Promotion__r.Image_Path_Desktop__c')
            .selectField('Promotion__r.Image_Path_Tablet__c')
            .selectField('Promotion__r.Small_Title__c')
            .selectField('Promotion__r.Large_Title__c')
            .selectField('Promotion__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Promotion__r.Publishing_Unit__c')
            .selectField('Promotion__r.Link__r.DeskTop_Url__c')
            .selectField('Promotion__r.Link__r.Mobile_Url__c')
            .selectField('Promotion__r.Link__r.Guest_url__c')
            .selectField('Promotion__r.Link__r.IsOnline__c')
            .selectField('Promotion__r.Publishing_Unit__r.isPublished__c')
            .selectField('Promotion__r.Publishing_Unit__r.Published_From__c')
            .selectField('Promotion__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Promotion__r.Promotion_Type__c')
            .selectField('Promotion__r.Is_Default_Category_Banner__c')
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select tag promotions by tag names
     * @param tagNames Set<String> - Set of string to filter through
     * @return List<Tag_Promotion__c> - with query results
     */
    public List<Tag_Promotion__c> selectByTagNames(Set<String> tagNames) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Promotion__r.isOnline__c')
            .selectField('Promotion__r.Provider__c')
            .selectField('Promotion__r.Provider__r.Name')
            .selectField('Promotion__r.Link__c')
            .selectField('Promotion__r.Action__c')
            .selectField('Promotion__r.Apply_Colour_Contrast_Inversion__c')
            .selectField('Promotion__r.Button_Label__c')
            .selectField('Promotion__r.Button_Title__c')
            .selectField('Promotion__r.Custom_Background_Colour__c')
            .selectField('Promotion__r.Custom_Banner_Styles__c')
            .selectField('Promotion__r.Destination_Url__c')
            .selectField('Promotion__r.Disabled__c')
            .selectField('Promotion__r.IsCarousel__c')
            .selectField('Promotion__r.Rank__c')
            .selectField('Promotion__r.Show_Button__c')
            .selectField('Promotion__r.SubText__c')
            .selectField('Promotion__r.Variant__c')
            .selectField('Promotion__r.WClass__c')
            .selectField('Promotion__r.Image_Path__c')
            .selectField('Promotion__r.Image_Path_Desktop__c')
            .selectField('Promotion__r.Image_Path_Tablet__c')
            .selectField('Promotion__r.Small_Title__c')
            .selectField('Promotion__r.Large_Title__c')
            .selectField('Promotion__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Promotion__r.Publishing_Unit__c')
            .selectField('Promotion__r.Link__r.DeskTop_Url__c')
            .selectField('Promotion__r.Link__r.Mobile_Url__c')
            .selectField('Promotion__r.Link__r.Guest_url__c')
            .selectField('Promotion__r.Link__r.IsOnline__c')
            .selectField('Promotion__r.Publishing_Unit__r.isPublished__c')
            .selectField('Promotion__r.Publishing_Unit__r.Published_From__c')
            .selectField('Promotion__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Promotion__r.Promotion_Type__c')
            .selectField('Promotion__r.Is_Default_Category_Banner__c')           
            .setCondition(' Tag__r.Name IN : tagNames AND Promotion__r.isOnline__c = TRUE')
            .toSOQL());
    }

    
    /**
     * @description select tag promotions by tag Ids
     * @param tagIds Set<Id> - Set of Ids to filter through
     * @return List<Tag_Promotion__c> - with query results
     */
    public List<Tag_Promotion__c> selectByTagIds(Set<Id> tagIds) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Promotion__r.isOnline__c')
            .selectField('Promotion__r.Provider__c')
            .selectField('Promotion__r.Provider__r.Name')
            .selectField('Promotion__r.Link__c')
            .selectField('Promotion__r.Action__c')
            .selectField('Promotion__r.Apply_Colour_Contrast_Inversion__c')
            .selectField('Promotion__r.Button_Label__c')
            .selectField('Promotion__r.Button_Title__c')
            .selectField('Promotion__r.Custom_Background_Colour__c')
            .selectField('Promotion__r.Custom_Banner_Styles__c')
            .selectField('Promotion__r.Destination_Url__c')
            .selectField('Promotion__r.Disabled__c')
            .selectField('Promotion__r.IsCarousel__c')
            .selectField('Promotion__r.Rank__c')
            .selectField('Promotion__r.Show_Button__c')
            .selectField('Promotion__r.SubText__c')
            .selectField('Promotion__r.Variant__c')
            .selectField('Promotion__r.WClass__c')
            .selectField('Promotion__r.Image_Path__c')
            .selectField('Promotion__r.Image_Path_Desktop__c')
            .selectField('Promotion__r.Image_Path_Tablet__c')
            .selectField('Promotion__r.Small_Title__c')
            .selectField('Promotion__r.Large_Title__c')
            .selectField('Promotion__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Promotion__r.Publishing_Unit__c')
            .selectField('Promotion__r.Link__r.DeskTop_Url__c')
            .selectField('Promotion__r.Link__r.Mobile_Url__c')
            .selectField('Promotion__r.Link__r.Guest_url__c')
            .selectField('Promotion__r.Link__r.IsOnline__c')
            .selectField('Promotion__r.Publishing_Unit__r.isPublished__c')
            .selectField('Promotion__r.Publishing_Unit__r.Published_From__c')
            .selectField('Promotion__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Promotion__r.Promotion_Type__c')
            .selectField('Promotion__r.Is_Default_Category_Banner__c')           
            .setCondition(' Tag__c IN : tagIds AND Promotion__r.isOnline__c = TRUE')
            .toSOQL());
    }
}