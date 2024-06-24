/*****************************************************************************************
 *@Name of the Class: SEL_ContentVersion
 *@Description      : Selector class for ContentVersion SObject 
 *@Author           : Likhitha Karusala
 *@Created Date     : 06-14-2022
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097 Added Methods on ContentVersion
 ******************************************************************************************/
public without sharing class SEL_ContentVersion extends fflib_SObjectSelector {
    /**
    * @description getSObjectFieldList
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContentVersion.Id,
            ContentVersion.FileType,
            ContentVersion.ContentDocumentId,
            ContentVersion.ContentBodyId,
            ContentVersion.Title,
            ContentVersion.VersionData
        };
    }

    /**
    * @description getSObjectType
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return ContentVersion.sObjectType;
    }

    /**
    * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	* and inject a mock instead of this class or to switch out this class for a new version.
    * @author TCK | 06-13-2022 
    * @return SEL_ContentVersion 
    **/
    public static SEL_ContentVersion newInstance() {
        return(SEL_ContentVersion) ORG_Application.selector.newInstance(ContentVersion.SObjectType);
    }

    /**
    * @description selectByContentDocumentId
    * @author TCK | 06-13-2022 
    * @param contentDocumentIds 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectByContentDocumentId(Set<Id> contentDocumentIds) {
        return (List<ContentVersion>) Database.query(
                        newQueryFactory()
                        .selectField('ContentDocument.LatestPublishedVersionId')
                        .setCondition('ContentDocumentId IN: contentDocumentIds')
                        .toSOQL());
     }
    
     /**
    * @description selectByListContentDocumentId
    * @author TCK | 06-13-2022 
    * @param contentDocumentIds 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectByListContentDocumentId(List<Id> contentDocumentIds) {
        return (List<ContentVersion>) Database.query(
                        newQueryFactory()
                        .setCondition('ContentDocumentId IN: contentDocumentIds')
                        .toSOQL());
    }


    /**
    * @description selectByRecordId
    * @author TCK | 12-05-2023
    * @param cVersion 
    * @return ContentVersion
    **/
    public ContentVersion selectByRecordId(Id cVersion) {
        return (ContentVersion) Database.query(
                        newQueryFactory()
                        .setCondition('Id =: cVersion')
                        .toSOQL());
    }

    /**
    * @description
    * @author Ankit Kumar | 02-27-2024
    * @param ids
    * @return List<ContentVersion>
    **/
    public List<ContentVersion> selectById(Set<Id> ids) {
        return (List<ContentVersion>) Database.query(
                        newQueryFactory()
                        .setCondition('Id IN: ids')
                        .toSOQL());
       }
}