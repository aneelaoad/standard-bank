import { LightningElement, track, api } from 'lwc';

export default class MallToastNotifcation extends LightningElement {

    @track type;
    @track message;
    @track notificationList = [];
    @track showToastBar = false;
    @api autoCloseTime = 5000;
 
    @api
    showToast(type, message, header) {
        var random = Math.random();
        let notification = {
            'type' : type,
            'message' : message,
            'header' : header,
            'index' : random,
            'iconName' : 'utility:' + type,
            'outerClass': 'slds-notify slds-notify_toast slds-theme_' + type,
            'innerClass': 'slds-icon-utility-' + type + ' slds-m-right_small slds-no-flex slds-align-top'
        };
        let toastList = this.notificationList;
        toastList.push(notification);
        this.notificationList = toastList; 
        setTimeout(() => {
            this.closeToast(random);
        }, this.autoCloseTime);
    }
 
    close(event) {
        this.closeToast(event.currentTarget.name);
    }
    
    closeToast(rowNum) {
        var index = this.notificationList.findIndex(x => x.index === rowNum)
        if(index != -1)
            this.notificationList.splice(index, 1);
    }
}