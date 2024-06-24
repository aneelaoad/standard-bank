import {LightningElement, api , wire} from 'lwc';
import updateNotification from '@salesforce/apex/OSB_Notifications_CTRL.markReadNotification';
import removeNotificationEvent from '@salesforce/apex/OSB_Notifications_CTRL.removeNotification';
import {NavigationMixin} from 'lightning/navigation';
import {publish, MessageContext} from 'lightning/messageService';
import eventChannelReceived from '@salesforce/messageChannel/osbInterCompEvent__c';

export default class OsbNotificationsItemLwc extends NavigationMixin(LightningElement) {
    @api notifications;
    @api classValue;
    @api empty;
    @api id;
    @api content;
    @api subtitle;
    @api date;
    @api isunread;
    dataText;
    @api title;
    ishidden = true;
    showPopUp = false;
    showToastSuccess = false;
    showToastFailure = false;

    @wire(MessageContext)
    messageContext;

    renderedCallback(){
        this.dataText = 'Notification Item | '+this.title;
    }

    navigateToNotifications(event){
        let index = event.target.dataset.index;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                url: "/s/notifications?index=" + index
            }
        });
    }

    toggle(event){
        let element = this.template.querySelector('[data-id="uitlink_link"]');
        if(this.ishidden){
           element.classList.remove('hidden');
        }else{
           element.classList.add('hidden');
        }
        this.ishidden = !this.ishidden;
        this.publishToAdobeClick(event);
    }

    updateNotificationEvent(){
        let notId = String(this.id.slice(0,18));
        updateNotification({recordId: notId});
        const payload = {
            ComponentName: 'Notifcations',
            Details: {
                Notification: 'Decrease'
            }
        };
        publish(this.messageContext, eventChannelReceived, payload);
    }

    removeNotification(event){
        this.publishToAdobeClick(event);
        this.showPopUp = true;   
    }

    handleCloseEvent(event){
        if(event.detail == 'YES'){
            let notId = String(this.id.slice(0,18));
            removeNotificationEvent({recordId: notId, deleteAll: false}).then((data,error) => {;
                const payload = {
                    ComponentName: 'Notifcations Refresh',
                    Details: {
                        Notification: 'Refresh'
                    }
                };
                publish(this.messageContext, eventChannelReceived, payload);
                this.showPopUp = false;
                this.showToastSuccess = true;
            });
        }else{
            this.showPopUp = false;
        }
    }

    publishToAdobeClick(event){
        document.dispatchEvent(new CustomEvent('triggerInteraction', {
            'detail': {
                eventName: 'flexiLinkTracking',
                linkIntent: event.currentTarget.dataset.intent,
                linkName: event.currentTarget.dataset.text+' link click',
                linkScope: 'Notifcations item'
            }
          }));
    }
}