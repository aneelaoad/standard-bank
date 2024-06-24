import { LightningElement, api } from 'lwc';

export default class OsbBenefitsContainerlwc extends LightningElement {

    @api imageOne;
    @api benefitsOne;
    @api imageTwo;
    @api benefitsTwo;
    @api imageThree;
    @api benefitsThree;
    @api imageFour;
    @api benefitsFour;
    @api background;
    @api backgrndColorOne;
    @api backgrndColorTwo;
    @api backgrndColorThree;
    @api backgrndColorFour;
    @api backgroundColor = '#F1F1F1;';

    renderedCallback() {
        this.template.querySelector('[data-id="teaserosbBen"]').style.backgroundColor = this.backgroundColor;
        this.template.querySelector('[data-id="benefitContainerOne"]').style.backgroundColor = this.backgrndColorOne;
        this.template.querySelector('[data-id="benefitContainerTwo"]').style.backgroundColor = this.backgrndColorTwo;
        this.template.querySelector('[data-id="benefitContainerThree"]').style.backgroundColor = this.backgrndColorThree;
        this.template.querySelector('[data-id="benefitContainerFour"]').style.backgroundColor = this.backgrndColorFour;
    }
}