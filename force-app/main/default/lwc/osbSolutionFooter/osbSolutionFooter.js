import { LightningElement,wire, api} from 'lwc';
import { addAnalyticsInteractions, pageViewSinglePageApp } from 'c/osbAdobeAnalyticsWrapperLwc';
import getOSBDocumentURL from '@salesforce/apex/OSB_RequestPage_CTRL.getOSBDocumentURL';
import getUserDetails from '@salesforce/apex/OSB_RequestPage_CTRL.getUserDetails';
import CaseCheck from '@salesforce/apex/OSB_RequestPage_CTRL.caseCheck';
import createCaseWithContactId from '@salesforce/apex/OSB_RequestPage_CTRL.createCaseWithContactId';
import { NavigationMixin } from "lightning/navigation";

export default class OsbSolutionFooter extends NavigationMixin (LightningElement) {
    @api btnlink;
    @api btnlabel;
    @api calltoactiontitle;
    @api background;
    @api backgroundbtm;
    @api btnColour;
    @api btnStyle = 'font-size:12px;';
    @api showFooterExt = 'false';
    @api solutionlogo;
    @api showFooterLogo;
    @api terms = 'https://corporateandinvestment.standardbank.com/cib/global/about-us/legal';
    @api legal = 'https://corporateandinvestment.standardbank.com/cib/global/about-us/legal';
    @api notices = 'https://corporateandinvestment.standardbank.com/cib/global/about-us/legal/important-notices';
    @api certification = 'https://corporateandinvestment.standardbank.com/cib/global/about-us/legal/usa-patriot-act-certification';
    @api questionnaire = 'https://corporateandinvestment.standardbank.com/cib/global/about-us/legal/wolfsberg-questionnaire';


    @api createCaseForExternalLink;
    @api sendEmailCheck = "false";
    @api solutionName;
    @api Email = "true";
    @api Company = "true";
    @api Mobile = "true";
    @api Region = "true";
    @api IdNumber = "true";

    fullName;
    email;
    companyName;
    cellphone;
    RequestButtonAdobe;
    RequestNotComplete;



    renderedCallback(){
        this.template.querySelector('[data-id="background"]').style.backgroundColor = this.background;
        this.template.querySelector('[data-id="background-bottom"]').style.backgroundColor = this.backgroundbtm;
        if(this.backgroundbtm){
            this.template.querySelector('[data-id="background-bottom"]').style.backgroundColor = this.backgroundbtm;
        }else{
            this.template.querySelector('[data-id="background-bottom"]').classList.add('hidden');
        }
        addAnalyticsInteractions(this.template);
    }

    connectedCallback(){
        let pagename = this.solutionName + ' Splash page';
        pageViewSinglePageApp(pagename);
    }

    
    @wire(getUserDetails) 
    contacts;

    @wire(getUserDetails) 
    getContact({ error, data }){
    if(data){ 
        this.fullName = data[0].FirstName +" "+ data[0].LastName ;
        this.companyName = data[0].OSB_Company_name__c;
        this.cellphone = data[0].Phone;
        this.email = data[0].Email;
    }else if(error){
        this.error = error;
    }
    this.checkForCase();
    };

    @wire(getOSBDocumentURL, {termsConditionsDoc: '$termsConditionsDoc'} )
    tAndCLink;

    checkForCase() {
        let sub = 'OneHub - ' + this.solutionName;
        CaseCheck({ email: this.email, subject: sub }).then((data) => {
            if (data) {
                if (data[0]) {
                    this.RequestNotComplete = false;
                }
                this.error = undefined;
            }
        });
    }

    requestAccess() { 
        if(this.RequestNotComplete === undefined){
            this.RequestNotComplete = true;
        }
        if(this.fullName && this.email && this.companyName && this.cellphone && this.RequestNotComplete){
            let origin = "Web";
            let status = "New";
                    let newCase ={
                    Origin : origin,
                    Status : status,
                    SuppliedEmail :this.email,
                    SuppliedName :this.fullName,
                    SuppliedPhone :this.cellphone,
                    SuppliedCompany :this.companyName,
                    Description :  this.solutionName+' sign up request',
                    Type :'OneHub ' + this.solutionName + ' Registration',
                    Subject :  'OneHub - '+this.solutionName
                    }      
                    
                    if (this.RequestNotComplete){
                        this.createCase(newCase);
                        this.returnToOnavigateToExternalLink(); 
                    }
                    
   
        }
        this.returnToOnavigateToExternalLink(); 
    }

    createCase(newCase){
    createCaseWithContactId({caseRecord:newCase})
    this.RequestNotComplete = false;
                
    }


    returnToOnavigateToExternalLink() {
        const config = {
            type: 'standard__webPage',
            attributes: {
                url:this.btnlink
            }
        };
        this[NavigationMixin.Navigate](config);
    }
   

}