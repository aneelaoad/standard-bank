import { LightningElement, api } from 'lwc';

export default class OsbToastComponentLwc extends LightningElement {
    @api
    toastType;

    @api
    toastMessage;

    @api
    closePopup;

    @api
    top;

    @api
    left;

    @api
    showToast(message, type) {
        window.scrollTo(0, 0);
        this.toastType = type;
        this.toastMessage = message;
        setTimeout(function () {
            this.showMessageToast = false;
        }, 10000);

    }

    get closePopup_equals_boolean_true() {
        return this.closePopup === true;
    }

    get string_top__plus_v_top_plus_string() {
        return "top:" + this.top + ";left:" + this.left;
    }

    get toastType_equals_success___toast_success___toast_warning() {
        return this.toastType === "success' ? 'toast_success' : 'toast_warning";
    }

    get toastType_equals_string_success___toast__success_left___toast_warning_left() {
        return this.toastType === "success' ? 'toast__success_left' : 'toast_warning_left";
    }

    get toastType_equals_success() {
        return this.toastType === "success";
    }

    closeToast(event) {
        this.closePopup = false;
    }
}