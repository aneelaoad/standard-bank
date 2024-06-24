/*****************************************************************************************
 *@Name of the Class: SEL_Attachment
 *@Description      : SFP-30097 Added Methods on SEL_Attachment 
 *@Author           : Likhitha Karusala
 *@Created Date     : Feb 2024
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
public inherited  sharing class SEL_Attachment extends fflib_SObjectSelector {

      /**
    * @description getSObjectFieldList
    * @author Pradeep Kota | 06-13-2023 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Attachment.Id,
            Attachment.Name,
            Attachment.Body,
            Attachment.OwnerId,
            Attachment.ContentType,
            Attachment.ParentId
        };
    }

    /**
    * @description getSObjectType
    * @author Pradeep Kota | 12-05-2023 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Attachment.sObjectType;
    }

    /**
    * @description selectByAttachmentRecordId
    * @author Pradeep Kota | 28-03-2024
    * @param attachmentId
    * @param limitCount
    * @return Attachment
    **/
    public Attachment selectByAttachmentRecordId(Id attachmentId,Integer limitCount) {
        return (Attachment) Database.query(
                        newQueryFactory()
                        .setCondition('Id =: attachmentId')
                        .setLimit(limitCount)
                        .toSOQL());
    }
}