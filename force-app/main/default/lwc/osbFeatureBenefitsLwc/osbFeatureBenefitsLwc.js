import { LightningElement ,api} from 'lwc';

export default class OsbFeatureBenefitsLwc extends LightningElement {
    @api textOnRight;
    @api title;
    @api mainContent;
    @api subContent;
    @api backgroundColor ='#ffffff';
    @api videolink;
    @api ImageUrl;
    @api showVideo ='false';
    @api showImage ='false';
    @api ImageStyle;
    image;
    logo;

    renderedCallback(){
        if(this.textOnRight == false){
            let element = this.template.querySelector('[data-id="text-on-right"]');
            element.classList.remove(...element.classList);
            element.classList.add('teaser__columns');
            element.classList.add('slds-grid');
        }
        this.template.querySelector('[data-id="teaserosb"]').style.backgroundColor = this.backgroundColor;
    }
}