/**
 * @description       : displays picklist
 * @author            : Mahlatse Tjale
 * @last modified on  : 07-20-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/

import {LightningElement, api, wire} from 'lwc';
import loadData from '@salesforce/apex/AOB_CTRL_ACPicklist.loadData';

export default class Aob_internal_comp_acPicklist extends LightningElement {
    @api helpText; 
    @api values; 
    @api label;
    @api sapfield;
    @api name;
    @api value ;
    @api missingValueMessage ;
    @api placeholder;
    @api required;
    @api index;
    soleOwner;
    businessReg;
    currentValues =[];
    code = "";
    navigationIndex =0;
    tempCounter=0;
    navigationItem;
    arrowup;
    arrowdown=true;
    
    //Gauteng Region city list for pre-application
    cityList = [{"Name":"CITY OF JOHANNESBURG","AOB_Code__c":"CITY OF JOHANNESBURG"},{"Name":"CITY OF TSHWANE","AOB_Code__c":"CITY OF TSHWANE"},{"Name":"EKURHULENI","AOB_Code__c":"EKURHULENI"},
    {"Name":"METWEDING DISTRICT","AOB_Code__c":"METWEDING DISTRICT"},{"Name":"SEDIBENG DISTRICT","AOB_Code__c":"SEDIBENG DISTRICT"},{"Name":"WEST RAND DISTRICT","AOB_Code__c":"WEST RAND DISTRICT"}];
    
    businessType = [{"Name":"SOLE PROPRIETORSHIP","AOB_Code__c":"SOLE PROPRIETORSHIP"},{"Name":"PRIVATE COMPANY","AOB_Code__c":"PRIVATE COMPANY"},{"Name":"CLOSE CORPORATION","AOB_Code__c":"CLOSE CORPORATION"},
                    {"Name":"OTHER","AOB_Code__c":"OTHER"}];
    
    enquiryFormHelpCategories = [{"Name":"Enquiry", "AOB_Code__c":"Enquiry"}, {"Name":"Open A Business Account", "AOB_Code__c":"Open A Business Account"}];
    
    
    connectedCallback(){
        if(this.sapfield){
            loadData({targetValue:this.sapfield}).then((result)=>{
                this.values = result;
                if(this.values){
                    this.currentValues = [...this.values];
                    this.setExistingData();
                    const customEvent = new CustomEvent('select', {
                        detail: { message: this.values}
                     });
                    this.dispatchEvent(customEvent);
                }
            }).catch((error=>{
                this.currentValues =[];
            }));
        }
        else{
            this.setStaticPicklist();
        }
    }

    setExistingData(){
        if(this.value){
            var loadedValue = this.values.find(item => item.AOB_Code__c === this.value);
            this.value = loadedValue.Name;
            this.code = loadedValue.AOB_Code__c;
        }
    }
    
    
    setStaticPicklist(){
         if(this.name == 'businessCity'){
             this.values = [...this.cityList]
            this.currentValues = [...this.values];
        }
       if(this.name =='businessType'){
             this.values = [...this.businessType];
        this.currentValues = [...this.values];
    }
    if(this.name == 'helpCategories'){
            this.values = [...this.enquiryFormHelpCategories];
            this.currentValues = [...this.values];
        }
    }
    
    /**
     * This will fire handle change 
     * @param {*} event 
     */
    handleChange(event) {
            this.navigationIndex = 0;
            this.tempCounter=0;
            this.currentValues = this.values.filter(elem => elem.Name.toLowerCase().includes(event.target.value.toLowerCase()));
            this.value = event.target.value;
            this.code = event.target.dataset.code;
            this.fireChangeEvent(event.target.dataset.code);
    }
    
    /**
     * This will be called on focus
     */
    handleFocus() {
        this.navigationIndex=0;
        this.tempCounter =0;
        const datalistElem = this.template.querySelector('.aob_datalist');
        const inputElem = this.template.querySelector('lightning-input');
        datalistElem.style.width = inputElem.offsetWidth + 'px';
        datalistElem.style.left = inputElem.offsetLeft + 'px';
        datalistElem.style.top = inputElem.offsetTop + inputElem.offsetHeight + 'px';
        datalistElem.style.display = 'block';
        if(this.navigationIndex) this.navigationItem.style.backgroundColor='white';
    }
    
    /**
     * This will be called on blur
     */
    @api handleBlur(event) {
        this.template.querySelector('.aob_datalist').style.display = 'none';
        this.fireBlurEvent(this.code);
    }
    
    /**
     * This will handle mouse down
     * @param {*} event 
     */
    handleMouseDown(event) {
        const newValue = event.target.dataset.value;
        this.code = event.target.dataset.code;
       this.template.querySelector('.aob_datalist').style.display = 'none';
        this.value = newValue;
        this.fireChangeEvent(this.code);
       
    }
    
    handlekeyPress(event){
        if(this.navigationItem) this.navigationItem.style.backgroundColor='white';
        if(event.keyCode == 40){
            event.preventDefault();
            if(this.tempCounter == 0){
                this.navigationIndex=0;
                this.tempCounter++;
                
            }
            else if(this.navigationIndex < this.currentValues.length-1){
                 this.navigationIndex++;
                 
            }
            const currentName = this.currentValues[this.navigationIndex].Name;
            this.navigationItem =   this.template.querySelector('li[data-value="'+currentName+'"]'); 
            this.navigationItem.style.backgroundColor ='lightGrey';
            if(this.navigationIndex > 6){
                this.template.querySelector('.aob_datalist').scrollTop+=26;
            }
        }
    
        if(event.keyCode == 38){
            if(this.navigationIndex !=0 ){
                this.navigationIndex--;
                const currentName = this.currentValues[this.navigationIndex].Name;
                this.navigationItem =   this.template.querySelector('li[data-value="'+currentName+'"]'); 
                this.navigationItem.style.backgroundColor = 'lightGrey';
                this.template.querySelector('.aob_datalist').scrollTop-=26;
            }
            if(this.navigationIndex ==0) this.navigationItem.style.backgroundColor = 'lightGrey';
        }
    
         if(event.keyCode == 13){
             event.preventDefault();
             const selectedItem = this.currentValues[this.navigationIndex];
             this.template.querySelector('.aob_datalist').style.display = 'none';
             if(selectedItem){
                 const newValue = selectedItem.Name;
                 this.code = selectedItem.AOB_Code__c;
                 this.value = newValue;
                 this.fireChangeEvent(this.code);
                 this.template.querySelector('lightning-input').blur();
            }
        }
    }
    
    /**
     * This will handle the change event
     * @param {*} newValue 
     */
    fireChangeEvent(newValue) {
        this.dispatchEvent(new CustomEvent('change', {
            
            bubbles: false,
            detail: {
                value: newValue,
                target: this.name,
                index: this.index
            }
        }));
    }
    
    /**
     * This will handle the blur event
     * @param {*} newValue 
     */
    @api fireBlurEvent(newValue) {
        this.dispatchEvent(new CustomEvent('blur', {
            bubbles: true,
            detail: {
                value: newValue,
                target: this.name,
                index: this.index
            }
        }));
    }
    
    @api triggerInsideBlur(){
        this.template.querySelectorAll('lightning-input').forEach((element) => { 
            if(!this.code){
                element.value = '';
                this.currentValues = [...this.values];
            }
            element.reportValidity();
        });
    }

    @api isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
}