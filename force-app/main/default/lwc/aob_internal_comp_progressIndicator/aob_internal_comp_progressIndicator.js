/**
 * @description       : Displays a progress bar of the application.
 * @author            : Sibonelo Ngcobo
 * @last modified on  : 09-13-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-20-2023   Sibonelo Ngcobo   SFP-25089
**/
import { LightningElement,api,wire } from 'lwc';
import getApplicationData from '@salesforce/apex/AOB_internal_CTRL_Onboarding.getApplicationData';
import { MessageContext, subscribe } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/progressMessageChannel__c';

export default class aob_internal_comp_progressIndicator extends LightningElement {
    showStep4 = true;
    currentPage;
    currentStep;
    @api recordId;
    continueClick=false;
    screen;
    steps = [
        { label: 'Pre-Application', value: 'step-1' },
        { label: 'Authentication', value: 'step-2' },
        { label: 'Personal', value: 'step-3' },
        { label: 'Company Details', value: 'step-4' },
        { label: 'Product Setup', value: 'step-5' },
        { label: 'Summary and Sign Offer', value: 'step-6' },
        { label: 'Application Complete', value: 'step-7' }
    ];
    subscription=null;

    @wire(MessageContext)
    MessageContext;

    connectedCallback(){
        
    this.getCurrentScreenApex();
    this.subscribeMC();
    }
    getCurrentScreenApex(){
        getApplicationData({recordId: this.recordId})
        .then((data)=>{
            this.screen=JSON.parse(JSON.stringify(data[0].AOB_CurrentScreen__c));
            this.getScreen();   

        })
        .catch((error)=>{
        });
    }
    subscribeMC(){
        if(this.subscription!=null){
            return this.subscription;
        }
        this.subscription=subscribe(this.MessageContext,messageChannel,(message)=>{
            this.screen=message.currentScreen;
            this.getScreen();
        })
        

    }
   
   
    getScreen(){ 
            if (['Personal Details', 'Employment Details', 'Residential Address'].includes(this.screen)) {
                this.currentStep='step-3'
            }
            else if (['Marketing Consent','Marketing Consent Internal','Company Details', 'Company Trading Address', 'Company Financial Details'].includes(this.screen)) {
                this.currentStep='step-4';
            }
            else if (['Card Selection','Notifications', 'Available Bundles', 'PocketBiz','SnapScan',].includes(this.screen)) {
                this.currentStep='step-5';
            } 
            else if (['Summary'].includes(this.screen)) {
                this.currentStep='step-6';
            } 
            else if (['Application Complete'].includes(this.screen)){
                this.currentStep='step-7';     
            }

        


    }
}