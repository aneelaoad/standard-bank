/**
 * @file MallTransactionsStatements.js
 * @description Lightning Web Component to manage and display transaction statements.
 * @created 2024-06-24
 */
import { LightningElement, wire } from 'lwc';
import sbgIcons from '@salesforce/resourceUrl/sbgIcons';
import getStatements from '@salesforce/apex/CTRL_MallStatements.getStatements';
import getCustomerDocumentByUUID from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerDocumentByUUID";
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getCustomerDocumentForViewing from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerDocumentForViewing";

/**
 * @class MallTransactionsStatements
 * @description Component to handle transaction statements, including view, download, and delete functionalities.
 * @extends LightningElement
 */
export default class MallTransactionsStatements extends LightningElement {
  icn_document_statement = sbgIcons + '/OTHER/icn_document_statement.svg';
  icn_download_statement = sbgIcons + '/OTHER/icn_download_statement.svg';
  showSpinner = false;

  statements = [];
  error;



 /**
   * @wire getStatements
   * @description Fetches the list of statements from the server.
  */

  @wire(getStatements)
  wiredStatements({ error, data }) {
    if (data) {
      this.statements = data.map(statement => ({
        ...statement,
        showMenu: false
      }));

      console.log(' this.statements : ', JSON.stringify(this.statements));
    } else if (error) {
      this.error = error;
      console.error(' error fetching statements : ', error);

    }
  }
   
 /**
   * @method redirectionAction
   * @description Redirects the user to the 'My Statements' page.
   */
  redirectionAction() {
    console.log('redirectionAction Called@@');
    window.location.href = '/mall/s/my-statements';
  }

  
 /**
   * @method handleUnstampedDocumentDownload
   * @description Handles the download of unstamped documents.
   * @param {Event} event - The event object from the button click.
   */
  async handleUnstampedDocumentDownload(event) {
    const downloadUrl = event.currentTarget.dataset.downloadurl;
    if (downloadUrl) {
      window.open(downloadUrl, "_blank");

    } else  {
      const documentUUID = event.currentTarget.dataset.documentuuid;
      const selectedBtn = event.currentTarget;
      console.log(documentUUID);
      console.log(selectedBtn);
      try {
          this.showSpinner = true;
          const link = await getCustomerDocumentByUUID({ documentUUID });
          this.showSpinner = false;
          this.statements.forEach(statement => {
            
            if (statement.uid === documentUUID) {
              statement.downloadUrl = link.downloadUrl;
              statement.publicUrl = link.publicViewUrl;
            }
          });
          window.open(link.downloadUrl, "_blank");
      } catch (error) {
          this.showSpinner = false;
          this.error = error;
          console.error('Error downloading document: ', error);
      } finally {
          this.closeContextMenu(documentUUID);
      }
  
    }
    // const publicUrl = event.currentTarget.dataset.publicUrl
}
 
    /**
     * @method viewStatement
     * @description Opens the PDF of the statement in a new window.
     * @param {Event} event - The event object from the statement title click.
     */
    async viewStatement(event) {
      const publicUrl = event.currentTarget.dataset.publicurl;
    if (publicUrl) {
      window.open(publicUrl, "_blank");

    } else  {
      const documentUUID = event.currentTarget.dataset.documentuuid;
      const selectedBtn = event.currentTarget;
      console.log(documentUUID);
      console.log(selectedBtn);
      try {
          this.showSpinner = true;
          const link = await getCustomerDocumentByUUID({ documentUUID });
          this.showSpinner = false;
          this.statements.forEach(statement => {
            
            if (statement.uid === documentUUID) {
              statement.downloadUrl = link.downloadUrl;
              statement.publicUrl = link.publicViewUrl;
            }
          });
          window.open(link.publicViewUrl, "_blank");
      } catch (error) {
          this.showSpinner = false;
          this.error = error;
          console.error('Error downloading document: ', error);
      } finally {
          this.closeContextMenu(documentUUID);
      }
  
    }
  }

  /**
   * @method deleteStatement
   * @description Handles the deletion of a statement.
   * @param {Event} event - The event object from the button click.
   */
  deleteStatement(event) {
    const documentUUID = event.currentTarget.dataset.documentuuid;
    console.log('Delete statement:', documentUUID);
    // Implement delete functionality
    this.closeContextMenu(documentUUID);
  }




  /**
   * @method showContextMenu
   * @description Toggles the context menu ie. view, delelet and download for a statement.
   * @param {Event} event - The event object from the button click.
   */
  showContextMenu(event) {
    const documentUUID = event.currentTarget.dataset.documentuuid;
    this.statements = this.statements.map(statement => ({
      ...statement,
      showMenu: statement.uid === documentUUID ? !statement.showMenu : false
    }));
  }
   /**
     * @method closeContextMenu
     * @description Closes the context menu for the statement with the specified UUID.
     * @param {String} documentUUID - The UUID of the statement to close the context menu for.
     */
   closeContextMenu(documentUUID) {
    this.statements = this.statements.map(statement => ({
        ...statement,
        showMenu: statement.uid === documentUUID ? false : statement.showMenu
    }));
}
}