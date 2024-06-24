import { LightningElement, api, wire } from 'lwc';
import getUserDetails from '@salesforce/apex/OSB_RequestPage_CTRL.getUserDetails';
import CaseCheck from '@salesforce/apex/OSB_RequestPage_CTRL.caseCheck';
import createCaseWithContactId from '@salesforce/apex/OSB_RequestPage_CTRL.createCaseWithContactId';
import { NavigationMixin } from "lightning/navigation";
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class osbSolutionBanner extends NavigationMixin (LightningElement) {
    @api link;
    @api provider;
    @api title;
    @api content;
    @api image;
    @api solutionLogo;
    @api mainContent;

    @api btnColour;
    @api btnStyle;
    @api btnStyleOneHub;
    @api showOneHubBtn;
    @api subContent;
    @api linkLabel;
    @api backgroundColor;
    @api contentStyle;
    @api setClassForImage = 'margin-left:90px;,padding-top:50px;';

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
        this.template.querySelector('[data-id="section"]').style.backgroundColor = this.backgroundColor;
        this.template.querySelector('.container__paragraph').style = this.contentStyle;

        this.adobeText = ('Landing Page | ' + this.title + ' | ' + this.linkLabel); 
        let styleArray = this.setClassForImage.split(',');
        let imageStyleComp = '';
        
        styleArray.forEach(element => {
            imageStyleComp += element;
        });
        this.template.querySelector('[data-id="image-container"]').style = imageStyleComp; 

        this.RequestButtonAdobe =  this.solutionName + " | request access";
        addAnalyticsInteractions(this.template);
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
            if(this.fullName && this.email && this.companyName && this.cellphone && this.RequestNotComplete ){
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
                this.createCase(newCase);
                this.returnToOnavigateToExternalLink(); 
        
            }
            if(!this.RequestNotComplete){
                this.returnToOnavigateToExternalLink(); 
            }
    }

    createCase(newCase){
        createCaseWithContactId({caseRecord:newCase})
        this.RequestNotComplete = false;
                
    }


    returnToOnavigateToExternalLink() {
        const config = {
            type: 'standard__webPage',
            attributes: {
                url:this.link
            }
        };
        this[NavigationMixin.Navigate](config);
    }
}