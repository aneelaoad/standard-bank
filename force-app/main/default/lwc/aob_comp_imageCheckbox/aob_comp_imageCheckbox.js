import { LightningElement, api } from 'lwc';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
export default class Aob_comp_imageCheckbox extends LightningElement {

    @api imageLink = THEME_OVERRIDES + "/assets/images/snapScan.png";
    @api imageLink1 = THEME_OVERRIDES + "/assets/images/SnapScan1.png";
    @api imageHeading;
    @api imageName;
    @api formDetails = {};
    @api totalArray = [];
    @api imagedata;
    @api imageSource;
    connectedCallback() {
        this.imageSource = this.imageLink;
        if (this.imageName == 'receiveOnline') this.imageSource = this.imageLink1;
        if (this.imageName == 'receiveInStore') this.imageSource = this.imageLink;
    }
    selectedCheckHandler(event) {
        let name = event.target.name;
        let value = event.target.checked;

        this.formDetails[name] = value;
        this.totalArray.push(this.formDetails);

        const bundleClick = new CustomEvent('send',
            { detail: { formName: name, checkboxc: event.target.checked } }
        );
        this.dispatchEvent(bundleClick);
    }


}