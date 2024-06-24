/**
* @description  : OneHub - MySupport Tab related component
* User Story : SFP-4835
*
* @author Sharath Chandra (sharath.chintalapati@standardbank.co.za)
* @date October 2021
*/
import { LightningElement, track, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import QUERY_TYPE_FIELD from '@salesforce/schema/Case.Query_Type__c';
import createNewCase from '@salesforce/apex/CB_GM_CaseController.createCase';

export default class CbMySupportHeader extends LightningElement {
    @track subjectFieldValue;
    @track descriptionFieldValue;
    @track queryType = '';
    @track recTypeId = '';
    @track isModalOpen = false;
    @track newCaseNumber;
    @api link;
    @api linkLabel;
    @api withOverlay;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseMetadata({ data, error }) {
        if (data) {        
            const rtis = data.recordTypeInfos;
            this.recTypeId =JSON.stringify(Object.keys(rtis).find(rti => rtis[rti].name === 'Cross Border CoE Record Type'));
        }
    }    

    @wire(getPicklistValues, {
        recordTypeId: '0122X000000oqvLQAQ',
        fieldApiName: QUERY_TYPE_FIELD
    }) queryTypePicklist;

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleChange(event) {
        if (event.target.name === 'subjectFieldValue') {
            this.subjectFieldValue = event.target.value;
        }
        else if (event.target.name === 'descriptionFieldValue') {
            this.descriptionFieldValue = event.target.value;
        }
    }

    createCase() {
        createNewCase({ subject:this.subjectFieldValue, description:this.descriptionFieldValue})
            .then(result => {
                this.message = result;
                this.error = undefined;
                if (this.message !== undefined) {
                    this.newCaseNumber = result;
                    const toastEvent = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Case ' + this.newCaseNumber + ' has been created successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(toastEvent);
                    this.isModalOpen = false;
                }
            })
            .catch(error => {
                this.errorMsg = error.message;
                this.isModalOpen = false;
            });
    }
}