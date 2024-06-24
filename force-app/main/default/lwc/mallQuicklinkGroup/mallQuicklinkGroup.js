import { LightningElement, api, wire,track } from 'lwc';
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
const MALL_NO_QUICKLINKS_MESSAGE = "You have removed all the quick links under this service. To add them back, select 'Configure'.";
const MALL_NO_QUICKLINKS_ADDED_TO_SERVICE_MESSAGE = "Your services will become available within 3-4 business days";
import {publish,MessageContext} from "lightning/messageService";
import MALL_PRE_NAVIGATION_EVT from "@salesforce/messageChannel/PreNavigationModal__c";
export default class MallQuicklinkGroup extends LightningElement {
    @api service;
    expanded = false;
    error;
    isHidden = !this.expanded;

    get id() { return this.service.id }
    get title() { return this.service.title }
    get imgUrl() { return this.service.imageUrl }
    get collection() {
        return this.setCollection(this.service.savedLinks);
    }

    @wire(MessageContext)
    messageContext;

    setCollection(data) {
        let collection = data.map((item) => {
            return {
                ...item,
                linkIcon: this.createBackgroundImg(item.icon)
            }
        })
        return collection;
    }

    createBackgroundImg(iconUrl) {
        return `background-image: url(${iconUrl}) ;`;
    }

    toggleAccordion() {
        this.expanded = !this.expanded;
        this.isHidden = !this.expanded;
    }

    removeLink(event) {
        this.dispatchEvent(new CustomEvent('removelink', {
            detail: event.target.dataset.linkid
        }));
    }

    get noQuicklinksMessage() {
        if (!this.service.hasUserSavedLinks && this.service.hasQuickLinks) {
            return MALL_NO_QUICKLINKS_MESSAGE;
        }
        else if (!this.service.hasUserSavedLinks && !this.service.hasQuickLinks) {
            return MALL_NO_QUICKLINKS_ADDED_TO_SERVICE_MESSAGE;
        }
    }

    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }

    /**
     * The function `navigateToLink` prevents the default behavior of a click event, sanitizes a URL,
     * and publishes an event with the sanitized URL and store name.
     * @param event - The event parameter is the event object that is passed to the function when the
     * event is triggered. It contains information about the event, such as the target element and any
     * data associated with it.
     */
    navigateToLink(event){
        event.preventDefault();
        try{
            publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {"targetUrl" : this.sanitizeUrl(event.target.dataset.url), "storeName" : this.service.title});
        }
        catch(error){
            this.error = error;
        }
    }

    sanitizeUrl(url){
        return url.replace(/[^A-Za-z0-9\/\:\.\-\=\&\#\?\_]/g, '');	
    }
}