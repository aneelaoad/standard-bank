import { LightningElement, track } from 'lwc';
import getUserProfile from '@salesforce/apex/MallProfileManagementController.getUserProfile';
import loggedInUserId from '@salesforce/user/Id';
import IS_GUEST from '@salesforce/user/isGuest';
import sbgVisualAssets from '@salesforce/resourceUrl/sbgVisualAssets';
import getCountryList from '@salesforce/apex/SBGNavigationBarController.getCountryList';
import { getBaseUrl } from 'c/mallNavigation';
import DEFAULT_MALL_COUNTRY from '@salesforce/label/c.DEFAULT_MALL_COUNTRY';
import DEFAULT_MALL_LANGUAGE_ISO from '@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO';
import STORE_MANAGER_PROFILE from '@salesforce/label/c.Store_Manager_Profile';
import STORE_WORKER_PROFILE from '@salesforce/label/c.Store_Worker_Profile';
import mallIcons from "@salesforce/resourceUrl/mallIcons";



export default class MallProfileManagement extends LightningElement {
    pingUserdetailsUpdateUrl = getBaseUrl() + '/mall/s/update-personal-details';
    @track isIndividualShopper;
    @track isBusinessShopper;
    @track isShop = true;
    @track preferenceOptions = [];
    @track showPersonalDetails;
    @track showBusinessDetails;
    @track showPreferences
    @track showShopDetails;
    isShopWorker;
    isShopManager;
    error;
    userProfile;
    user;
    account;
    contact;
    personAccount;
    firstName = '';
    lastName = '';
    cellPhone = '';
    userName = '';
    emailAddress = '';
    @track country;
    @track language;
    userType;
    preferences = [];
    businessName;
    vatRegistrationNumber;
    cipc;
    preferenceLabels = [];
    promotionalEmailConsent = false;
    preferencesHelperText = "Note that available products and services will change depending on your selected country. To temporarily change your country, please select the flag icon on the top right corner of your page.";
    businessHelpText = 'Save time and effort by giving us your business details now. We\'ll securely store them so you won\'t need to retype them for future purchases.';
    notificationHelpText = 'Choose your preferred way of communication. Note that some notifications are mandatory for your information’s security.';
    marketingConsentHelpText = 'Select your preferred marketing channels below and indicate if you agree to share your data with with the listed parties.';
    //auto save fields flags
    countryFlag;
    languageName;
    signInOpted;
    promotionalEmailConsentFlag;
    cipcFlag;
    businessNameFlag;
    vatRegistrationNumberFlag;
    preferenceFlag;
    //if only one language
    hasSingleLanguage = false;
    showCountryDropdown = false;
    showLanguageDropdown = false;
    disableLanguageDropdown = false;
    showBusinessDocuments = true; // Change when ready
    //countries list
    countryList = [];
    //language list
    languageList = [];
    //available categories;
    categories = [];
    backIcon = sbgVisualAssets + '/icn_chevron_left.svg';

    rightIcon = mallIcons + "/ic_chevron-right.svg";

    showPersonalDetailsMobile = false; 
    showPreferencesMobile  = false;
    showManageNotificationsMobile  = false;
    showBusinessDetailsMobile  = false;
    showMarketingConsentMobile  = false;
    

    buttonInteractionIntent;
    buttonInteractionScope;
    buttonInteractionType; 
    buttonInteractionText;
    buttonInteractionTextBefore;
    sendButtonLabel = 'Save';

    isSaving = false;
    isSaved = false;

    mallSavingIcon = mallIcons + '/mallLoadingIcon.svg';
    mallSavedIcon = mallIcons + '/mallSavedIcon.svg';

    connectedCallback() {
        if (!IS_GUEST) {
            this.getUserProfileDetails();
        }
    }


    goBack() {
        history.back();
    }

    async getUserProfileDetails() {
        try {
            this.userProfile = await getUserProfile({ currentUserId: loggedInUserId });
            if(this.userProfile.user) {
                this.user = this.userProfile.user;
            }
            if(this.userProfile.user.Contact) {
                this.contact = this.userProfile.user.Contact;
            }
            if(this.userProfile.user.Contact && this.userProfile.user.Contact.Account) {
                this.account = this.userProfile.user.Contact.Account;
            }
            if(this.user) {
                this.firstName = this.user.FirstName ? this.user.FirstName : '';
                this.lastName = this.user.LastName ? this.user.LastName : '';
                this.emailAddress = this.user.Email ? this.user.Email : '';
                this.userName = this.user.Ping_UserName__c ? this.user.Ping_UserName__c : '';
                this.country = this.user.User_Franco__c ? this.user.User_Franco__c : DEFAULT_MALL_COUNTRY; 
                this.language = this.user.Language_ISO_Code__c ? this.user.Language_ISO_Code__c :DEFAULT_MALL_LANGUAGE_ISO ;
                this.cellPhone = this.user.MobilePhone ? this.user.MobilePhone : '';
            }
            this.accountId = this.userProfile.user.AccountId;
            //get country and language setup
            this.getCountriesList();
            //setup account related section
            if (this.userProfile.user.Contact.Account.Name) {
                this.businessName = this.userProfile.user.Contact.Account.Name;
            }
            if (this.userProfile.user.Contact.Account.VAT_Registration_Number__c) {
                this.vatRegistrationNumber = this.userProfile.user.Contact.Account.VAT_Registration_Number__c;
            }
            if (this.userProfile.user.Contact.Account.CIPC__c) {
                this.cipc = this.userProfile.user.Contact.Account.CIPC__c;
            }
            //setup shop related profiles
            this.showBusinessDetails = true;
            if(this.userProfile.user.Profile.Name == STORE_WORKER_PROFILE) {
                this.isShopWorker = true;
            }
            if(this.userProfile.user.Profile.Name == STORE_MANAGER_PROFILE) {
                this.isShopManager = true;
            }
            if((this.isShopWorker || this.isShopManager) && this.userProfile.user.Profile.Name.includes('Store')) {
                this.showPersonalDetails = true;
                this.showBusinessDetails = false;
            }
        } catch (error) {
            this.error = error;
        }
    }


    async getCountriesList() {
        let countryList = [];
        try {
            let data = await getCountryList();
            if (data) {
                data.forEach(continent => {
                  let countries = [];
                  continent.countries.forEach(country => {
                    let languages = [];
                    country.languages.forEach(lang => {  
                    languages.push({
                        label: lang.languageName,
                        value: lang.languageISOCode,
                    });
                    });
                    countries.push({
                        label: country.countryName,
                        value:country.countryName,
                        languages: languages,
                        flagImage: sbgVisualAssets + "/" + country.flagImage
                    });

                    if (country.countryName == this.country) {
                        this.languageList = [...languages];
                        if(this.languageList.length == 1) {
                            this.hasSingleLanguage = true;
                        }
                    }
                  });
                  countryList.push(...countries);
                });
            }
            this.countryList = [...countryList];
            let selectedCountry = this.countryList.find(cntry => cntry.value == this.country);
            this.countryFlag = selectedCountry.flagImage;
            this.languageName = selectedCountry.languages.find(lang => lang.value == this.language).label;
            if (selectedCountry.languages.length <= 1) {
                this.disableLanguageDropdown = true;
            }
        } catch(error) {
            this.countryList = [];
            this.error = error;
        }
    }

    showOrHideCountryDropdown() {
        this.showCountryDropdown = !this.showCountryDropdown;
    }

    setSelectedCountry(event) {
        this.country = event.currentTarget.dataset.country;
        let selectedCountry = this.countryList.find(cntry => cntry.value == this.country);
        this.languageList = selectedCountry.languages;
        this.language = this.languageList.length == 1 ? 'en' : null;
        console.log('Languages: ', selectedCountry.languages);
        if (this.language) {
            this.languageName = selectedCountry.languages.find(lang => lang.value == this.language).label;
        }
        this.disableLanguageDropdown = this.languageList.length <= 1;
        this.countryFlag = selectedCountry.flagImage;
        this.showCountryDropdown = false;
    }

    showOrHideLanguageDropdown() {

        let selectedCountry = this.countryList.find(cntry => cntry.value == this.country);
        this.languageList = selectedCountry.languages;
        console.log('Languages: ', selectedCountry.languages);

        if (this.languageList.length > 1 && !this.showLanguageDropdown) {
            this.showLanguageDropdown = true;
        } else {
            this.showLanguageDropdown = false;
        }
    }

    setSelectedLanguage(event) {
        this.language = event.currentTarget.dataset.language;
        this.languageName = selectedCountry.languages.find(lang => lang.value == this.language).label;
        this.showLanguageDropdown = false;
    }

    setMobileTabs(event) {
        let currentTab = event.currentTarget.dataset.tab;
        this.showBusinessDetailsMobile = !this.showBusinessDetailsMobile && currentTab == 'Business Details';
        this.showManageNotificationsMobile = !this.showManageNotificationsMobile && currentTab == 'Manage Notifications';
        this.showMarketingConsentMobile  = !this.showMarketingConsentMobile && currentTab == 'Marketing Consent';
        this.showPersonalDetailsMobile = !this.showPersonalDetailsMobile && currentTab == 'Personal Details';
        this.showPreferencesMobile  = !this.showPreferencesMobile && currentTab == 'Preferences';
        
    }
    

    get signInOptions() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'SMS', value: 'SMS' },
            { label: 'Both', value: 'Both' }
        ];
    }

    get marketingConsentOptions() {
        return [
            {
                sectionLabel: 'Telesales',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Email marketing',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'SMS marketing',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'In-app marketing notifications',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Data sharing within the Group',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Data sharing with third parties',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Data sharing across within the Group',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Receive marketing',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Marketing research',
                sectionValue: null,
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            }
        ]
    }
}