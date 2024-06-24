import {
    LightningElement,
    api,
    track
}
    from 'lwc';
import {
    NavigationMixin
} from "lightning/navigation";
/*Apex Controllers*/
import getApplicationData from '@salesforce/apex/AOB_CTRL_Exit.getApplicationData';
import getMymobizManagementSetting from '@salesforce/apex/AOB_CTRL_BackToBCBPlatform.getMymobizManagementSetting';

import { getErrorMessage } from 'c/aob_comp_utils';
//Adobe imports
import {
    loadScript
} from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";
import SBG_SRC from '@salesforce/resourceUrl/AOB_ThemeOverrides';
const CHANNEL_NAME_KEY = "channel";
const CHANNEL_NAME_VALUE_MALL = "mall";

export default class aob_comp_exit extends NavigationMixin(LightningElement) {
    closeImg = SBG_SRC + '/assets/images/CloseButton.svg';
    adobeDataTextExit;
    businessAccountURL;
    adobeDataTextCancel = 'are you sure you want to leave | cancel button click';
    adobeDataTextExitApp = 'are you sure you want to leave | exit application button click';
    adobeDataTextExitModal = 'are you sure you want to leave | exit button click';
    isVisible;
    isRendered;
    isLoaded = true;
    @api teams = ["Self Assisted"];
    label = {};

    @api customContent;
    @track error;
    @track message;
    @track AOB_accountsUrl__c;
    @api applicationId;
    @api isShowingCloseButton;
    @api recordId;
    @api LWCFunction() {
        this.isVisible = true;
    }

    renderedCallback() {
        //Adobe screen load event called
        if (!this.isRendered) {
            loadScript(this, FireAdobeEvents)
                .then(() => {
                    this.isRendered = true;
                });
        }
    }
    handleResultChange(event) {
        this.label = event.detail;
        this.businessAccountURL=this.label.PBP_ZA_ProductSiteBaseURL + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';
    }

    /**
     * @description method to get the application data
     */
    getAppData() {
        // Set up the Adobe and other application information  
        getApplicationData({
            'applicationId': this.applicationId
        })
            .then(result => {
                this.message = this.label.AOB_Exit_Content.replace('{####}', result.daysUpToExpiry);
            })
            .catch(error => {
                this.isVisible = false;
                this.failing = true;
                this.errorMessage = getErrorMessage.call(this, error);
            })
    }

    /**
     * @description method to get the current screen and fire Adobe tagging
     */
    getAppDataAndFire(event) {
        // Set up the Adobe and other application information  
        getApplicationData({
            'applicationId': this.applicationId
        })
            .then(result => {
                event.target.dataset.intent = 'navigational';
                event.target.dataset.scope = result.productName + ' business application';
                event.target.dataset.scope = event.target.dataset.scope.toLowerCase();
                event.target.dataset.text = result.currentScreen + ' exit button click';
                event.target.dataset.text = event.target.dataset.text.toLowerCase();
                window.fireButtonClickEvent(this, event);
            })
            .catch(error => {
                this.isVisible = false;
                this.failing = true;
                this.errorMessage = getErrorMessage.call(this, error);
            })
    }

    get getOpenClosePageModal() {
        return this.isShowingCloseButton && this.openClosePageModal;
    }

    /**
     * @description method to handle exit of application.
     */
    exitApplication(event) {
        this.isLoaded = false;
        let url_string = window.location;
        let url = new URL(url_string);
        let urlHref = url.href;
        if (urlHref.includes('/s/aob-application/')) {
            const urlParts = urlHref.split('/');
            const aobIndex = urlParts.indexOf('aob-application');
            this.applicationId = urlParts[aobIndex + 1];
            createExternalLead({
                applicationId: this.applicationId,
                leadReason: 'Clicked Exit Button '
            }).then((result) => {
                this.navigateToAutomaticLead();
            }).catch((error) => {
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
            });
        }
        else{
            this.navigateToAutomaticLead();
        }
        window.fireButtonClickEvent(this, event);
        let channel = sessionStorage.getItem(CHANNEL_NAME_KEY);
        if (channel && channel == CHANNEL_NAME_VALUE_MALL) {
            this.navigateBackToBCBPlatform(channel);
        }
    }

    navigateToAutomaticLead() {
        this.isVisible = false;
        this.isLoaded = true;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'PreApplication_Automatic_Lead__c'
            }
        });
    }
    async navigateBackToBCBPlatform(channelName) {
        try {
            const mymobizManagementSettingByChannel = await getMymobizManagementSetting({ channelName: channelName });
            if (mymobizManagementSettingByChannel) {
                let channelSetting = { ...mymobizManagementSettingByChannel };
                sessionStorage.setItem(CHANNEL_NAME_KEY, "");
                if (channelSetting && channelSetting.Channel_URL__c) {
                    window.open(channelSetting.Channel_URL__c, "_self");
                }
            }
        } catch (error) {
            this.error = error;
        }
    }

    /**
     * @description method to handle cancel button.
     */
    closeModal(event) {
        window.fireButtonClickEvent(this, event);
        this.isVisible = false;
    }

    /**
     * @description method to handle exit from modal 
     */
    exitModal(event) {
        event.target.dataset.intent = 'navigational';
        event.target.dataset.scope = 'modal';
        event.target.dataset.text = this.adobeDataTextExitModal;
        window.fireButtonClickEvent(this, event);
        this.isVisible = false;
    }

    /**
     * @description method to handle exit pop-up window.
     */
    openPopup(event) {
        this.getAppDataAndFire(event);
        this.isVisible = true;
    }
}