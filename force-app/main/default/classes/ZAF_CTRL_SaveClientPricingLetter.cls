/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_SaveClientPricingLetter
* @description           : Class for saving the Client Pricing Letter PDF to the related pricing arrangement record.
* @Author                :Likhitha Karusala 
* @Created Date          : 07 Mar 2024
/***************************************************************************************
*@Last Modified By  : Likhitha Karusala 
*@Last Modified On  : 07 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/
public class ZAF_CTRL_SaveClientPricingLetter {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ZAF_CTRL_SaveClientPricingLetter');    
      /**
    * @description passing recordid to vf page
    */
    public Id recordId {get;set;}  
    /**
    * @description constructor to render the vf page
    * @param controller
    */
   
    public ZAF_CTRL_SaveClientPricingLetter(ApexPages.StandardController controller) {
        recordId  = ApexPages.currentPage().getParameters().get('id');
    }
    /**
    * @description getting the VFpage data and attaching to the record
    * @return PageReference
    */
    public PageReference downPdf(){
        try{
           Id pricingId= recordId;
           PageReference pdf = Page.ZAF_GeneratePricingLetterVFPage;
            pdf.getParameters().put('Id',pricingId);
            Blob pdfBlob ;
            if(Test.isRunningTest()) { 
               pdfBlob = blob.valueOf('Unit.Test');
            } else {
               pdfBlob = pdf.getContent();
            }
            List<ContentDocumentLink> getContentDocumentList = new SEL_ContentDocumentLink().selectByStringLinkEntityId(pricingId);
            Integer version = getContentDocumentList.size()+1;        
            Attachment att = new Attachment(parentId = pricingId, name='Client Pricing Letter-V'+ version + '.pdf', Body = pdfBlob);

            insert att;
            Attachment attach = new SEL_Attachment().selectByAttachmentRecordId(att.id,1);
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; 
            cVersion.PathOnClient = attach.Name;
            cVersion.Origin = 'H';
            cVersion.OwnerId = attach.OwnerId;
            cVersion.Title = attach.Name;
            cVersion.VersionData = attach.Body;
            Insert cVersion;
            Id conDocument = new SEL_ContentVersion().selectByRecordId(cVersion.Id).ContentDocumentId;
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;
            cDocLink.LinkedEntityId = attach.ParentId;
            cDocLink.ShareType = 'I';
            cDocLink.Visibility = 'InternalUsers';
            Insert cDocLink;
        }catch(Exception e){
            LOGGER.error('Any error message'+e);
        }
        return null;
    }
}