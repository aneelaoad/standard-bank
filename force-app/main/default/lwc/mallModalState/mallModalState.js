import { LightningElement, api } from 'lwc';
const assetPath = "/sfsites/c/resource/sbgIcons/";

export default class MallModalState extends LightningElement {
    @api stateType;
    @api title;
    @api description;
    state;
    image;

    exclamationMark = assetPath + "ALERTSNOTIFICATION/icn_alert.svg";
    questionMark = assetPath + "NAVIGATIONVIEWS/icn_questionmark_standard.svg";
    tickMark = assetPath + "ALERTSNOTIFICATION/icn_check_normal.svg";
    yieldMark = assetPath + "ALERTSNOTIFICATION/icn_warning_outline.svg";

    createBackgroundImg(iconUrl) {
        return `background-image: url(${iconUrl}) ;`;
    }

    setState() {
        this.state = this.stateType
        switch (this.stateType) {
            case "error":
                this.image = this.createBackgroundImg(this.exclamationMark);
                break;
            case "info":
                this.image = this.createBackgroundImg(this.questionMark);
                break;
            case "success":
                this.image = this.createBackgroundImg(this.tickMark);
                break;
            case "warning":
                this.image = this.createBackgroundImg(this.yieldMark);
                break;

            default:
                this.image = this.createBackgroundImg(this.exclamationMark);
                break;
        }
    }

    connectedCallback() {
        this.setState();
    }
}