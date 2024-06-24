/**
 * @description       : Use to override actions of the Opportunity object to redirect to the stadnard UI
 * @author            : Derek Hughes
 * @group             : UI
 * @last modified on  : 07-04-2023
 * @last modified by  : Derek Hughes
**/
import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

const ACTIONS = { NEW : 'new', EDIT : 'edit', VIEW : 'view'}

export default class OpportunityOverride extends NavigationMixin(LightningElement) {

    @api action;
    @api recordId;
    @api recordTypeId;

    prOpportunity;
    prFinal;
    prInContextOf;

    urlOpportunity;
    urlFinal;

    //FOR TESTING
    get currentPage() {return JSON.stringify(this.currentPageRef);}
    get inContextOfPage () {return JSON.stringify(this.prInContextOf);}

    get pageType() {
        if (this.action === ACTIONS.NEW) {
            return 'standard__objectPage';
        }
        else if (this.action === ACTIONS.VIEW || this.action === ACTIONS.EDIT) {
            return 'standard__recordPage';
        }
        return '';
    }

    @wire(CurrentPageReference)
    currentPageRef;

    connectedCallback() {
        
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
        if (this.action==='new' && this.urlFinal) {
            this.doRedirect();
        }
    }
    
    getActionOverride() {
        this.generatePageRefs();
    }

    generatePageRefs() {

        let p0;

        this.prOpportunity = {
            type: this.pageType,
            attributes: {
                objectApiName: 'Opportunity',
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

        p0 = this[NavigationMixin.GenerateUrl](this.prOpportunity);
        
        Promise.all([p0]).then((results) => {
            this.urlOpportunity = results[0];
            this.setUrlFinal();
        });

    }
    
    setUrlFinal () {

        this.urlFinal = this.urlOpportunity;
        this.prFinal = this.prOpportunity;
    
        this.doRedirect();  
    }
    
    doRedirect() {
        this[NavigationMixin.Navigate](this.prFinal);
    }

}