import { LightningElement,wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import userIsActiveFld from '@salesforce/schema/User.IsActive';
import userAliasFld from '@salesforce/schema/User.Alias';

export default class MallSignin extends LightningElement {
    userId = Id;
    currentUserName;
    currentUserEmailId;
    currentIsActive;
    currentUserAlias;
    error;

    displayName = 'Sign in';

    @wire(getRecord, { recordId: Id, fields: [UserNameFld, userEmailFld, userIsActiveFld, userAliasFld ]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserEmailId = data.fields.Email.value;
            this.currentIsActive = data.fields.IsActive.value;
            this.currentUserAlias = data.fields.Alias.value;
            this.displayName = this.currentUserName;

        } else if (error) {
            this.error = error ;
            console.log(this.error);
        }      
    }

    handleOpenSignIn(){
        window.dispatchEvent(new CustomEvent('opensignin', {detail:{view:'signin'}}));
    }
}