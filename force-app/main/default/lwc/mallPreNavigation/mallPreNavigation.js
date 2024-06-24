import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import IS_GUEST from '@salesforce/user/isGuest';
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import MALL_SIGN_UP_OR_SIGN_IN from '@salesforce/label/c.MALL_SIGN_UP_OR_SIGN_IN';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
  } from "lightning/messageService";
import MALL_PRE_NAVIGATION_EVT from "@salesforce/messageChannel/PreNavigationModal__c";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";

export default class MallPreNavigation extends NavigationMixin(LightningElement) {
    isShowModal = false;
    @api showRegistration = false;
    @api showRedirection = false;
    navigateToWebPage = navigateToWebPage.bind(this);
    signupurl = getBaseUrl() + "/mall/s/" + "sign-up";
    mallRegisterOrSignIn = MALL_SIGN_UP_OR_SIGN_IN;
    isGuestUser = IS_GUEST;

    popupIcon = mallIcons + "/avatar_alert_negative.svg";
    popupClockIcon = mallIcons + "/icn_clock_future.svg";

    cancelNavigation = true;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
        if(IS_GUEST) {
            this.setUpRegisterModal();
        } else {
            this.setUpRedirectModal();
        }
    }

    renderedCallback() {
      addAnalyticsInteractions(this.template);
    }

    handleModalOpen(message) {
        this.modalConfig.targetUrl = message.targetUrl;
        this.modalConfig.storeName = message.storeName;
        this.showModalBox();
        this.cancelNavigation = false;
        setTimeout(() => {
            if(!this.cancelNavigation) {
              this.cancelNavigation = true;
              if(this.modalConfig.targetUrl) {
                this.navigateToWebPage(this.modalConfig.targetUrl);
              }
            }
        },5000);
    }
  
    subscribeToMessageChannel() {
      if (!this.subscription) {
        this.subscription = subscribe(
          this.messageContext,
          MALL_PRE_NAVIGATION_EVT,
          (message) => this.handleModalOpen(message),
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

    @api modalConfig = {
        icon : this.popupIcon,
        title : "Register",
        contentMessage1 : "",
        contentMessage2 : "",
        buttons : [],
        showCloseButton : true,
        targetUrl : "",
        storeName : ""
    };

    handleGoToRegister(event) {
        event.preventDefault();
        event.stopPropagation();
        this.hideModalBox();
        const signupurl = getBaseUrl() + "/mall/s/" + "sign-up";
        this.navigateToWebPage(signupurl);
    }

    handleRedirectCancel(event) {
        event.preventDefault();
        event.stopPropagation();
        this.cancelNavigation = true;
        this.hideModalBox();
    }

    handleRedirectContinue(event) {
        event.preventDefault();
        event.stopPropagation();
        this.cancelNavigation = false;
        this.navigateToWebPage(this.modalConfig.targetUrl);
    }

    showModalBox(event) {
        this.isShowModal = true;
    }
    
    hideModalBox() {
        this.isShowModal = false;
    }

    setUpRegisterModal() {
        let modalConfig = {};
        modalConfig.icon = this.popupIcon;
        modalConfig.title = 'Attention';
        modalConfig.contentMessage1 = 'It looks like you are not signed in/registered.';
        modalConfig.contentMessage2 = 'To continue to the page, please sign in or register.';
        modalConfig.buttons = [{"title": "SIGN IN / REGISTER", "function" : "handleRedirectUrlToSignUp"}];
        modalConfig.showCloseButton = true;
        this.modalConfig = {...modalConfig};
    }
    
    setUpRedirectModal() {
        let modalConfig = {};
        modalConfig.icon = this.popupClockIcon;
        modalConfig.title = 'Redirecting';
        modalConfig.contentMessage1 = 'You are being redirected to ';  
        modalConfig.contentMessage2 = 'please wait...';      
        modalConfig.contentMessage3 = 'If you haven’t been redirected in 5 seconds, please click continue.';
        modalConfig.buttons = [{"title" : "CANCEL", "function" : "handleRedirectCancel"}, 
                               {"title" :"CONTINUE", "function" : "handleRedirectContinue"}
                              ];
        modalConfig.showCloseButton = false;
        this.modalConfig = {...modalConfig};
    }
    
}