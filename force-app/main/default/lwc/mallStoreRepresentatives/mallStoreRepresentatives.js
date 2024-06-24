import { LightningElement, track, wire } from 'lwc';
import getUserProfile from '@salesforce/apex/MallProfileManagementController.getUserProfile';
import loggedInUserId from '@salesforce/user/Id';
import getContactRecords from '@salesforce/apex/MallStoreRepresentativesController.getContactRecords';
import { navigateToRecordPage, navigateToWebPage } from 'c/mallNavigation';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import PERMISSIONS_FIELD from '@salesforce/schema/Contact.BCB_Platform_Tenant_Role__c';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';


export default class MallStoreRepresentatives extends NavigationMixin(LightningElement) {
    userProfile;
    accountId;
    @track contacts;
    error;
    navigateToRecordPage = navigateToRecordPage.bind(this);
    navigateToWebPage = navigateToWebPage.bind(this);

    formData = {};
    failureType = null;
    saveStatus = {};
    saveInProcess = false;
    firstName;
    lastName;
    middleName;
    email;
    cellphone;
    permissions;
    promotionalEmail;
    salutation;
    @track isShowModal = false;
    @track selectedContactId;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;
    @wire( getPicklistValues,  { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PERMISSIONS_FIELD } )
    permissionsPicklistValues;

    @wire( getPicklistValues,  { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SALUTATION_FIELD } )
    salutationPicklistValues;

    connectedCallback() {
        this.getContacts();
    }

    //pagination setup
    currentPage = 1;
    pageSize = 6;

    get totalPages() {
        if(this.contacts) {
            return Math.ceil(this.contacts.length / this.pageSize);
        } 
    }

    get displayedContacts() {
        if(this.contacts) {
            const startIndex = (this.currentPage - 1) * this.pageSize;
            const endIndex = startIndex + this.pageSize;
            return this.contacts.slice(startIndex, endIndex);
        }
    }

    handlePaginationChange(event) {
        event.preventDefault();
        event.stopPropagation();
        this.currentPage = event.detail.selectedPage;
    }
                
    async getContacts() {
        this.userProfile = await getUserProfile({ currentUserId: loggedInUserId });
        this.accountId = this.userProfile.user.AccountId;
        let contacts = await getContactRecords({ accountId: this.accountId });
        let contactsCopy = [];
        for(let row=0; row< contacts.length; row++) {
            let contact = {...contacts[row]};
            contact.Name = contact.FirstName + ' ' + contact.LastName;
            contact.Status = contact.Register_Mall_Tenant__c ? 'Registered' : 'Not registered';
            contactsCopy.push(contact);
        }
        this.contacts = [...contactsCopy];
    }

    onSelectingRepresentative(event) {
        event.preventDefault();
        event.stopPropagation();
        let selectedContactId =  event.target.dataset.id;
        this.navigateToRecordPage(selectedContactId);
    }
  
    updateFirstName(event) {
        this.firstName = event.target.value;
    }

    updateMiddleName(event) {
        this.middleName = event.target.value;
    }

    updateLastName(event) {
        this.lastName = event.target.value;
    }

    updateEmail(event) {
        this.email = event.target.value;
    }

    updatePhone(event) {
        this.cellphone = event.target.value;
    }

    updatePermissions(event) {
        this.permissions = event.target.value;
    }

    updateSalutation(event) {
        this.salutation = event.target.value;
    }

    updatePromotionalEmail(event) {
        this.promotionalEmail = event.target.checked;
    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    handleCreateRepresentative(event) {
        event.preventDefault();
        event.stopPropagation();
        this.showModalBox();
    }

    async saveContact() {
        try{
            let contact = {};
            contact["Salutation"] = this.salutation;
            contact["FirstName"] = this.firstName;
            contact["MiddleName"] = this.middleName;
            contact["LastName"] = this.lastName;
            contact["Email"] = this.email;
            contact["Cellphone__c"] = this.cellphone;
            contact["Permissions__c"] = this.permissions;
            contact["Promotional_Email__c"] = this.promotionalEmail;
            contact["AccountId"] = this.accountId;
            contact["OwnerId"] = this.userProfile.user.Account.OwnerId;
            contact["Register_Mall_Tenant__c"] = true;
            this.contact = contact;
        }catch(error) {
            this.error = error;
        }
    }

    async handleSave(event) {
        try {
            event.preventDefault();
            let error = this.handleSaveValidation();
            if(error) {
                this.showToast("Failure!", error, "error");
                return;
            }
            let contactId =  await this.saveContact();
            if(contactId) {
                this.showToast("Success!", "Store representative saved successfully!", "success");
                this.resetAddRepsForm();
                this.hideModalBox();
                this.navigateToRecordPage(contactId);
            } else {
                this.showToast("Failure!", error, "error");    
            }
        } catch(error) {
            this.error = error;
            this.showToast("Failure!", error, "error");    
        }
    }

    async handleSaveAndNew(event) {
        try {
            event.preventDefault();
            let error = this.handleSaveValidation();
            if(error) {
                this.showToast("Failure!", error, "error");
                return;
            }
            let contactId =  await this.saveContact();
            if(contactId) {
                this.showToast("Success!", "Store representative saved successfully!", "success");
                this.resetAddRepsForm();
            } else {
                this.showToast("Failure!", error, "error");    
            }
        } catch(error) {
            this.error = error;
            this.showToast("Failure!", error, "error");    
        }
    }

    resetAddRepsForm() {
        this.salutation = '';
        this.firstName = '';
        this.middleName = '';
        this.lastName = '';
        this.email = '';
        this.cellphone = '';
        this.permissions = '';
        this.promotionalEmail = '';
        this.contact = {};
    }

    handleSaveValidation() {
        let errors = [];
        if(!this.firstName) {
            errors.push('Please provide firstName');
        }
        if(!this.lastName) {
            errors.push('Please provide lastName');
        }
        if(!this.email) {
            errors.push('Please provide email address');
        }
        if(!this.permissions) {
            errors.push('Please select permission');  
        }
        return errors.join(', ');
    }

    handleCancel() {
        this.hideModalBox();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleEditClick(event) {
        const index = event.target.dataset.index;
        this.selectedContactId = event.target.dataset.id;
        if (this.selectedContactId) {
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: this.selectedContactId,
              objectApiName: 'Contact',
              actionName: 'edit'
            }
          });
        }
    }
}