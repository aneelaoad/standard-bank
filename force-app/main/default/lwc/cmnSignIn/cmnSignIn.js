import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import signInImage from '@salesforce/resourceUrl/ACM_Signin';
import isguest from '@salesforce/user/isGuest';

export default class CmnSignIn extends NavigationMixin(LightningElement){

    signinImage=signInImage;
    @api loginUrl;
    @api registrationUrl;
    @api hyperlink;
    @api signInButtonLabel;
    @api registerButtonLabel;
    isGuestUser = isguest;

    navigateToLogin(){
        var baseURL = basePath.substring(0, basePath.indexOf("/s"));
        document.location.href = `${baseURL}${this.loginUrl}`
    }

    navigateToRegistration(){
        document.location.href=this.registrationUrl;
    }

    get showButtons(){
        var registerButtonLabelVar =  this.registerButtonLabel;
        var registrationUrlVar =  this.registrationUrl;   

        if(registerButtonLabelVar && registrationUrlVar){
            return true;
        }else{
            return false;
        }              
    }
}