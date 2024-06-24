import {
    LightningElement,
    api,
    track
} from 'lwc';
import getApplicationName from '@salesforce/apex/AOB_CTRL_SaveForLater.getApplicationName';
import updateApplicationToInProgressStatus from '@salesforce/apex/AOB_CTRL_SaveForLater.updateApplicationToInProgressStatus';


export default class Aob_comp_saveForLater extends LightningElement {

    failing = false;
    errorContent = '';
    customerName='Maryem';// TO BE DYNAMICALLY FETCHED
    @track applicationName = '';

    @api teams = ["Self Assisted"];
    label = {};
    @api applicationId;

    /**
     * @description Initiates the Screen
     */
     connectedCallback() {
         console.log('this.applicationId in connected cb:' + this.applicationId);
        getApplicationName({
            'applicationId': this.applicationId
        })
        .then(result => {
            this.applicationName=this.label.AOB_SaveForLater_ApplicationNo.replace('{####}',result.Name);
        });
    }
      handleResultChange(event) {
        this.label = event.detail;
    }

    get getOpenClosePageModal() {
        return this.isShowingCloseButton && this.openClosePageModal;
    }

    /**
    * @description method to move to previous screen
    */
    backToPreviousPage(){
        this.dispatchEvent(new CustomEvent('closed', {}));
    }

    /**
    * @description method to move to previous screen
    */
    saveForLater(){

        updateApplicationToInProgressStatus({
            'applicationId': this.applicationId
        });

        this.dispatchEvent(new CustomEvent('closed', {}));
    }

}