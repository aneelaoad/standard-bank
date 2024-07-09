import { LightningElement, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getOnboardingDetails from '@salesforce/apex/OSB_Dashboard_CTRL.getOnboardingDetails';
import hasRegisteredDevices from '@salesforce/apex/OSB_Dashboard_CTRL.hasRegisteredDevices';
import setUserContactOnboardingDate from '@salesforce/apex/OSB_Dashboard_CTRL.setUserContactOnboardingDate';
import messageChannel from '@salesforce/messageChannel/osbMenuEvents__c';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE, } from 'lightning/messageService';
import PROVIDER_CHANNEL from '@salesforce/messageChannel/Provider_Channel__c';
const hideMFA = 'Hide MFA';
export default class OsbDashboardlwc extends LightningElement {
    showDashboard;
    showApplicationMarketPlace;
    showApiMarketplace;
    showInsights;
    isMobile = false;
    showMiniMall = false;
    showFeature = true;
    providersubscription = null;
    subscription = null;
    isDashboard;
    isApplicationMarketPlace;
    isApplicationGallery;
    showToast;
    showToastFail;
    deviceNotRegistered;
    isLoading;
    userContactId;
    isAdditionalOnboardingRequired;
    TabName;
    providerId;
    userId = Id;
    dashboardValue = true;

    @wire(MessageContext)
    MessageContext;

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.MessageContext,
            messageChannel,
            (message) => {
                if (
                    message.ComponentName === 'Header' ||
                    message.ComponentName === 'API marketplace bread crumb'
                ) {
                    this.handleTabSelection(message.Details.tabName);
                } else if (message.ComponentName === 'Bread crumb') {
                    this.showApplicationMarketPlace = true;
                    this.showDashboard = false;
                    this.showApplicationGallery = false;
                    this.showApiMarketplace = false;
                    this.showFeature = true;

                    if (
                        this.template.querySelector(
                            '[data-id="ApplicationMarketPlace"]'
                        )
                    ) {
                        this.template
                            .querySelector('[data-id="ApplicationMarketPlace"]')
                            .classList.remove('withGallery');
                    }
                }
                if (message.ComponentName === 'Header Mobile') {
                    this.isMobile = message.Details.isMobile;
                }
            }
        );

    }

    handleTabSelection(tabValue) {
        if (tabValue === 'Dashboard') {
            this.showDashboard = true;
            this.showApplicationMarketPlace = false;
            this.showApplicationGallery = false;
            this.showMiniMall = false;
            this.showFeature = false;
            this.showInsights = false;
            this.showApiMarketplace = false;
        }
        if (tabValue === 'Application Marketplace') {
            this.showApplicationMarketPlace = true;
            this.showDashboard = false;
            this.showApplicationGallery = false;
            this.showFeature = true;
            this.showInsights = false;
            this.showApiMarketplace = false;
            if (
                this.template.querySelector(
                    '[data-id="ApplicationMarketPlace"]'
                )
            ) {
                this.template
                    .querySelector('[data-id="ApplicationMarketPlace"]')
                    .classList.remove('withGallery');
            }
        }
        if (tabValue === 'OneDeveloper') {
            this.showApiMarketplace = true;
            this.showInsights = false;
            this.showApplicationMarketPlace = false;
            this.showDashboard = false;
            this.showMiniMall = false;
            this.showFeature = false;
        }
        if (tabValue === 'Insights') {
            this.showInsights = true;
            this.showApplicationMarketPlace = false;
            this.showDashboard = false;
            this.showMiniMall = false;
            this.showFeature = false;
            this.showApiMarketplace = false;
        }
    }

    handleRefresh(event) {
        this.dispatchEvent(
            new CustomEvent('refreshrecords', { detail: event.detail })
        );
    }

    connectedCallback() {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const tabValue = urlParams.get('tab');
        this.handleSubscribe();
        this.subscribeToMessageChannel();

        let urlString = window.location.href;
        let urlLine = new URL(urlString);
        let tabselection = urlLine.searchParams.get('tab');
        if (tabselection) {
            if (tabselection === 'ApplicationMarketplace') {
                this.TabName = 'Application Marketplace';
            } else if (tabselection === 'APImarketplace') {
                this.TabName = 'OneDeveloper';
            } else {
                this.TabName = tabselection;
            }

            this.handleTabSelection(this.TabName);
        } else {
            this.showDashboard = true;
            this.isDashboard = true;
            this.isApplicationMarketPlace = false;
            this.showInsights = false;
            this.deviceNotRegistered = false;
        }

        document.cookie =
            'firstTimeUser=true; expires=Fri, 31 Dec 9999 23:59:59 GMT; SameSite=Lax;';
        let sPageURL = decodeURIComponent(window.location);
        let sURLVariables = sPageURL.split('?');
        if (sURLVariables.length > 1) {
            let sURLVariableName = sURLVariables[1].split('=');
            if (
                sURLVariableName[0] === 'success' &&
                sURLVariableName[1] === 'true'
            ) {
                this.showToast = true;
                setTimeout(function () {
                    this.showToast = false;
                }, 5000);
            }
        }

        this.isLoading = false;
        getOnboardingDetails().then((data) => {
            let contact = JSON.parse(JSON.stringify(data));
            if (contact) {
                if (!contact.Manage_Site_Features__c) {
                    let visited = sessionStorage.getItem('visited');
                    if (!visited) {
                        sessionStorage.setItem('visited', true);
                    }
                    hasRegisteredDevices().then((data) => {
                        let responseMap = JSON.parse(JSON.stringify(data));
                        if (responseMap) {
                            if ('DeviceMap1' in responseMap) {
                                this.deviceNotRegistered = false;
                            } else {
                                if (!visited) {
                                    this.deviceNotRegistered = true;
                                }
                            }
                        }
                    });
                } else if (!contact.Manage_Site_Features__c.includes(hideMFA)) {
                    let visited = sessionStorage.getItem('visited');
                    if (!visited) {
                        sessionStorage.setItem('visited', true);
                    }
                    hasRegisteredDevices().then((data) => {
                        let responseMap = JSON.parse(JSON.stringify(data));
                        if (responseMap) {
                            if ('DeviceMap1' in responseMap) {
                                this.deviceNotRegistered = false;
                            } else {
                                if (!visited) {
                                    this.deviceNotRegistered = true;
                                }
                            }
                        }
                    });
                } else {
                    this.deviceNotRegistered = false;
                }
            }
            if (contact && !contact.Onboarding_Tour_Date__c) {
                this.userContactId = contact.Id;
                let userRole = contact.OSB_Community_Access_Role__c;
                let AdditionalOnboardingRequired =
                    userRole === 'Authorised Person' ||
                    userRole === 'Designated Person';
                this.isAdditionalOnboardingRequired =
                    AdditionalOnboardingRequired;
            }
        });

    }

    handleErrorFired(event) {
        let errorCode = event.getParam('errorCode');
        if (errorCode === '4401') {
            this.showToastFail = true;
        } else {
            this.showToastFail = true;
        }
    }

    handleEventAdd() {
        this.showApplicationMarketPlace = true;
        this.showDashboard = false;
        this.showMiniMall = false;
        this.showFeature = true;
        if (this.template.querySelector('[data-id="ApplicationMarketPlace"]')) {
            this.template
                .querySelector('[data-id="ApplicationMarketPlace"]')
                .classList.remove('withGallery');
        }
    }

    handleAppGalleryDisplay(event) {
        this.showFeature = event.detail;
        this.showMiniMall = true;
        if (this.template.querySelector('[data-id="ApplicationMarketPlace"]')) {
            this.template
                .querySelector('[data-id="ApplicationMarketPlace"]')
                .classList.add('withGallery');
        }
    }

    callAddApp() {
        this.template.querySelector('c-osb-add-applications').addapp();
    }

    handleDeviceRegistered() {
        this.deviceNotRegistered = false;
        getOnboardingDetails().then((data) => {
            let contact = JSON.parse(JSON.stringify(data));
            if (contact && !contact.Onboarding_Tour_Date__c) {
                setTimeout(function () {
                    document.dispatchEvent(new CustomEvent('signUpLwc'));
                }, 5000);
                setUserContactOnboardingDate({ contactId: contact.Id });
            }
        });
    }

    handleNoComingSoon() {
        this.template
            .querySelector('[data-id="ComingSoonHolder"]')
            .classList.add('noBackground');
    }

    subscribeToMessageChannel() {
        if (!this.providersubscription) {
            this.providersubscription = subscribe(this.MessageContext, PROVIDER_CHANNEL, (message) => this.handleMessage(message), { scope: APPLICATION_SCOPE },);
        }
    }

    handleMessage(message) {

        if (message.providerId) {
            this.template.querySelector('.MarketplaceHolderOne').style="padding:1.25rem 0rem";

        }

    }
    unsubscribeToMessageChannel() {
        unsubscribe(this.providersubscription);
        this.providersubscription = null;
    }



}