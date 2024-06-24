import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUnreadFeedItemsNo from '@salesforce/apex/OSB_Header_CTRL.getUnreadFeedItemsNumberForUser';
import contactAuth from '@salesforce/apex/OSB_Header_CTRL.getContactAuth';
import getChangePasswordUrl from '@salesforce/apex/OSB_Header_CTRL.getChangePasswordUrlPing';
import getTermsLink from '@salesforce/apex/OSB_Header_CTRL.getTermsLink';
import getUserNameIfLoggedIn from '@salesforce/apex/OSB_Header_CTRL.getUserNameIfLoggedIn';
import getApiLink from '@salesforce/apex/OSB_Header_CTRL.getApiLink';
import badge from '@salesforce/resourceUrl/OSB_logoBadge';
import icon from '@salesforce/resourceUrl/OSB_icons';
import getIELoginURL from '@salesforce/apex/OSB_Header_CTRL.getIELoginURL';
import getLoginURL from '@salesforce/apex/OSB_Header_CTRL.getLoginURL';
import { publish, MessageContext } from 'lightning/messageService';
import eventChannel from '@salesforce/messageChannel/osbMenuEvents__c';
import { subscribe } from 'lightning/messageService';
import eventChannelReceived from '@salesforce/messageChannel/osbInterCompEvent__c';
import {
    pageViewSinglePageApp,
    addAnalyticsInteractions,
    interactionClick
} from 'c/osbAdobeAnalyticsWrapperLwc';
import scroll from '@salesforce/resourceUrl/ScrollJS';
import { loadScript } from 'lightning/platformResourceLoader';

export default class OsbHeaderLwc extends NavigationMixin(LightningElement) {
    hasRendered = false;
    displayedUnreadNotifications;
    unreadNotificationsNumber = 0;
    notificationRendered = false;
    autorisation;
    showTeamProfile;
    isUserLoggedIn;
    isGuestUser;
    loginUrl;
    tcLink;
    apiSetting;
    mobileMenuToggled;
    mobileDisplayMenu = false;
    showDashboard = true;
    showApplicationMarketPlace = false;
    showApplicationGallery = false;
    showApiMarketplace = false;

    @api withMenu;
    @api withUserName;
    @api noOverlay;
    @api showBannerMessage;
    @api withMenuStyle;
    @api menuOpened;

    OSB_logoBadge = badge;
    iconBell = icon + '/ms-icn_bell';
    subscription = null;
    currentTabName = 'Dashboard';

    @wire(MessageContext)
    MessageContextSub;

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.MessageContextSub,
                eventChannelReceived,
                (message) => this.handleSubscribe(message)
            );
        }
    }

    handleSubscribe(message) {
        if (message) {
            if (message.ComponentName === 'Notifcations') {
                this.getUnreadNotifications();
                this.handleTabs('notifications');
            } else {
                let allTabs = this.template.querySelectorAll('.tab');
                allTabs.forEach((element) => {
                    if (element.dataset.id === message.Details.Tab) {
                        element.classList.add('tab-menu-selected');
                        let tabName = element.dataset.id;
                        let tabFinal = encodeURIComponent(
                            tabName.replace(/\s/g, '')
                        );
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'Home'
                            },
                            state: {
                                tab: tabFinal
                            }
                        });

                        if(this.currentTabName !== tabName){
                            this.currentTabName = tabName;
                            this.notifyAnalyticsTab(tabName);
                        }
                       
                    } else {
                        element.classList.remove('tab-menu-selected');
                    }
                });
            }
        }
    }

    handleSelection(tabName) {
        let allTabs = this.template.querySelectorAll('.tab');
        allTabs.forEach((element) => {
            if (element.dataset.id === tabName) {
                element.classList.add('tab-menu-selected');
                if (tabName === 'notifications') {
                    element.classList.remove('tab-menu-selected');
                    if (this.unreadNotificationsNumber > 0) {
                        element.classList.add('tab-menu-selected-notif');
                        element.classList.remove('tab-menu-selected-notif-None');
                    } else {
                        element.classList.add('tab-menu-selected-notif-None');
                        element.classList.remove('tab-menu-selected-notif');
                    }
                } else {
                    element.classList.remove('tab-menu-selected-notif');
                }
            } else {
                element.classList.remove('tab-menu-selected');
            }
        });
    }

    handleAppDynamics = (pagePath) => {
        if (pagePath.includes('onedeveloper-product-subscribe')) {
            window['adrum-disable'] = true;
        } else {
            window['adrum-disable'] = false;
        }
    };

    get isUserNotLoggedIn() {
        return this.isUserLoggedIn ? false : true;
    }

    connectedCallback() {
        let pagePath = window.location.pathname;
        this.handleAppDynamics(pagePath);
        getUserNameIfLoggedIn().then((data) => {
            if (data) {
                this.isUserLoggedIn = 'true';
                this.userName = data.FirstName;
                this.getUnreadNotifications();
                this.getAuthorisation();
            } else {
                this.isGuestUser = 'true';
            }
        });
        this.subscribeToMessageChannel();
    }

    @wire(MessageContext)
    messageContext;

    handleTabChange(tabNameValue) {
        const payload = {
            ComponentName: 'Header',
            Details: {
                tabName: tabNameValue
            }
        };
        publish(this.messageContext, eventChannel, payload);
        window.scroll(0, 0);
    }

    @wire(getTermsLink)
    tcLink;

    @wire(getApiLink)
    getApiLink({ error, data }) {
        if (data) {
            this.apiSetting = data;
        }
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);

        if(!this.hasRendered){
            this.hasRendered = true;
            this.setClasses();
            if (
                window.navigator.userAgent.indexOf('MSIE ') > 0 ||
                !!navigator.userAgent.match(/Trident.*rv\:11\./)
            ) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'unsupportedInternetExplorer__c'
                    }
                });
                getIELoginURL().then((data) => {
                    this.loginUrl = data;
                });
            } else {
                getLoginURL().then((data) => {
                    this.loginUrl = data;
                });
            }
            window.addEventListener('scroll', () => this.handleScrollMethod());
            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
            const pageUrl = window.location.pathname;
            let pageUrls = pageUrl.split('/');
            let tabName;

            if(urlParams.get('tab')){
                tabName = urlParams.get('tab') === 'ApplicationMarketplace' ? 'Application Marketplace' : urlParams.get('tab');
                this.handleSelection(tabName);
            }else{
                tabName = pageUrls.pop();
                if(tabName && this.currentTabName !== tabName){
                    this.handleTabs(tabName);
                }else{
                    this.handleSelection(this.currentTabName);
                }
            }
           
        }
        if(this.notificationRendered && this.currentTabName === 'notifications'){
            this.handleSelection(this.currentTabName);
        }
    }

    handleScrollMethod() {
        let daysTemplate = this.template;
        let notificationNum = this.unreadNotificationsNumber;
        loadScript(this, scroll).then(() => {
            handleScroll(daysTemplate, notificationNum);
        });
    }

    setClasses() {
        let elementHeader = this.template.querySelector(
            '[data-id="header-check"]'
        );
        let elementAcc = this.template.querySelector('[data-id="header-acc"]');
        if (this.mobileMenuToggled) {
            this.template
                .querySelector('[data-id="mobile-menu"]')
                .classList.remove('closed_mobile-menu');
            this.template
                .querySelector('[data-id="mobile-menu"]')
                .classList.add('hidden');
            this.template
                .querySelector('[data-id="Mobile-menu-toggled"]')
                .classList.add('header-dropdown');
            this.template
                .querySelector('[data-id="Mobile-menu-toggled"]')
                .classList.add('mobile__menu');
            this.template
                .querySelector('[data-id="Mobile-menu-toggled"]')
                .classList.remove('hidden');
        } else {
            this.template
                .querySelector('[data-id="Mobile-menu-toggled"]')
                .classList.remove('header-dropdown');
            this.template
                .querySelector('[data-id="Mobile-menu-toggled"]')
                .classList.remove('mobile__menu');
            this.template
                .querySelector('[data-id="Mobile-menu-toggled"]')
                .classList.add('hidden');
            this.template
                .querySelector('[data-id="mobile-menu"]')
                .classList.remove('hidden');
            this.template
                .querySelector('[data-id="mobile-menu"]')
                .classList.add('closed_mobile-menu');
        }
        if (!this.withMenu) {
            let element = this.template.querySelector('[data-id="with-menu"]');
            element.classList.remove(...element.classList);
            element.classList.add('header-container');
        }
        if (this.isUserLoggedIn) {
            elementHeader.classList.remove(...elementHeader.classList);
            let element2 = this.template.querySelector(
                '[data-id="mobile-sec"]'
            );
            element2.classList.remove(...element2.classList);
            element2.classList.add('header__mobile-menu');
            if (this.withMenu) {
                elementHeader.classList.add('header');
                elementHeader.classList.add('withMenu');
            } else {
                elementHeader.classList.add('header');
            }
        } else {
            this.template
                .querySelector('[data-id="logged-check"]')
                .classList.remove('header__icon-cont');
            this.template
                .querySelector('[data-id="mobile-sec"]')
                .classList.add('hidden_nonmobile');
            elementAcc.classList.remove(...elementAcc.classList);
            elementAcc.classList.add('header__account');
            if (!this.withMenu) {
                elementHeader.classList.add('header');
                elementHeader.classList.add('withMenu');
                elementHeader.classList.add('cancel_reverse');
            } else {
                elementHeader.classList.add('header');
                elementHeader.classList.add('cancel_reverse');
            }
        }
    }

    handleMobielNav(event) {
        event.target.dataset.id = event.detail;
        let isMobileNav = true;
        this.handleNav(event, isMobileNav);
    }

    handleMobileMenuEvent(event) {
        let toggle = event.getParam('menuOpened');
        this.toggleMobileMenu(toggle);
    }

    closeMenu() {
        this.closeMobileMenu();
    }

    hideMobileMenu() {
        this.mobileDisplayMenu = false;
    }

    displayMobileMenu() {
        this.mobileDisplayMenu = true;
    }

    navigateNotifications() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Notifications__c'
            }
        });
    }

    navigateContactUs() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'OPTL_Contact_Us__c'
            }
        });
    }

    handleReadNotification() {
        let notifications = this.unreadNotificationsNumber;
        this.setNotifications(--notifications);
    }

    handleNav(event) {
        let url = window.location.pathname.split('/');
        if (!url.pop()) {
            let tabName = event.target.dataset.id;
            event.preventDefault();
            this.handleTabs(tabName);
        } else {
            let tabName = event.target.dataset.id;
            let tabFinal = encodeURIComponent(tabName.replace(/\s/g, ''));
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Home'
                },
                state: {
                    tab: tabFinal
                }
            });
            this.handleTabs(tabName);
        }
    }

    handleTabs(tabName) {
        if (tabName === 'Dashboard') {
            this.showDashboard = true;
            this.showApplicationMarketPlace = false;
            this.showApplicationGallery = false;
            this.showApiMarketplace = false;
        } else if (tabName === 'Application Marketplace') {
            this.showApplicationMarketPlace = true;
            this.showDashboard = false;
            this.showApplicationGallery = false;
            this.showApiMarketplace = false;
        } else if (tabName === 'OneDeveloper') {
            this.showApiMarketplace = true;
            this.showApplicationMarketPlace = false;
            this.showDashboard = false;
            this.showApplicationGallery = false;
        } else if (tabName === 'Insights') {
            this.showApplicationGallery = true;
            this.showApplicationMarketPlace = false;
            this.showDashboard = false;
            this.showApiMarketplace = false;
        }

        this.handleSelection(tabName);

        const selectedEvent = new CustomEvent('tabSelected', {
            detail: tabName
        });

        if (tabName) {
            const url = new URL(window.location.href);
            url.searchParams.set(
                'tab',
                encodeURIComponent(tabName.replace(/\s/g, ''))
            );
            let encoded = encodeURI(url);
            window.history.pushState(null, null, encoded);
        }
        this.dispatchEvent(selectedEvent);
        this.handleTabChange(tabName);
        if(this.currentTabName !== tabName){
            this.currentTabName = tabName;
            this.notifyAnalyticsTab(tabName);
        }
       
    }

    handleDropMenu() {
        let selectedMenuItem = 'Menu';
        this.notifyAnalyticsClick(selectedMenuItem);
    }

    handleSelect(event) {
        let pageName;
        let selectedMenuItem = event.detail.value;
        switch (selectedMenuItem) {
            case 'Edit Profile':
                pageName = 'Profile_and_Settings__c';
                break;
            case 'Change Password':
                this.changePasswordPing();
                break;
            case 'Team Profile':
                pageName = 'team_profile__c';
                break;
            case 'Code of Conduct':
                pageName = 'Code_Of_Conduct__c';
                break;
            case 'conditions':
                selectedMenuItem = 'Terms and Conditions';
                pageName = 'Terms_and_Conditions__c';
                break;
            case 'Sign Out':
                this.logout();
                break;
        }
        this.notifyAnalyticsClick(selectedMenuItem);
        if (pageName) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: pageName
                }
            });
        }
    }

    handleCloseEvent(event) {
        this.mobileMenuToggled = event.detail.menuOpened;
        this.menuOpened = event.detail.menuOpened;
        this.isMobileView = event.detail.isMobileView;
        this.unreadNotificationsNumber = event.detail.unreadNotificationsNumber;
        this.showTeamProfile = event.detail.showTeamProfile;
        this.template
            .querySelector('[data-id="Mobile-menu-toggled"]')
            .classList.add('hidden');
        const payload = {
            ComponentName: 'Header Mobile',
            Details: {
                isMobile: false
            }
        };
        publish(this.messageContext, eventChannel, payload);
    }

    closeMobileMenu() {
        this.closeMobileMenu();
        document.body.style.overflow = 'auto';
    }

    openMobileMenu() {
        this.toggleVisibilityForMobileMenu();
    }

    logout() {
        window.location.replace('/secur/logout.jsp?retUrl=/s/');
    }

    getUnreadNotifications() {
        getUnreadFeedItemsNo().then((data) => {
            let displayedNotifications = data > 99 ? '99+' : data;
            this.displayedUnreadNotifications = data > 0 ? true : false;
            this.unreadNotificationsNumber = displayedNotifications;
            if (data === 0) {
                this.template.querySelector(
                    '[data-id="mobile-sec"]'
                ).style.marginTop = '3%';
                this.template.querySelector(
                    '[data-id="menu-notifications"]'
                ).style.marginTop = '0.125rem';
            } else {
                this.template.querySelector(
                    '[data-id="mobile-sec"]'
                ).style.marginTop = '3%';
                this.template.querySelector(
                    '[data-id="menu-notifications"]'
                ).style.marginTop = '1.25rem';
            }
            this.notificationRendered = true;

        });
    }

    getAuthorisation() {
        contactAuth().then((data) => {
            this.autorisation = data;
            if (data === 'Nominated Person') {
                this.showTeamProfile = false;
            } else {
                this.showTeamProfile = true;
            }
        });
    }

    changePasswordPing() {
        getChangePasswordUrl().then((data) => {
            let strURL = data;
            strURL = encodeURI(strURL);
            window.open(strURL, '_top');
        });
    }

    toggleVisibilityForMobileMenu() {
        this.menuOpened = true;
        this.mobileMenuToggled = true;
        this.template
            .querySelector('c-osb-mobile-menu-lwc')
            .handleMenuToggled(this.menuOpened);
        this.template
            .querySelector('[data-id="Mobile-menu-toggled"]')
            .classList.remove('hidden');
        const payload = {
            ComponentName: 'Header Mobile',
            Details: {
                isMobile: true
            }
        };
        publish(this.messageContext, eventChannel, payload);
    }

    dispatchTabEvent() {
        const selectedEvent = new CustomEvent('selected', {
            detail: this.contact.Id
        });
        this.dispatchEvent(selectedEvent);
    }

    notifyAnalyticsTab(tabName) {
        pageViewSinglePageApp(tabName);
    }

    notifyAnalyticsClick(pagename) {
        let eventValues = {
            name: 'Header | ' + pagename + ' link',
            intent: 'navigational'
        };
        interactionClick(eventValues);
    }

    toggleMobileMenu(toggle) {
        this.mobileMenuToggled = toggle;
    }
}