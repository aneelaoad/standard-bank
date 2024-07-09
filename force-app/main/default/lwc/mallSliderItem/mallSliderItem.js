import { LightningElement, api } from 'lwc';
import benefitsIcons from "@salesforce/resourceUrl/mallBenefits";

export default class MallSliderItem extends LightningElement {
    slideIndex = 1;
    slides = [];

    @api
    get slidesData() {
        return this.slides;
    }

    set slidesData(data) {
        this.slides = data.map((slide, i) => {
            if (i === 0) {
                return {
                    ...slide,
                    index: i + 1,
                    slideClass: 'fade slds-show',
                    dotClass: 'dot active',
                    iconURL: benefitsIcons+slide.imageURL
                };
            }
            return {
                ...slide,
                index: i + 1,
                slideClass: 'fade slds-hide',
                dotClass: 'dot',
                iconURL: benefitsIcons+slide.imageURL
            };
        });
    }
}