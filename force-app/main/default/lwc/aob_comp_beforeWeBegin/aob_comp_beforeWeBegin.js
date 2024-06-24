import { LightningElement, api } from 'lwc';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents";
import { NavigationMixin } from "lightning/navigation";

export default class Aob_cmp_beforeWeBegin extends NavigationMixin(LightningElement) {

    sep = THEME_OVERRIDES + '/assets/images/sep.png';
    Lock = THEME_OVERRIDES + '/assets/images/Lock.png';
    Camera = THEME_OVERRIDES + '/assets/images/Camera.png';
    passport = THEME_OVERRIDES + '/assets/images/passport.png';
    @api teams = ["Self Assisted"];
    @api applicationId;
    title;
    productId;
    label = {};
    pricingOption;
    adobePageTag = {
        pageName: "business:products and services:bank with us:business bank accounts:",
        dataId: "link_content",
        dataIntent: "informational",
        dataScope: "before you begin",
        cancelButtonText: " ",
        continueButtonText: "Continue button Click",
        privacyintent: "informational",
        privacyscope: " ",
        formName: "",
        siteErrorCode: "",
        application: {
            applicationProduct: "",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Application:",
            applicationStep: "step 0",
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

    connectedCallback() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
        let url_string = window.location;
        let url = new URL(url_string);
        this.productId = url.searchParams.get("prodId");
        this.pricingOption = url.searchParams.get("prOpt");
        this.adobePageTag.applicationStep = "Step 0"
        if (this.pricingOption == 'ZMMB') {
            this.title = 'MyMoBiz';
            this.adobePageTag.pageName = this.adobePageTag.pageName + "mymobiz account origination step 0 before you begin";
            this.adobePageTag.application.applicationName = this.adobePageTag.application.applicationName + 'mymobiz business account';
            this.adobePageTag.application.applicationProduct = "mymobiz business account";
            this.adobePageTag.continueButtonText = "mymobiz business account | Continue button Click";
            loadScript(this, FireAdobeEvents).then(() => {
                if (!this.isEventFired) {
                    this.isEventFired = true;
                    window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
                    window.fireFormStartEvent(this, this.adobePageTag.application);

                }
            })
                .catch(error => {
                    this.errorMessage = getErrorMessage.call(this, error);
                    this.adobePageTag.siteErrorCode = this.errorMessage;


                });
        } else {
            this.title = 'MyMoBizPlus';
            this.adobePageTag.pageName = this.adobePageTag.pageName + "mymobiz plus account origination step 0 before you begin";
            this.adobePageTag.application.applicationName = this.adobePageTag.application.applicationName + 'mymobiz plus business account';
            this.adobePageTag.application.applicationProduct = "mymobiz plus business account";
            this.adobePageTag.continueButtonText = "mymobiz plus business account | Continue button Click";

            loadScript(this, FireAdobeEvents).then(() => {
                if (!this.isEventFired) {
                    this.isEventFired = true;
                    window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
                    window.fireFormStartEvent(this, this.adobePageTag.application);

                }
            })
                .catch(error => {
                    this.errorMessage = getErrorMessage.call(this, error);
                    this.adobePageTag.siteErrorCode = this.errorMessage;


                });
        }
    }

     handleResultChange(event) {
        this.label = event.detail;
    }

    handleContinueClicked(event) {
        window.fireButtonClickEvent(this, event);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Business_Preapplication_Page__c'
            },
            state: {
                prodId: this.productId,
                prOpt: this.pricingOption
            }
        }).then(() => {
            window.scrollTo(0, 0);
        }).catch(error => {
            this.errorMessage = getErrorMessage.call(this, error);
        });
    }
}