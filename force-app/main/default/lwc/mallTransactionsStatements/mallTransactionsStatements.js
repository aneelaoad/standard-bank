/**
 * @file MallTransactionsStatements.js
 * @description Lightning Web Component to manage and display transaction statements.
 * @created 2024-06-24
 */
import { LightningElement, wire, track } from 'lwc';
import sbgIcons from '@salesforce/resourceUrl/sbgIcons';
import getStatements from '@salesforce/apex/MallStatementsCtrl.getStatements';
import getCustomerDocumentByUUID from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerDocumentByUUID";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * @class MallTransactionsStatements
 * @description Component to handle transaction statements, including view, download, and delete functionalities.
 * @extends LightningElement
 */
export default class MallTransactionsStatements extends LightningElement {
  icn_document_statement = sbgIcons + '/OTHER/icn_document_statement.svg';
  icn_download_statement = sbgIcons + '/OTHER/icn_download_statement.svg';
  showSpinner = false;
  error;

  statements = [];



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
    const documentUUID = event.currentTarget.dataset.documentuuid;
    const selectedBtn = event.currentTarget;
    console.log(documentUUID);
    console.log(selectedBtn);
    try {
        this.showSpinner = true;
        const link = await getCustomerDocumentByUUID({ documentUUID });
        this.showSpinner = false;
        window.open(link, "_blank");
    } catch (error) {
        this.showSpinner = false;
        this.error = error;
        console.error('Error downloading document: ', error);
    } finally {
        selectedBtn.classList.toggle("hidden");
    }
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
   * @method viewStatement
   * @description Displays a toast with the statement details.
   * @param {Event} event - The event object from the button click.
   */
  viewStatement(event) {
    const documentUUID = event.currentTarget.dataset.documentuuid;
    console.log('View statement:', documentUUID);

    // Find the statement with the matching UUID
    const selectedStatement = this.statements.find(statement => statement.uid === documentUUID);

    // Prepare the message with statement details
    const message = `Account Name: ${selectedStatement.title}
                     Date From: ${selectedStatement.strDate}
                     `

    // Show a popup with the statement details
    // window.confirm(message);
    const toastEvent = new ShowToastEvent({
      title: 'Statement Details',
      message: message,
      variant: 'Success'
    });
    this.dispatchEvent(toastEvent);
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
  }
}