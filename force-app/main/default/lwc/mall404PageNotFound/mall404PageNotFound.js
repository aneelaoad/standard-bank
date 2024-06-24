import { LightningElement } from 'lwc';
import ERROR_IMAGES from "@salesforce/resourceUrl/errorImages";
// import { getBaseUrl } from "c/mallNavigation";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";

export default class Mall404PageNotFound extends LightningElement {
    
    error404Image = ERROR_IMAGES + '/404-error-image.png';
    goToHome = 'Go to our home page'
    navigateToWebPage = navigateToWebPage.bind(this);

    returnUrl = getBaseUrl() + "/mall/s/faq"
    homeUrl = getBaseUrl() + "/mall/s"

    gotToHome(e) {
        e.preventDefault();
        this.navigateToWebPage(getBaseUrl() + "/mall/s");
    }


}