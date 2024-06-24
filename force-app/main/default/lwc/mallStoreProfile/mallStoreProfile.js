import { LightningElement, track } from 'lwc';
import getUserProfile from '@salesforce/apex/MallProfileManagementController.getUserProfile';
import getStoreProfile from '@salesforce/apex/MallStoreProfileController.getStoreProfile';
import loggedInUserId from '@salesforce/user/Id';


export default class MallStoreProfile extends LightningElement {

    accountInfo;
    account;
    @track contacts =[];
    segments;
    categories;
    accountId;
    country;
    error;
    name;
    cellphone;
    emailAddress;
    vatRegistrationNumber;
    @track segmentOptions = [];
    @track categoryOptions = [];
    bankName;
    bankAccountName;
    bankAccountNumber;
    bankAccountType;
    swiftCode;
    categoriesString;
    transactionRelationships;

    @track columns = [
        {
            label: 'Name',
            fieldName: 'Name'
        },
        {
            label: 'Role',
            fieldName: 'Role'
        }  
    ];
    url;
    connectedCallback() {
        if(!this.accountInfo) {
            this.fetchStoreProfile();
        }
    }

    async fetchStoreProfile() {
        try {
            let userProfile = await getUserProfile({ currentUserId: loggedInUserId });
            this.accountId = userProfile.user.AccountId;
            this.accountInfo = await getStoreProfile({ accountId: this.accountId });
            this.account = this.accountInfo.account;
            let contactRecords = this.accountInfo.contacts;
            let contacts = [];
            if(contactRecords && contactRecords.length) {
                for(let row=0; row < contactRecords.length; row++) {
                    let contact = {};
                    contact.Name = contactRecords[row].FirstName + ' ' + contactRecords[row].LastName;
                    contact.Role = contactRecords[row].BCB_Platform_Tenant_Role__c; 
                    contacts.push(contact);
                }
            }
            this.contacts = [...contacts];
            this.segments = this.accountInfo.segments;
            this.categories = this.accountInfo.categories;
            this.country = this.accountInfo.country;
            this.name = this.account.Name;
            this.cellphone = this.account.CellPhone__c;
            this.emailAddress = this.account.Email__c;
            this.vatRegistrationNumber = this.account.VAT_Registration_Number__c;
            this.bankName = this.account.Bank_Name__c;
            this.bankAccountName = this.account.Bank_Account_Name__c;
            this.bankAccountNumber = this.account.Bank_Account_Number__c;
            this.bankAccountType = this.account.Bank_Account_Type__c;
            this.swiftCode = this.account.Swift_Code__c;
            this.country = this.accountInfo.country;
            if(this.accountInfo.account.Link__r) {
                this.url = this.accountInfo.account.Link__r.Desktop_url__c;
            }

            this.segmentOptions = this.segments.map(segment => {
                return { label: segment.name, value: segment.id, image: segment.iconUrl, checked: false };
            });
            this.categoryOptions = this.categories.map(category => {
                return { label: category.name, value: category.id, image: category.iconUrl, checked: false };
            });
            let categoriesList = [];
            for(let row=0; row< this.categories.length; row++) {
                categoriesList.push(this.categories[row].name);
            }
            this.categoriesString = categoriesList.join(', ');

            let segmentsList = [];
            for(let row=0; row< this.segments.length; row++) {
                segmentsList.push(this.segments[row].name);
            }
            this.transactionRelationships = segmentsList.join(', ');
            this.transactionRelationships = this.transactionRelationships ? this.transactionRelationships : "Business";
        }catch(error) {
            this.error = error;
        }
    }
}