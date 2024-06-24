import { LightningElement, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import getPartnerDetails from '@salesforce/apex/PP_RegistrationForm_CTRL.getPartnerDetails';
import { trackLink } from 'c/ppEventUtils'

const FIELDS = [
    'User.Id',
    'User.Name',
    'User.FullPhotoUrl',
    'User.SmallPhotoUrl',
];


export default class PpDashboardEditProfile extends LightningElement {

    userId = Id;
    name;
    pictureUrl;
    partner = { 'sobjectType': 'PP_PartnerApplication__c' };
    capabilities;
    industry;
    error;
    dataloaded;
    isModalOpen;

    @wire(getRecord, { recordId: '$userId', fields: FIELDS })
    wireuser({ error, data }) {
        if (data) {
            this.error = undefined;
            this.name = data.fields.Name.value;
            this.pictureUrl = data.fields.FullPhotoUrl.value;
        }
        else if(error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.getPartner();
    }

    getPartner() {
        getPartnerDetails().then(response => {
            this.error = undefined;
            this.partner = response;
            this.capabilities = response.PP_Capabilities__c.replace(';', ',');
            this.industry = response.PP_Industry__c.replace(';', ',');
        }).catch(error => {
            this.error = error;
        });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleEditProfileClick(event) {
        this.tracker(event);
        this.isModalOpen = true;
    }

    tracker(event) {
        trackLink(event);
    }
}