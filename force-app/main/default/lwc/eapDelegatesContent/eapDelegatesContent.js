import { LightningElement, track, api } from 'lwc';
import getDelegates from '@salesforce/apex/EAP_CTRL_DelegatesPage.getDelegates';
import getFilters from '@salesforce/apex/EAP_CTRL_DelegatesPage.getFilters';
import SEARCH_LABEL from '@salesforce/label/c.Eap_Search_Label';
import ENTER_SEARCH_LABEL from '@salesforce/label/c.Eap_EnterSearch_Label';
import DELEGATES_LABEL from '@salesforce/label/c.Eap_Delegates_Label';
import ALL_DELEGATES_LABEL from '@salesforce/label/c.Eap_AllDelegates_Label';

export default class EapDelegatesContent extends LightningElement {
    labels = {Search: SEARCH_LABEL, EnterSearch: ENTER_SEARCH_LABEL, Delegates: DELEGATES_LABEL, AllDelegates:ALL_DELEGATES_LABEL};
    @track defaultDelegates = [];
    @track numberDelegates = this.defaultDelegates.length;
    @track delegates = this.defaultDelegates;

    filters = [];
    lookingfor = "";
    @track allFilters = [{Name: 'allDelegates', State: true, Reference: this.labels.AllDelegates}];

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
        this.loadFilters();
        this.loadEvent();
    }

    loadEvent(){
        getDelegates({eventId: this.eventId})
        .then((data) => {
            for(let i = 0; i < data.length; i++){
                let delegate = data[i];
                let delegateToInsert = {
                    Id: delegate.id,
                    Img: delegate.contactPhoto,
                    Name: delegate.name,
                    RolInEvent: delegate.roleInEvent,
                    ClientName: delegate.clientName
                };

                if (delegateToInsert.Img === null){
                    delegateToInsert.Initials = this.getInitials(delegateToInsert.Name);
                }
                this.defaultDelegates.push(delegateToInsert);
            }

            this.showDelegatesSortedByFilters();
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        })
        .catch((error) => {});

    }

    loadFilters(){
        getFilters({eventId: this.eventId})
        .then((data) => {
            for(let i = 0; i < data.length; i++){
                let filter = {Name: data[i].replace(' ', ''), State: false, Reference: data[i]}
                this.allFilters.push(filter);
            }
        })
        .catch((error) => {});
    }

    @track _isSortedByName;
    @track _isSortedAscending;

    @api 
    get isSortedByName(){
        return this._isSortedByName;
    }
    set isSortedByName(value) {
        this.setAttribute('v', value);
        this._isSortedByName = value;
        this.showDelegatesSortedByFilters();
    }

    @api
    get isSortedAscending(){
        return this._isSortedAscending;
    }
    set isSortedAscending(value) {
        this.setAttribute('v', value);
        this._isSortedAscending = value;
        this.showDelegatesSortedByFilters();
    }
    

    //This method select and apply the filters
    selectFilter(e){
        let name = e.target.name;
        let selectedFilter = this.getSelectedFilter(name);

        if (name === "allDelegates")
        {
            this.filters = []
            this.allFilters.forEach(filter => {
                filter.State = false;
            });
            this.allFilters[0].State = true;
            
        }else
        {
            //If it wasn't selected before this will select it and add it to the list of filter.
            //If it was selected then it will be unselected and removed from the list
            if (!selectedFilter.State)
            {
                this.filters.push(selectedFilter.Reference);
                selectedFilter.State = true;
                this.allFilters[0].State = false;
            
            }else {
                this.filters.splice(this.filters.indexOf(selectedFilter.Reference), 1);
                selectedFilter.State = false;

                if (this.filters.length === 0){
                    this.allFilters[0].State = true;
                }
            }
        }

        this.showDelegatesSortedByFilters();
    }

    getSelectedFilter(name){
        let selectedFilter;
        this.allFilters.forEach(filter => {
            if (filter.Name === name)
            {
                selectedFilter = filter;
            }
        });

        return selectedFilter;
    }

    showDelegatesSortedByFilters() {
        let orderedDelegates = [...this.defaultDelegates];

        //Find delegates
        if (this.lookingfor !== "")
        {
            orderedDelegates = orderedDelegates.filter(delegate => delegate.Name.toLowerCase().includes(this.lookingfor.toLowerCase()))
        }

        //Sort Delegates
        if (this.isSortedByName)
        {
            orderedDelegates.sort(this.compareName);
        }else
        {
            orderedDelegates.sort(this.compareCompany);
        }

        if (!this.isSortedAscending)
        {
            orderedDelegates.reverse();
        }
        
        //Filter delegates
        if (this.filters.length === 0)
        {
            this.delegates = orderedDelegates;
        
        }else{
            this.delegates = orderedDelegates.filter(delegate => this.filters.includes(delegate.RolInEvent));
        }
        this.numberDelegates = this.delegates.length;
    }

    compareName(delegateA, delegateB){
        if ( delegateA.Name < delegateB.Name )
            return -1;
        else if ( delegateA.Name > delegateB.Name )
            return 1;
        else
            return 0;
    }

    compareCompany(delegateA, delegateB){
        if ( delegateA.Name < delegateB.Name )
            return -1;
        else if ( delegateA.Name > delegateB.Name )
            return 1;
        else
            return 0;
    }

    findDelegate(e) {
        this.lookingfor = this.template.querySelector("[name='searchDelegate']").value;
        this.showDelegatesSortedByFilters();
    }

    getInitials(fullName){
        let fullNameArray = fullName.split(" ");
        let initials = '';

        fullNameArray.forEach(name => {
            initials += name[0];
        })

        return initials;
    }
}