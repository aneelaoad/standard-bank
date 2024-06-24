/***************************************************************************************
* @Name of the Component :zafSendEmail
* @description           :SFP-36983 Component to show existing contacts and to send Email
* @Author                :Pradeep Kota  
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By  : Pradeep Kota 
*@Last Modified On  : 08 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/

import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import getClientLetterJSON from '@salesforce/apex/ZAF_CTRL_FullStandardPricingLetter.getClientLetterJSON';
import sendEmailToControllers from '@salesforce/apex/ZAF_CTRL_SendClientPricingLetter.sendEmailToController';
import sendCustomEmail from '@salesforce/apex/ZAF_CTRL_SendClientPricingLetter.sendCustomEmail';
import { createLogger } from 'sbgplatform/rflibLogger';

export default class ZAFSendEmail extends LightningElement {
    logger = createLogger('ZAFSendEmail');
    @api recordId;
    @track showEmail; 
    @track checkedEmail = [];
    @track closeEmailbox = false;
    @track showFootor = true;
    @track isLoaded = true;
    @track showEmailbox = false;
    @track NoEmail;
    @track NoEmailmsg = false;
    @track ListOfContacts;
    @track clientName;
    @track disabledbutton = true;
    @track showTable = false;
    @track ispreview=true;

    /**
	 * @description wire to get current Page record Id and to call send Email function
	*/
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.sendEmail();
           
        }
    }
    /**
     * @description handles to render metadata
     */
      connectedCallback() {
    this.handleClientLetterData();
  }

    /**
	 * @description handles to send Emails of checked checkbox with recordId to apex
	*/
    sendAction() {
        this.isLoaded = false;
        this.closeEmailbox = true;
        sendCustomEmail({ recordId: this.recordId, customEmail: this.checkedEmail })
            .then((result) => {
                if (result) {
                    this.showEmailbox = true;
                    this.showFootor = false;
                    this.isLoaded = true;
                    
                }
                
            }).catch(error => {
                this.NoEmailmsg = true;
                this.NoEmail = this.ClientLetterData.EmailError;
                this.logger.error('An error occurred in sendCustomEmail:', error);

            })
    }
    

    /**
	 * @description handles to fetch All related records of client Account data and show in UI
	*/
    sendEmail() {
        sendEmailToControllers({ recordId: this.recordId })
            .then((result) => {
                if (result.length > 0) {
                    this.showTable = true;
                    this.ListOfContacts = result;
                    let e = JSON.stringify(result);
                    this.clientName = result[0].Account.Name;

                } else if (result.length === 0) {
                    this.NoEmailmsg = true;
                    this.NoEmail = this.ClientLetterData.EmailEmptyMsg;
                }
            }).catch(error => {
                this.logger.error('An error occurred in sendEmailMethod:', error);
            })
    }


    /**
	 * @description handles to collect data in array of checked boxes and to enable/disable button
	*/
    changeHandler(event) {

        if (event.target.checked) {
            this.checkedEmail.push(event.currentTarget.dataset.text);
        }
        else {
            this.checkedEmail = this.checkedEmail.filter(item => item !== event.currentTarget.dataset.text);
        }
        if (this.checkedEmail == '') {
            this.disabledbutton = true;
        } else {
            this.disabledbutton = false;
        }
    }


    /**
	 * @description handles to close the model Popup
	*/
    closeAction() {

        this.dispatchEvent(new CloseActionScreenEvent());

    }
    ClientLetterData = {};
    /**
      *@description Method i used to get the custom meta data
      */
    handleClientLetterData() {
      getClientLetterJSON({ developerName: 'Client_sector' })
        .then(result => {
          this.ClientLetterData = JSON.parse(result.Description__c);
        })
        .catch(error => {
          this.logger.error('An error occurred in Meta data:', error);

        });
    }
    /**
     * @description handles to preview PDF on other tab
     */
   handleGeneratePDF()
    {
           window.open('/apex/ZAF_GeneratePricingLetterVFPage?id=' +this.recordId);
    }
    
   

}