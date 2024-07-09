import { LightningElement } from 'lwc';

import mallHomeBusinessBanner from "@salesforce/resourceUrl/mallHomeBusinessBanner";

export default class MallSolutionsBanner extends LightningElement {

    businessBanner = mallHomeBusinessBanner + '/mall_business_banner.jpg';


    get backgroundImageStyle() {
        return `background-image: url(${businessBanner})`;
    }

}