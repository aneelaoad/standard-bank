import {
    LightningElement, api
} from 'lwc';

export default class OsbBannerLwc extends LightningElement {

    @api toasttype;
    @api bannerheader;
    @api bannermessage;
    toastSuccess = false;
    toastWarning = false;
    closeBanner() {
        const banner = this.template.querySelector('.bannerMessage');
        banner.style.display = 'none';
    }
    renderedCallback() {
        window.scrollTo(0, 0);
        let elementType = this.template.querySelector('[data-id="toast-type"]');
        if (this.toasttype === 'success') {
            elementType.classList.add('toast_success');
            this.template.querySelector('.core_border_colour').style = 'background: #36b66c;';
            this.toastSuccess = true;
        } else {
            elementType.classList.add('toast_warning');
            this.toastWarning = true;
        }
    }
}