import { LightningElement, wire, track } from 'lwc';
import sbgIcons from '@salesforce/resourceUrl/sbgIcons';
import getStatements from '@salesforce/apex/MallStatementsCtrl.getStatements';
import getCustomerDocumentByUUID from "@salesforce/apex/CTRL_MallDocumentManagement.getCustomerDocumentByUUID";

export default class MallTransactionsStatements extends LightningElement {
    icn_document_statement = sbgIcons + '/OTHER/icn_document_statement.svg';
    icn_download_statement = sbgIcons + '/OTHER/icn_download_statement.svg';
    showSpinner = false;
    error;

    @track statements = [];

    @wire(getStatements)
    wiredStatements({ error, data }) {
        if (data) {
            this.statements = data.map(statement => ({
                ...statement,
                showMenu: false
            }));

            console.log(' this.statements : ',JSON.stringify( this.statements));
        } else if (error) {
            this.error = error;
        }
    }

    redirectionAction() {
        console.log('redirectionAction Called@@');
        window.location.href = '/mall/s/my-statements';
    }

    async handleUnstampedDocumentDownload(event) {
    let documentUUID = event.target.dataset.documentuid;

        const selectedBtn = event.currentTarget;

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

    showContextMenu(event) {
        const documentUUID = event.currentTarget.dataset.documentuuid;
        this.statements = this.statements.map(statement => ({
            ...statement,
            showMenu: statement.uid === documentUUID ? !statement.showMenu : false
        }));
    }

    viewStatement(event) {
        const documentUUID = event.currentTarget.dataset.documentuuid;
        console.log('View statement:', documentUUID);
        // Implement view functionality
    }

    deleteStatement(event) {
        const documentUUID = event.currentTarget.dataset.documentuuid;
        console.log('Delete statement:', documentUUID);
        // Implement delete functionality
    }
}