import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getNavItems from "@salesforce/apex/SBGNavigationBarController.getNavItems";
import sendLoginAlertNotifications from "@salesforce/apex/SBGNavigationBarController.sendLoginAlertNotifications";
import getCountryList from "@salesforce/apex/SBGNavigationBarController.getCountryList";
import updateUserPreference from "@salesforce/apex/SBGNavigationBarController.updateUserPreference";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";
import NAME from "@salesforce/schema/User.Name";
import USER_COUNTRY from "@salesforce/schema/User.User_Franco__c";
import ID_FIELD from "@salesforce/schema/User.Id";
import IS_GUEST from "@salesforce/user/isGuest";
import loggedInUserId from "@salesforce/user/Id";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { getCookie, putCookie } from "c/cmnCookieUtils";
import { mallStateName, getUserState, setUserState } from "c/sbgUserStateUtils";
import {
  APPLICATION_SCOPE,
  MessageContext,
  publish,
  subscribe,
  unsubscribe
} from "lightning/messageService";
import USER_LANGUAGE_CHANGED_EVT from "@salesforce/messageChannel/UserLanguageChanged__c";
import USER_COUNTRY_CHANGED_EVT from "@salesforce/messageChannel/UserCountryChanged__c";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import USER_ID from "@salesforce/user/Id";
import getUserProfile from "@salesforce/apex/MallProfileManagementController.getUserProfile";
import updateSObjects from "@salesforce/apex/MallStorefrontManagementController.updateSObjects";
import {
  MallTranslationService,
  getTranslatedLabelByLabelName,
  getTranslatedLabelByMetadataId
} from "c/mallTranslationService";

//Translations
import FORM_FACTOR from "@salesforce/client/formFactor";
import DEFAULT_MALL_COUNTRY from "@salesforce/label/c.DEFAULT_MALL_COUNTRY";
import DEFAULT_MALL_LANGUAGE_ISO from "@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO";
import DEFAULT_MALL_LANGUAGE from "@salesforce/label/c.DEFAULT_MALL_LANGUAGE";
import MALL_SIGN_IN from "@salesforce/label/c.MALL_SIGN_IN";
import MALL_SIGN_UP from "@salesforce/label/c.MALL_SIGN_UP";
import MALL_SIGN_OUT from "@salesforce/label/c.MALL_SIGN_OUT";
import MALL_SIGN_UP_OR_SIGN_IN from "@salesforce/label/c.MALL_SIGN_UP_OR_SIGN_IN";
import MALL_GO_TO_SHOP from "@salesforce/label/c.MALL_GO_TO_SHOP";
import MALL_GO_TO_MALL from "@salesforce/label/c.MALL_GO_TO_MALL";
import MALL_MY_PROFILE from "@salesforce/label/c.MALL_MY_PROFILE";
import MALL_HELP_LABEL from "@salesforce/label/c.MALL_HELP_LABEL";
import MALL_MENU_LABEL from "@salesforce/label/c.MALL_MENU_LABEL";

export default class SbgNavigationBar extends NavigationMixin(
  LightningElement
) {
  @api enableCategory;
  topLeftNavItems = [];
  topRightNavItems = [];
  bottomLeftNavItems = [];
  bottomRightNavItems = [];
  countriesList = [];
  visibleCountriesList = [];

  mobileTabsList = [];
  renderCheck;

  saImage = sbgVisualAssets + "/flag-south-africa.svg";
  sbgLogoImage = sbgVisualAssets + "/sbg-header-logo.svg";
  userImage = sbgVisualAssets + "/sbg-people_1.svg";
  mobileLogo = sbgVisualAssets + "/SB_Logo_Transparent.png";

  showNavSubMenu = false;
  showShopMenu = false;
  showSignInMenu = false;
  showCountriesPopup = false;
  showCountriesMobilePopup = false;
  showLanguagesMobilePopup = false;
  showMobilePopupBackdrop = false;
  showLanguageDropDown = false;
  hasMultipleCountries = false;
  hasMultipleLangugages = false;
  userProfile;
  @track isStoreProfileEdit = undefined;
  @track isStoreProfileView = true;
  @track isStoreProfile = false;

  get visibilityClass() {
    return this.hasMultipleLangugages ? "slds-visible" : "slds-hidden";
  }

  selectedCountry = getUserState(
    mallStateName.mallUserSelectedCountry,
    DEFAULT_MALL_COUNTRY
  );
  selectedCountryFlag =
    sbgVisualAssets +
    "/flag-" +
    this.selectedCountry.toLowerCase().replace(" ", "-") +
    ".svg";

  selectedLanguage = DEFAULT_MALL_LANGUAGE;
  selectedLanguageISO = DEFAULT_MALL_LANGUAGE_ISO;

  languages = [];

  open = false;
  accountOpen = false;
  activeItem = "";
  activeSecondaryItem = "";
  activeTertiaryItem = "";
  expanded = false;

  headerHost = "";
  categoryDropdown = "";

  isFirstRender = true;
  customLabels = {};
  emailSent = false;
  isGuestUser = IS_GUEST;
  navigateToWebPage = navigateToWebPage.bind(this);

  signInText = MALL_SIGN_IN;
  signUpText = MALL_SIGN_UP;
  signUpOrSignInText = MALL_SIGN_UP_OR_SIGN_IN;
  signOutText = MALL_SIGN_OUT;
  goToShopText = MALL_GO_TO_SHOP;
  goToMallText = MALL_GO_TO_MALL;
  myProfileText = MALL_MY_PROFILE;
  helpLabel = MALL_HELP_LABEL;
  menuLabel = MALL_MENU_LABEL;

  tokenVsLabelsObject = {
    signUpOrSignInText: "MALL_SIGN_UP_SIGN_IN",
    signUpText: "SIGN_UP_BUTTON_LABEL",
    signInText: "MALL_SIGN_IN",
    signOutText: "MALL_SIGN_OUT",
    goToShopText: "MALL_GO_TO_SHOP",
    goToMallText: "MALL_GO_TO_MALL",
    myProfileText: "MALL_MY_PROFILE",
    helpLabel: "MALL_HELP_LABEL",
    menuLabel: "MALL_MENU_LABEL"
  };

  mobileGreeting = "Good Morning,";
  mobileCountryButtonBaseClass = "country-radio-btn";
  mobileLanguageButtonBaseClass = "language-radio-btn";
  radioButtonWrapperBaseClass = "radio-input-wrapper";
  countryRadioWrapperBaseClass = "radio-button-wrapper";

  countryHeading = "Country";
  countrySelectorHelperText = "Please select your country or region";
  languageHeading = "Language";
  languageSelectorHelperText = "Please select your preferred language";
  helpHeading = "Help";

  @api standardBankLogo;
  @api primaryBarBackgroundColor;
  @api secondryBarBackgroundColor;
  @api primaryTextColor;
  @api secondryTextColor;
  @api signInBackgroundColor;
  @api textColor;
  @api applyTheme;

  @api showMobileSearch = false;

  @api recordId;

  @track showSignupInstructions = false;

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME, USER_COUNTRY]
  })
  user;

  get contactName() {
    return getFieldValue(this.user.data, NAME);
  }

  get contactCountry() {
    return getFieldValue(this.user.data, USER_COUNTRY);
  }

  @wire(MessageContext)
  messageContext;
  subscription = null;

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        USER_COUNTRY_CHANGED_EVT,
        (message) => this.handleCountryChange(message),
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

  handleCountryChange(message) {
    let countryName = message.countryName;
  }

  @wire(getNavItems, { position: "Top Left" })
  topLeftNavigationItems({ data, error }) {
    if (data) {
      this.topLeftNavItems = this.sortData(
        "Order_Number__c",
        "asc",
        data,
        "number"
      );
    } else if (error) {
      this.topLeftNavItems = [];
    }
  }

  @wire(getNavItems, { position: "Top Right" })
  topRightNavigationItems({ data, error }) {
    if (data) {
      this.topRightNavItems = this.sortData(
        "Order_Number__c",
        "asc",
        data,
        "number"
      );
      this.topRightNavItems = this.setUpTranslatedLabels([
        ...this.topRightNavItems
      ]);
    } else if (error) {
      this.topRightNavItems = [];
    }
  }

  @wire(getNavItems, { position: "Bottom Left" })
  bottomLeftNavigationItems({ data, error }) {
    let tenantEditMode = false;
    if (this.userProfile) {
      if (
        !IS_GUEST &&
        this.userProfile.user.Profile.Name.includes("Store") &&
        this.userProfile.user.Edit_Mode__c
      ) {
        tenantEditMode = true;
      }
    }
    if (this.userProfile && data && !tenantEditMode) {
      this.bottomLeftNavItems = this.sortData(
        "Order_Number__c",
        "asc",
        data,
        "number"
      );
      this.bottomLeftNavItems = this.setUpTranslatedLabels([
        ...this.bottomLeftNavItems
      ]);
    } else if (this.userProfile && data && tenantEditMode) {
      this.bottomLeftNavItems = [];
    } else if (!this.userProfile) {
      this.setUpUserNavigation(data, true);
    } else if (error) {
      this.bottomLeftNavItems = [];
    }
  }

  @wire(getNavItems, { position: "Bottom Right" })
  bottomRightNavigationItems({ data, error }) {
    let tenantEditMode = false;
    if (this.userProfile) {
      if (
        !IS_GUEST &&
        this.userProfile.user.Profile.Name.includes("Store") &&
        this.userProfile.user.Edit_Mode__c
      ) {
        tenantEditMode = true;
      }
    }
    if (this.userProfile && data && !tenantEditMode) {
      this.bottomRightNavItems = this.sortData(
        "Order_Number__c",
        "asc",
        data,
        "number"
      );
      this.bottomRightNavItems = this.setUpTranslatedLabels([
        ...this.bottomRightNavItems
      ]);
    } else if (this.userProfile && data && tenantEditMode) {
      this.bottomRightNavItems = [];
    } else if (!this.userProfile) {
      this.setUpUserNavigation(data, false);
    } else if (error) {
      this.bottomLeftNavItems = [];
    }
  }

  async setUpUserNavigation(data, isLeft) {
    try {
      let tenantEditMode = false;
      await this.setUserProfile();
      if (this.userProfile) {
        if (
          !IS_GUEST &&
          this.userProfile.user.Profile.Name.includes("Store") &&
          this.userProfile.user.Edit_Mode__c
        ) {
          tenantEditMode = true;
        }
      }
      if (data && !tenantEditMode) {
        if(isLeft) {
          this.bottomLeftNavItems = this.sortData(
            "Order_Number__c",
            "asc",
            data,
            "number"
          );
          this.bottomLeftNavItems = this.setUpTranslatedLabels([
            ...this.bottomLeftNavItems
          ]);
        } else {
          this.bottomRightNavItems = this.sortData(
            "Order_Number__c",
            "asc",
            data,
            "number"
          );
          this.bottomRightNavItems = this.setUpTranslatedLabels([
            ...this.bottomRightNavItems
          ]);
        }
      } else if (data && tenantEditMode) {
        this.bottomLeftNavItems = [];
      }
    } catch (error) {
      this.error = error;
    }
  }

  @wire(getCountryList, {})
  getCountriesList({ data, error }) {
    let mallUserSelectedLanguageISO = getUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      DEFAULT_MALL_LANGUAGE_ISO
    );
    if (data) {
      let countries = [];
      countries.push({
        flagImage: this.selectedCountryFlag,
        countryName: this.selectedCountry
      });
      this.countriesList.push({
        name: "Recommended Country",
        countries: countries
      });
      data.forEach((continent) => {
        countries = [];
        continent.countries.forEach((country) => {
          let languages = [];
          let isActiveCountry = this.selectedCountry == country.countryName;

          country.languages.forEach((lang) => {
            let isActiveLanguage = false;
            if (lang.languageISOCode == mallUserSelectedLanguageISO) {
              isActiveLanguage = true;
              this.selectedLanguage = lang.languageName;
              this.selectedLanguageISO = lang.languageISOCode;
            }
            languages.push({
              languageName: lang.languageName,
              languageISOCode: lang.languageISOCode,
              activeLanguageRadio: isActiveLanguage,
              styleClass: lang.styleClass
            });
          });
          let flagImage = sbgVisualAssets + "/" + country.flagImage;
          let activeLanguage =
            languages.length > 1 && isActiveCountry
              ? this.selectedLanguage
              : DEFAULT_MALL_LANGUAGE;
          let activeLanguageISO =
            languages.length > 1 && this.selectedCountry == country.countryName
              ? this.selectedLanguageISO
              : DEFAULT_MALL_LANGUAGE_ISO;

          countries.push({
            isActive: isActiveCountry,
            radioButtonClass: isActiveCountry
              ? `${this.radioButtonWrapperBaseClass} radio-input-wrapper--checked`
              : this.radioButtonWrapperBaseClass,
            countryRadioWrapper: isActiveCountry
              ? `${this.countryRadioWrapperBaseClass} country-radio-button-checked`
              : `${this.countryRadioWrapperBaseClass}`,
            activeLanguage: activeLanguage,
            activeLanguageISO: activeLanguageISO,
            flagImage: flagImage,
            countryName: country.countryName,
            languages: languages
          });
          if (country.countryName == this.contactCountry) {
            this.selectedCountry = country.countryName;
            this.selectedCountryFlag = flagImage;
          }

          if (country.countryName == this.selectedCountry) {
            this.languages = languages;
          }
        });
        this.countriesList.push({
          name: continent.name,
          countries: countries
        });
      });
      if (this.countriesList.length > 1) {
        this.hasMultipleCountries = true;
      }

      if (this.languages.length > 1) {
        this.hasMultipleLangugages = true;
      }
      this.visibleCountriesList = this.countriesList.filter((continent) => {
        return !continent.name.includes("Recommended");
      });
      this.updateLanguageCookies();
      let message = { languageISOCode: this.selectedLanguageISO };
      publish(this.messageContext, USER_LANGUAGE_CHANGED_EVT, message);
    } else if (error) {
      this.countriesList = [];
      this.visibleCountriesList = this.countriesList;
    }
  }

  toggleDropdown(event) {
    let selector;
    if (event && event.target) {
      if (event.target.getAttribute("[aria-expanded]")) {
        selector = event.target;
      } else {
        selector = event.target.closest("[aria-expanded]");
      }

      let state = selector.getAttribute("aria-expanded") === "true";

      this.triggerCloseDropdowns();

      window.dropdownIntentToOpen = !state;
      selector.setAttribute("aria-expanded", !state);
    }
  }

  triggerCloseDropdowns() {
    window.dispatchEvent(new CustomEvent("closeDropdowns"));
  }

  connectedCallback() {
    window.addEventListener("closeDropdowns", () => {
      let dropdowns = this.template.querySelectorAll(
        ".dropdown [aria-expanded]"
      );
      dropdowns.forEach((item) => {
        item.setAttribute("aria-expanded", false);
      });
    });

    window.addEventListener("click", () => {
      if (window.dropdownIntentToOpen !== true) {
        window.dispatchEvent(new CustomEvent("closeDropdowns"));
        window.dropdownIntentToOpen = false;
      }
    });

    this.getTranslatedLabels();
    this.setUserProfile();

    //handle Signup Screen rendering
    if (!this.emailSent) {
      this.sendLoginEmailAlert();
    }

    window.addEventListener("message", (message) => {
      if (message.data.hidesignup) {
        this.showSignupInstructions = false;
        putCookie("redirectToSignupPage", false);
      } else if (
        getCookie("redirectToSignupPage") === "true" &&
        message.data.hidesignup != undefined
      ) {
        this.showSignupInstructions = true;
      }
    });
  }

  renderedCallback() {
    if (this.renderCheck) {
      clearTimeout(this.renderCheck);
    }
    this.renderCheck = setTimeout(() => {
      addAnalyticsInteractions(this.template);
    }, 1000);

    if (!this.isFirstRender) {
      return;
    }

    this.isFirstRender = false;
    this.sbLogoImage =
      sbgVisualAssets +
      "/" +
      (this.standardBankLogo ? this.standardBankLogo : "sbg-header-logo.svg");

    this.headerHost = this.template.host;

    if (window.innerWidth <= 768) {
      if (this.enableCategory) {
        this.headerHost.style.height = "15rem";
      } else {
        this.headerHost.style.height = "11rem";
      }
    }

    window.addEventListener("resize", () => {
      if (window.innerWidth <= 768) {
        if (this.enableCategory) {
          this.headerHost.style.height = "15rem";
        } else {
          this.headerHost.style.height = "11rem";
        }
      }
    });
  }

  handleSignIn(e) {
    e.preventDefault();
    this.navigateToWebPage(
      getBaseUrl() + "/mall/services/auth/sso/mall_ping_custom"
    );
  }

  handleSignUp(e) {
    putCookie("userDesiredPage", getBaseUrl() + "/mall/s/");
    putCookie("redirectToUserDesiredPage", "true");
    putCookie("redirectToExternalShopPage", "true");
    let signUpUrl = getBaseUrl() + "/mall/s/sign-up";
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: signUpUrl
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl, "_self");
    });
  }

  handleCloseSignupInstructions() {
    this.showSignupInstructions = false;
    putCookie("redirectToSignupPage", false);
  }

  setSelectedLanguage(event) {
    this.selectedLanguage = event.currentTarget.dataset.language;
    this.languages.forEach((lang) => {
      if (lang.languageName == this.selectedLanguage) {
        this.selectedLanguageISO = lang.languageISOCode;
        lang.styleClass = "icon active";
      } else {
        lang.styleClass = "icon";
      }
    });
    this.showLanguageDropDown = false;
    this.updateLanguageCookies();
    this.updateUserData();
    let message = { languageISOCode: this.selectedLanguageISO };
    publish(this.messageContext, USER_LANGUAGE_CHANGED_EVT, message);
    location.reload();
  }

  setShowCountriesPopup() {
    this.toggleDropdown();
    this.showCountriesPopup = !this.showCountriesPopup;
    if (this.showCountriesPopup) {
    } else {
      this.visibleCountriesList = this.countriesList.filter((continent) => {
        return !continent.name.includes("Recommended");
      });
      this.isFirstRender = true;
      this.renderedCallback();
    }
  }

  setShowCountriesMobilePopup() {
    if (this.showLanguagesMobilePopup) {
      this.showLanguagesMobilePopup = !this.showLanguagesMobilePopup;
      this.showCountriesMobilePopup = !this.showCountriesMobilePopup;
      this.showMobilePopupBackdrop = !this.showMobilePopupBackdrop;
    } else {
      this.showCountriesMobilePopup = !this.showCountriesMobilePopup;
      this.showMobilePopupBackdrop = !this.showMobilePopupBackdrop;
    }
  }

  setShowLanguagesMobilePopup() {
    this.showLanguagesMobilePopup = !this.showLanguagesMobilePopup;
  }

  toggleMobileMenu(event) {
    let menuSelector = this.template.querySelector(".header");
    let host = this.template.host;
    menuSelector.classList.toggle("menu-open");
    host.classList.toggle("slds-p-around_none");
    this.toggleDropdown(event);
  }

  setCountryDetails(event) {
    this.selectedCountry = event.currentTarget.dataset.country
      ? event.currentTarget.dataset.country
      : DEFAULT_MALL_COUNTRY;
    this.selectedCountryFlag = event.currentTarget.dataset.flag
      ? event.currentTarget.dataset.flag
      : this.saImage;
    this.countriesList.forEach((region) => {
      region.countries.forEach((country) => {
        if (this.selectedCountry == country.countryName) {
          this.languages = country.languages;
        }
      });
    });

    this.visibleCountriesList = this.countriesList.filter((continent) => {
      return !continent.name.includes("Recommended");
    });

    this.visibleCountriesList.forEach((region) => {
      region.countries.forEach((country) => {
        if (this.selectedCountry == country.countryName) {
          this.languages = country.languages;
          country.isActive = true;
          country.radioButtonClass = `${this.radioButtonWrapperBaseClass} radio-input-wrapper--checked`;
          country.countryRadioWrapper = `${this.countryRadioWrapperBaseClass} country-radio-button-checked`;
        } else {
          country.isActive = false;
          country.radioButtonClass = `${this.radioButtonWrapperBaseClass}`;
          country.countryRadioWrapper = `${this.countryRadioWrapperBaseClass}`;
        }
      });
    });

    //Don't set language for small form factor for mobile
    if (this.languages.length > 1) {
      let selectedlanguage = this.languages.find(
        (lang) => lang.languageName != DEFAULT_MALL_LANGUAGE
      );
      this.selectedLanguage = selectedlanguage.languageName;
      this.selectedLanguageISO = selectedlanguage.languageISOCode;
      this.hasMultipleLangugages = true;
    } else if (FORM_FACTOR == "Small") {
      if (this.languages.length > 1) {
        this.selectedLanguage =
          event.target.dataset.language || DEFAULT_MALL_LANGUAGE;
        this.selectedLanguageISO =
          event.target.dataset.iso || DEFAULT_MALL_LANGUAGE_ISO;
        this.hasMultipleLangugages = true;
      } else if (this.languages.length == 1) {
        let selectedlanguage = this.languages[0];
        this.selectedLanguage = selectedlanguage.languageName;
        this.selectedLanguageISO = selectedlanguage.languageISOCode;
        this.hasMultipleLangugages = false;
      }
    } else {
      this.selectedLanguage = DEFAULT_MALL_LANGUAGE;
      this.selectedLanguageISO = DEFAULT_MALL_LANGUAGE_ISO;
      this.hasMultipleLangugages = false;
    }

    setUserState(mallStateName.mallUserSelectedCountry, this.selectedCountry);
    this.updateLanguageCookies();
    this.updateUserData();
  }

  setCountry(event) {
    this.setCountryDetails(event);
    this.setShowCountriesPopup();
    this.navigateToWebPage(getBaseUrl() + "/mall/s/");
  }

  changeSelectedCountry() {
    setUserState(mallStateName.mallUserSelectedCountry, this.selectedCountry);
    this.updateLanguageCookies();
    this.updateUserData();
    this.navigateToWebPage(getBaseUrl() + "/mall/s/");
  }

  setMobileCountryActive(event) {
    this.selectedLanguage;
    let countryRadioBtns = this.template.querySelectorAll(
      "button.country-radio-btn"
    );
    let CountryOptions = [...countryRadioBtns];
    let selectedOption = event.target;

    this.setCountryDetails(event);

    CountryOptions.forEach((countryOption) => {
      countryOption.classList.remove("country-radio-btn--checked");
    });

    selectedOption.classList.add("country-radio-btn--checked");
  }

  setMobileLanguageActive(event) {
    let languageRadioBtns = this.template.querySelectorAll(
      "button.language-radio-btn"
    );
    let languageOptions = [...languageRadioBtns];
    let selectedOption = event.target;

    this.setSelectedLanguage(event);

    languageOptions.forEach((languageOption) => {
      languageOption.classList.remove("language-radio-btn--checked");
    });

    selectedOption.classList.add("language-radio-btn--checked");
  }

  changeSelectedLanguage() {
    this.updateLanguageCookies();
    this.updateUserData();
    this.setShowCountriesMobilePopup();
    let message = { languageISOCode: this.selectedLanguageISO };
    publish(this.messageContext, USER_LANGUAGE_CHANGED_EVT, message);
    this.navigateToWebPage(getBaseUrl() + "/mall/s/");
  }

  async updateUserData() {
    try {
      if (USER_ID && !IS_GUEST) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = USER_ID;
        fields[USER_COUNTRY.fieldApiName] = this.selectedCountry;
        const recordInput = { fields };
        updateRecord(recordInput)
          .then(() => {})
          .catch((error) => {
            this.error = error;
        });
        await updateUserPreference({userId: USER_ID, languageName: this.selectedLanguageISO});
      }
    } catch(error) {
      this.error = error;
    }
  }

  updateLanguageCookies() {
    setUserState(mallStateName.mallUserSelectedLanguage, this.selectedLanguage);
    setUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      this.selectedLanguageISO
    );
  }

  showSearchWindow() {
    this.showMobileSearch = true;
  }

  handleMyProfile() {
    this.navigateToWebPage(getBaseUrl() + "/mall/s/my-profile");
  }

  handleSignOut() {
    const retUrl = getBaseUrl() + "/mall/s/";
    const logoutUrl = getBaseUrl() + "/mall/secur/logout.jsp?retUrl=" + retUrl;
    this.navigateToWebPage(logoutUrl);
  }

  handleGotoStore(event) {
    event.preventDefault();
    event.stopPropagation();
    this.handleStoreContextSwitch(true);
  }

  handleGotoMall(event) {
    event.preventDefault();
    event.stopPropagation();
    this.handleStoreContextSwitch(false);
  }

  async handleStoreContextSwitch(editMode) {
    let sObject = {};
    sObject.Id = USER_ID;
    sObject.Edit_Mode__c = editMode;
    try {
      await updateSObjects({ sObjects: [sObject] });
      let userProfile = await getUserProfile({ currentUserId: USER_ID });
      this.userProfile = userProfile;
      let accountId = userProfile.user.AccountId;
      this.navigateToWebPage(getBaseUrl() + "/mall/s/account/" + accountId);
    } catch (error) {
      this.error = error;
    }
  }

  async getTranslatedLabels() {
    try {
      const translatedLabelsInstance = MallTranslationService.getInstance();
      const translatedLabels =
        await translatedLabelsInstance.getTranslatedLabels();
      this.customLabels = { ...translatedLabels };
    } catch (error) {
      this.error = error;
    }
  }

  setUpTranslatedLabels(navItems) {
    //Get the custom labels
    let customlabels = { ...this.customLabels };

    //Add translation for defined tokenVsLabelsObject
    if (this.tokenVsLabelsObject) {
      for (let property in this.tokenVsLabelsObject) {
        const value = getTranslatedLabelByLabelName(
          this.tokenVsLabelsObject[property],
          customlabels
        );
        this[property] = value ? value : this[property];
      }
    }

    //Custom metadata is used to dynamically generate the footer links
    //Hence, we don't have preprocessed list of tokens to be translated
    let navItemList = [];
    for (let row = 0; row < navItems.length; row++) {
      let value = getTranslatedLabelByMetadataId(
        navItems[row].Id,
        customlabels
      );
      let navItem = { ...navItems[row] };
      if (value) {
        navItem.translatedLabel = value;
      } else {
        navItem.translatedLabel = navItem.MasterLabel;
      }
      navItemList.push(navItem);
    }
    return navItemList;
  }

  async sendLoginEmailAlert() {
    try {
      if (!IS_GUEST && !this.emailSent) {
        await sendLoginAlertNotifications({ userId: loggedInUserId });
        this.emailSent = true;
      }
    } catch (error) {
      this.error = error;
    }
  }

  async setUserProfile() {
    try {
      let userProfile = await getUserProfile({ currentUserId: USER_ID });
      this.userProfile = userProfile;
      if (this.userProfile.user.Profile.Name.includes("Store")) {
        this.isStoreProfile = true;
        if (this.userProfile.user.Edit_Mode__c) {
          this.isStoreProfileEdit = true;
          this.isStoreProfileView = false;
        }
        if (!this.userProfile.user.Edit_Mode__c) {
          this.isStoreProfileView = true;
          this.isStoreProfileEdit = false;
        }
      }
    } catch (error) {
      this.error = error;
    }
  }

  sortData(fieldName, sortDirection, array, type) {
    let sortResult = [...array];
    let parser = (v) => v;
    if (type === "date" || type === "datetime") {
      parser = (v) => v && new Date(v);
    }
    let sortMult = sortDirection === "asc" ? 1 : -1;
    array = sortResult.sort((a, b) => {
      let a1 = parser(a[fieldName]),
        b1 = parser(b[fieldName]);
      let r1 = a1 < b1,
        r2 = a1 === b1;
      return r2 ? 0 : r1 ? -sortMult : sortMult;
    });
    return array;
  }

  //Navigation Item click handler method
  handleNavItemClick(event) {
    event.preventDefault();
    event.stopPropagation();
    const link = event.currentTarget.dataset.link;
    if (link) {
      this.navigateToWebPage(getBaseUrl() + link);
    }
  }
}