import { api, LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getRelatedFiles from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.getRelatedFiles'
import getRelatedPartnerships from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.getRelatedPartnerships'
import createPartnership from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.createPartnership'
import deletePartnership from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.deletePartnership'
import { NavigationMixin } from 'lightning/navigation'
import Assets from '@salesforce/resourceUrl/PP_Assets';
import { trackLink } from 'c/ppEventUtils'

const FIELDS = [
    'PP_PartnershipOpportunity__c.Id',
    'PP_PartnershipOpportunity__c.Name',
    'PP_PartnershipOpportunity__c.PP_Content__c',
    'PP_PartnershipOpportunity__c.PP_PublishStartDate__c',
];

export default class PpOpportunityViewSingle extends NavigationMixin(LightningElement) {
    @api
    recordId;
    @api
    heading;
    @api
    btnText;
    opportunity;
    title;
    content;
    publishStartDate;
    filesList = [];
    partnership = { 'sobjectType': 'PP_Partnership__c' };
    opptyId;
    interestedFlag;
    alreadyInterestedFlag = false;
    backIcon;
    tickIcon;
    crossIcon;
    questionMarkImg;
    popupImg;
    popupText;
    isModalOpen;

    @wire(getRelatedFiles, { recordId: '$recordId' })
    wiredResult({ data, error }) {
        if (data) {
            this.filesList = Object.keys(data).map(item => ({
                "label": data[item],
                "value": item,
                "url": `/sfc/servlet.shepherd/document/download/${item}`
            }))
        }
    }


    connectedCallback() {
        this.backIcon = Assets + '/Icons/backIcon.png';
        this.tickIcon = Assets + '/Icons/tickIcon.png';
        this.crossIcon = Assets + '/Icons/crossIcon.png';
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    opportunityRecord({ error, data }) {

        if (error) {
            this.toast('Error loading Opportunity', 'error');
        } else if (data) {
            this.opportunity = data;
            this.title = this.opportunity.fields.Name.value;
            this.content = this.opportunity.fields.PP_Content__c.value;
            this.publishStartDate = this.opportunity.fields.PP_PublishStartDate__c.value;
            this.opptyId = this.opportunity.fields.Id.value;
            this.checkPartnershipOpportunityInterest();

        }
    }

    checkPartnershipOpportunityInterest() {
        getRelatedPartnerships({ opportunityId: this.opptyId }).then(response => {
            this.partnership = response;
            if (this.partnership) {
                this.interestedFlag = true;
                this.alreadyInterestedFlag = true;
                this.btnText = 'INTERESTED';
            } else {
                this.interestedFlag = false;
                this.btnText = 'EXPRESS INTEREST';
            }
        });
    }

    handleInterestClick() {
        if (this.alreadyInterestedFlag == true) {
            this.popupImg = Assets + '/images/questionMark.png';
            this.popupText = 'Remove this from the opportunities you are interested in?';
        } else {
            this.popupImg = Assets + '/Icons/trackerCompleteIcon.png';
            this.popupText = 'We have noted your interest in this opportunity';
            this.savePartnership();
        }
        this.isModalOpen = true;

    }

    removeInterest() {
        deletePartnership({ partnership: this.partnership }).then(response => {
            this.isModalOpen = false;
            this.btnText = 'EXPRESS INTEREST';
            this.interestedFlag = false;
            this.alreadyInterestedFlag = false;
        });
    }

    savePartnership() {
        createPartnership({ opportunityId: this.opptyId }).then(response => {
            this.partnership = response;
            if (response) {
                this.interestedFlag = true;
                this.btnText = 'INTERESTED';
            }
        });
    }

    closeModal() {
        this.isModalOpen = false;
        this.alreadyInterestedFlag = true;
    }

    toast(title, toastVariant) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: toastVariant
        })
        this.dispatchEvent(toastEvent)
    }

    navigateToOpportunities() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'opportunities__c'
            }
        });
    }

    tracker(event) {
        trackLink(event);
    }

}