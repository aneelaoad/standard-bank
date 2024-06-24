/**
 * @description       : Displays the card types for selection.
 * @author            : Mahlatse Tjale
 * @last modified on  : 10-11-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   SFP-25089
**/
import { LightningElement, track, api,wire } from 'lwc';
import setApplicationStep from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setApplicationStep';
import setApplicationData from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setApplicationData';
import updateScreen from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updateScreen';
import updatePreviousScreen from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updatePreviousScreen';
import { getErrorMessage } from 'c/aob_comp_utils';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import mymobiz from '@salesforce/label/c.PBP_ZA_MYMOBizDebitCard';
import AOB_ZA_Visit from '@salesforce/label/c.AOB_ZA_Visit';
import AOB_ZA_Get from '@salesforce/label/c.AOB_ZA_Get';
import AOB_ZA_Stayin from '@salesforce/label/c.AOB_ZA_Stayin';
import AOB_ZA_R from '@salesforce/label/c.AOB_ZA_R';
import AOB_ZA_ZERO from '@salesforce/label/c.AOB_ZA_ZERO';
import AOB_ZA_ANNUAL from '@salesforce/label/c.AOB_ZA_ANNUAL';
import chequecard from '@salesforce/label/c.PBP_MYMOBizChequeCard';
import AOB_ZA_StayinGetyourbusiness from '@salesforce/label/c.AOB_ZA_StayinGetyourbusiness';
import AOB_ZA_Getunlimited from '@salesforce/label/c.AOB_ZA_Getunlimited';
import AOB_ZA_NUM from '@salesforce/label/c.AOB_ZA_NUM';
import AOB_ZA_Getfreeautomaticrate from '@salesforce/label/c.AOB_ZA_Getfreeautomaticrate';
import { publish, MessageContext } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/progressMessageChannel__c';
import BackmessageChannel from '@salesforce/messageChannel/previousScreenMessageChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createLogger } from 'sbgplatform/rflibLogger';

export default class aob_internal_comp_select_card extends LightningElement {
    logger = createLogger('aob_internal_comp_select_card');
    label = {
        mymobiz,
        AOB_ZA_Visit,
        AOB_ZA_Get,
        AOB_ZA_Stayin,
        AOB_ZA_R,
        AOB_ZA_ZERO,
        chequecard,
        AOB_ZA_StayinGetyourbusiness,
        AOB_ZA_Getunlimited,
        AOB_ZA_Getfreeautomaticrate,
        AOB_ZA_NUM,
        AOB_ZA_ANNUAL
    }
    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }
    isLoaded = true;
    debitCard = AOB_ThemeOverrides + '/assets/images/gold-debit-mobile.png';
    chequeCard = AOB_ThemeOverrides + '/assets/images/gold-credit-mobile.png';
    defaultImg = AOB_ThemeOverrides + '/assets/images/defaultTag.png';
    upgradeImg = AOB_ThemeOverrides + '/assets/images/upgradeTag.png';
    @api applicationId;
    @api screenName;
    @api previousScreen;
    @api nextScreen;
    @track customFormModal = false;
    isEventFired;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    adobeDataScopeApp;
    adobeDataTextBack;
    adobeDataTextContinue;
    cardDetails={};
    application = {
        applicationProduct: "Customer on boarding",
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "",
        applicationStep: "",
        applicationStart: true,
        applicationComplete: false
    }
    failing;
    errorMessage;
    isOpenCardDelivery = false;
    @api availableActions = [];

    next1;

    @wire(MessageContext)
    MessageContext;

    handleClick() {
        if(this.screenName==='Card Selection'){
            this.next1='Notifications';
        }
        else if(this.screenName==='Card delivery New'){
            this.next1='Notifications';
        }
        else if(this.screenName==='Card delivery'){
            this.next1='Notifications';
        }
        const message= new CustomEvent('buttonclick',
        {detail:this.next1
        });
        this.dispatchEvent(message);
    }
    handleChildMethod(event){
        this.screenName = event.detail;
        if(this.screenName==='Card Selection'){
            this.next1='Notifications';
        }
        else if(this.screenName==='Card delivery New'){
            this.next1='Notifications';
        }
        else if(this.screenName==='Card delivery'){
            this.next1='Notifications';
        }
        const message= new CustomEvent('buttonclick',
        {detail:this.next1
        });
        this.dispatchEvent(message);
    }
    handleBackProgress(){
        var progressMessage={currentScreen:this.previousScreen};
        publish(this.MessageContext,messageChannel,progressMessage);
    }
    handleBackClick() {
        this.handleBackProgress();
        var previousScreenMessage={previousScreen:this.previousScreen};
        publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
    }
    connectedCallback() {
      
        setApplicationStep({
            'applicationId': this.applicationId,
            'currentScreen': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
        }).catch(error => {
            this.logger.error('An error occurred while calling setApplicationStep:', error);
            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
        });
    }
    continueToNextPageCheque(event) {
       
        this.cardDetails={"chequeCardSelected":"true"};
        setApplicationData({
            'applicationId': this.applicationId,
            'appData': JSON.stringify(this.cardDetails)
        }).then(result => {
            this.chequeCardSuccess();
            this.isOpenCardDelivery = true;
        }).catch(error => {
            this.logger.error('An error occurred while calling setApplicationData:', error);
            this.showToast('error,please select the card again','error');
            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
        });
        
    }
    continueToNextPageDebit(event) {
        this.cardDetails={"debitCardSelected":"true"};
        setApplicationData({
            'applicationId': this.applicationId,
            'appData': JSON.stringify(this.cardDetails)
        }).then(result => {
            this.updateScreen();
        }).catch(error => {
            this.logger.error('An error occurred while calling setApplicationData:', error);
            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
        });
        this.handleClick();
    }
    chequeCardSuccess() {
        // this.handleClick();
        this.updateScreen();
    }
    closePopup(){
        this.isOpenCardDelivery = false;
    }
    backToPreviousPage(event) {

        this.handleBackClick();
        this.updatePreviousScreen();
    }

    updateScreen(){
        updateScreen({
            'applicationId': this.applicationId,
            'currentScreen': this.nextScreen,
            'previousScreen': this.previousScreen
        }).then(result => {
        })
            .catch(error => {
                this.logger.error('An error occurred while calling updateScreen:', error);
                this.failing = true;
                this.errorMessage = getErrorMessage.call(this, error);
            });
    }
    updatePreviousScreen(){
        updatePreviousScreen({
            'applicationId': this.applicationId,
            'currentScreen': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
        })
            .catch(error => {
                this.logger.error('An error occurred while calling updatePreviousScreen:', error);
                this.failing = true;
                this.errorMessage = getErrorMessage.call(this, error);
            });
    }
    showToast(message,variant) {
        const event = new ShowToastEvent({
            label:'',
            variant:variant,
            message:message,
        });
        this.dispatchEvent(event);
    }
}