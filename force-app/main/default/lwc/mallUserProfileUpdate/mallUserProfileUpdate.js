import { LightningElement, api } from 'lwc';
import { getBaseUrl } from 'c/mallNavigation';
import sbgVisualAssets from '@salesforce/resourceUrl/sbgVisualAssets';
import MALL_PING_PROFILE_UPDATE_URL from '@salesforce/label/c.Mall_Ping_Profile_Update_Url';

export default class MallUserProfileUpdate extends LightningElement {
    @api buttonTitle = "Back to my profile";
    backIcon = sbgVisualAssets + '/icn_chevron_left.svg';
    isTrue = true;
    pingUserdetailsUpdateUrl = MALL_PING_PROFILE_UPDATE_URL;
    
    handleBackToProfile() {
        window.location.href = getBaseUrl() + '/mall/s/my-profile';
    }

    goBack() {
        history.back();
    }
}