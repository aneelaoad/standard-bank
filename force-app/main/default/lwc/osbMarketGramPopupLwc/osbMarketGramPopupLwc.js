import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CASE_OBJECT from '@salesforce/schema/Case';
import saveCase from '@salesforce/apex/OSB_MarketGramPopup_Ctrl.saveCase';

export default class Osb_MarketGramPopup extends NavigationMixin(LightningElement){

    displayPopUp = true;
    @api loading;
    @api userMap;
    @api icon;
    @api title;
    @api content;
    @api signUp;
    QueryTypes = [{'label': 'Incorrect credentials', 'value': 'Incorrect credentials'},
                  {'label': 'I’m not interested ', 'value': 'I’m not interested '},
                  {'label': 'Other', 'value': 'Other'}
                 ];
    DefaultType = 'Incorrect credentials';
    @api showLoading = false;

    dispatchChangePopUpPageEvent (pageNumber, isNextPage) {
        this.dispatchEvent(new CustomEvent('changePopUpPageEvent', { "pageNumber": pageNumber, "isNextPage":isNextPage}));
    }

    dispatchClosePopUpEvent (optionSelected) {
        this.dispatchEvent(new CustomEvent('closepopupevent', { "optionSelected": optionSelected}));
    }

    handleClose (event) {
        this.displayPopUp = false;
        this.dispatchEvent(new CustomEvent('closepopupevent', { detail: event.target.innerText }));
    }
    
    handleSign (event){
        this.showLoading = true;
        this.displayPopUp = false;
        this.loading = true;
        let userMap = this.userMap;
        let newCase = CASE_OBJECT;
        let subject = 'OneHub Authorised Person Sign Up Cancellation ';
        let origin = "Web";
        let status = "New";
        newCase.Origin = origin;
        newCase.Status = status;
        newCase.SuppliedEmail = userMap[0].Email;
        newCase.SuppliedName = userMap[0].FirstName + '' + userMap[0].LastName;
        newCase.SuppliedPhone = userMap[0].Phone;
        let choice = this.template.querySelector('[data-id="queryType"]').value;
        newCase.Description = choice;
		newCase.Subject = subject;
        newCase.ContactId = userMap[0].Id;
        this.createCase(newCase);
        this.dispatchEvent( new CustomEvent('dispatchClosePopUpEvent', { "optionSelected":event.detail}));
    }
    
    createCase (newCase) {
        let userMap = this.userMap;
        saveCase({
            "MarketGramCase": newCase,
            "IdentityNum": userMap[0].Identity_Number__c,
            "PassNum": userMap[0].OSB_Passport_Number__c
        }).then(result => {
            this.showLoading = false
            this.redirect();
        })
    }
    
    redirect(){
        this[NavigationMixin.Navigate]({
            type:'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
    
    handleClearForm () {
        this.displayPopUp = false;
        window.open(window.location.href);
    }

     scrollToTile (element, window) {
        let fromTop = window.scrollY;
        let windowHeight = window.innerHeight - 80;
        let scrollRequired = false;
        if( element.offsetTop > fromTop + windowHeight || element.offsetTop < fromTop || element.offsetTop + element.offsetHeight > windowHeight) {
            window.scrollTo(0, element.offsetTop - 16);
            scrollRequired = true;
        }
        return scrollRequired;
    }
}