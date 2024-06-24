/*************************************************************************
    @ Author        : Abhishek
    @ Date          : 7. 7. 2016
    @ Test File     : MeetingConsole_AttachmentController_Test
    @ Description   : US-1389
    
	@ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 17, 2016
    @ Modification Description : US-1247/DEF-2050

    @ Last Modified By  : Emmanuel Nocks Mulea
    @ Last Modified On  : 01.16.2020
    @ Modification Description : US-4260 / ability to upload files and get a list of them
****************************************************************************/
public without sharing class MeetingConsole_AttachmentController{
    
    private transient Attachment attch = new Attachment();
    
    public Boolean popupDisplayed { get; set; }
    
    public Boolean haseditnbac{ get; set; }
    
    public Id nbacIDval{
        get; 
        
        set {
            nbacIDval = value;
        } 
    }
        
    
    public MeetingConsole_AttachmentController() {
        popupDisplayed = false;
        
    }
    
    
    public PageReference displayattfilepop() {
        
        popupDisplayed = true;
        return null;
    }
    
    public Attachment attachmentrec {
      get {
          if (attch == null) {
              attch = new Attachment();
          }
          return attch;
        }
      set;
    }
    
    public PageReference upload() {

        attachmentrec.OwnerId = UserInfo.getUserId();
        attachmentrec.ParentId = nbacIDval; // the record the file is attached to
        attachmentrec.IsPrivate = false;

        try {
          insert attachmentrec;
        } catch (DMLException e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
          return null;
        } finally {
          attachmentrec = new Attachment(); 
        }

        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Attachment uploaded successfully'));
        return null;
    }
    /***
Use
@param  	    :  string nbacId, string ContentDocumentId
@return   	    :  String
@ Description 	:  upload files related to NBAC record
***/
    @AuraEnabled
    public Static string uploadAura(string nbacId, string ContentDocumentId) {

        Attachment attachmentrec = new Attachment();
        try {
            ContentDocument conD = new ContentDocument(id=ContentDocumentId);
            Contentversion conVersion = [Select id, ContentDocumentId,Title,FileExtension,VersionData from Contentversion where ContentDocumentId=:ContentDocumentId];
            attachmentrec.OwnerId = UserInfo.getUserId();
            attachmentrec.ParentId = nbacId; // the record the file is attached to
            attachmentrec.IsPrivate = false;
            attachmentrec.body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(conVersion.VersionData));
            attachmentrec.name = conVersion.Title;

            if(conVersion.FileExtension=='jpeg' || conVersion.FileExtension=='jpg' || conVersion.FileExtension=='png'){
                attachmentrec.ContentType = 'image/'+conVersion.FileExtension;
            }
            else{
                attachmentrec.ContentType = 'application/'+conVersion.FileExtension;
            }

            insert attachmentrec;
            delete conD; // deleting it because i am using SF lightning:FileUpload which it upload the file into the ContentDocument and now i am bypassing it by making an attachment direct
            return '{"isError":false,"msg":"Successfully uploaded"}';
        }
        catch (Exception e) {
            return '{"isError":true,"msg":"'+ e.getMessage()+'"}';
        }
    }
    public PageReference hidepopupWindow() {
        
        popupDisplayed = false; 
        return null;
      
    }
    
    public List<Attachment> atts{
        get {
            atts = new List<Attachment>();
            if (nbacIDval != null) {
                atts = [SELECT id, name, parentId, owner.name, ownerId, createdBy.name, lastModifiedBy.name, lastModifiedDate FROM Attachment WHERE parentId = :nbacIDval ORDER BY lastModifiedDate DESC];
            }
            return atts;
        }
        
        private set;
    }
    /***
Use
@param  	    :  string nbacId
@return   	    :  List of Attachment
@ Description 	:  get List Of Attachments
***/
    @AuraEnabled
    public static Map<string,List<Object>> getListOfAttachments(string nbacId){
        List<SObject> attachList = new List<SObject>();
        Map<string,List<Object>> mapFiles= new Map<string,List<Object>>();
        list<Id> cdIds = new list<Id>();
        for(ContentDocumentLink cd : [SELECT ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId =:nbacId]){
            cdIds.add(cd.ContentDocumentId);
        }
        List<SObject> conVersion = [Select id, owner.name,OwnerId,Title,lastModifiedBy.name, createdBy.name,lastModifiedDate from Contentversion where ContentDocumentId IN:cdIds ORDER BY lastModifiedDate DESC];
        attachList = [SELECT id, name, parentId, owner.name, ownerId, createdBy.name, lastModifiedBy.name, lastModifiedDate FROM Attachment WHERE parentId = :nbacId ORDER BY lastModifiedDate DESC];
        mapFiles.put('conVersion',conVersion);
        mapFiles.put('attachList',attachList);
        return mapFiles;
    }
}