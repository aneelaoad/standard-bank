import { LightningElement, wire } from 'lwc';
import sbgIcons from '@salesforce/resourceUrl/sbgIcons';
import getStatements from '@salesforce/apex/MallStatementsCtrl.getStatements';
import getCustomerDocumentByUUID from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerDocumentByUUID";

export default class MallTransactionsStatements extends LightningElement {
    icn_document_statement = sbgIcons + '/OTHER/icn_document_statement.svg';
    icn_download_statement = sbgIcons + '/OTHER/icn_download_statement.svg';

    showSpinner;
    
    @wire(getStatements)
    statements;
    
    redirectionAction() {
        console.log('redirectionAction Called@@');
        window.location.href = '/mall/s/my-statements';
    }

    async handleUnstampedDocumentDownload(event) {
        let documentUUID = event.target.dataset.documentuuid;
        let selectedBtn = event.target;

        try {
          this.showSpinner = true;
          const link = await getCustomerDocumentByUUID({
            documentUUID: documentUUID
          });
          this.showSpinner = false;
          window.open(link, "_blank");
          //this.handlePostDocumentDownloadCleanUp(link);
        } catch (error) {
          this.showSpinner = false;
          this.error = error;
        } finally {
          selectedBtn.classList.toggle("hidden");
          selectedCard.classList.toggle("active");
        }
      }    
   
}