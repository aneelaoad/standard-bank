import {
	LightningElement,
	wire,
	track
}
from "lwc";
import getLegalTabsInfo from '@salesforce/apex/CTRL_Mall_ArticleLegals.getLegalTabsInfo';
import getLegalInfo from "@salesforce/apex/CTRL_Mall_ArticleLegals.getLegalInfo";
import {
	mallStateName,
	getUserState
}
from "c/sbgUserStateUtils";
import {
	CurrentPageReference,
	NavigationMixin
}
from "lightning/navigation";
import {
	subscribe,
	unsubscribe,
	APPLICATION_SCOPE,
	MessageContext
}
from "lightning/messageService";
import USER_LANGUAGE_CHANGED_EVT from "@salesforce/messageChannel/UserLanguageChanged__c";
import {
	addAnalyticsInteractions
}
from "c/mallAnalyticsTagging";
const DEFAULT_MALL_COUNTRY = "South Africa";
const DEFAULT_MALL_LANGUAGE_ISO = "en";

export default class SbgLegal extends NavigationMixin(LightningElement) {
	@track body;
	error;
	currentPageReference;
	legalContent = [];
	tabs = [];
	runOnce = false;
	tabsMeta = {};
	@track selectedTab = {};
	subscription = null;
	@wire(MessageContext)
	messageContext;

	connectedCallback() {
		this.subscribeToMessageChannel();
		this.getLegalTabs();
		this.fetchLegalInfo();
		this.getContentForSelectedLegal();
	}

	subscribeToMessageChannel() {
		if (!this.subscription) {
			this.subscription = subscribe(
				this.messageContext,
				USER_LANGUAGE_CHANGED_EVT,
				(message) => this.handleLanguageChange(message), {
					scope: APPLICATION_SCOPE
				}
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

	handleLanguageChange(message) {
		if (!this.selectedTab.tabName) {
			for (const property in this.tabsMeta) {
				if (this.tabsMeta[property] == this.selectedTab.value) {
					this.selectedTab.tabName = property;
				}
			}
		}
		this.fetchLegalInfo();
		this.getContentForSelectedLegal();
	}

	async getLegalTabs() {
		try {
			let legalTabs = await getLegalTabsInfo();
			let tabsMeta = {};
			for (let row = 0; row < legalTabs.length; row++) {
				if (legalTabs[row].IsActive__c) {
					tabsMeta[legalTabs[row].Label] = legalTabs[row].Position__c + "";
				}
			}
			this.tabsMeta = tabsMeta;
		}
		catch (error) {
			this.error = error;
		}
	}

	async fetchLegalInfo() {
		//set mallContext
		let userSelectedCountry = getUserState(mallStateName.mallUserSelectedCountry, DEFAULT_MALL_COUNTRY);
		try {
			let legalContent = await getLegalInfo({country: userSelectedCountry, category: 'Legal'});
			if (legalContent) {
				let tabs = []
				legalContent.forEach(legal => {
					if (Object.keys(this.tabsMeta).includes(legal.Title)) {
						tabs.push({
							tabName: legal.Title,
							value: this.tabsMeta[legal.Title]
						});
					}
				});
        tabs.sort(function(a,b){return a.value-b.value});
				this.tabs = [...tabs];
				this.legalContent = legalContent;
			}
		}
		catch (error) {
			this.error = error;
			this.body = '';
		}
	}

	@wire(CurrentPageReference)
	async getStateParameters(currentPageReference) {
		this.currentPageReference = currentPageReference;
		await this.getLegalTabs();
		if (currentPageReference) {
			let tabValue = currentPageReference.state["tab"];
			this.selectedTab.value = tabValue;
			if (tabValue) {
				for (const property in this.tabsMeta) {
					if (tabValue && this.tabsMeta[property] == tabValue) {
						this.selectedTab = {
							tabName: property,
							value: tabValue
						};
						if (this.legalContent) {
							this.getContentForSelectedLegal();
						}
						break;
					}
				}
			}
		}
	}

	getContentForSelectedLegal() {
		let selectedLegal;
		for (let row = 0; row < this.legalContent.length; row++) {
			if (this.legalContent[row].Title === this.selectedTab.tabName) {
				selectedLegal = this.legalContent[row];
				break;
			}
		}
		if (selectedLegal) {
			this.body = selectedLegal.Info__c;
		}
	}

	handleActiveTabChange(event) {
		event.preventDefault();
		event.stopPropagation();
		let selectedTabValue = event.target.value;
		this.handleStateChange(selectedTabValue);
	}

	handleStateChange(selectedTabValue) {
		let updatedPageReference = this.getUpdatedPageReference({
			tab: selectedTabValue
		});
		this[NavigationMixin.Navigate](updatedPageReference, true);
	}

	renderedCallback() {
		addAnalyticsInteractions(this.template);
		if (this.legalContent && this.legalContent.length)
			this.getContentForSelectedLegal();
	}

	getUpdatedPageReference(stateChanges) {
		return Object.assign({}, this.currentPageReference, {
			state: Object.assign({}, this.currentPageReference.state, stateChanges)
		});
	}
}