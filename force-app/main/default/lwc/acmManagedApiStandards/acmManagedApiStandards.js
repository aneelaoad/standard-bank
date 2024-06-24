import { LightningElement, api } from 'lwc';
import RESOURCE_BASE_PATH from '@salesforce/resourceUrl/ACM_Assets';

export default class AcmManagedApiStandards extends LightningElement {
    @api title;
    @api subtitle;
    @api buttonLabel;
    @api buttonLink;
    
    @api bannerTitle;
    @api bannerSubtitle;
    @api bannerButtonLabel;
    @api bannerbuttonLInk;
    @api image;

    get banner() {
        return RESOURCE_BASE_PATH + this.image;
    }
    
}