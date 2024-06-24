import {
  LightningElement,
  track,
  api
} from 'lwc';

import {
  loadStyle
} from 'lightning/platformResourceLoader';
import aob_theme from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import AOB_Cancel_Button from '@salesforce/label/c.AOB_Cancel';
import AOB_Exit_Application from '@salesforce/label/c.AOB_ExitApplication';
import AOB_Exit_Content from '@salesforce/label/c.AOB_ExitModal_Content';
import AOB_Exit_Title from '@salesforce/label/c.AOB_Exitbutton_Title';
import PBP_ZA_EXIT from '@salesforce/label/c.PBP_ZA_EXIT';
import PBP_ZA_Cancel_and_close from '@salesforce/label/c.PBP_ZA_Cancel_and_close';
import PBP_ZA_IfYouExit from '@salesforce/label/c.PBP_ZA_IfYouExit';
import PBP_ZA_No from '@salesforce/label/c.PBP_ZA_No';
import PBP_ZA_YesImsure from '@salesforce/label/c.PBP_ZA_YesImsure';
import PBP_ZA_SbBankApp from '@salesforce/label/c.PBP_ZA_SbBankApp';
import PBP_ZA_ProductSiteBaseURL from '@salesforce/label/c.PBP_ZA_ProductSiteBaseURL';
export default class Pbp_comp_ao_onboarding_theme_layout extends LightningElement {
  logo = AOB_ThemeOverrides + '/assets/logos/sbg-logo.svg';

  isLoaded = true;
  isEventFired;
  adobePageTag = {
    pageName: "pre-application form",
    dataId: "link_content",
    dataIntent: "navigational",
    dataScope: "pre-application ",
    closeButtonText: " close button click",
    YesImsureButtonText: " Yes,I'msure button click",
    continueButtonText: " No,I'd like to continue button click",
    exitbuttontext:PBP_ZA_EXIT+"button click"
  }
  applestore = aob_theme + '/assets/images/app-store-badge.png';
  googleplay = aob_theme + '/assets/images/google-play-badge.png';
  appsnapshot = aob_theme + '/assets/images/app.png';


  label = {
    AOB_Cancel_Button,
    AOB_Exit_Application,
    AOB_Exit_Content,
    AOB_Exit_Title,
    PBP_ZA_EXIT,
    PBP_ZA_Cancel_and_close,
    PBP_ZA_IfYouExit,
    PBP_ZA_No,
    PBP_ZA_YesImsure,
    PBP_ZA_SbBankApp,
    PBP_ZA_ProductSiteBaseURL
  };

  @api customContent;
  @track error;
  @track message;
  @track AOB_accountsUrl__c;
  @api applicationId;
  @api isShowingCloseButton;
  @api recordId;

  @track isModalOpen = false;
  customFormModal = true;
  connectedCallback() {

    loadStyle(this, AOB_ThemeOverrides + '/styleDelta.css')
      .then(() => {
        this.isRendered = true;

      })
      .catch(error => {

      });


  }
  get getOpenClosePageModal() {
    return this.isShowingCloseButton && this.openClosePageModal;
  }

  /**
   * @description method to handle exit of application.
  */
  exitApplication(event) {
    window.fireButtonClickEvent(this, event);
    window.open(PBP_ZA_ProductSiteBaseURL + "/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts", "_self");

  }

  /**
   * @description method to handle cancel button.
  */
  closeModal(event) {
    window.fireButtonClickEvent(this, event);
    this.isModalOpen = false;
  }

  /**
   * @description method to handle exit pop-up window.
   */
  openPopup(event) {
    this.getAppDataAndFire(event);
    this.isVisible = true;
  }
  constructor() {
    super();
    this.isMobileDevice = window.matchMedia("only screen and (max-width: 576px)").matches;
  }
  openModel(event) {
    window.fireButtonClickEvent(this, event);
    this.isModalOpen = true;
  }
}