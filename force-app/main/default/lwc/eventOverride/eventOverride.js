/**
 * @description       : Use to override action on the Event object and redirect to the correct UI
 * @author            : Derek Hughes
 * @group             : UI
 * @last modified on  : 07-04-2023
 * @last modified by  : Derek Hughes
**/
import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getActionOverride from '@salesforce/apex/CTRL_EventOverrideAction.getActionOverride';

import USER_ID from '@salesforce/user/Id';

const ACTIONS = { NEW : 'new', EDIT : 'edit', VIEW : 'view'}

export default class EventOverride extends NavigationMixin(LightningElement) {

    @api action;
    @api recordId;
    @api recordTypeId;
    callReportId;
    urlNewLegacy;
    urlEditLegacy;

    userName;
    userProfileName;

    get pageType() {
        if (this.action === ACTIONS.NEW) {
            return 'standard__objectPage';
        }
        else if (this.action === ACTIONS.VIEW || this.action === ACTIONS.EDIT) {
            return 'standard__recordPage';
        }
        return '';
    }

    prNewLegacy;
    prEvent;
    prCallReport;
    prFinal;

    urlEvent;
    urlCallReport;
    urlFinal;
    urlReturn;

    error;
    errorMessage;
    prInContextOf;
    get currentPage() {return JSON.stringify(this.currentPageRef);}
    get inContextOfPage () {return JSON.stringify(this.prInContextOf);}

    @wire(CurrentPageReference)
    currentPageRef;

    /*
     * Logic Flow - asynchrounous processes chained together
     *
     * 1. connectedCallBack - ends with a prmoise then calls getActionOverride
     * 2. getActionOverrid - after it received data it calls generatePageRefs
     * 3. generatePageRefs - ends with a promise then calls setUrlFinal
     * 4. setUrlFinal - calls doRedirect
     * 5. doRedirect
     * 
     */

    connectedCallback() {

        // get the current page reference from the URL an decode it to get the return URL is any
        let base64Context = this.currentPageRef.state.inContextOfRef;
        if (base64Context) {
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
            this.prInContextOf = JSON.parse(window.atob(base64Context));

            this[NavigationMixin.GenerateUrl](this.prInContextOf).then(url => {
                this.urlReturn = url;
                this.getActionOverride();
            });
        }
        else {
            this.getActionOverride();
        }

    }

    renderedCallback() {
        if (this.action===ACTIONS.EDIT && this.urlFinal) {
            this.doRedirect();
        }
    }
    
    getActionOverride() {

        getActionOverride({actionName: this.action, eventId: this.recordId, userId: USER_ID})
            .then(result => {
                this.userName = result.userName;
                this.userProfileName = result.profileName;       
                this.callReportId = result.callReportId;
                this.urlNewLegacy = result.overrideUrl;
             
                this.generatePageRefs();
            })
            .catch(error => {
                this.error = error;
                this.errorMessage = error.body.message;
                this.showToast('error', 'sticky', 'SYSTEM ERROR', this.errorMessage);
            });
    }

    generatePageRefs() {

        let p0;
        let p1;

        this.prNewLegacy = {
            type: 'standard__webPage',
            attributes: {
                url: this.urlNewLegacy
            }
        }

        this.prEvent = {
            type: this.pageType,
            attributes: {
                objectApiName: 'Event',
                recordId: this.recordId,
                actionName: this.action
            },
            state: {
                nooverride: 'true',
                inContextOfRef: this.currentPageRef.state.inContextOfRef,
                navigationLocation: this.currentPageRef.state.navigationLocation,
                backgroundContext: this.urlReturn
            }
        };

        p0 = this[NavigationMixin.GenerateUrl](this.prEvent);
        
        if (this.callReportId) {
            this.prCallReport = {
                type: this.pageType,
                attributes: {
                    objectApiName: 'Call_Report__c',
                    recordId: this.callReportId,   
                    actionName: this.action
                },
                state: {
                    inContextOfRef: this.currentPageRef.state.inContextOfRef,
                    navigationLocation: this.currentPageRef.state.navigationLocation,
                    backgroundContext: this.urlReturn
                }
            };
            p1 = this[NavigationMixin.GenerateUrl](this.prCallReport);
        }


        Promise.all([p0, p1]).then((results) => {
            this.urlEvent = results[0];
            this.urlCallReport = results[1];
            this.setUrlFinal();
        });

    }

    setUrlFinal () {

        if (this.action===ACTIONS.NEW) {
            if (this.userProfileName==='BCC AR Custom Std User - Mobile') {
                this.urlFinal = this.urlEvent;
                this.prFinal = this.prEvent;
            }
            else {
                this.urlFinal = this.urlNewLegacy;
                this.prFinal = this.prNewLegacy;
                }
            }
        else { // "edit" or "view"
            //if there is a call report then redirect to that, otherwise redirect to event itself
            if (this.prCallReport) {
                this.urlFinal = this.urlCallReport;
                this.prFinal = this.prCallReport;
            }
            else {
                this.urlFinal = this.urlEvent;
                this.prFinal = this.prEvent;
            }
        }

       this.doRedirect();  
      
    }

    doRedirect() {
        this[NavigationMixin.Navigate](this.prFinal);
    }

    showToast(variant, mode, title, message) {
        const toastEvent = new ShowToastEvent({
          title,
          variant: variant,
          mode: mode,
          message: message
        })
        this.dispatchEvent(toastEvent)
    }

}