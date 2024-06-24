import { LightningElement } from 'lwc';
import OSB_Images from '@salesforce/resourceUrl/OSB_Images_Three';
import { addAnalyticsInteractions, pageViewSinglePageApp } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbWyzetalkSitePage extends LightningElement {
    vodacomLogo = OSB_Images + '/VodacomLogo.png';
    WyzeLogo = OSB_Images + '/WyzeLogo.png';
    BannerImage = OSB_Images + '/Wyze-MainBanner.png';
    DSProduct = OSB_Images + '/Wyze-DS.png';
    PAProduct = OSB_Images + '/Wyze-PA.png';
    PSProduct = OSB_Images + '/Wyze-PS.png';
    BenefitProduct = OSB_Images + '/Wyze-BOTP.png';
    RequestButtonAdobe;
    ReturnButtonAdobe;
    
    connectedCallback(){
        let pagename =  ' Wyzetalk | Splash page';
        this.RequestButtonAdobe =  " Wyzetalk | request access";
        this.ReturnButtonAdobe =  "Wyzetalk | return to Onehub";
        pageViewSinglePageApp(pagename);
    }

    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }
}