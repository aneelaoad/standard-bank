import { LightningElement,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import NextSteps1 from '@salesforce/label/c.AOB_ZA_STAFF_NextSteps1';
import NextSteps2 from '@salesforce/label/c.AOB_ZA_STAFF_NextSteps2';
import NextSteps3 from '@salesforce/label/c.AOB_ZA_STAFF_NextSteps3';
import NextSteps4 from '@salesforce/label/c.AOB_ZA_STAFF_NextSteps4';
import NextSteps5 from '@salesforce/label/c.AOB_ZA_STAFF_NextSteps5';
import FilterID from '@salesforce/label/c.AOB_ZA_STAFF_FilterID';
import getListView from '@salesforce/apex/AOB_CTRL_Navigation.getMyApplicationsListViewId';
import { publish, MessageContext } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/progressMessageChannel__c';
import { createLogger } from 'sbgplatform/rflibLogger';

export default class Aob_internal_comp_applicationComplete extends NavigationMixin(LightningElement) {
    logger = createLogger('Aob_internal_comp_applicationComplete');
    labels = {
        NextSteps1,
        NextSteps2,
        NextSteps3,
        NextSteps4,
        NextSteps5
    }
    filterId;
    @wire(MessageContext)
    MessageContext;

    async completeApplication(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'AOB_Application__c',
                actionName: 'home'
            },
            state: {

                filterName:this.filterId 
            }
        });
    }
    connectedCallback(){
        let completeApp='Application Complete';
        var progressMessage={currentScreen:completeApp};
        publish(this.MessageContext,messageChannel,progressMessage);
        this.getListViewId();
    }

    getListViewId(){
        getListView()
        .then(result=>{
            this.filterId=result;
        })
        .catch(error=>{
            this.logger.error('An error occurred while calling getListViewId:', error);
        });
    }
}