import { LightningElement } from 'lwc';
import IS_GUEST from '@salesforce/user/isGuest';
import { NavigationMixin } from "lightning/navigation";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import MALL_SIGN_UP from '@salesforce/label/c.MALL_SIGN_UP';
import MALL_SIGN_UP_TEXT from '@salesforce/label/c.MALL_SIGN_UP_TEXT';
import MALL_BECOME_A_PARTNER from '@salesforce/label/c.MALL_BECOME_A_PARTNER';
import { getCookie, putCookie } from "c/cmnCookieUtils";


export default class MallSignUpFooter extends NavigationMixin(LightningElement) {

    isGuestUser = false;
    signUpText = MALL_SIGN_UP_TEXT;
    navigateToWebPage = navigateToWebPage.bind(this);
    registerButton = MALL_SIGN_UP;
    becomeAPartnerButton = MALL_BECOME_A_PARTNER;

    connectedCallback() {
        this.isGuestUser = IS_GUEST;
    }

    handleSignUp(e) {
        e.preventDefault();
        putCookie("userDesiredPage",getBaseUrl() + "/mall/s/");
        putCookie('redirectToUserDesiredPage','true');
        putCookie('redirectToExternalShopPage','true');
        this.navigateToWebPage(getBaseUrl() + "/mall/s/sign-up");
    }

    handleBecomeAPartner(e) {
        e.preventDefault();
        this.navigateToWebPage(getBaseUrl() + "/mall/s/partner-with-us");
    }
}