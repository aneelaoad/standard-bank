import { LightningElement } from 'lwc';
import { getBaseUrl } from "c/mallNavigation";

export default class MallModalUserConsent extends LightningElement {

    topParagraph = "We understand that your personal information is important to you. By using our products, you acknowledge that your personal information will be processed by us and third parties (if necessary) according to our Privacy Statement, which is in line with all applicable laws on protecting and processing personal information.";
    bottomParagraph = "Please note that you have the right to change your consent and preferences at any time in the future at any branch, by contacting your relationship manager, calling us on 0860 123 000, emailing us on info@bcbplatform.co.za or logging in to our banking channels to update your preferences.";

    // Add variable for links
    
    seeMore(event) {
        let elementTarget = event.target;
        if (elementTarget.previousElementSibling.classList.contains("consent-modal--hiddenContent-open")) {
            elementTarget.previousElementSibling.classList.remove("consent-modal--hiddenContent-open");
        }else{
            elementTarget.previousElementSibling.classList.add("consent-modal--hiddenContent-open");
        }
    }

    
    value = '';

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

      handleRedirectUrlToAboutUs(event) {
        event.preventDefault();
        const aboutUsUrl = getBaseUrl() + "/mall/s/about-us/";
        window.open(aboutUsUrl, "_blank");
      }

















}