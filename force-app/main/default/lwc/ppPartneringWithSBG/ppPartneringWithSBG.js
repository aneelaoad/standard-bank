/**
* @description  : Partner Portal Partner Banefit Component
* User Story : SFP-5160
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
import { LightningElement, track , api} from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';

export default class PpPartneringWithSBG extends LightningElement {

    @api
    mainHeading;
    @api
    headingOne;
    @api
    headingTwo;
    @api
    headingThree;
    @api
    textOne;
    @api
    textTwo;
    @api
    textThree;
    @api
    faqHeading;
    @api
    faqSubHeading
    iconOne;
    iconTwo;
    iconThree;
    @track
    tabsNameDefaultClass = 'slds-tabs_default__item';
    tabsContentDefaultClass = 'slds-tabs_default__content slds-hide';
    newTabOneNameClass;
    newTabOneContentClass;
    newTabTwoNameClass;
    newTabTwoContentClass;

    //Initializing Images, Tabs and FAQs
    connectedCallback() {
        this.iconOne = Assets + '/Icons/registration-icon.png';
        this.iconTwo = Assets + '/Icons/discovery-icon.png';
        this.iconThree = Assets + '/Icons/onboarding-icon.png';

        this.newTabOneNameClass = this.tabsNameDefaultClass + ' slds-is-active';
        this.newTabOneContentClass = this.tabsContentDefaultClass.replace('slds-hide', 'slds-show');
        this.newTabTwoNameClass = this.tabsNameDefaultClass;
        this.newTabTwoContentClass = this.tabsContentDefaultClass;
    }

    //Handling Tab Click
     tabOneClick() {

        this.newTabOneNameClass = this.tabsNameDefaultClass + ' slds-is-active';
        this.newTabOneContentClass = this.tabsContentDefaultClass.replace('slds-hide', 'slds-show');
        this.newTabTwoNameClass = this.tabsNameDefaultClass;
        this.newTabTwoContentClass = this.tabsContentDefaultClass;
    }

    tabTwoClick() {

        this.newTabOneNameClass = this.tabsNameDefaultClass;
        this.newTabOneContentClass = this.tabsContentDefaultClass;
        this.newTabTwoNameClass = this.tabsNameDefaultClass + ' slds-is-active';
        this.newTabTwoContentClass = this.tabsContentDefaultClass.replace('slds-hide', 'slds-show');

    }
    
   

}