import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getUserInfo from '@salesforce/apex/EAP_CTRL_HeaderHome.getUserInfo';
import HELLO_LABEL from '@salesforce/label/c.Eap_Hello_Label';

export default class EapHeaderHome extends NavigationMixin(LightningElement) {
    labels = {Hello: HELLO_LABEL};
    // hiddenMenuIsOpen = false;
    title = this.labels.Hello;
    userId;
    iconStart = customIcons + '/logo.svg';

    @wire(getUserInfo)
    wiredUser({ error, data }) {
        if (data) {
            this.title = this.labels.Hello+' ' + data.FirstName;
            this.userId = data.Id;
        } else if (error) {
            this.error = error;
        }
    }

    iconsEnd = [
        {
            Id:1,
            Url: customIcons + '/user.svg',
            Text: "Profile",
            Click: function() {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name:'Profile__c'
                    }
                });
            }
        }
    ]
}