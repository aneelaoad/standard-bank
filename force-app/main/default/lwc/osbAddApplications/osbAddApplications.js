import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRegisteredApplicationRT from '@salesforce/apex/OSB_Dashboard_CTRL.getRegisteredApplicationwithRecordType';
import getRegisteredShortcutRT from '@salesforce/apex/OSB_Dashboard_CTRL.getRegisteredShortcutwithRecordType';
import Id from '@salesforce/user/Id';
import { refreshApex } from '@salesforce/apex';
import removeUserMultipleSubscribedSolution from '@salesforce/apex/OSB_YourSolutionTile_CTRL.removeUserMultipleSubscribedSolution';
import LOADER_SPINNER from '@salesforce/resourceUrl/OSB_Loader';
import $RESOURCE_OSB_AddAppIcon from '@salesforce/resourceUrl/OSB_AddAppIcon';
import { publish, MessageContext } from 'lightning/messageService';
import eventCompChannel from '@salesforce/messageChannel/osbInterCompEvent__c';
import getSolutions from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getSolutionShowcase';
import getSolutionShowcaseWithCategory from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getSolutionShowcaseWithCategory';
import getSolutionSearchResultsWithCategory from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getSolutionSearchResultsWithCategory';
import getCategories from '@salesforce/apex/OSB_MiniMallCustomMetadata_CTRL.fetchMetaListLwc';
import mfaDeviceRefresh from '@salesforce/apex/OSB_Dashboard_CTRL.hasRegisteredDevices';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
import OSB_Images from '@salesforce/resourceUrl/OSB_OnehubDashboard';
import getUserDetails from '@salesforce/apex/OSB_RequestPage_CTRL.getUserDetails';
import flagShortcuts from '@salesforce/apex/OSB_Dashboard_CTRL.flagShortcuts';
const HideShortcut = 'Hide Shortcuts';
const SupportShortcut = 'Support Shortcuts';
export default class osbAddApplications extends NavigationMixin(
    LightningElement
) {
    AddApplicationImage = OSB_Images + '/AddApplicationsIllustration.svg';
    AddShortcutImage = OSB_Images + '/AddShortcutIllustration.svg';
    OSBAddAppIcon = $RESOURCE_OSB_AddAppIcon;
    deleter = LOADER_SPINNER;
    userId = Id;
    isDeleting = false;
    @api applicationowner;
    isLoading = false;
    refreshCategories;
    refreshApplications;
    refreshSearchApplications;
    refreshResult;
    refreshMFAResult;
    refreshGeneralSolutions;
    refreshContact;
    refreshShortcuts;
    mfaDevices;
    mfaReceived = false;
    categories = '';
    searchinput = '';
    error;
    hasShortcut = false;
    shortcutsHidden = false;
    contact;

    @api ssoredirecturl;
    registeredApplications = [];
    registeredApplicationsNoDups = [];
    myAppsDisplay = false;
    myShortcutDisplay = false;
    solutionid;
    registeredShortcuts = [];

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.updateContact();
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
        let shortcutHolder = this.template.querySelector(
            '[data-id="myShortcutsContainer"]'
        );

        let shortcutChevron = this.template.querySelector('[data-id="ShortcutChevron"]');

        if (shortcutHolder) {
            if (this.shortcutsHidden) {
                this.template
                    .querySelector('[data-id="myShortcutsContainer"]')
                    .classList.remove('expanded');
                    if(shortcutChevron){
                        this.template
                        .querySelector('[data-id="ShortcutChevron"]')
                        .classList.add('open');
                    }

            } else {
                this.template
                    .querySelector('[data-id="myShortcutsContainer"]')
                    .classList.add('expanded');
                    if(shortcutChevron){
                        this.template
                        .querySelector('[data-id="ShortcutChevron"]')
                        .classList.remove('open');
                    }
                    
            }
        }
    }

    updateCategories() {
        return refreshApex(this.refreshCategories);
    }

    updateMyApplications() {
        return refreshApex(this.refreshResult);
    }

    updateApplications() {
        return refreshApex(this.refreshApplications);
    }

    updateGeneralApplications() {
        return refreshApex(this.refreshGeneralSolutions);
    }

    updateSearchApplications() {
        return refreshApex(this.refreshSearchApplications);
    }

    updateMFA() {
        return refreshApex(this.refreshMFAResult);
    }

    updateContact() {
        return refreshApex(this.refreshContact);
    }

    updateShortcuts() {
        return refreshApex(this.refreshShortcuts);
    }

    @wire(getUserDetails)
    getUserDetails(result) {
        this.refreshContact = result;
        if (result.data) {
            this.contact = JSON.parse(JSON.stringify(result.data))[0];
            if (this.contact.Manage_Site_Features__c) {
                let arrManageFeature = this.contact.Manage_Site_Features__c;
                this.shortcutsHidden = false;
                if (arrManageFeature) {
                    if (arrManageFeature.includes(HideShortcut)) {
                        this.shortcutsHidden = true;
                    } else {
                        this.shortcutsHidden = false;
                    }
                }
            } else {
                this.shortcutsHidden = false;
            }

        }
    }

    @wire(getSolutionShowcaseWithCategory, {
        userId: '$userId',
        categories: '$categories'
    })
    getSolutionShowcaseWithCategory(result) {
        this.refreshApplications = result;
    }

    @wire(getSolutions, { userId: '$userId' })
    getSolutions(result) {
        this.refreshGeneralSolutions = result;
    }

    @wire(getRegisteredShortcutRT)
    getRegisteredShortcutRT(result) {
        this.refreshShortcuts = result;
        if (result.data) {
            let shortcut = JSON.parse(JSON.stringify(result.data));
            if (shortcut.length >= 0) {
                if (shortcut.length === 0) {
                    this.myShortcutDisplay = false;
                } else {
                    this.myShortcutDisplay = true;
                    this.registeredShortcuts = shortcut;
                }
            } else {
                this.myShortcutDisplay = false;
                this.error = result.error;
            }
        } else if (result.error) {
            this.myShortcutDisplay = false;
        }
    }

    @wire(getSolutionSearchResultsWithCategory, {
        userId: '$userId',
        searchKeyword: '$searchinput',
        categories: '$categories'
    })
    getSolutionSearchResultsWithCategory(result) {
        this.refreshSearchApplications = result;
    }

    @wire(getCategories, { userId: '$userId' })
    getCategories(result) {
        this.refreshCategories = result;
    }

    @wire(mfaDeviceRefresh)
    mfaDeviceRefresh(result) {
        this.refreshMFAResult = result;
        if (result.data) {
            let responseMap = JSON.parse(JSON.stringify(result.data));
            if (responseMap) {
                if ('DeviceMap1' in responseMap) {
                    this.mfaDevices = true;
                } else {
                    this.mfaDevices = false;
                }
                this.mfaReceived = true;
            }
        }
    }

    navigatetoApplicationGallery() {
        this.dispatchEvent(new CustomEvent('application'));
        const payload = {
            ComponentName: 'Add application header',
            Details: {
                Tab: 'Application Marketplace'
            }
        };
        publish(this.messageContext, eventCompChannel, payload);
    }

    navigatetoManageShortcuts() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Manage_Shortcuts__c'
            }
        });
    }

    @wire(getRegisteredApplicationRT)
    getRegisteredApplicationRT(result) {
        this.isLoading = true;
        this.refreshResult = result;
        if (result.data) {
            let myapps = JSON.parse(JSON.stringify(result.data));
            this.isLoading = false;
            this.registeredApplications = myapps;

            if (myapps.length >= 0) {
                this.updateMFA();
                if (myapps.length === 0) {
                    this.myAppsDisplay = false;
                } else {
                    this.myAppsDisplay = true;
                }
                this.error = undefined;
                this.hasShortcut = false;
                for (let i = 0; i < myapps.length; i++) {
                    let arrFeatureManagement =
                        myapps[i].Solution__r.Feature_Management__c;
                    if (arrFeatureManagement) {
                        if (arrFeatureManagement.includes(SupportShortcut)) {
                            this.hasShortcut = true;
                        }
                    }
                }

            } else {
                this.myAppsDisplay = false;
                this.error = result.error;
            }
        } else {
            if (result.error) {
                this.error = result.error;
            }
        }
    }

    handleMFADevice(event) {
        let deviceValue = event.detail;
        this.mfaDevices = deviceValue;
        this.updateMFA();
        this.template
            .querySelector('c-osb-my-applications-tile')
            .handleDeviceUpdateforAll(deviceValue);
    }

    shortcutsDisplayChevron() {
        this.template
            .querySelector('[data-id="ShortcutChevron"]')
            .classList.toggle('open');
            this.template
            .querySelector('[data-id="myShortcutsContainer"]')
            .classList.toggle('expanded');
        
        this.shortcutsHidden = this.shortcutsHidden === true ? false : true;
        flagShortcuts({ hideShortcuts: this.shortcutsHidden});
    }

    deleteSolution(event) {
        this.solutionid = event.detail.solutionid;
        let removeShortcuts = event.detail.removeShortcuts;
        let solutions = [];
        let subscribedSolution = {
            sobjectType: 'Subscribed_Solutions__c',
            Id: this.solutionid
        };
        solutions.push(subscribedSolution);
        if(removeShortcuts){
            let currentShortcuts = this.registeredShortcuts;
            let appSolutionId = this.registeredApplications.find((sol) => sol.Id === this.solutionid );
            let removeShortcutsList = currentShortcuts.filter((x) => x.Solution__c === appSolutionId.Solution__c);
            if(removeShortcutsList.length > 0){
                removeUserMultipleSubscribedSolution({
                    solutionIdList: removeShortcutsList
                }).then();
            }
        }
        this.isDeleting = true;
        removeUserMultipleSubscribedSolution({
            solutionIdList: solutions
        }).then(() => {
            this.updateApplications();
            this.updateCategories();
            this.updateShortcuts();
            this.updateMyApplications();
            this.isDeleting = false;
        });
    }

    disconnectedCallback(){
        this.updateContact();
    }

}