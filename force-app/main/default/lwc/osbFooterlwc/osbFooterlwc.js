import { LightningElement, api, wire } from 'lwc';
import footerStatic from "@salesforce/resourceUrl/OSB_FooterImages";
import {addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbFooterlwc extends LightningElement {
    google = footerStatic + '/GoogleFooter.svg';
    appStore = footerStatic + '/AppleFooter.svg';
    ipads= footerStatic + '/FooterImage.png';
    @api terms;
    @api legal;
    @api notices;
    @api certification;
    @api questionnaire;
    @api privacy;
    @api securitycentre;
    @api regulartory;
    


    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }
}