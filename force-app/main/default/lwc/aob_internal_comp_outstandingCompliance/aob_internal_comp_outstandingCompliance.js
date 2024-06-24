/**
 * @description       : Displays outstanding Compliance in a lightning table
 * @author            : Sibonelo Ngcobo
 * @last modified on  : 10-16-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-20-2023   Sibonelo Ngcobo   SFP-25089
**/
import { LightningElement,api } from 'lwc';
import checkComplianceRP from '@salesforce/apex/AOB_CTRL_Internal_CheckComplianceRP.checkComplianceRPFromWire';
import getDirectorDetails from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.getDirectorDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createLogger } from 'sbgplatform/rflibLogger';
export default class aob_internal_comp_outstandingCompliance extends LightningElement {
    logger = createLogger('aob_internal_comp_outstandingCompliance');
    @api applicationId;
    @api outstandingComplianceClose;
    complianceInfo;

    showOutstandingComplianceTable = false;
    showRelatedPartiesTable = true;
    showTable = false;
    showRefresh=false;
    showCust1=false;
    isLoaded=false;
    showTabs=false;
    showCompliance=false;
    cust1stUrl;
    nextScreen='Card Selection';

    columns = [
        { label: 'Description', fieldName: 'description' },
        { label: 'Status', fieldName: 'status' },

    ];

    rpColumns = [
        { label: 'Name', fieldName: 'firstName'},
        { label: 'Surname', fieldName: 'lastName'},
        { label: 'ID Number', fieldName: 'identificationNumber'},
        { label: 'Status / Role', fieldName: 'status'}

    ]

    data = [];
    rpData;

    connectedCallback(){
        this.checkComplianceRPAPI();
        this.getDirectorDetailsAPI();
    }

    
    
    checkComplianceRPAPI(){
        checkComplianceRP({'applicationId':`${this.applicationId}`})
        .then(data=>{
        if(data){
            this.complianceInfo=data;
            this.showCompliance=true;
            this.isLoaded=true;
            this.showTabs=true;
            let results = Object.fromEntries(Object.entries(data).map(([key,value]) => [key, [value]]))
            results.complianceData.forEach(x => {
                x.forEach(y => {
                    let obj = {
                        description: y.complianceTypeDescription,
                        status: y.complianceStatus
                    };
                    this.data.push(obj);
                })
            })
            this.showTable = true;
            this.showCust1=true;
            this.cust1stUrl = results.customerFirstURL[0];
        }})
        .catch(error=>{
            this.logger.error('An error occurred while calling Check Compliance API:', error);
        })
    }

    RefreshcheckComplianceRPAPI(){
        checkComplianceRP({'applicationId':`${this.applicationId}`})
        .then(data=>{
        if(data){
            this.complianceInfo=data;
            this.showCompliance=true;
            this.isLoaded=true;
            this.showTabs=true;
            let results = Object.fromEntries(Object.entries(data).map(([key,value]) => [key, [value]]))
            results.complianceData.forEach(x => {
                x.forEach(y => {
                    let obj = {
                        description: y.complianceTypeDescription,
                        status: y.complianceStatus
                    };
                    this.data.push(obj);
                })
            })
            this.showTable = true;
            this.showCust1=true;
            this.cust1stUrl = results.customerFirstURL[0];
        }})
        .catch(error=>{
            this.logger.error('An error occurred while calling Check Compliance API:', error);
            this.showToast('An error occurred while calling Check Compliance API:','error');

        })
    }

    getDirectorDetailsAPI(){

        getDirectorDetails({'applicationId':`${this.applicationId}`})
        .then(data=>{
            if(data){
            this.isLoaded=true;
            this.rpData=data;
            }

        })
        .catch(error=>{
            this.showToast('An error occurred while getting director details:' + error,'error');
            
        })
    }
    handleShowRefresh(){
        this.data = [];
        this.showCust1=true;
        this.showRefresh=false;

        this.showCompliance=false;
        this.RefreshcheckComplianceRPAPI();
    }
    onCustomer1st(){
        this.showCust1=false;
        this.showRefresh=true;
        window.open(this.cust1stUrl, '_blank');
    }
    nextScreens(event){
        this.RefreshcheckComplianceRPAPI();
        if(this.complianceInfo.complianceIndicator){
            const selectedEvent = new CustomEvent("changescreen", {
                detail: this.applicationId
            });  
            this.dispatchEvent(selectedEvent);
        }else{
            this.showToast('Please Complete all compliance!','error');
        }
    }
    cancelModal(event) {
      this.outstandingComplianceClose = true;
      const selectedEvent = new CustomEvent("progressvaluechange", {
        detail: this.outstandingComplianceClose
      });
  
      this.dispatchEvent(selectedEvent);
      this.data = [];
    }

    compRpHandler(event)
	{
		if(event.target.id.includes('oc'))
		{
			this.showOutstandingComplianceTable = true;
			this.showRelatedPartiesTable = false;
		}
		else if(event.target.id.includes('rp'))
		{
			this.showOutstandingComplianceTable = false;
			this.showRelatedPartiesTable = true;
		}
	}
    
    showToast(message,variant) {
        const event = new ShowToastEvent({
            variant:variant,
            message:message,
        });
        this.dispatchEvent(event);
    }
}