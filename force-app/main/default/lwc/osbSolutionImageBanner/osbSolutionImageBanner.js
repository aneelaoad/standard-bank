import { LightningElement, api, track } from 'lwc';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class osbSolutionImageBanner extends LightningElement {
    adobeText;
    @api link;
    @api linkLabel;
    @api imageId;
    @api textOnRight;
    @api title;
    @api mainContent;
    @api subContent;
    @api solutionLogo;
    @api backgroundColor ='#ffffff';
    @api videolink;
    @api showVideo ='false';
    @api btnColour;
    @api btnStyle = '12px';
    @api showOneHubBtn;
    @api btnStyleOneHub;
    image;
    logo;

    renderedCallback(){
        addAnalyticsInteractions(this.template);
        if(this.textOnRight == false){
            let element = this.template.querySelector('[data-id="text-on-right"]');
            element.classList.remove(...element.classList);
            element.classList.add('teaser__columns');
            element.classList.add('slds-grid');
        }
        this.template.querySelector('[data-id="teaserosb"]').style.backgroundColor = this.backgroundColor;
        this.adobeText = ('Landing Page | ' + this.title + ' | ' + this.linkLabel);    
    }
}