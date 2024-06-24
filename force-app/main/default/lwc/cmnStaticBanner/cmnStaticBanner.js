import { api, LightningElement } from 'lwc';
import STATIC_RESOURCE_URL from '@salesforce/resourceUrl/MallStaticBanners';

export default class CmnStaticBanner extends LightningElement {
    @api introTitle;
    @api mainTitle;
    @api spacerColour;
    @api paragraphText;
    @api buttonBGColour;
    @api buttonTextColour;
    @api buttonText;
    @api buttonLinkUrl;
    @api bgImageMobile;
    @api bgImageDesktop;

    backgroundImage;
    spacerStyle;
    buttonStyle;

    connectedCallback(){
        this.spacerStyle = 'background:' + this.spacerColour;
        this.buttonStyle = 'background:' + this.buttonBGColour + '; border:' + this.buttonBGColour + '; color:' + this.buttonTextColour + ';';

        const mq = window.matchMedia("(min-width: 768px)");
        mq.addEventListener("change", (event) => {
            this.handleSetBackground(event);
        });
        this.handleSetBackground(mq);
    }

    handleSetBackground(event){
        if(event.matches){
            this.backgroundImage = 'background-image: url('+ STATIC_RESOURCE_URL + '/' + this.bgImageDesktop + ')';
        }else{
            this.backgroundImage = 'background-image: url(' + STATIC_RESOURCE_URL + '/' + this.bgImageMobile + ')';
        }
    }
}