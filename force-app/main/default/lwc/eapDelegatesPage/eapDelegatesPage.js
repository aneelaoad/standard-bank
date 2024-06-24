import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import DELEGATES_LABEL from '@salesforce/label/c.Eap_Delegates_Label';
import TITLE_SORT_LABEL from '@salesforce/label/c.Eap_SortResult_Label';
import APPLY_ORDER_LABEL from '@salesforce/label/c.Eap_ApplyOrder_Label';
import FILTER_LABEL from '@salesforce/label/c.Eap_Filter_Label';

export default class EapDelegatesPage extends LightningElement {
    labels = {Title: DELEGATES_LABEL, ApplyOrder: APPLY_ORDER_LABEL, TitleSort: TITLE_SORT_LABEL, Filter: FILTER_LABEL};
    @track loading = true;

    @track title = this.labels.Title;
    @track showDelegates = true;
    @track showSortBy = false;
    @track isSortedByName = true;
    @track isSortedAscending = true;

    @track eventId;

    /* Receive event Id */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.eventId = this.urlStateParameters.eventId || null;
    }
    
    changeView(){
        if (this.showSortBy){
            this.loading = true;
            this.isSortedByName = this.template.querySelector('c-eap-delegates-sort').isSortedByName;
            this.isSortedAscending = this.template.querySelector('c-eap-delegates-sort').isSortedAscending;
            this.title = this.labels.Title;
        }else{
            this.title = this.labels.TitleSort;
        }

        this.showDelegates = !this.showDelegates;
        this.showSortBy = !this.showSortBy;
    }

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";
    }
}