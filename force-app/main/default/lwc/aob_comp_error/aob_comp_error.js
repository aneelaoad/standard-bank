import { LightningElement, api,track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getMymobizManagementSetting from '@salesforce/apex/AOB_CTRL_BackToBCBPlatform.getMymobizManagementSetting';

const CHANNEL_NAME_KEY = "channel";
const CHANNEL_NAME_VALUE_MALL = "mall";

export default class Aob_comp_error extends NavigationMixin(LightningElement) {

    @api teams = ["Self Assisted"];
    label = {};
    backtobrowsin;
    @api content;
    @api technical;
    @api productName;
    @api applicationId;
    businessAccountURL;
    @track iconSize ="medium";
    adobePageTag = {
     
        dataId: "link_content",
        dataIntent: "navigational",
        dataScope: "",
        cancelButtonText: " Technical difficulties | "+this.backtobrowsin+" button click",
        continueButtonText: " Technical difficulties | "+this.label.AOB_ZA_RETR+" button click",
        privacyintent: "informational",
        privacyscope: "mymobiz application",
        privacylinkclick: "pre application | privacy statement link click",
        siteErrorCode: "",
        application: {
            applicationProduct: "Preapplication",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Preapplication",
            applicationStep: "",
            applicationStart: true,
            applicationComplete: false,
        },
    };

    closeModal(event) {
        this.technical = false;
        const selectedEvent = new CustomEvent("cancel", {
            detail: 'cancelled'
        });
        this.dispatchEvent(selectedEvent);
    }
    
   
    connectedCallback() {
        this.adobePageTag.dataScope=this.productName +' application';
        if (window.matchMedia("(max-width: 768px)").matches) {
            this.iconSize ="x-small";
        }
     }

    handleGoNext() {
        window.open(this.commerceSite, "_self");
    }

    retryAPI(event) {
        window.fireButtonClickEvent(this, event);
        const selectedEvent = new CustomEvent("retry", {
            detail: 'retryselected'
        });
        this.dispatchEvent(selectedEvent);

    }
    
    backhome(event) {
        window.fireButtonClickEvent(this, event);
        let channel = sessionStorage.getItem(CHANNEL_NAME_KEY);
        if(channel && channel == CHANNEL_NAME_VALUE_MALL) {
            this.navigateBackToBCBPlatform(channel);
        } else {
            window.open(this.businessAccountURL, '_self');
        }
    }

    async navigateBackToBCBPlatform(channelName) {
        try{
            const mymobizManagementSettingByChannel = await getMymobizManagementSetting({channelName : channelName});
            if(mymobizManagementSettingByChannel) {
                let channelSetting = {...mymobizManagementSettingByChannel};
                sessionStorage.setItem(CHANNEL_NAME_KEY, "");
                if(channelSetting && channelSetting.Channel_URL__c) {
                    window.open(channelSetting.Channel_URL__c, "_self"); 
                }
            }
        } catch(error) {
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorCodeEvent(this, this.errorMessage);
        }
    }


    handleResultChange(event) {
        this.label = event.detail;
        this.backtobrowsin=this.label.AOB_ZA_backtobrowsin;
        this.businessAccountURL=this.label.PBP_ZA_siteURL + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';
    }
}