import { LightningElement, track , api} from 'lwc';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getContacts from '@salesforce/apex/EAP_CTRL_ContactsPage.getContacts';

export default class EapContactsContent extends LightningElement {
    iconPhone = customIcons + '/phone.svg';
    iconEmail = customIcons + '/profileEmail.svg';

    @track isError = false;
    @track noData = false;
    @track elements = [];
    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
        this.loadElements();
    }

    loadElements(){
        getContacts({eventId: this.eventId})
        .then((data) => {
            if (data.length > 0) {
                for(let i=0; i<data.length; i++){
                    let dataContact = data[i];
                    let contact = {
                        Id: dataContact.id,
                        SupTitle: dataContact.name,
                        Title: dataContact.rol,
                        SubTitle: dataContact.title,
                        ExtraData: []
                    };
                    
                    if (dataContact.mainPhoto !== undefined){
                        contact.Img = dataContact.mainPhoto;
                    
                    }else{
                        contact.Initials = this.getInitials(contact.SupTitle);
                    }
    
                    if (dataContact.phone){
                        contact.ExtraData.push({
                            Icon: this.iconPhone,
                            Value: dataContact.phone,
                            Rute: 'tel:'+dataContact.phone
                        })
                    }
    
                    if (dataContact.email){
                        contact.ExtraData.push({
                            Icon: this.iconEmail,
                            Value: dataContact.email,
                            Rute: 'mailto:'+dataContact.email
                        })
                    }
    
                    this.elements.push(contact);
                }
            } else {
                this.noData = true;
            }
        })
        .catch((error) => {
            this.isError = true;
        });
        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }

    getInitials(fullName){
        let fullNameArray = fullName.split(" ");
        let initials = '';

        fullNameArray.forEach(name => {
            initials += name[0];
        })

        return initials;
    }
}