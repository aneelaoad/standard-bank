import {
    LightningElement,
    wire,
    api
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';
import caseCheck from '@salesforce/apex/OSB_RegistrationRequest_Ctrl.caseCheck';
import saveCase from '@salesforce/apex/OSB_RegistrationRequest_Ctrl.saveCase';
import checkDuplicate from '@salesforce/apex/OSB_RegistrationRequest_Ctrl.checkDuplicate';
export default class OsbRegistrationRedirectLwc extends NavigationMixin(LightningElement) {

    reasonForPopup;
    redirectAfterSubmit = false;
    showToastFailure = false;
    showToastSuccess = false;
    showPopUp = false;
    subMittingCase = false;
    showLoading = false;
    RegistrationNotComplete = true;
    value = 'South Africa +27';
    caseResult;
    contacts
    regCase;
    showSigninredirect = false;
    caseFound = false;
    Cases;
    @api signinredirect;
    newCase = {
        sobjectType: "Case"
    };
    contact = {
        sobjectType: "Contact"
    };

    checkForContact() {
        checkDuplicate({
            cont: this.contact
        }).then(result => {
            let contactFound = JSON.parse(JSON.stringify(result));
            let emailCmp = this.template.querySelector(".email");
            if (contactFound === true) {
                emailCmp.setCustomValidity("There is an existing account with this email address. Please sign in below to access your account or request a new password.");
                emailCmp.reportValidity();
                this.showSigninredirect = true;
                this.showLoading = false
            } else {
                this.showSigninredirect = false;
                this.checkForCase();
            }
        }).catch(error => {
            this.error = error;
        });
    }

    checkForCase() {
        caseCheck({
            email: this.newCase.SuppliedEmail,
            subject: this.newCase.Subject
        })
            .then(result => {
                let caseFound = JSON.parse(JSON.stringify(result));
                let emailCmp = this.template.querySelector(".email");
                if (caseFound === true) {
                    emailCmp.setCustomValidity("We're sorry, but it appears that we have already received a registration request using this email address. Please check your email inbox, including your spam or junk folders, for any previous correspondence from us. If you believe this is an error, or if you need further assistance, please contact our support team at onehub@standardbank.co.za. Thank you.");
                    emailCmp.reportValidity();
                    this.showLoading = false;
                } else {
                    this.callCapture();
                }
            }).catch(error => {
                this.error = error;
            });
    }

    createCase() {
        let newCase = this.newCase;
        saveCase({
            regCase: newCase
        }).then(result => {
            this.caseResult = result;
            this.showLoading = false;
            this.showToastSuccess = true;
            {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: "Nearly_there__c"
                    },
                });
            }
        }).catch(error => {
            this.error = error;
        });
    }

    signUp() {
        if (!this.showLoading) {
            const validateEmail = email => /^[^@ ]+@[^@ ]+\.[^@ \.]+$/.test(email);
            const isValidEmail = value => validateEmail(value);
            let firstNameField = this.template.querySelector(`[data-id="FirstName"]`);
            let firstName = firstNameField ? firstNameField.value : "";
            let lastNameField = this.template.querySelector(`[data-id="LastName"]`);
            let lastName = lastNameField ? lastNameField.value : "";
            let cellphoneField = this.template.querySelector(`[data-id="Cellphone"]`);
            let dialingCodeField = this.template.querySelector(`[data-id="dialingCode"]`);
            let dialingCode = dialingCodeField ? dialingCodeField.value : "";
            let cellphone = cellphoneField ? cellphoneField.value : "";
            let emailField = this.template.querySelector(`[data-id="Email"]`);
            let email = emailField ? emailField.value : "";
            let jobTitleField = this.template.querySelector(`[data-id="jobtitle"]`);
            let jobTitle = jobTitleField ? jobTitleField.value : "";
            let companyNameField = this.template.querySelector(`[data-id="company"]`);
            let companyName = companyNameField ? companyNameField.value : "";
            let caseSwitch = false;
            let isAllValid = false;
            if (firstName === '') {
                let firstNameFld = this.template.querySelector(".firstName");
                firstNameFld.setCustomValidity("Please enter a valid name");
                firstNameFld.reportValidity();
            } else {
                this.template.querySelector(".firstName").setCustomValidity("");
                this.template.querySelector(".firstName").reportValidity();
            }
            if (lastName === '') {
                let lastNameFld = this.template.querySelector(".surname");
                lastNameFld.setCustomValidity("Please enter a valid Surname");
                lastNameFld.reportValidity();
            } else {
                this.template.querySelector(".surname").setCustomValidity("");
                this.template.querySelector(".surname").reportValidity();
            }
            if (cellphone === '') {
                let cellphoneFld = this.template.querySelector(".cellphone");
                cellphoneFld.setCustomValidity("Please enter a valid cellphone number");
                cellphoneFld.reportValidity();
            } else {
                this.template.querySelector(".cellphone").setCustomValidity("");
                this.template.querySelector(".cellphone").reportValidity();
            }
            if (email === '') {
                let emailFld = this.template.querySelector(".email");
                emailFld.setCustomValidity("Please enter a valid email");
                emailFld.reportValidity();
            } else if (!isValidEmail(email)) {
                let emailFld = this.template.querySelector(".email");
                emailFld.setCustomValidity('It seems an entered email address is not valid. Please review and try again!');
                emailFld.reportValidity();
            } else {
                this.template.querySelector(".email").setCustomValidity("");
                this.template.querySelector(".email").reportValidity();
            }
            if (jobTitle === '') {
                let jobTitleFld = this.template.querySelector(".jobTitle");
                jobTitleFld.setCustomValidity("Please enter a valid job title");
                jobTitleFld.reportValidity();
            } else {
                this.template.querySelector(".jobTitle").setCustomValidity("");
                this.template.querySelector(".jobTitle").reportValidity();
            }
            if (companyName === '') {
                let companyNameFld = this.template.querySelector(".companyName");
                companyNameFld.setCustomValidity("Please enter a valid company name");
                companyNameFld.reportValidity();
            } else {
                this.template.querySelector(".companyName").setCustomValidity("");
                this.template.querySelector(".companyName").reportValidity();
            }
            if (firstName !== '' && lastName !== '' !== '' && cellphone !== '' && email !== '' && jobTitle !== '' && companyName !== '' && this.RegistrationNotComplete && isValidEmail(email)) {
                isAllValid = false;
                caseSwitch = true;
            } else {
                isAllValid = true;
            }
            if (isAllValid) {
                let redirectAfterSubmit = this.redirectAfterSubmit;
                if (redirectAfterSubmit) {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            pageName: "Nearly_there__c"
                        },
                    });
                } else {
                    if (!this.showToastFailure) {
                        window.scrollTo(0, 0);
                        this.showToastFailure = true;
                        setTimeout(() => {
                            this.showToastFailure = false;
                        }, 5000);
                    } else {
                        this.template.querySelector('c-osb-toast').opentoast();
                    }
                }

                return;
            } else if (caseSwitch) {
                this.showLoading = true;
                let contact = this.contact;
                contact.Email = email;
                contact.OSB_Community_Access_Status__c ='Approved';
                this.subMittingCase = true;
                let subject = 'Registration Request';
                let origin = "Web";
                let status = "New";
                let newCase = this.newCase;
                newCase.Subject = subject;
                newCase.Origin = origin;
                newCase.Status = status;
                newCase.SuppliedEmail = email;
                newCase.SuppliedName = firstName + ' ' + lastName;
                newCase.SuppliedPhone = dialingCode + '-' + cellphone;
                newCase.SuppliedCompany = companyName;
                newCase.User_Job_Title__c = jobTitle;
                newCase.Status = 'New';
                newCase.Subject = 'OneHub - ' + subject;
                newCase.Type = 'OneHub Registration';
                this.newCase = newCase;
                if (this.newCase) {
                    this.checkForContact();
                }
            } else {
                if (!this.showToastFailure) {
                    window.scrollTo(0, 0);
                    this.showToastFailure = true;
                    setTimeout(() => {
                        this.showToastFailure = false;
                    }, 5000);
                } else {
                    this.template.querySelector('c-osb-toast').opentoast();
                }
            }
            return;
        }
    }

    cancel() {
        this.reasonForPopup = 'Cancel SignUp';
        this.titleForPopup = 'Cancel request?';
        this.contentForPopup = 'By doing so you will clear the form to it’s original state.';
        this.showPopUp = true;
    }
    handleInputChange(event) {
        const inputBox = event.currentTarget;
        inputBox.setCustomValidity('');
        inputBox.reportValidity();
    }
    handleCloseEvent(event) {
        let optionSelected = event.detail;
        if (optionSelected === "YES") {
            let reasonForPopup = this.reasonForPopup;
            if (reasonForPopup === 'Cancel SignUp') {
                this.template.querySelector('.firstName').value = '';
                this.template.querySelector('.surname').value = '';
                this.template.querySelector('.cellphone').value = '';
                this.template.querySelector('.email').value = '';
                this.template.querySelector('.jobTitle').value = '';
                this.template.querySelector('.companyName').value = '';
                location.reload()
            }
            this.showPopUp = false;
        } else {
            this.showPopUp = false;
        }
    }

    callCapture() {
        this.template.querySelector('[data-id="recaptureChild"]').doSubmit();
        document.addEventListener("checkvalue", (e) => {
            if (e.detail) {
                this.createCase();
            }
        });
    }


    get options() {
        return [
            { label: 'Afghanistan +93', value: '+93' },
            { label: 'Albania +355', value: '+355' },
            { label: 'Algeria +213', value: '+213' },
            { label: 'American Samoa +684', value: '+684' },
            { label: 'Andorra +376', value: '+376' },
            { label: 'Angola +244', value: '+244' },
            { label: 'Anguilla +809', value: '+809' },
            { label: 'Antigua +268', value: '+268' },
            { label: 'Argentina +54', value: '+54' },
            { label: 'Armenia +374', value: '+374' },
            { label: 'Aruba  +297', value: '+297' },
            { label: 'Ascension Island +247', value: '+247' },
            { label: 'Australia +61', value: '+61' },
            { label: 'Australian External Territories +672', value: '+672' },
            { label: 'Austria +43', value: '+43' },
            { label: 'Azerbaijan +994', value: '+994' },
            { label: 'Bahamas +242', value: '+242' },
            { label: 'Barbados +246', value: '+246' },
            { label: 'Bahrain +973', value: '+973' },
            { label: 'Bangladesh +880', value: '+880' },
            { label: 'Belarus +375', value: '+375' },
            { label: 'Belgium +32', value: '+32' },
            { label: 'Belize +501', value: '+501' },
            { label: 'Bermuda +809 ', value: '+809' },
            { label: 'Bhutan +975', value: '+975' },
            { label: 'British Virgin Islands +284', value: '+284' },
            { label: 'Bolivia +591', value: '+591' },
            { label: 'Bosnia and Hercegovina +387', value: '+387' },
            { label: 'Botswana +267', value: '+267' },
            { label: 'Brazil +55', value: '+55' },
            { label: 'British V.I. +284', value: '+284' },
            { label: 'Brunei Darussalm +673', value: '+673' },
            { label: 'Bulgaria +359', value: '+359' },
            { label: 'Burkina Faso +226', value: '+226' },
            { label: 'Burundi +257', value: '+257' },
            { label: 'Cambodia +855', value: '+855' },
            { label: 'Cameroon +237', value: '+237' },
            { label: 'Canada +1', value: '+1' },
            { label: 'CapeVerde Islands +238', value: '+228' },
            { label: 'Caribbean Nations +1', value: '+1' },
            { label: 'Cayman Islands +345', value: '+345' },
            { label: 'Cape Verdi +238', value: '+238' },
            { label: 'Central African Republic +236', value: '+236' },
            { label: 'Chad +235', value: '+235' },
            { label: 'Chile +56', value: '+56' },
            { label: "China (People's Republic) +86", value: '+ 86' },
            { label: "China-Taiwan +886", value: '+ 886' },
            { label: "Colombia +57", value: '+ 57' },
            { label: "Comoros and Mayotte +269", value: '+269' },
            { label: "Congo +242", value: '+ 242' },
            { label: "Cook Islands +682", value: '+ +682' },
            { label: "Costa Rica +506", value: '+506' },
            { label: "Croatia +385", value: '+385' },
            { label: "Denmark +45", value: '+45' },
            { label: "Diego Garcia +246", value: '+ 246' },
            { label: "Dominca +767", value: '+767' },
            { label: "Dominican Republic +809", value: '+809' },
            { label: "Djibouti +253", value: '+253' },
            { label: "Ecuador +593", value: '+593' },
            { label: "Egypt +20", value: '+20' },
            { label: "El Salvador +503", value: '+503' },
            { label: "Equatorial Guinea +240", value: '+240' },
            { label: "Eritrea +291", value: '+291' },
            { label: "Estonia +372", value: '+251' },
            { label: "Ethiopia +291", value: '+291' },
            { label: "Falkland Islands +500", value: '+500' },
            { label: "Faroe (Faeroe) Islands (Denmark) +298", value: '+298' },
            { label: "Fiji +679", value: '+679' },
            { label: "Finland +33", value: '+33' },
            { label: "France +291", value: '+291' },
            { label: "French Antilles +596", value: '+596' },
            { label: "France +291", value: '+291' },
            { label: "French Guiana +594", value: '+594' },
            { label: "Gabon (Gabonese Republic) +241", value: '+241' },
            { label: "Gambia +220", value: '+220' },
            { label: "Georgia +995", value: '+995' },
            { label: "Germany +49", value: '+49' },
            { label: "Ghana +594", value: '+594' },
            { label: "Gibraltar +350", value: '+350' },
            { label: "Greecea +30", value: '+30' },
            { label: "Greenland +299", value: '+299' },
            { label: "Grenada/Carricou +473", value: '+473' },
            { label: "Guam +671", value: '+671' },
            { label: "Guatemala +502", value: '+502' },
            { label: "Guinea +224", value: '+224' },
            { label: "Guinea-Bissau +245", value: '+245' },
            { label: "Guyana +592", value: '+592' },
            { label: "Haiti +509", value: '+509' },
            { label: "Honduras +504", value: '+504' },
            { label: "Hong Kong +852", value: '+852' },
            { label: "Hungary +36", value: '+36' },
            { label: "Iceland +354", value: '+354' },
            { label: "India +91", value: '+91' },
            { label: "Indonesia +62", value: '+62' },
            { label: "Iran +98", value: '+98' },
            { label: "Iraq +964", value: '+964' },
            { label: "Ireland (Irish Republic; Eire) +353", value: '+353' },
            { label: "Israel +39", value: '+39' },
            { label: "Italy +353", value: '+353' },
            { label: "Ivory Coast (La Cote d'Ivoire) +225", value: '+225' },
            { label: "Jamaica +876", value: '+876' },
            { label: "Japan +81", value: '+81' },
            { label: "Jordan", value: '+962' },
            { label: "Kazakhstan  +7", value: '+7' },
            { label: "Kenya  +254", value: '+254' },
            { label: "Khmer Republic (Cambodia/Kampuchea)  +855", value: '+855' },
            { label: "Kiribati Republic (Gilbert Islands)  +686", value: '+686' },
            { label: "Korea, Republic of (South Korea)   +82", value: '+82' },
            { label: "Korea, People's Republic of (North Korea)  +850", value: '+850' },
            { label: "Kuwait   +965", value: '+965' },
            { label: "Kyrgyz Republic   +996", value: '+996' },
            { label: "Latvia  +371", value: '+371' },
            { label: "Lagos +856", value: '+856' },
            { label: "Lebanon  +961", value: '+961' },
            { label: "Liberia   +266", value: '++231' },
            { label: "Lithuani a   +370", value: '+370' },
            { label: "Libya   +218", value: '+218' },
            { label: "Liechtenstein   +423", value: '+423' },
            { label: "Luxembourg  +352", value: '+352' },
            { label: "Macao   +853", value: '+853' },
            { label: "Macedonia  +389", value: '+389' },
            { label: "Madagascar  +261", value: '+261' },
            { label: "Malawi  +265", value: '+265' },
            { label: "Malaysia  +60", value: '+60' },
            { label: "Maldives +960", value: '+960' },
            { label: "Mali   + 223", value: '+223' },
            { label: "Malta  +356", value: '+356' },
            { label: "Marshall Islands   +692", value: '+692' },
            { label: "Martinique (French Antilles)   +596", value: '+596' },
            { label: "Mauritania +222", value: '+222' },
            { label: "Mauritius  +230", value: '+230' },
            { label: "Mayolte  +269", value: '+269' },
            { label: "Mexico +52", value: '+52' },
            { label: "Moldova +373", value: '+373' },
            { label: "Monaco  +596", value: '+33' },
            { label: "Mongolia  +976", value: '+976' },
            { label: "MaMontserrat  +473", value: '+473' },
            { label: "Morocco  +212", value: '+212' },
            { label: "Mozambique  +258", value: '+258' },
            { label: "Myanmar (former Burma)  +95", value: '+95' },
            { label: "Namibia (former South-West Africa)  +264", value: '+264' },
            { label: "Nauru  +674", value: '+674' },
            { label: "Nepal  +977", value: '+977' },
            { label: "Netherlands Antilles  +599", value: '+599' },
            { label: "Nevis  +869", value: '+869' },
            { label: "New Caledonia  +687", value: '+687' },
            { label: "New Zealand  +64", value: "+64" },
            { label: "Nicaragua  +505", value: "+505" },
            { label: "Niger  +227", value: "+227" },
            { label: "Nigeria", value: "+234" },
            { label: "Niue  +683", value: "+683" },
            { label: "North Korea  +850", value: "+850" },
            { label: "North Mariana Islands (Saipan)  +1 670", value: "+1 670" },
            { label: "Norway  +47", value: "+47" },
            { label: "Oman   +968", value: "+968" },
            { label: "Pakistan  +92", value: "+92" },
            { label: "Palau  +680", value: "+680" },
            { label: "Panama  +507", value: "+507" },
            { label: "Papua New Guinea  +675", value: "+675" },
            { label: "Paraguay +595", value: "+595" },
            { label: "Peru   +51", value: "+51" },
            { label: "Philippines   +63", value: "+63" },
            { label: "Poland", value: "+48" },
            { label: "Portugal (includes Azores)  +351", value: "+351" },
            { label: "Puerto Rico  +1 787", value: "+1 787" },
            { label: "Qatar  +974", value: "+974" },
            { label: "Reunion (France)  +262", value: "+262" },
            { label: "Romania  +40", value: "+40" },
            { label: "Russia  +7", value: "+7" },
            { label: "Rwanda (Rwandese Republic)   +250", value: "+250" },
            { label: "Saipan  +670", value: "+670" },
            { label: "San Marino", value: "+378" },
            { label: "Sao Tome and Principe  +239", value: "+239" },
            { label: "Saudi Arabia  +966", value: "+966" },
            { label: "Senegal  +221", value: "+221" },
            { label: "Serbia and Montenegro", value: "+381" },
            { label: "Seychelles  +248", value: "+248" },
            { label: "Sierra Leone  +232", value: "+232" },
            { label: "Singapore  +65", value: "+65" },
            { label: "Slovakia  +421", value: "+421" },
            { label: "Slovenia  +386", value: "+386" },
            { label: "Solomon Islands  +677", value: "+677" },
            { label: "Somalia  +252", value: "+252" },
            { label: "South Africa  +27", value: "+27" },
            { label: "Spain +34", value: "+34" },
            { label: "Sri Lanka  +94", value: "+94" },
            { label: "St. Helena  +290", value: "+290" },
            { label: "St. Kitts/Nevis  +869", value: "+869" },
            { label: "St. Pierre &(et) Miquelon (France)  +508", value: "+508" },
            { label: "Sudan", value: "+249" },
            { label: "Surilabel  +597", value: "+597" },
            { label: "Swaziland  +268", value: "+268" },
            { label: "Sweden  +46", value: "+46" },
            { label: "Switzerland  +41", value: "+41" },
            { label: "Syrian Arab Republic (Syria) +963", value: "+963" },
            { label: "Tahiti (French Polynesia)  +689", value: "+689" },
            { label: "Taiwan  +886", value: "+886" },
            { label: "Tajikistan  +7", value: "+7" },
            { label: "Tanzania (includes Zanzibar)", value: "+255" },
            { label: "Thailand  +66", value: "+66" },
            { label: "Togo (Togolese Republic)  +228", value: "+228" },
            { label: "Tokelau +690", value: "+690" },
            { label: "Tonga  +676", value: "+676" },
            { label: "Trinidad and Tobago +1 868", value: "+1 868" },
            { label: "Tunisia  +216", value: "+216" },
            { label: "Turkey   +90", value: "+90" },
            { label: "Turkmenistan  +993", value: "+993" },
            { label: "Tuvalu (Ellice Islands) +688", value: "+688" },
            { label: "Uganda  +256", value: "+256" },
            { label: "Ukraine  +380", value: "+380" },
            { label: "United Arab Emirates  +971", value: "+971" },
            { label: "United Kingdom +44", value: "+44" },
            { label: "Uruguay +598", value: "+598" },
            { label: "USA  +1", value: "+1" },
            { label: "Uzbekistan  +7", value: "+7" },
            { label: "Vanuatu (New Hebrides)  +678", value: "+678" },
            { label: "Vatican City +39", value: "+39" },
            { label: "Venezuela +58", value: "+58" },
            { label: "Viet Nam  +84", value: "+84" },
            { label: "Virgin Islands +1 340", value: "+1 340" },
            { label: "Wallis and Futuna  +681", value: "+681" },
            { label: "Western Samoa  +685", value: "+685" },
            { label: "Yemen (People's Democratic Republic of) +381", value: "+381" },
            { label: "Yemen Arab Republic (North Yemen) +967", value: "+967" },
            { label: "Yugoslavia (discontinued)  +381", value: "+381" },
            { label: "Zaire +243", value: "+243" },
            { label: "Zambia +260", value: "+260" },
            { label: "Zimbabwe  +263", value: "+263" },
        ];
    }
}