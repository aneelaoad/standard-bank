import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertPublicFiles from '@salesforce/apex/PP_ContentDocument_CTRL.insertPublicFiles';

export default class PpPublicFileUpload extends LightningElement {
    @api 
    recordId;
    handleUploadFinished(event) {
        // Get the list of uploaded files
        let contentDocumentIds = [];
        const uploadedFiles = event.detail.files;

        uploadedFiles.forEach(item =>{
            contentDocumentIds.push(item.documentId);
        });

        insertPublicFiles({ contentDocumentIds: contentDocumentIds, linkedEntityId: this.recordId}).then(result => {
           if(result == 'Success'){
            this.toast('Files Uploaded','Success');
           }
            
        });
    }
    toast(title, toastVariant) {
        const toastEvent = new ShowToastEvent({
          title,
          variant: toastVariant
        })
        this.dispatchEvent(toastEvent)
      }
}