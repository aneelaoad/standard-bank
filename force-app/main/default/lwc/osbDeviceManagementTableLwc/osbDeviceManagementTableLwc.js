import { LightningElement, api } from "lwc";
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class ExampleLWC extends LightningElement {

    @api allDeviceAuthList = [];

    removeDevice = false;
    removeAllDevices = false;
    optionSelected;


    devicesToDeleteList = [];

    disconnectedCallback() {
        window.removeEventListener('message', this.receiveMessage);
    }

    connectedCallback() {
        this.init();
    }

    init(event) {
        let allDeviceAuthList = this.allDeviceAuthList;
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }

    confirmationPopupRemove(event) {
        this.removeDevice = false;
        let authIdToDelete = event.currentTarget.value;

        if (authIdToDelete) {
            this.removeDevice = true;
            let devicesToDeleteList = this.devicesToDeleteList;
            devicesToDeleteList.splice(0, devicesToDeleteList.length);
            if (devicesToDeleteList.length == 0) {
                devicesToDeleteList.push(authIdToDelete);

            }

        } else {
            this.removeDevice = false;
        }
    }

    handlePopupClose(event) {

        const optionSelected = event.detail;
        const devicesToDeleteList = this.devicesToDeleteList;

        if (optionSelected === "YES") {

            const selectedEvent = new CustomEvent('deletevent', {
                detail: [...this.devicesToDeleteList]

            });
            this.dispatchEvent(selectedEvent);

        } if (optionSelected === "NO") {

            const selectedEvent = new CustomEvent('closepopupevent', {
                detail: event.target.innerText

            });
            this.dispatchEvent(selectedEvent);
        }
        this.removeDevice = false;

    }


    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }
}