import { LightningElement, api } from 'lwc';
import Assets from '@salesforce/resourceUrl/GettingStarted';

export default class AcmGettingStartedBanner extends LightningElement {
    @api title;
    @api subtext;
    @api bannerImage;
    @api bannerImgSource

    get bannerImg() {
        this.bannerImgSource = Assets + '/getting-started-icons/';
        return this.bannerImgSource + this.bannerImage;
    }

}