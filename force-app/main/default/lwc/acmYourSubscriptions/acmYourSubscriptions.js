import { LightningElement,wire,track,api } from 'lwc';
import getSubscriptionList from '@salesforce/apex/ACM_YourSubscriptions.getSubscriptionList';
import AcmYourSubscriptionscss from './AcmYourSubscriptions.css';


export default class AcmYourSubscriptions extends LightningElement {
    static stylesheets = [
        AcmYourSubscriptionscss
        ];
    @api recordId;
    @track subscriptionList;
    @track newdataArray = [];

    @wire(getSubscriptionList,{recId:'$recordId'})
    wiredApiProductList({ error, data }) {
        if (data) {
            this.subscriptionList = data;
            console.log('data:::' + JSON.stringify(data));
            for(var i=0 ; i<this.subscriptionList.length;i++){
                if(this.subscriptionList[i].status === "Approved"){
                    this.newdataArray.push({apiProduct: this.subscriptionList[i].apiProduct, status: this.subscriptionList[i].status, version: this.subscriptionList[i].version,environment: this.subscriptionList[i].enviornment, statusClass:'dynamic-approved-status'});
                  }
                if(this.subscriptionList[i].status === "Pending Approval"){
                    this.newdataArray.push({apiProduct: this.subscriptionList[i].apiProduct, status: this.subscriptionList[i].status, version: this.subscriptionList[i].version,environment: this.subscriptionList[i].enviornment, statusClass:'dynamic-pending-status'});
                }
                if(this.subscriptionList[i].status === "Declined"){
                    this.newdataArray.push({apiProduct: this.subscriptionList[i].apiProduct, status: this.subscriptionList[i].status, version: this.subscriptionList[i].version,environment: this.subscriptionList[i].enviornment, statusClass:'dynamic-rejected-status'});
                 }
            }
           
        } else if (error) {
            // Handle error
            console.log(error);
            alert(error);
        }
    }   

    
}