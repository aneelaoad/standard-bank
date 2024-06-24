import { LightningElement, api, wire } from 'lwc';
import createUserSubscribedSolution from '@salesforce/apex/OSB_Modal_CTRL.createUserSubscribedSolution';
import OSB_Logo from '@salesforce/resourceUrl/OSB_logoBadge';
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import ApplicationRefresh from '@salesforce/messageChannel/osbApplicationRefresh__c';
import eventCompChannel from '@salesforce/messageChannel/osbMenuEvents__c';
import eventChannel from '@salesforce/messageChannel/osbInterCompEvent__c';
import getImageURL from '@salesforce/apex/OSB_SolutionCaseImage.getImageURL';
import getProviderSpaces from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getProviderSpaces';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
import PROVIDER_CHANNEL from '@salesforce/messageChannel/Provider_Channel__c';

export default class OsbModallwc extends NavigationMixin(LightningElement) {
    SBlogo = OSB_Logo;
    oneHubBaseURL;
    modalissolution = true;
    modalissolutionTwo = true;
    thirdParty = false;
    solTM = false;
    disabled = false;
    buttonChange = false;
    buttonChangeTwo = false;
    ModalSignupText;
    ModalVisitText;
    ModalAddAppText;
    tps = false;
    goToPge = false;
    @api isopen;
    @api apiDocAvailable;
    @api modallogo;
    @api modaltype;
    @api modaltitle;
    @api modalcontent;
    @api firstButtonLabel;
    @api modalfirstbuttonurl;
    @api modalscndbuttonurl;
    @api recordid;
    @api isProductHighlight = false;
    @api displaySecondButton = false;
    @api isonshowcase = false;
    @api currenttab = 'Dashboard';
    @api applicationowner;
    @api urlname;
    @api providerid;
    @api title;    
    @api isproviderexit;  
    @api solutionid;
    @api providerexit;
    @api stopduplicate ;
    exitProvider = false;
    displayProvider = [];
    value = '';
    iconImage;
    providerspace = false;
    @api providertitle;


    get getSolutionId() {
        return this.solutionid;
    }

   
    @wire(MessageContext)
    messageContext;

    renderedCallback() {
        addAnalyticsInteractions(this.template);
        if (this.applicationowner === '3rd Party') {
            this.thirdParty = true;
            let imageUrl = this.modallogo;
            getImageURL({ url: imageUrl })
                .then((data) => {
                    if (data) {
                        this.iconImage = data;
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
        } else {
            this.thirdParty = false;
        }
        if (this.modaltitle === 'AUTHENTIFI') {
            this.solTM = true;
        } else {
            this.solTM = false;
        }

        if (this.modaltitle === 'My Support') {
            this.buttonChange = true;
        } else {
            this.buttonChangeTwo = true;
        }
        if (this.providerid) {            
            this.providerspace = true;
        }else{
            this.providerspace = false;
                    }
        if (this.isproviderexit) {
            this.exitProvider = true;
            this.providerspace = false;
            this.modalissolutionTwo = false;
        }

        this.ModalSignupText = this.modaltitle + ' Modal | Sign Up';
        this.ModalVisitText = this.modaltitle + ' Modal | Visit Website';
        this.ModalAddAppText =
            this.modaltitle + ' Application Modal | Add solution';
    }

    closeModel() {
        this.template
            .querySelector('[data-id="Modal"]')
            .classList.toggle('close');
        setTimeout(() => {
            this.dispatchEvent(new CustomEvent('close'));
        }, '500');
    }

    openfirsturl() {
        let urlToOpen = this.modalfirstbuttonurl;
        window.open(urlToOpen);
        this.isopen = false;
        document.body.style.overflow = 'auto';
        this.dispatchEvent(new CustomEvent('close'));
    }

    opensecondurl() {
        let urlToOpen = this.modalscndbuttonurl;
        if (this.modalissolution) {
            window.open(urlToOpen);
        } else {
            let urlArray = String(urlToOpen).split('=');
            let urlStateValue = urlArray[1];
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'API_Details__c'
                },
                state: {
                    apiId: urlStateValue
                }
            });
        }
        this.isopen = false;
        document.body.style.overflow = 'auto';
        this.dispatchEvent(new CustomEvent('close'));
    }
    openmarketplace() {
        if (this.modaltype === 'secondLevel') {
            this.isopen = false;
            document.body.style.overflow = 'auto';
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Home'
                },
                state: {
                    activeTab: 'BeHeard'
                }
            });
        }
    }

    @wire(getProviderSpaces, { providerId: '$providerid' })
    getProviderSpace({ error, data }) {
        if (data) {
            this.record = data;
            let articles = JSON.parse(JSON.stringify(this.record));        
            let provider = [];
            for (let j = 0; j < articles.length; j++) {
                provider.push(articles[j]);
            }
            this.displayProvider = provider;            
        } else if (error) {
            this.error = error;
        }
    }

    addSolutionAsFavourite() {
        this.disabled = true;
        createUserSubscribedSolution({ solutionId: this.recordid }).then(
            (result) => {
                this.isopen = false;
                document.body.style.overflow = 'auto';
                const payload = {
                    ComponentName: 'Header',
                    Details: {
                        tabName: 'Dashboard'
                    }
                };
                publish(this.messageContext, eventCompChannel, payload);
                const payloadHeader = {
                    ComponentName: 'Header',
                    Details: {
                        Tab: 'Dashboard'
                    }
                };
                publish(this.messageContext, eventChannel, payloadHeader);
                const galleryPayLoad = { recordAdded: 'Application Added' };
                publish(
                    this.messageContext,
                    ApplicationRefresh,
                    galleryPayLoad
                );
                this.disabled = false;
            }
        );
    }

    goToProvider(event) {
        this.closeModel();
        const payload = {
            providerId: event.target.dataset.providerid,
            providerTitle: event.target.dataset.title,         
            applicationContent: event.target.dataset.content,
            modalfirstbuttonurl: this.modalfirstbuttonurl,
            
        };
        publish(this.messageContext, PROVIDER_CHANNEL, payload);
    }
}