/**
 * @description       : Selector class for ContentDistribution SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_ContentDistribution extends fflib_SObjectSelector {
    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContentDistribution.Id,
            ContentDistribution.ContentDownloadUrl,
            ContentDistribution.ContentVersionId,
            ContentDistribution.DistributionPublicUrl
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return ContentDistribution.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_ContentDistribution 
    **/
    public static SEL_ContentDistribution newInstance() {
        return(SEL_ContentDistribution) ORG_Application.selector.newInstance(ContentDistribution.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param contentVersionList 
    * @return List<ContentDistribution> 
    **/
    public List<ContentDistribution> selectByContentVersionId(Set<Id> contentVersionList) {
        return (List<ContentDistribution>) Database.query(
                        newQueryFactory()
                        .setCondition('ContentVersionId IN: contentVersionList')
                        .toSOQL());
    }
    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024
    * @param ids Set<Id>
    * @return List<ContentDistribution> 
    **/
    public List<ContentDistribution> selectById(Set<Id> ids) {
        return (List<ContentDistribution>) Database.query(
                        newQueryFactory()
                        .setCondition('Id IN: ids')
                        .toSOQL());
    }
}