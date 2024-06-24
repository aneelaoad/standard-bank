import { api, LightningElement } from 'lwc';

export default class OsbapiProductFeatureTile extends LightningElement {

    @api title;
    @api imageLink;
    @api description;
    @api hasIcon;  
    icon = '';
    displayIcon = false;

    cleanUpImageLink(data) {
        let tempArr = data.split('(');
        tempArr[1] = tempArr[1].slice(0 , -1);
        return tempArr[1];
    }

    checkIcon() {
        this.displayIcon = (this.hasIcon === 'true');
    }

    connectedCallback() {
        this.checkIcon();
        if (this.imageLink !== '') {
            this.icon = this.cleanUpImageLink(this.imageLink);
        }
    }

}