import { LightningElement } from 'lwc';
import getQuickLinks from '@salesforce/apex/AR_QuickLinks_CTRL.getQuickLinks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSectorResources from '@salesforce/apex/AR_QuickLinks_CTRL.getSectorResources';

export default class ArQuickLink extends LightningElement {

    quickLinks = [];
    sectorResources = [];
    isSectorResourcesModalOpened =  false;
    isProcessing = true;
    isReady = false;
    isError = false;

    connectedCallback() {
        this.getQuickLinks();
    }

    getQuickLinks() {
        getQuickLinks().then(response => {
            response.forEach(ql => {
                if (ql.label == 'Sector Resources') {
                    ql.isSectorResource = true;
                }
                let iconParts = ql.icon.split("#");
                ql.imageUrl = '/resource/SLDS221ICONs/' + iconParts[0] + '/' + iconParts[1] + '_120.png';
            });
            this.quickLinks = response;

            getSectorResources().then(response => {
                this.sectorResources = response;
                this.isProcessing = false;
                this.isReady = true;
            }).catch(error => {
                this.toast('Server Error', 'There was an error loading the Sector Resources.', 'error');
                this.isProcessing = false;
                this.isError = true;
            });

         
        }).catch(error => {
            this.toast('Server Error', 'There was an error loading the Quick Links.', 'error');
            this.isProcessing = false;
            this.isError = true;
        });

      
        
    }

    openSectorResourcesModal() {
        this.isSectorResourcesModalOpened = true;
    }

    closeSectorResourceModal() {
        this.isSectorResourcesModalOpened = false;
    }

    toast(title, message, toastVariant) {
        const toastEvent = new ShowToastEvent({
          title: title,
          message: message,
          variant: toastVariant
        })
        this.dispatchEvent(toastEvent);
    }
}