/*****************************************************************************************
 *@Name of the Class: SEL_ContentDocumentLink
 *@Description      : SFP-30097 Added Methods on ContentDocumentLink
 *@Author           : Likhitha Karusala
 *@Created Date     : Feb 2024
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ApexDoc,PMD.LocalVariableNamingConventions')
public without sharing class SEL_ContentDocumentLink extends fflib_SObjectSelector {
    
    /**
* @description 
* @author TCK | 06-13-2022 
* @return List<Schema.SObjectField> 
**/
    public List<Schema.SObjectField> getSObjectFieldList() {
        
        return new List<Schema.SObjectField> {
            ContentDocumentLink.Id,
                ContentDocumentLink.LinkedEntityId,
                ContentDocumentLink.ContentDocumentId,
                ContentDocumentLink.Visibility
                };
                    }
    
    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return ContentDocumentLink.sObjectType;
    }
    
    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_ContentDocumentLink 
    **/
    public static SEL_ContentDocumentLink newInstance() {
        return(SEL_ContentDocumentLink) ORG_Application.selector.newInstance(ContentDocumentLink.SObjectType);
    }
    
    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param linkedEntityId 
    * @return List<ContentDocumentLink> 
    **/
    public List<ContentDocumentLink> selectByLinkedEntityId(Set<Id> linkedEntityId) {
        return (List<ContentDocumentLink>) Database.query(
            newQueryFactory()
            .selectField('ContentDocument.LatestPublishedVersionId')
            .selectField('ContentDocument.FileExtension')
            .setCondition('LinkedEntityId IN: linkedEntityId')
            .toSOQL());
    }
    
    /**
    * @description 
    * @author Khushmeet Kaur | 04-08-2023 
    * @param linkedEntityId 
    * @return List<ContentDocumentLink> 
    **/
    public List<ContentDocumentLink> selectByLinkedEntityIdAllFields(Set<Id> linkedEntityId) {
        return (List<ContentDocumentLink>) Database.query(
            newQueryFactory()
            .selectField('ContentDocument.Title')
            .selectField('ContentDocument.FileExtension')
            .setCondition('LinkedEntityId IN: linkedEntityId')
            .toSOQL());
    }
    
     /**
    * @description 
    * @author Khushmeet Kaur | 04-08-2023 
    * @param contentDocumentId 
    * @return List<ContentDocumentLink> 
    **/
    public List<ContentDocumentLink> selectByContentDocumentId(Set<Id> contentDocumentId) {
        return (List<ContentDocumentLink>) Database.query(
            newQueryFactory()
            .setCondition('ContentDocumentId IN: contentDocumentId')
            .toSOQL());
    }
    
    /**
    * @description 
    * @author Khushmeet Kaur | 04-08-2023 
    * @param ContentDocumentId 
    * @return List<ContentDocumentLink> 
    **/
    public List<ContentDocumentLink> selectRecordByContentDocumentId(String contentDocumentId) {
        return (List<ContentDocumentLink>) Database.query(
            newQueryFactory()
            .setCondition('ContentDocumentId =: contentDocumentId')
            .toSOQL());
    }
    
    /**
    * @description 
    * @author Khushmeet Kaur | 04-08-2023 
    * @param linkedEntityId 
    * @return List<ContentDocumentLink> 
    **/
    public List<ContentDocumentLink> selectByStringLinkEntityId(String linkedEntityId) {
        return (List<ContentDocumentLink>) Database.query(
            newQueryFactory()
            .setCondition('LinkedEntityId =: linkedEntityId')
            .toSOQL());
    }
    
    /**
    * @description 
    * @author Khushmeet Kaur | 04-08-2023 
    * @param recordIds 
    * @return List<ContentDocumentLink> 
    **/
    public List<ContentDocumentLink>selectByListLinkEntityId(List<Id>recordIds){
        return (List<ContentDocumentLink>) Database.query(
            newQueryFactory()
            .selectField('ContentDocumentId')
            .selectField('ContentDocument.Title')
            .selectField('LinkedEntityId')
            .selectField('ContentDocument.FileExtension')
            .setCondition('LinkedEntityId =: recordIds')
            .toSOQL());
    }
}