import { LightningElement, wire } from 'lwc';
import getMySolutions from '@salesforce/apex/MallAuthSolutionsCtrl.getMySolutions';
import getCustomerAccountList from "@salesforce/apex/MallAuthSolutionsCtrl.getCustomerAccountList";
import getCustomerAccountBalances from "@salesforce/apex/MallAuthSolutionsCtrl.getCustomerAccountBalances";



export default class MallAuthSolutions extends LightningElement {

    mySolutions;

    @wire(getMySolutions)
    wiredMySolutions({ error, data }) {
        if (data) {
            this.mySolutions = data;
            console.log('@@Solutions:', this.mySolutions);
        } else if (error) {
            console.error('@@Error:',error);
        }
    }

    handleRedirectionAction(event){
        const redirectUrl = event.detail.redirectUrl;
        if(redirectUrl!=''){
            console.log('RedirectURL:', redirectUrl);
            window.location.href = redirectUrl;

        }else{

            console.log('RedirectURL is empty');
        }
        
    }

    connectedCallback() {
        this.getCustomerAccountListDetails();
        //this.getCustomerAccountBalanceDetails();
    }


    async getCustomerAccountBalanceDetails() {
        try {
          let customerAccountBalanceResponse = await getCustomerAccountBalances();
          console.log('@@Custom Account Balance', customerAccountBalanceResponse);

        }catch (error) {
            this.error = error;
        }
    }  

    async getCustomerAccountListDetails() {
        try {
          let customerProfileAndAccountListResponse = await getCustomerAccountList();
          console.log('@@Custom Account LIst', customerProfileAndAccountListResponse);

          let customerAccountListDetails = customerProfileAndAccountListResponse.customerAccountListDetails;

          if(!customerAccountListDetails && customerAccountListDetails.length <=0) {
            return;
          }
        }catch (error) {
            this.error = error;
        }
    }      
}