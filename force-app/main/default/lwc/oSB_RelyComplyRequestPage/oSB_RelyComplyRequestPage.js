import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import OSB_Images from '@salesforce/resourceUrl/OSB_Images';
import getOSBDocumentURL from '@salesforce/apex/OSB_RequestPage_CTRL.getOSBDocumentURL';
import getUserDetails from '@salesforce/apex/OSB_RequestPage_CTRL.getUserDetails';
import CaseCheck from '@salesforce/apex/OSB_RequestPage_CTRL.caseCheck';
import createCaseWithContactId from '@salesforce/apex/OSB_RequestPage_CTRL.createCaseWithContactId';
import { addAnalyticsInteractions, pageViewSinglePageApp } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class oSB_RelyComplyRequestPage extends LightningElement {
imageHeader = OSB_Images + '/RelyHeader.svg';
relyComplyName = OSB_Images + '/RelyComplyName.svg';
relyComplyLogo = OSB_Images + '/RelyComplyLogo.png';

@track RequestNotComplete = true;
termsConditionsDoc = 'Terms_Conditions';
solutionName= 'RelyComply';
email ='';

RequestButtonAdobe;
ReturnButtonAdobe;
ReturntoSitePageAdobe;
TnCAdobeButton;

connectedCallback(){
    let pagename =  'RelyComply Registration page';
    this.RequestButtonAdobe = pagename+ " | request access";
    this.ReturnButtonAdobe = pagename+ " | return to Onehub";
    this.ReturntoSitePageAdobe = pagename+ " | return to Relycomply splash page";
    this.TnCAdobeButton = pagename+ " | download TnC";
    pageViewSinglePageApp(pagename);
}

renderedCallback(){
    addAnalyticsInteractions(this.template);
}

@wire(getUserDetails) 
contacts;

@wire(getUserDetails) 
getContact({ error, data }){
    if(data){
        this.email = data[0].Email;
    }else if(error){
        this.error = error;
    }
};

@wire(getOSBDocumentURL, {termsConditionsDoc: '$termsConditionsDoc'} )
tAndCLink;

@wire(CaseCheck,({email: '$email', subject: 'OneHub - RelyComply'}))
caseChecker({ error, data }){
    if (data) {
       if(data[0].OwnerId){
        this.RequestNotComplete = false;
        }
        this.error = undefined;
    } else if (error) {
        this.error = error;
               
    }
}

requestAccess() { 
let fullNameField = this.template.querySelector("lightning-input[data-id=Fullname]");
let fullName = fullNameField ? fullNameField.value : "";
let emailField = this.template.querySelector("lightning-input[data-id=emailAddress]");
let email = emailField ? emailField.value : ""; 
let companyNameField = this.template.querySelector("lightning-input[data-id=Company]");
let companyName = companyNameField ? companyNameField.value : "";
let cellphoneField = this.template.querySelector("lightning-input[data-id=mobileNumber]");
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
    Description :  'RelyComply sign up request',
    Type :'OneHub RelyComply Registration',   
    Subject : "OneHub - RelyComply"
    }
    this.createCase(newCase)   
        
}
}

createCase(newCase){
    createCaseWithContactId({caseRecord:newCase})
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