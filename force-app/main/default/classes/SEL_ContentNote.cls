/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_ContentNote extends fflib_SObjectSelector {
    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContentNote.Id,
            ContentNote.Title,
            ContentNote.LastModifiedDate,
            ContentNote.Content
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return ContentNote.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_ContentNote 
    **/
    public static SEL_ContentNote newInstance() {
        return(SEL_ContentNote) ORG_Application.selector.newInstance(ContentNote.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param noteId 
    * @return ContentNote 
    **/
    public ContentNote selectById(Id noteId) {
        return (ContentNote) Database.query(
                        newQueryFactory()
                        .setCondition('Id =: noteId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param notesId 
    * @param creatorId 
    * @return List<ContentNote> 
    **/
    public List<ContentNote> selectByIdAndCreator(Set<Id> notesId, String creatorId) {
        return (List<ContentNote>) Database.query(
                        newQueryFactory()
                        .setCondition('CreatedById =: creatorId AND Id IN: notesId')
                        .toSOQL());
    }
}