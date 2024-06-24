/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   devi ravuri   PreApplication data privacy comp
 * @last modified on  : 26 APRIL 2024
   @last modified by  : Narendra 
   @Modification Description : SFP-38348
 */
import {
    LightningElement,
    api,
    wire
} from 'lwc';
import {
    CurrentPageReference
} from 'lightning/navigation';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents";
import {
    loadScript
} from 'lightning/platformResourceLoader';
import isDILinkedToBPID from '@salesforce/apex/AOB_CTRL_FindApplications.isDILinkedToBPID';
import updatePreAppStage from '@salesforce/apex/AOB_CTRL_FindApplications.updatePreAppStage';

export default class Aob_cmp_verificationSuccessful extends LightningElement {
    @api teams = ["Self Assisted"];
    label = {};
    isEventFired;
    adobePageTag = {
        pageName: "business:products and services:bank with us:business bank accounts:",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: "pre-application",
        cancelButtonText: "verification successful | sign in to continue | sign in button click",
        continueButtonText: " ",
        privacyintent: "informational",
        privacyscope: " ",
        formName: "",
        privacylinkclick: "pre application | privacy statement link click",
        siteErrorCode: "",
        application: {
            applicationProduct: "",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Application:",
            applicationStep: "step 1",
            applicationStart: true,
            applicationComplete: false,
        },
        ecommerce: {
            product: [{

            }],
            purchaseID: "",
            currencycode: "ZAR"
        },
    };
    isLoaded;
    openverification;
    verificationsuccessful = true;
    peopleSVG = THEME_OVERRIDES + '/assets/images/icn-people-1.svg';
    clipboardSVG = THEME_OVERRIDES + '/assets/images/icn-clipboard.svg';
    formfillSVG = THEME_OVERRIDES + '/assets/images/icn-form-fill.svg';
    nametagSVG = THEME_OVERRIDES + '/assets/images/icn-nametag.svg';
    @api pageName;
    @api isFiringScreenLoad;
    @api continueBtnDataIntent;
    @api currentDataScope;
    @api availableActions = [];
    @api txtBoxVal;
    @api applicationId;
    @api recordId;
    @api product;
    status;
    digitalIDLinked = false;
    showProceedToApp = false;

    // read parameters passed to the page via URL params
    @wire(CurrentPageReference)
    getStateParameter(currentPageReference) {
        if (currentPageReference) {
            this.applicationId = currentPageReference.state.appId;
            this.productcode = currentPageReference.state.product;
        }
    }

    get showSignInRegister() {
        if (this.showProceedToApp == false && this.digitalIDLinked == false) {
            return true;
        } else {
            return false;
        }
    }

    get showSignIn() {
        if (this.showProceedToApp == false && this.digitalIDLinked == true) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @description method for initialisation
     */
    connectedCallback() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
        if (localStorage.getItem('$AuraClientService.token$siteforce:communityApp')) {
            this.showProceedToApp = true;
        }
        this.adobePageTag.dataScope = this.productcode?.toLowerCase() + ' application';
        this.adobePageTag.pageName = this.adobePageTag.pageName + this.productcode?.toLowerCase() + " account origination step 2 verification successful";
        this.adobePageTag.application.applicationName = this.adobePageTag.application.applicationName + this.productcode?.toLowerCase() + ' business account';
        this.adobePageTag.application.applicationProduct = this.productcode?.toLowerCase() + " business account";
        this.adobePageTag.ecommerce.product[0].productName = this.adobePageTag.application.applicationProduct;

        this.adobePageTag.formName = "apply now business bank account " + this.adobePageTag.pageName;
        if (this.applicationId) {
            this.adobePageTag.application.applicationID = this.applicationId;
            isDILinkedToBPID({
                'appId': this.applicationId
            }).then(result => {
                let data = JSON.parse(result);               
                if (data.initiatorDigitalID) {
                    this.digitalIDLinked = true;
                } else {
                    this.digitalIDLinked = false;
                }
            }).catch(error => {
                this.isLoaded = true;
            });
        }
        loadScript(this, FireAdobeEvents).then(() => {
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
                window.fireFormStartEvent(this, this.adobePageTag.application);
            }
        })
            .catch(error => {
                this.isLoaded = true;
            });
    }
     handleResultChange(event) {
        this.label = event.detail;
    }

    /**
     * @description Launches the url which initiates Account Onboarding
    */
    launchApplication(event) {
        let dataContext = event.target.dataset.context;
        window.fireButtonClickEvent(this, event);
        updatePreAppStage({
            'appId': this.applicationId,
            'stageToUpdate': dataContext
        }).then(result => {
            var launchURL = this.label.AOB_AO_Base_URL + this.applicationId;
            window.open(launchURL, "_self");
        }).catch(error => {
            this.isLoaded = true;
        });


    }


}