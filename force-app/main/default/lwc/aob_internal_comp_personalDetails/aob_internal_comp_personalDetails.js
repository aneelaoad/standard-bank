import {
    LightningElement,
    api,
    track
} from 'lwc';

import AOB_PersonalDetails_title from '@salesforce/label/c.AOB_PersonalDetails_title';
import AOB_PersonalDetails_subTitle from '@salesforce/label/c.AOB_PersonalDetails_subTitle';
import AOB_CITIZENSHIP from '@salesforce/label/c.AOB_CITIZENSHIP';
import AOB_NATIONALITY from '@salesforce/label/c.AOB_NATIONALITY';
import AOB_Nationality_HelpText from '@salesforce/label/c.AOB_Nationality_Helptext';
import AOB_Citizenship_HelpText from '@salesforce/label/c.AOB_Citizenship_HelpText';
import AOB_Nationality_Message_Value_Missing from '@salesforce/label/c.AOB_Nationality_Message_Value_Missing';
import AOB_Nationality_Placeholder from '@salesforce/label/c.AOB_Nationality_Placeholder';
import AOB_Citizenship_Message_Value_Missing from '@salesforce/label/c.AOB_Citizenship_Message_Value_Missing';
import AOB_Citizenship_Placeholder from '@salesforce/label/c.AOB_Citizenship_Placeholder';
import AOB_NatureAssociation_Placeholder from '@salesforce/label/c.AOB_NatureAssociation_Placeholder';
import AOB_PublicAuthority from '@salesforce/label/c.AOB_PublicAuthority';
import AOB_NatureAssociation_Message_Value_Missing from '@salesforce/label/c.AOB_NatureAssociation_Message_Value_Missing';
import AOB_RelatedPublicAuthority from '@salesforce/label/c.AOB_RelatedPublicAuthority';
import AOB_NatureAssociation from '@salesforce/label/c.AOB_NatureAssociation';
import AOB_NameSurnameAssociation from '@salesforce/label/c.AOB_NameSurnameAssociation';
import AOB_SelectPlaceHolder from '@salesforce/label/c.AOB_SelectPlaceHolder';
import AOB_NatureOfRelationHelpText from '@salesforce/label/c.AOB_NatureOfRelationHelpText';
import AOB_RelatedToAuthorityHelpText from '@salesforce/label/c.AOB_RelatedToAuthorityHelpText';
import AOB_Yes from '@salesforce/label/c.AOB_Yes';
import AOB_No from '@salesforce/label/c.AOB_No';
import AOB_EmptyFieldErrorMsg from '@salesforce/label/c.AOB_EmptyFieldErrorMsg';
import { FlowNavigationNextEvent} from 'lightning/flowSupport';
import { FlowNavigationBackEvent} from 'lightning/flowSupport';

//fieldsMap fields names
const SELECTPLACEHOLDER = 'Please select';

export default class Aob_internal_comp_personalDetails extends LightningElement {

    failing = false;
    errorContent = '';
    customerName='Maryem';// TO BE DYNAMICALLY FETCHED

    //Labels
    label = {
        AOB_PersonalDetails_subTitle,
        AOB_PersonalDetails_title,
        AOB_SelectPlaceHolder,
        AOB_CITIZENSHIP,
        AOB_NATIONALITY,
        AOB_Nationality_HelpText,
        AOB_Citizenship_HelpText,
        AOB_Nationality_Message_Value_Missing,
        AOB_Nationality_Placeholder,
        AOB_Citizenship_Message_Value_Missing,
        AOB_NatureAssociation_Message_Value_Missing,
        AOB_NatureAssociation_Placeholder,
        AOB_Citizenship_Placeholder,
        AOB_PublicAuthority,
        AOB_NameSurnameAssociation,
        AOB_RelatedPublicAuthority,
        AOB_NatureOfRelationHelpText,
        AOB_NatureAssociation,
        AOB_Yes,
        AOB_No,
        AOB_EmptyFieldErrorMsg,
        AOB_RelatedToAuthorityHelpText

    };
    
    @api applicationId;
    @api personalDetails;
    @api pageName;
    @api isFiringScreenLoad;
    @api isShowingCloseButton;

    @api availableActions = [];
        constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
        }

    @track fieldsMap={};    
    openClosePageModal;
    isLoaded = true;
    isPublicOfficial = undefined;
    isNotPublicOfficial = false;
    isRelatedToPublic = undefined;
    
    nationalityError = undefined;
    citizenshipError = undefined;
    publicOfficialError = undefined;
    relatedToPublicOfficialError = undefined;
    natureAssociationError = undefined;
    nameofTheIndividualError = undefined;
    nationality = undefined;
    citizenship = undefined;
    publicOfficial = undefined;
    relatedToPublicOfficial = undefined;
    natureAssociation = undefined;
    nameofTheIndividual = undefined;

    get getOpenClosePageModal() {
        return this.isShowingCloseButton && this.openClosePageModal;
    }

    /**
     * @description Initiates the Screen
     */
    connectedCallback() {
        this.label.AOB_PersonalDetails_subTitle=this.label.AOB_PersonalDetails_subTitle.replace('{####}',this.customerName);
    }

    /**
     * @description Change Handlers for Radio Buttons is public official
     */
     publicOfficialChangeHandler(event){
        if(event.target.id.includes('Yes')){
            this.publicOfficial=event.target.checked;
            this.isNotPublicOfficial = false;
        }
        else{
            this.publicOfficial=!event.target.checked;
            this.isNotPublicOfficial = true;
        }
        this.genericInputOnChange(event);
    }
    
    /**
     * @description Change Handlers for Radio Buttons is relatd to public official
     */
    
    relatedToPublicOfficialChangeHandler(event) {
        if(event.target.id.includes('Yes')){
                this.relatedToPublicOfficial=event.target.checked;
                this.isRelatedToPublic = true;
        }
        else{
                this.relatedToPublicOfficial=!event.target.checked;
                this.isRelatedToPublic = false;
        }
        this.genericInputOnChange(event);
    }

    nameofTheIndividualChange(event) {
        if (!event.target.value) {
            this.fieldsMap[event.target.name] = null;
        } else {
            this.fieldsMap[event.target.name] = event.target.value;
            this.nameofTheIndividual = event.target.value;
        }
    }

    /**
     * @description generic change handler for all inputs to capture the entered values by the user
     */
     genericInputOnChange(event) {
        if (!event.target.value || event.target.value === SELECTPLACEHOLDER) {
            this.fieldsMap[event.target.name] = null;
        } else {
            this.fieldsMap[event.target.name] = event.target.value;
        }
     }

    /**
     * @description nationality change handler for inputs to capture the entered values by the user
     */
    nationalityOnChange(event) {
        if (!event.target.value) {
            this.fieldsMap[event.target.name] = null;
        } else {
            this.nationality = event.target.value;
            this.fieldsMap[event.target.name] = event.target.value;
        }
    }

    /**
     * @description citizen change handler for inputs to capture the entered values by the user
     */
      citizenOnChange(event) {
        if (!event.target.value) {
            this.fieldsMap[event.target.name] = null;
        } else {
            this.citizenship = event.target.value;
            this.fieldsMap[event.target.name] = event.target.value;
        }
    }

    /**
     * @description natureAssociation change handler for inputs to capture the entered values by the user
     */
     natureAssociationOnChange(event) {
        if (!event.target.value) {
            this.fieldsMap[event.target.name] = null;
        } else {
            this.natureAssociation = event.target.value;
            this.fieldsMap[event.target.name] = event.target.value;
        }
    }

    /**
     * @description citizen change handler for inputs to capture the entered values by the user
     */
     citizenOnChange(event) {
        if (!event.target.value) {
            this.fieldsMap[event.target.name] = null;
        } else {
            this.citizenship = event.target.value;
            this.fieldsMap[event.target.name] = event.target.value;
        }
    }

    /**
     * @description Method to remove errors
     */
     removeErrors() {
        this.nationalityError='';
        this.citizenshipError='';
        this.publicOfficialError='';
        this.relatedToPublicOfficialError='';
        this.natureAssociationError='';
        this.nameofTheIndividualError='';
    }

    /**
     * @description Method to check if all required fields are filled
     */

    validateForm() {
        this.removeErrors();
       let isValid = true;
       if(this.nationality==undefined){
           this.nationalityError='please fill this field';
           isValid=false;
       }

       if(this.citizenship==undefined){
           this.citizenshipError='please fill this field';
           isValid=false;
       }

       if(this.publicOfficial==undefined){
            this.publicOfficialError='please fill this field';
            isValid=false;
       }

       if(this.publicOfficial==false && this.relatedToPublicOfficial==undefined){
            this.relatedToPublicOfficialError='please fill this field';
            isValid=false;
       }

       if(this.relatedToPublicOfficial==true && this.natureAssociation==undefined){
            this.natureAssociationError='please fill this field';
            isValid=false;
       }

       if(this.relatedToPublicOfficial==true && this.nameofTheIndividual==undefined){
        this.nameofTheIndividualError='please fill this field';
        isValid=false;
       }

       return isValid;
   }

    /**
    * @description method to move to next screen
    */
    continueToNextPage() {

        if(this.validateForm()){
            // check if NEXT is allowed on this screen
                if (this.availableActions.find(action => action === this.constants.NEXT)) {
                    // navigate to the next screen
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                }
        }
    }

    /**
    * @description method to move to previous screen
    */
    backToPreviousPage(){
    // check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === this.constants.BACK)) {
    // navigate to the next screen
        const navigateNextEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateNextEvent);
        }
    }

}