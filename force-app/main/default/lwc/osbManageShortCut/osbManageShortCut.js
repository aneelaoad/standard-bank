import { LightningElement, wire } from 'lwc';
import viewShortcuts from '@salesforce/apex/OSB_Modal_CTRL.viewShortcuts';
import getRegisteredApplicationRT from '@salesforce/apex/OSB_Dashboard_CTRL.getRegisteredApplicationwithRecordType';
import OSB_Logo from '@salesforce/resourceUrl/OSB_logoBadge';
import getRegisteredShortcutRT from '@salesforce/apex/OSB_Dashboard_CTRL.getRegisteredShortcutwithRecordType';
import createUserSubscribedShorcut from '@salesforce/apex/OSB_Modal_CTRL.createUserSubscribedShorcut';
import removeUserMultipleSubscribedSolution from '@salesforce/apex/OSB_YourSolutionTile_CTRL.removeUserMultipleSubscribedSolution';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import eventCompChannel from '@salesforce/messageChannel/osbMenuEvents__c';
import eventChannel from '@salesforce/messageChannel/osbInterCompEvent__c';
import {
    interactionForm,
    addAnalyticsInteractions
} from 'c/osbAdobeAnalyticsWrapperLwc';
const SupportShortcut = 'Support Shortcuts';
export default class OsbManageShortCut extends LightningElement {
    maxShortcuts = 10;
    savedShortcuts = 0;
    disableAdditionButton = false;
    bannerType = 'warning';
    bannerHeading = 'Shortcut limit reached';
    bannerMessage = 'Remove some shortcuts to add more';
    isLoading = false;
    maxReached = false;
    applicationsArr = [];
    shortcutArr = [];
    savedShortcutsArr = [];
    SBlogo = OSB_Logo;
    displayapps = false;
    mainManageShortcutsPage = true;
    solutionShortcutPage = false;
    solutionTitle;
    solutionIconImage;
    solutionId;
    tileType = false;
    newShortcutsArr = [];
    removeShortcutsArr = [];
    refreshCurrentShourtcuts;
    formStartedValue = false;
    eventValues = {
        name: 'globalFormStart',
        formName: 'shortcuts',
        formStatus: '',
        formisSubmitted: 'false'
    };

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }

    @wire(viewShortcuts, { solutionName: '$solutionTitle' })
    viewShortcuts(result) {
        if (result.data) {
            let shortcuts = JSON.parse(JSON.stringify(result.data)).data.shortcuts;
            let shortcutDetails;
            let displayShortcuts = [];
            let currentShortcuts = this.savedShortcutsArr;
            for (let i = 0; i < shortcuts.length; i++) {
                let shortcutAlreadySaved = true;
                for (let j = 0; j < currentShortcuts.length; j++) {
                    if (
                        shortcuts[i].name ===
                            currentShortcuts[j].Short_Cut_Name__c &&
                        this.solutionTitle ===
                            currentShortcuts[j].Solution__r.Title
                    ) {
                        shortcutAlreadySaved = false;
                    }
                }
                shortcutDetails = {
                    Name: shortcuts[i].name,
                    redirectURL: shortcuts[i].url,
                    Category: shortcuts[i].category,
                    addButton: shortcutAlreadySaved
                };
                displayShortcuts.push(shortcutDetails);
            }

            this.isLoading = false;
            this.displayapps = true;
            this.shortcutArr = displayShortcuts;
        }
    }

    @wire(MessageContext)
    messageContext;

    @wire(getRegisteredApplicationRT)
    getRegisteredApplicationRT(result) {
        this.isLoading = true;
        this.refreshResult = result;
        this.hasShortcut = false;
        if (result.data) {
            let applications = JSON.parse(JSON.stringify(result.data));
            let appArrWithShortcuts = [];
            this.isLoading = false;

            if (applications.length >= 0) {
                for (let i = 0; i < applications.length; i++) {
                    if (applications[i].Solution__r.Feature_Management__c) {
                        if (
                            applications[
                                i
                            ].Solution__r.Feature_Management__c.includes(';')
                        ) {
                            let arrFeatureManagement =
                                applications[
                                    i
                                ].Solution__r.Feature_Management__c.split(';');
                            if (
                                arrFeatureManagement.includes(SupportShortcut)
                            ) {
                                appArrWithShortcuts.push(applications[i]);
                            }
                        } else {
                            let arrFeatureManagement =
                                applications[i].Solution__r
                                    .Feature_Management__c;
                            if (
                                arrFeatureManagement.includes(SupportShortcut)
                            ) {
                                appArrWithShortcuts.push(applications[i]);
                            }
                        }
                    }
                }
                this.displayapps = true;
                this.applicationsArr = appArrWithShortcuts;
                this.error = undefined;
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

    @wire(getRegisteredShortcutRT)
    getRegisteredShortcutRT(result) {
        this.refreshCurrentShourtcuts = result;
        if (result.data) {
            let shortcut = JSON.parse(JSON.stringify(result.data));
            if (shortcut.length >= 0) {
                if (shortcut.length === 0) {
                    this.savedShortcuts = 0;
                } else {
                    this.savedShortcutsArr = shortcut;
                    if (shortcut.length === this.maxShortcuts) {
                        this.maxReached = true;
                        this.disableAdditionButton = true;
                    }
                    this.savedShortcuts = shortcut.length;
                }
                this.error = undefined;
            } else {
                this.error = result.error;
            }
        } else if (result.error) {
            this.error = result.error;
        }
    }

    choseShortcutSolution(event) {
        this.solutionTitle = event.detail.title;
        this.solutionId = event.detail.id;
        this.displayapps = false;
        this.mainManageShortcutsPage = false;
        this.solutionShortcutPage = true;

        if (event.detail.icon) {
            this.solutionIconImage = event.detail.icon;
        } else {
            this.solutionIconImage = this.SBlogo;
        }

        this.tileType = true;
        this.isLoading = true;
    }

    backtoManageShortcuts() {
        if (this.formStartedValue) {
            let event = this.eventValues;
            event.name = 'globalFormAbandon';
            event.formStatus = 'abandon';
            event.formisSubmitted = false;
            this.setInitalAdobeFields();
        }
        this.formStartedValue = false;
        this.savedShortcuts = this.savedShortcutsArr.length;
        if (this.savedShortcutsArr.length === this.maxShortcuts) {
            this.maxReached = true;
            this.disableAdditionButton = true;
        }
        this.removeShortcutsArr = [];
        this.newShortcutsArr = [];
        this.solutionTitle = null;
        this.solutionId = null;
        this.solutionShortcutPage = false;
        this.mainManageShortcutsPage = true;
        this.tileType = false;
    }

    backtoDashboard() {
        const payload = {
            ComponentName: 'Header',
            Details: {
                tabName: 'Dashboard'
            }
        };
        const payloadHeader = {
            ComponentName: 'Header',
            Details: {
                Tab: 'Dashboard'
            }
        };
        publish(this.messageContext, eventChannel, payloadHeader);
        publish(this.messageContext, eventCompChannel, payload);
    }

    storeShortcuts() {
        this.isLoading = true;
        let removalArr = this.removeShortcutsArr;
        let newArr = this.newShortcutsArr;
        let currentShortcuts = this.savedShortcutsArr;

        let removeShortcutsList = currentShortcuts.filter((x) =>
            removalArr.some((y) => x.Short_Cut_Name__c === y.Short_Cut_Name__c)
        );
        let addShortcutsList = newArr.filter(
            (x) =>
                !currentShortcuts.some(
                    (y) => x.Short_Cut_Name__c === y.Short_Cut_Name__c
                )
        );

        removeUserMultipleSubscribedSolution({
            solutionIdList: removeShortcutsList
        }).then();
        createUserSubscribedShorcut({ shortcutsList: addShortcutsList }).then(
            () => {
                let event = this.eventValues;
                this.updateCurrentShorcuts().then(() => {
                    this.backtoDashboard();
                });
                this.isLoading = false;
                event.name = 'globalFormComplete';
                event.formStatus = 'complete';
                event.formisSubmitted = true;
                this.setInitalAdobeFields();
                this.formStartedValue = false;
            }
        );
    }

    addNewShortcut(event) {
        if (!this.formStartedValue) {
            this.formStartedValue = true;
            this.setInitalAdobeFields();
        }
        if (this.savedShortcuts < this.maxShortcuts) {
            this.maxReached = false;
            let shortcutArr = this.newShortcutsArr;
            let shortcutArrRemoval = this.removeShortcutsArr;
            let shortcut = this.createShortcutObject(event);
            shortcutArr.push(shortcut);
            shortcutArr = this.removeDuplicates(shortcutArr);
            shortcutArrRemoval = this.removeShortcutFromList(
                shortcutArrRemoval,
                shortcut
            );
            this.removeShortcutsArr = shortcutArrRemoval;
            this.newShortcutsArr = shortcutArr;
            if (
                this.savedShortcuts >= 0 &&
                this.savedShortcuts !== this.maxShortcuts
            ) {
                ++this.savedShortcuts;
            }
            if (this.savedShortcuts === this.maxShortcuts) {
                this.maxReached = true;
                this.disableAdditionButton = true;
            }
        } else {
            this.maxReached = true;
            this.disableAdditionButton = true;
        }
    }

    removeOldShortcut(event) {
        if (!this.formStartedValue) {
            this.formStartedValue = true;
            this.setInitalAdobeFields();
        }
        let shortcutArr = this.removeShortcutsArr;
        let shortcutArrAddition = this.newShortcutsArr;
        let shortcut = this.createShortcutObject(event);
        shortcutArr.push(shortcut);
        shortcutArr = this.removeDuplicates(shortcutArr);
        shortcutArrAddition = this.removeShortcutFromList(
            shortcutArrAddition,
            shortcut
        );
        this.newShortcutsArr = shortcutArrAddition;
        this.removeShortcutsArr = shortcutArr;
        if (this.savedShortcuts >= 0) {
            --this.savedShortcuts;
            this.disableAdditionButton = false;
            this.maxReached = false;
        }
    }

    createShortcutObject(event) {
        return {
            sobjectType: 'Subscribed_Solutions__c',
            Short_Cut_Name__c: event.detail.name,
            Short_Cut_Redirect_URL__c: event.detail.shortcutredirecturl,
            Solution__c: event.detail.shortcutsolutionid
        };
    }

    removeDuplicates(arr) {
        let newList = JSON.parse(JSON.stringify(arr));
        const key = 'Short_Cut_Name__c';
        let ArrangedList = [
            ...new Map(newList.map((item) => [item[key], item])).values()
        ];
        return ArrangedList;
    }

    removeShortcutFromList(arr, shortcut) {
        let newList = JSON.parse(JSON.stringify(arr));
        let ArrangedList = newList.filter(
            (item) => item.Short_Cut_Name__c !== shortcut.Short_Cut_Name__c
        );
        return ArrangedList;
    }

    updateCurrentShorcuts() {
        return refreshApex(this.refreshCurrentShourtcuts);
    }

    setInitalAdobeFields() {
        interactionForm(this.eventValues);
    }

    disconnectedCallback() {
        if (this.formStartedValue) {
            let event = this.eventValues;
            event.name = 'globalFormAbandon';
            event.formStatus = 'abandon';
            event.formisSubmitted = false;
            this.setInitalAdobeFields();
        }
    }
}