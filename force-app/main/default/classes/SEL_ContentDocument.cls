/**
 * @description       : US: SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_ContentDocument extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            ContentDocument.Id,
            ContentDocument.Title,
            ContentDocument.LatestPublishedVersionId
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return ContentDocument.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_ContentDocument 
    **/
    public static SEL_ContentDocument newInstance() {
        return(SEL_ContentDocument) ORG_Application.selector.newInstance(ContentDocument.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param ids 
    * @return List<ContentDocument> 
    **/
    public List<ContentDocument> selectById(Set<Id> ids) {
        return (List<ContentDocument>) Database.query(
                        newQueryFactory()
                        .setCondition('Id IN: ids')
                        .toSOQL());
    }
}