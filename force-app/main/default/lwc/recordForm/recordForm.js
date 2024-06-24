import { LightningElement,api,track } from 'lwc';
import TEXT from '@salesforce/schema/Content__c.Text__c';
import RICHTEXT from '@salesforce/schema/Content__c.Rich_Text__c';
import NAME from '@salesforce/schema/Content__c.Name';
import SECTION from '@salesforce/schema/Content__c.Section__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { navigateToRecordPage,getBaseUrl,navigateToWebPage } from "c/mallNavigation";
import { NavigationMixin } from 'lightning/navigation';
import getRecordTypeName from '@salesforce/apex/MallContentRecordFormController.getRecordTypeName';

export default class RecordForm extends LightningElement {

    navigateToWebPage = navigateToWebPage.bind(this);
    @api recordTypeId;
    @api recordId;
    @track fields;
    error;
    recordTypeVsFields={'Insight': [NAME,TEXT,RICHTEXT],
            'FAQ':[TEXT,RICHTEXT],
            'Legal': [NAME,RICHTEXT],
            'Partner with us': [NAME,TEXT,RICHTEXT,SECTION],
            'About us': [NAME,TEXT,RICHTEXT,SECTION]
        };

    connectedCallback(){
        getRecordTypeName({objectAPIName:'Content__c',recordTypeId:this.recordTypeId})
        .then((result) => {
            this.fields=this.recordTypeVsFields[result];
        })
        .catch((error) => {
            this.error = error;
        });
    }

    handleSuccess(event){
        const evt = new ShowToastEvent({
            title: 'content record created!',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        let url=getBaseUrl()+'/lightning/r/Content__c/'+event.detail.id+'/view';
        window.open(url,'_self');
    }

    handleCancel(){
        let url=getBaseUrl()+'/lightning/o/Content__c/list?filterName=Recent';
        window.open(url,'_self');
    }
}