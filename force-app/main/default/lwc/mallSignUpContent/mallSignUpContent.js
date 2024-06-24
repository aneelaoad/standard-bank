import { LightningElement, api, wire, track } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import USER_LANGUAGE_CHANGED_EVT from "@salesforce/messageChannel/UserLanguageChanged__c";
import { getCookie } from "c/cmnCookieUtils";
import { mallStateName, setUserState, getUserState } from "c/sbgUserStateUtils";
import pingCountries from "@salesforce/label/c.Countries_With_Ping";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";
import mallStaticBanners from "@salesforce/resourceUrl/MallStaticBanners";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { MallTranslationService } from "c/mallTranslationService";
import MALL_SIGNUP_TITLE from "@salesforce/label/c.MALL_SIGNUP_TITLE";
import MALL_SIGN_UP_WHATISTHIS from "@salesforce/label/c.MALL_SIGN_UP_WHATISTHIS";
import MALL_JOIN_MESSAGE_SHOPPER from "@salesforce/label/c.MALL_JOIN_MESSAGE_SHOPPER";
import MALL_AGREEMENT_MESSAGE from "@salesforce/label/c.MALL_AGREEMENT_MESSAGE";
import MALL_EXISTING_WELCOME_LABEL from "@salesforce/label/c.MALL_EXISTING_WELCOME_LABEL";
import MALL_EXISTING_WELCOME_DETAILS from "@salesforce/label/c.MALL_EXISTING_WELCOME_DETAILS";
import MALL_NEW_USER_TEXT from "@salesforce/label/c.MALL_NEW_USER_TEXT";
import MALL_BACK_BUTTON from "@salesforce/label/c.MALL_BACK_BUTTON";
import MALL_SIGN_UP_CONTINUE from "@salesforce/label/c.MALL_SIGN_UP_CONTINUE";
import MALL_ALREADY_REIGSTERED from "@salesforce/label/c.MALL_ALREADY_REIGSTERED";
import MALL_SIGN_IN from "@salesforce/label/c.MALL_SIGN_IN";
import MALL_SIGN_UP from "@salesforce/label/c.MALL_SIGN_UP";
import MALL_TERMS_OF_SERVICE from "@salesforce/label/c.MALL_TERMS_OF_SERVICE";
import MALL_DIVIDER_TEXT from "@salesforce/label/c.MALL_DIVIDER_TEXT";
import DEFAULT_MALL_COUNTRY from "@salesforce/label/c.DEFAULT_MALL_COUNTRY";
import MALL_EXISTING_WELCOME_NOT_PING_LABEL from "@salesforce/label/c.MALL_EXISTING_WELCOME_NOT_PING_LABEL";
import MALL_EXISTING_WELCOME_NOT_PING_DETAILS from "@salesforce/label/c.MALL_EXISTING_WELCOME_NOT_PING_DETAILS";

export default class MallSignUpContent extends NavigationMixin(
  LightningElement
) {
  @track pingCountry = true;
  @api newUserTextString;
  @api existingUserTextString;
  dividerText = MALL_DIVIDER_TEXT;
  imgUrl = mallStaticBanners + "/sbg_bcb_platform_background_register.png";
  subscription = null;
  selectedLanguageISOCode;
  signInUrl = getBaseUrl() + "/mall/services/auth/sso/mall_ping_custom";
  signUpUrl =
    getBaseUrl() + "/mall/services/auth/sso/mall_pingRegistrationProvider";
  navigateToWebPage = navigateToWebPage.bind(this);

  signUpTitle = MALL_SIGNUP_TITLE;
  whatIsThis = MALL_SIGN_UP_WHATISTHIS;
  joinMessageShopper = MALL_JOIN_MESSAGE_SHOPPER;
  agreementMessage = MALL_AGREEMENT_MESSAGE;
  existingUserWelcomeLabel = MALL_EXISTING_WELCOME_LABEL;
  existingUserWelcomeDetailsLabel = MALL_EXISTING_WELCOME_DETAILS;
  existingUserWelcomeNotPingLabel = MALL_EXISTING_WELCOME_NOT_PING_LABEL;
  existingUserWelcomeDetailsNotPingLabel =
    MALL_EXISTING_WELCOME_NOT_PING_DETAILS;
  newUserTextLabel = MALL_NEW_USER_TEXT;
  backButton = MALL_BACK_BUTTON;
  signUpButtonLabel = MALL_SIGN_UP;
  signUpContinueButton = MALL_SIGN_UP_CONTINUE;

  alreadyRegistered = MALL_ALREADY_REIGSTERED;
  signInText = MALL_SIGN_IN;
  termsOfService = MALL_TERMS_OF_SERVICE;

  isTenant = false;
  titleApplyTrue = false;

  sbLogoImage = sbgVisualAssets + "/sbg_bcb_platform_logo_register_shield.svg";

  get joineMessage() {
    return this.joinMessageShopper;
  }

  get existingUserWelcome() {
    if (this.pingCountry) {
      return this.existingUserWelcomeLabel;
    } else {
      return this.existingUserWelcomeNotPingLabel;
    }
  }

  get existingUserWelcomeDetails() {
    if (this.pingCountry) {
      return this.existingUserWelcomeDetailsLabel;
    } else {
      return this.existingUserWelcomeDetailsNotPingLabel;
    }
  }

  get newUserText() {
    return this.newUserTextLabel;
  }

  get existingUserText() {
    return this.existingUserWelcomeDetailsLabel;
  }

  toggleAccordion(event) {
    const elementTarget = event.target;
    if (
      elementTarget.classList.contains("open") ||
      elementTarget.closest(".accordion").classList.contains("open")
    ) {
      elementTarget.classList.contains(".accordion")
        ? elementTarget.classList.remove("open")
        : elementTarget.closest(".accordion").classList.remove("open");
      return;
    }
    elementTarget.classList.contains(".accordion")
      ? elementTarget.classList.add("open")
      : elementTarget.closest(".accordion").classList.add("open");
  }

  connectedCallback() {
    this.getTranslatedLabels();
    this.subscribeToMessageChannel();
    this.country = this.readCountryFromCookie();
  }

  //Code to setup the translations for the labels
  tokenVsLabelsObject = {
    // signUpTitle: "MALL_SIGNUP_TITLE",
    // whatIsThis: "MALL_SIGN_UP_WHATISTHIS",
    // joinMessageShopper: "MALL_JOIN_MESSAGE_SHOPPER",
    // agreementMessage: "MALL_AGREEMENT_MESSAGE",
    // alreadyRegistered: "MALL_ALREADY_REIGSTERED",
    // signInText: "MALL_SIGN_IN",
    // dividerText: "MALL_DIVIDER_TEXT",
    // termsOfService: "MALL_TERMS_OF_SERVICE",
    // existingUserWelcomeLabel: "MALL_EXISTING_WELCOME_LABEL",
    // existingUserWelcomeDetailsLabel: "MALL_EXISTING_WELCOME_DETAILS",
    // newUserTextLabel: "MALL_NEW_USER_TEXT",
    // signUpButtonLabel: "SIGN_UP_BUTTON_LABEL",
    // backButton: "MALL_BACK_BUTTON",
    // signUpContinueButton: "MALL_SIGN_UP_CONTINUE",
    // existingUserWelcomeNotPingLabel: "MALL_EXIST_WELCOME_NOT_PING_LABEL",
    // existingUserWelcomeDetailsNotPingLabel: "MALL_EXIST_WELCOME_NOT_PING_DETAIL"
  };

  //get the translated labels
  async getTranslatedLabels() {
    try {
      const translatedLabelsInstance = MallTranslationService.getInstance();
      const translatedLabels =
        await translatedLabelsInstance.getTranslatedLabels();
      this.setUpTranslatedLabels(translatedLabelsInstance);
    } catch (error) {
      this.error = error;
    }
  }

  // Method to create and setting up labels as properties
  setUpTranslatedLabels(translatedLabelsInstance, translatedLabels) {
    //Add translation for defined tokenVsLabelsObject
    if (this.tokenVsLabelsObject) {
      for (let property in this.tokenVsLabelsObject) {
        const value = translatedLabelsInstance.getTranslatedLabelByLabelName(
          this.tokenVsLabelsObject[property],
          translatedLabels
        );
        this[property] = value ? value : this[property];
      }
    }
  }

  readCountryFromCookie() {
    let country = getUserState(
      mallStateName.mallUserSelectedCountry,
      DEFAULT_MALL_COUNTRY
    );
    this.pingCountry = pingCountries.split(";").includes(country)
      ? true
      : false;
    return getCookie("mallCountry") || DEFAULT_MALL_COUNTRY;
  }

  @api async refresh() {
    this.country = this.readCountryFromCookie();
  }

  @wire(MessageContext)
  messageContext;

  handleLanguageChange(message) {
    let languageISOCode = message.languageISOCode;
    this.selectedLanguageISOCode = languageISOCode;
    setUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      this.selectedLanguageISOCode
    );
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        USER_LANGUAGE_CHANGED_EVT,
        (message) => this.handleLanguageChange(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  goBack() {
    if (history.length > 2) {
      history.back();
    } else {
      this.navigateToWebPage(getBaseUrl() + "/mall/s");
    }
  }

  goToLegal(event) {
    event.preventDefault();
    this.navigateToWebPage(getBaseUrl() + "/mall/s/legal?tab=4");
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    this.currentPageReference = currentPageReference;
    if (currentPageReference) {
      let target = currentPageReference.state["target"];
      if (target == "tenant") {
        this.isTenant = true;
      }
    }
  }
}