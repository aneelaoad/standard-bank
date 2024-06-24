import { LightningElement, api } from 'lwc';

export default class Acm_TitleWithSubtitle extends LightningElement {
    @api title;
    @api isPageTitle;
    @api showSubtitle;    
    @api subtitle;
    @api textAlignment;
    @api textColor;
    @api fontsize;
    @api titleFullWidth;

    getTextAlignment(){
        let alignmentName = 'justify-content-left';
        if (this.textAlignment === 'Center') {
            alignmentName = `justify-content-center`;
        } else if (this.textAlignment === 'Right') {
            alignmentName = `justify-content-right`;
        } 
        return alignmentName;
    }

    get getAlignment() {
        return `row ${this.getTextAlignment()}`;
    }

    get getTitleStyle() {
        
        return `margin-left: 0; text-align:${this.textAlignment}; color: ${this.textColor}; font-size: ${this.fontsize}`;
    }

    get getSubtitleStyle() {
        return `color: ${this.textColor}`;
    }

    get getTitleCol() {
        if(this.titleFullWidth){
            return `col col-12`;
        }        
        return `col col-12 col-md-8`;
    }
}