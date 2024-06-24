import { LightningElement,api,wire } from 'lwc';
import getAppData from '@salesforce/apex/ACMAppManagement.getExternalObjectData';
import updateAppData from '@salesforce/apex/ACMAppManagement.updateApplicationData';
import resetClientCredentials from '@salesforce/apex/ACMAppManagement.resetClientCredentials';
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class acmParentComponent extends LightningElement {
    @api recordId;
    @api appName='';
    @api appDesc='';
    @api redirectUri='';
    @api appId='';
    @api clientId='';
    @api clientSecret = '';
    @api modalClientSecret = null;
    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {   
       this.loadData();  
    }
    
    loadData() {
        getAppData({ recordId: this.currentPageReference.attributes.recordId }).then((result) => {
          try{
            this.appName = result.appName;
            this.appDesc = result.appDescription;
            this.redirectUri = result.redirectURL;
            this.appId = result.appId;
            this.clientId = result.clientId;
            this.clientSecret = result.clientSecret;
          }catch(e){
             this.showToast(
               "Error",
               " Error : " + e.message );
          }

          })
          .catch((error) => {
                   this.showToast(
                     "Error",
                     "Server error when fetching data " +
                       error.message
                   );
          });
    
      }
      handleUpdateApplication(event){
        updateAppData({ appName: event.detail.appName,appDesc:event.detail.appDesc ,redirectUri:event.detail.redirectUri,appId: event.detail.appId,clientId: this.clientId,clientSecret: this.clientSecret }).then((result) => {
          if(result.statusCode === 200){
              this.showToast('Success','Application has been updated successfully', 'success');
            }else if(result.statusCode === 409){
              this.showToast('Error','Application name already exists' , 'error');
            }else{
              this.showToast('Error','There was an error updating the application: '+result.message + ':' +result.statusCode, 'error');
            }
          })
          .catch((error) => {
              this.showToast(
                "Error",
                "There was an error retrieving the application: " +
                  error.message
              );
          });

      }
      handleUpdateClientCredentials(event){
        resetClientCredentials({ recordId: this.currentPageReference.attributes.recordId }).then((result) => {
            if(result.statusCode == 200){
              this.showToast('Success','Application has been updated successfully', 'success');
              this.clientSecret = result.clientSecret;
              this.modalClientSecret = result.clientSecret;
            }else{
              this.showToast('Error','There was an error updating the application: '+result.message + ':' +result.statusCode, 'error');
            }
          })
          .catch((error) => {
                  this.showToast(
                    "Error",
                    "There was an error updating the application: " +
                      error.message
                  );
          });
      }
      showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    
}