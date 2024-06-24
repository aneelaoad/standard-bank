import { LightningElement, api } from 'lwc';
import RESOURCE_BASE_PATH from '@salesforce/resourceUrl/sbgVisualAssets';
export default class Acm_FourBlocksGH extends LightningElement {
    

    @api headerText;
    @api ShieldType;
    @api ACMHomepageicon1svg;
    @api ShieldBackingicon1svg;
    @api section1subtext1;
    @api section1subtext2;

    @api ACMHomepageicon2svg;
    @api section2subtext1;
    @api section2subtext2;

    @api ACMHomepageicon3svg;
    @api section3subtext1;
    @api section3subtext2;

    @api ACMHomepageicon4svg;
    @api section4subtext1;
    @api section4subtext2;

    
    get mainHeaderText() {
        return this.headerText;
    }
   
    // Section 1 
    get section1Image() {
        return RESOURCE_BASE_PATH + this.ACMHomepageicon1svg;
    }

    get shieldBackingImage() {
        return RESOURCE_BASE_PATH + this.ShieldBackingicon1svg;
    }

    get section1subtxt1() {
        return this.section1subtext1;
    }

    get section1subtxt2() {
        return this.section1subtext2;
    }

    // Section 2

    get section2Image() {
        return RESOURCE_BASE_PATH + this.ACMHomepageicon2svg;
    }

    get section2subtxt1() {
        return this.section2subtext1;
    }

    get section2subtxt2() {
        return this.section2subtext2;
    }

    // Section 3

    get section3Image() {
        return RESOURCE_BASE_PATH + this.ACMHomepageicon3svg;
    }

    get section3subtxt1() {
        return this.section3subtext1;
    }

    get section3subtxt2() {
        return this.section3subtext2;
    }

    // Section 4

    get section4Image() {
        return RESOURCE_BASE_PATH + this.ACMHomepageicon4svg;
    }

    get section4subtxt1() {
        return this.section4subtext1;
    }

    get section4subtxt2() {
        return this.section4subtext2;
    }
}