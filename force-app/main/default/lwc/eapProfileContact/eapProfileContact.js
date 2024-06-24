import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import FIND_OUR_INFORMATION_LABEL from '@salesforce/label/c.Eap_FindOurInformation_Label';
import RELATIONSHIP_MANAGER_LABEL from '@salesforce/label/c.Eap_RelationshipManager_Label';
import LOCAL_LABEL from '@salesforce/label/c.Eap_Local_Label';
import LOCAL_PHONE_LABEL from '@salesforce/label/c.Eap_LocalPhone_Label';
import INTERNATIONAL_LABEL from '@salesforce/label/c.Eap_International_Label';
import INTERNATIONAL_PHONE_LABEL from '@salesforce/label/c.Eap_InternationalPhone_Label';
import EMAIL_LABEL from '@salesforce/label/c.Eap_Email_Label';
import EMAIL_VALUE_LABEL from '@salesforce/label/c.Eap_EmailValue_Label';

export default class EapProfileContact extends NavigationMixin(LightningElement) {
    labels = {FindOurInfo: FIND_OUR_INFORMATION_LABEL, RelationshipManager: RELATIONSHIP_MANAGER_LABEL, Email: EMAIL_LABEL,
            Local: LOCAL_LABEL, International: INTERNATIONAL_LABEL, EmailValue: EMAIL_VALUE_LABEL, LocalPhone: LOCAL_PHONE_LABEL, InternationalPhone: INTERNATIONAL_PHONE_LABEL};
    emailIcon = customIcons +'/profileEmail.svg';
    phoneIcon = customIcons +'/profilePhone.svg';

    get elements() {
        let contacts = [{
                        Id: 1,
                        Title: this.labels.Local,
                        Subtitle: this.labels.LocalPhone,
                        IconStart: this.phoneIcon,
                        IconEnd: "utility:chevronright",
                        Link: "tel:" + this.labels.LocalPhone
                    },
                    {
                        Id: 2,
                        Title: this.labels.International,
                        Subtitle: this.labels.InternationalPhone,
                        IconStart: this.phoneIcon,
                        IconEnd: "utility:chevronright",
                        Link: "tel:" + this.labels.InternationalPhone
                    },
                    {
                        Id: 3,
                        Title: this.labels.Email,
                        Subtitle: this.labels.EmailValue,
                        IconStart: this.emailIcon,
                        IconEnd: "utility:chevronright",
                        Link: "mailto:" + this.labels.EmailValue,
                        isEmail: true
                    }
                ]
    
        return contacts;
    }
}