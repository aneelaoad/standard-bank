import { LightningElement, api, wire } from 'lwc';
import notifcationEmpty from "@salesforce/resourceUrl/OSB_notificationsEmpty";
import getFeedItemsForUser from '@salesforce/apex/OSB_Notifications_CTRL.getFeedItemsForUser';
import getFeedItemsSearched from '@salesforce/apex/OSB_Notifications_CTRL.getFeedItemsSearched';
import removeNotificationEvent from '@salesforce/apex/OSB_Notifications_CTRL.removeNotification';
import { refreshApex } from '@salesforce/apex';
import { subscribe,publish, MessageContext } from 'lightning/messageService';
import eventChannelReceived from '@salesforce/messageChannel/osbInterCompEvent__c';
import { interactionSearch, pageViewSinglePageApp, addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbNotificationsLwc extends LightningElement {
    @api notifications;
    @api pages;
    @api currentPage;
    @api empty;
    @api notificationsList =[];

    OSB_notificationsEmpty = notifcationEmpty;
    appSolutions = [];
    regApps = [];
    searchedSolutions = [];
    noSearchResults;
    appSolutionDisplay = false;
    appCategories = [];
    noFilteredSolutions = false;
    Applicationsubscription = null;
    searchInputSaved;
    refreshResult;
    refresh = false;
    refreshRegisteredResult;
    recordAdded;
    fullListApp;
    currentCategories;
    showPopUp = false;
    resultCount = 0;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.handleSubscribe();
        //pageViewSinglePageApp('notifications');
    }

    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }

    handleSubscribe() {
        if (this.subscription) {
          return;
        }
        this.subscription = subscribe(this.messageContext,eventChannelReceived,(message) => {
            if (message.ComponentName == "Notifcations Refresh") {
                this.refresh = true;
                this.refrehsHandler();
            }
          });
    }

    refrehsHandler() {
        return refreshApex(this.refreshResult);
    }

    @wire(getFeedItemsForUser)retrievedFeedItems(result){
        this.refreshResult = result;
        this.notifications = result.data;
        if(result.data){
            this.pages = true;
            this.notificationsList = result.data;
            let searchFor = true;
            if(result.data.length >= 1){
               this.empty = false; 
            }
            if(this.refresh){
                this.template.querySelector('c-osb-paginationlwc').handleChanges(this.notificationsList,searchFor); 
            }
        }else{
            this.empty = true;
        }
    }

    searchForNotifcations(){ 
        let searchInputField = this.template.querySelector(`[data-id="searchInput"]`);
        let searchInput = searchInputField ? searchInputField.value : "";
        searchInput = searchInput.toLowerCase();
        this.searchInputSaved = searchInput;
        this.appSolutionDisplay = true;
        if((searchInput) && (searchInput.length>1)){
            this.searchedSolutions = [];
            this.noSearchResults = false;
            getFeedItemsSearched({searchKeyword: searchInput})
            .then(data => {
                if(data){
                    if(data.length>0){
                        this.noSearchResults = false;
                        let searchFor = true;
                        this.resultCount = data.length;
                        this.template.querySelector('c-osb-paginationlwc').handleChanges(data,searchFor );
                    } else{
                        this.noSearchResults = true;
                        this.appSolutionDisplay = false;
                    }
                }
            })
        }else{
            let searchFor = false;
            this.noSearchResults = false;
            this.appSolutionDisplay = true;
            this.template.querySelector('c-osb-paginationlwc') ? this.template.querySelector('c-osb-paginationlwc').handleChanges(this.notificationsList,searchFor) : '';
        }
    }

    removeAllNotification(){
        this.showPopUp = true;
    }

    handleCloseEvent(event){
        if(event.detail == 'NO'){
            this.showPopUp = false; 
        }else{
            let notId = null;
            removeNotificationEvent({recordId: notId, deleteAll: true}).then((data) => {
                const payload = {
                    ComponentName: 'Notifcations Refresh',
                    Details: {
                        Notification: 'Refresh'
                    }
                };
                publish(this.messageContext, eventChannelReceived, payload);
                this.showPopUp = false;
                this.empty = true;
            });
        }  
    }

    publishToAdobeClickSearch(){
        let eventData = {searchTerm : this.searchInputSaved,searchResult: this.resultCount,linkScope: 'Notifications'};
        interactionSearch(eventData);
    }
}