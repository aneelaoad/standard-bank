import { LightningElement, api, wire } from "lwc";
import fetchMetaListLwc from "@salesforce/apex/OSB_MiniMallCustomMetadata_CTRL.fetchMetaListLwc";
import MiniMall from "@salesforce/resourceUrl/OSB_MiniMall";
import eventCompChannel from "@salesforce/messageChannel/osbInterCompEvent__c";
import Id from "@salesforce/user/Id";
import { publish, MessageContext } from "lightning/messageService";
import { subscribe, APPLICATION_SCOPE } from "lightning/messageService";
import ApplicationRefresh from "@salesforce/messageChannel/osbApplicationRefresh__c";
import messageChannel from "@salesforce/messageChannel/osbMenuEvents__c";
import { refreshApex } from "@salesforce/apex";
import { addAnalyticsInteractions } from "c/osbAdobeAnalyticsWrapperLwc";

export default class osbCategoriesLwc extends LightningElement {
  AllApplication = MiniMall + "/AllApplications.svg";
  userId = Id;
  records;
  wiredRecords;
  error;
  draftValues = [];
  subscription = null;
  Applicationsubscription = null;
  refreshResult;
  recordAdded;
  recordTester;

  @api categories = "";
  showApps = true;
  @api showMiniMallFilter = false;

  @wire(fetchMetaListLwc, { userId: "$userId" })
  fetchMetaListLwc(result) {
    this.refreshResult = result;
    if (result.data) {
      let receivedCategories = JSON.parse(JSON.stringify(result.data));
      let startSpeed = 0.85;
      let categoryList = [];
      for (let i = 0; i < receivedCategories.length; i++) {
        startSpeed += 0.3;
        let category = {
          Id: receivedCategories[i].Id,
          MasterLabel: receivedCategories[i].MasterLabel,
          ImageLink__c: receivedCategories[i].ImageLink__c,
          animationDelay: "animation-delay:" + startSpeed + "s;",
        };
        categoryList.push(category);
      }

      if (categoryList) {
        this.records = categoryList;
      }
    }
  }

  renderedCallback() {
    this.retrieveCategories();
    this.handleSubscribe();
    addAnalyticsInteractions(this.template);
  }

  retrieveCategories() {
    fetchMetaListLwc({ userId: this.userId })
      .then((data) => {
        if (data) {
          let receivedCategories = JSON.parse(JSON.stringify(data));
          let startSpeed = 0.85;
          let categoryList = [];
          for (let i = 0; i < receivedCategories.length; i++) {
            startSpeed += 0.3;
            let category = {
              Id: receivedCategories[i].Id,
              MasterLabel: receivedCategories[i].MasterLabel,
              ImageLink__c: receivedCategories[i].ImageLink__c,
              animationDelay: "animation-delay:" + startSpeed + "s;",
            };
            categoryList.push(category);
          }
        }
      })
      .catch((error) => {
        this.error = error;
      });
  }

  @wire(MessageContext)
  messageContext;

  @wire(MessageContext)
  MessageContextChannelMenu;

  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.MessageContextChannelMenu,
      messageChannel,
      (message) => {
        if (
          message.ComponentName === "Bread crumb" ||
          message.ComponentName === "Header"
        ) {
          this.showMiniMallFilter = false;
        }
      }
    );
    if (!this.Applicationsubscription) {
      this.Applicationsubscription = subscribe(
        this.messageContext,
        ApplicationRefresh,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  handleMessage(message) {
    this.recordAdded = message.recordAdded;
    return refreshApex(this.refreshResult);
  }

  handleClick(event) {
    this.showMiniMallFilter = true;
    let category = event.currentTarget;
    this.categories = category.dataset.value;

    const payload = {
      ComponentName: "Categories",
      Details: {
        Tab: "Application Marketplace",
      },
    };

    publish(this.messageContext, eventCompChannel, payload);
    this.showApps = false;

    this.dispatchEvent(
      new CustomEvent("displayapplicationgallery", {
        detail: !this.showMiniMallFilter,
      })
    );
  }

  @api
  addapp() {
    const payload = {
      ComponentName: "Categories",
      Details: {
        propertyValue: "",
      },
    };
    this.showMiniMallFilter = true;
    publish(this.messageContext, eventCompChannel, payload);
    this.showApps = false;
  }
}