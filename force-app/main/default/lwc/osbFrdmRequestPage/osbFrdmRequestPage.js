import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import OSB_Images from '@salesforce/resourceUrl/OSB_Images_Two';
import getOSBDocumentURL from '@salesforce/apex/OSB_RequestPage_CTRL.getOSBDocumentURL';
import getUserDetails from '@salesforce/apex/OSB_RequestPage_CTRL.getUserDetails';
import CaseCheck from '@salesforce/apex/OSB_RequestPage_CTRL.caseCheck';
import createCaseWithContactId from '@salesforce/apex/OSB_RequestPage_CTRL.createCaseWithContactId';
import { addAnalyticsInteractions, pageViewSinglePageApp } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class osbFrdmRequestPage extends LightningElement {
    FRDMLogo = OSB_Images + '/OSB_Images_Two/FRDM_Request_Page.png';
    @track RequestNotComplete = true;
    @track tncDownload;
    termsConditionsDoc = 'FRDM_Terms_and_Conditions';
    solutionName= 'FRDM';
    email ='';

    RequestButtonAdobe;
    ReturnButtonAdobe;
    TnCAdobeButton;

    connectedCallback(){
        let pagename =  ' Frdm Registration page';
        this.RequestButtonAdobe = pagename+ " | request access";
        this.ReturnButtonAdobe = pagename+ " | return to Onehub";
        this.TnCAdobeButton = pagename+ " | download TnC";
        pageViewSinglePageApp(pagename);
    }

    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }
  
    @wire(getUserDetails) 
    contacts;
    
    @wire(getUserDetails) 
    getContact({error,data}){
        if(data){
         this.email = data[0].Email;
        }
    };

    @wire(getOSBDocumentURL, ({docName: '$termsConditionsDoc'}))
    getOSBDocumentURL({ error, data}){
        if(data){
            this.tncDownload = window.location.origin+data;
        }else if (error){
            this.error
        }
    }

    @wire(CaseCheck,({email: '$email', subject: 'OneHub - FRDM'}))
    caseChecker({error,data}){
            if (data) {
                if(data[0]){                    
                    this.RequestNotComplete = false;
                }
                this.error = undefined;
            }
    }

    requestAccess() { 

        let fullNameField = this.template.querySelector(`[data-id="Fullname"]`);
        let fullName = fullNameField ? fullNameField.value : "";
        let emailField = this.template.querySelector(`[data-id="EmailAddress"]`);
        let email = emailField ? emailField.value : ""; 
        let companyNameField = this.template.querySelector(`[data-id="Company"]`);
        let companyName = companyNameField ? companyNameField.value : "";
        let cellphoneField = this.template.querySelector(`[data-id="MobileNumber"]`);
        let cellphone = cellphoneField ? cellphoneField.value : "";
                
        if(fullName && email && companyName && cellphone && this.RequestNotComplete ){
            
            let origin = "Web";
            let status = "New";
        
            let newCase ={
            Origin : origin,
            Status : status,
            SuppliedEmail :email,
            SuppliedName :fullName,
            SuppliedPhone :cellphone,
            SuppliedCompany : companyName,
            Description :  'FRDM sign up request',
            Type :'OneHub FRDM Registration',   
            Subject : 'OneHub - FRDM'
            }   
            this.createCase(newCase);               
        }
    }

    createCase(newCase){
        let regURLName = 'FRDM_Registration_URL';
        createCaseWithContactId({caseRecord:newCase,urlName: regURLName})
        this.RequestNotComplete = false;                      
    }

    returnToOneHub(){
        this[NavigationMixin.Navigate]({
            type:'standard__namedPage',
            attributes: {
                pageName: 'Profile_and_Settings__c'
            },
        });
        
    }          
    
}