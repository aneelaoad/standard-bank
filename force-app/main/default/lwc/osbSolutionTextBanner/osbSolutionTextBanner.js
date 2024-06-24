import { LightningElement, api } from 'lwc';

export default class osbSolutionTextBanner extends LightningElement {
    @api leftContent;
    @api rightContent;
    @api swapTextSides = false;
    @api backgroundColor = '#ffffff';
    @api alignItemsVertically = false;
    @api alignItemsHorizontally = false;

    renderedCallback(){
        let element = this.template.querySelector('[data-id="text-on-right"]');
        if(this.swapTextSides == false){
            element.classList.remove(...element.classList);
            element.classList.add('teaser__columns');
            element.classList.add('slds-grid');
        }
        this.template.querySelector('[data-id="teaserosb"]').style.backgroundColor = this.backgroundColor;
        if(this.alignItemsVertically){
            element.classList.remove('teaser__columns');
            element.classList.add('teaser__columns_vertically');
            let contentLeft = this.template.querySelector('[data-id="content-left"]');
            contentLeft.classList.remove('slds-large-size_6-of-12');
            contentLeft.classList.add('slds-large-size_12-of-12');
            let contentRight = this.template.querySelector('[data-id="content-right"]');
            contentRight.classList.remove('slds-large-size_6-of-12');
            contentRight.classList.add('slds-large-size_12-of-12');
        }
    }
}