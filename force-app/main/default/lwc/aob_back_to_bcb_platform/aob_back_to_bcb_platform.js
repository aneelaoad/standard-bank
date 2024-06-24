import { LightningElement, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getMymobizManagementSetting from '@salesforce/apex/AOB_CTRL_BackToBCBPlatform.getMymobizManagementSetting';
import Back_To_BCB_Platform_Message from '@salesforce/label/c.Back_To_BCB_Platform_Message';
import BCB_Platform_Trusted_Partners_Message from '@salesforce/label/c.BCB_Platform_Trusted_Partners_Message';

const CHANNEL_NAME_KEY = "channel";
const CHANNEL_NAME_VALUE_MALL = "mall";

export default class Aob_back_to_bcb_platform extends NavigationMixin(LightningElement) {

    showBanner = false;
    @track channelSetting;
    backToBCBPlatformMessage = Back_To_BCB_Platform_Message;
    trustedPartnerMessage = BCB_Platform_Trusted_Partners_Message;
    connectedCallback() {
        let channelName = this.getChannelName();
        if(channelName) {
            this.getMymobizManagementSettingByChannel(channelName);
        }
    }

    getChannelName() {
        const path = window.location.href;
        const urlParams = this.getParameters(path);
        let channelName = '';
        if(urlParams.length) {
            for(let row=0; row< urlParams.length; row++) {
                if(urlParams[row].key == CHANNEL_NAME_KEY && urlParams[row].value) {
                    channelName = urlParams[row].value;
                    break;
                }
            }
        }
        return channelName;
    }

    async getMymobizManagementSettingByChannel(channelName) {
        try{
            const mymobizManagementSettingByChannel = await getMymobizManagementSetting({channelName : channelName});
            if(mymobizManagementSettingByChannel) {
                this.showBanner = true;
                this.channelSetting = {...mymobizManagementSettingByChannel};
                sessionStorage.setItem(CHANNEL_NAME_KEY, CHANNEL_NAME_VALUE_MALL);
            }
        } catch(error) {
            this.error = error;
        }
    }

    handleGotomall(event) {
        event.preventDefault();
        event.stopPropagation();
        if(this.channelSetting && this.channelSetting.Channel_URL__c) {
            this.navigateToWebPage(this.channelSetting.Channel_URL__c)
        }
    }

    navigateToWebPage(pageUrl) {
        this[NavigationMixin.GenerateUrl]({
          type: "standard__webPage",
          attributes: {
            url: pageUrl
          }
        }).then((generatedUrl) => {
          window.open(generatedUrl, "_self");
        });
    };

    getParameters(url) {
        let urlString = url;
        let paramString = urlString.split('?')[1];
        let queryString = new URLSearchParams(paramString);
        let urlParams = [];
        for(let pair of queryString.entries()) {
            let key = pair[0];
            let value = pair[1];
            let param = {key : key, value : value };
            urlParams.push(param);
        }
        return urlParams;
    }
}