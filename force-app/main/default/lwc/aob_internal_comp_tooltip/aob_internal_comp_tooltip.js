import {
    LightningElement,
    api
} from 'lwc';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';

export default class Aob_internal_comp_tooltip extends LightningElement {
    infoIcon = THEME_OVERRIDES + '/assets/images/info_icon.svg';
    @api message;
    isRendered;
    renderedCallback() {
        if (!this.isRendered) {
            this.syncTooltip();
            window.addEventListener('resize', () => {
                this.syncTooltip();
                this.isRendered = true;
            });
        }
    }
    syncTooltip() {
        const tooltipContentElem = this.template.querySelector('.aob_tooltip_content');
        const tooltipContainerElem = this.template.querySelector('.aob_tooltip');
        const tooltipWidth = tooltipContentElem.getBoundingClientRect().width;
        const currentX = tooltipContainerElem.getBoundingClientRect().x;
        let newLeft = -(tooltipWidth * currentX / window.innerWidth);
        newLeft = this.checkAndGetLeft(newLeft, -tooltipWidth + 36, -18);
        tooltipContentElem.style.left = `${newLeft}px`;
    }
    checkAndGetLeft(newLeft, minLeft, maxLeft) {
       
        return newLeft > maxLeft ? maxLeft : newLeft < minLeft ? minLeft : newLeft;
    }
    getBackHoverAuto() {
    
    }
}