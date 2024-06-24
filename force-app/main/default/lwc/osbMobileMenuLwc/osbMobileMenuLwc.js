import { api, LightningElement, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getInsights from "@salesforce/apex/OSB_HeaderDropdown_CTRL.getInsights";
import CloseIcon from "@salesforce/resourceUrl/OSBCloseIcon";
import getPingURL from "@salesforce/apex/OSB_HeaderDropdown_CTRL.getChangePasswordUrlPing";
import messageChannel from '@salesforce/messageChannel/osbMenuEvents__c';
import { subscribe, MessageContext } from 'lightning/messageService';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbMobileMenuLwc extends NavigationMixin(LightningElement) {
  @api currentTab = "Dashboard";
  @api mobileMenuToggled;
  @track Dashboard;
  @track overviewClicked = true;
  @track teamProfileClicked = true;
  @track profileAndSettingsClicked = true;
  @track communityClicked = false;
  @track collaborateClicked = false;
  @track displayedUnreadNotifications = false;
  OSBCloseIcon = CloseIcon;
  @api unreadNotificationsNumber;
  showTeamProfile = true;
  InsightUrl;
  chevronvalue = true;

  @wire(MessageContext)
  MessageContext;

  connectedCallBack(){
    this.handleSubscribe();
    this.handleReadNotification();
  }

  handleSubscribe() {
    if (this.subscription) {
        return;
    }
    this.subscription = subscribe(this.messageContext, messageChannel, (message) => {
        console.log('Subscription ' + message.messageText);
    });
}

  renderedCallback() {
    addAnalyticsInteractions(this.template);
    let urlSearchString = window.location.search;
    if (urlSearchString != null && urlSearchString != "") {
      let urlParams = String(urlSearchString).split("?");
      let sUrlVarList = urlParams[1].split("&");
      sUrlVarList.forEach(function (urlVar, index) {
        let item = urlVar.split("=");
        if (item[0] === "section") {
          if (item[1] !== "" && item[1] !== undefined) {
            this.currentTab = item[1];
          }
        }
      });
    }
    if (this.currentTab === "Dashboard") {
      this.Dashboard = true;
    }
  }

  @wire(getInsights)
  InsightUrl;

  handleTabChange() {
    this.currentTab = event.getParam("tabName");
    this.notifyAnalytics(event.getParam("tabName"));
  }

  @api
  handleMenuToggled(menuOpened) {
    this.mobileMenuToggled = menuOpened;
  }

  clickedOverview() {
    this.overviewClicked = !this.overviewClicked;
  }

  clickedNotifications() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Notifications__c",
      },
    });
  }

  clickedTeamProfile() {
    let tpClicked = this.teamProfileClicked;
    this.toggleTeamProfileMenu(tpClicked);
  }

  clickedTeamProfileLink() {
    this.openTeamProfile();
  }

  clickedPandS() {
    let pSClicked = this.profileAndSettingsClicked;
    this.profileAndSettingsClicked = !pSClicked;
  }

  handleReadNotification() {
    let notifications = this.unreadNotificationsNumber;
    this.setNotifications(notifications);
  }

  clickedProfileandSettings() {
    let selectedMenuItem = "editProfileAndSettings";
    this.handleSelect(selectedMenuItem);
  }

  clickedDeviceManagement() {
    let selectedMenuItem = "DeviceManagement";
    this.redirecttoDeviceManagement(selectedMenuItem);
  }

  clickedSignOut() {
    let selectedMenuItem = "signOut";
    this.handleSelect(selectedMenuItem);
  }

  handleAuthorization() {
    let selectedMenuItem = "changePasswordPing";
    this.setAuthorisation(selectedMenuItem);
  }

  openDashboard(event) {
    this.dispatchEvent(new CustomEvent('opennav', {
      detail: event.target.dataset.id
    }));
    this.closeMenuEvent(); 
  }

  openApplicationMarket(event){ 
    this.dispatchEvent(new CustomEvent('opennav', {
      detail: event.target.dataset.id
    }));
    this.closeMenuEvent();
  }

  openInsights(event){
    this.dispatchEvent(new CustomEvent('opennav', {
      detail: event.target.dataset.id
    }));
    this.closeMenuEvent();
  }

  clickedInviteTeamMembers() {
    let chosenOption = "Invite_Members";
    this.redirectOnTeamProfile(chosenOption);
  }

  clickedPendingApprovals() {
    let chosenOption = "Approvals";
    this.redirectOnTeamProfile(chosenOption);
  }

  clickedTeamDetails() {
    let chosenOption = "Team_Details";
    this.redirectOnTeamProfile(chosenOption);
  }

  clickedBeHeard() {
    let chosenOption = "BeHeard";
    this.sendMarketPlaceTabEvent(chosenOption);
  }

  clickedActivity() {
    let chosenOption = "MyActivity";
    this.sendMarketPlaceTabEvent(chosenOption);
  }

  clickedBookmarks() {
    let chosenOption = "Bookmarks";
    this.sendMarketPlaceTabEvent(chosenOption);
  }

  clickedSubmitIdea() {
    let chosenOption = "SubmitAnIdea";
    this.sendMarketPlaceTabEvent(chosenOption);
  }

  clickedSubmitProblem() {
    let chosenOption = "SubmitABusinessProblem";
    this.sendMarketPlaceTabEvent(chosenOption);
  }

  clickedProfile() {
    let selectedMenuItem = "editProfile";
    this.handleSelect(selectedMenuItem);
  }

  clickedCodeOfConduct() {
    let selectedMenuItem = "codeconduct";
    this.handleSelect(selectedMenuItem);
  }

  clickedConditions() {
    let selectedMenuItem = "conditions";
    this.handleSelect(selectedMenuItem);
  }

  clickedChangePassword() {
    let selectedMenuItem = "changePasswordPing";
    this.handleSelect(selectedMenuItem);
  }

  handleAuthorization(event) {
    this.setAuthorisation(event);
  }

  clickedCommunity() {
    let comClicked = this.communityClicked;
    this.toggleCommunity(comClicked);
  }

  clickedCollaborate() {
    let colClicked = this.collaborateClicked;
    this.toggleCollaborate(colClicked);
  }

  clickedContactUs() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "OPTL_Contact_Us__c",
      },
    });
  }

  toggleMenu(menuOpened) {
    this.mobileMenuToggled = menuOpened;
  }

  toggleOverview(ovClicked) {
    this.overviewClicked = !ovClicked;
  }

  logout() {
    window.location.replace("/secur/logout.jsp?retUrl=/s/");
  }

  handleSelect(selectedMenuItem) {
    let pageName;
    switch (selectedMenuItem) {
      case "editProfileAndSettings":
        pageName = "Profile_and_Settings__c";
        break;
      case "changePasswordPing":
        this.changePasswordPing();
        break;
      case "teamProfile":
        pageName = "team_profile__c";
        break;
      case "codeconduct":
        pageName = "Code_Of_Conduct__c";
        break;
      case "conditions":
        pageName = "Terms_and_Conditions__c";
        break;
      case "signOut":
        this.logout();
        break;
    }

    if (pageName) {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: pageName,
        },
      });
    }
  }

  changePasswordPing() {
    getPingURL().then((data) => {
      if (data) {
        let strURL = data.getReturnValue();
        strURL = encodeURI(strURL);
        window.open(strURL, "_top");
      }
    });
  }

  toggleTeamProfileMenu(tpClicked) {
    this.teamProfileClicked = !tpClicked;
  }

  openProduct() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "API_Products_OPTL__c",
      },
    });
    this.closeMenuEvent();
  }

  openTeamProfile() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "team_profile__c",
      },
    });
    this.closeMenuEvent();
  }

  redirectOnTeamProfile(option) {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "team_profile__c",
      },
      state: {
        activeTab: option,
      },
    });
    this.closeMenuEvent();
  }

  redirecttoDeviceManagement(option) {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Profile_and_Settings__c",
      },
      state: {
        activeTab: option,
      },
    });
    appEvent.fire();
    this.closeMenuEvent();
  }

  setAuthorisation() {
    this.showTeamProfile = false;
  }

  toggleCommunity(comClicked) {
    this.communityClicked = !comClicked;
  }

  setNotifications(notifications) {
    let displayedNotifications = notifications > 99 ? "99+" : notifications;
    this.displayedUnreadNotifications = displayedNotifications >= 1 ? true : false;;
    this.unreadNotificationsNumber = notifications;
  }

  toggleCollaborate(colClicked) {
    this.collaborateClicked = !colClicked;
  }

  sendMarketPlaceTabEvent(option) {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Home",
      },
      state: {
        activeTab: option,
        section: "MarketPlace",
      },
    });
    appEvent.fire();
    this.closeMenuEvent();
  }

  closeMobileMenu() {
    this.mobileMenuToggled = false;
    this.closeMenuEvent();
    document.body.style.overflow = "auto";
  }

  closeMenuEvent() {
    let details = {
      menuOpened: false,
      isMobileView: true,
      unreadNotificationsNumber: parseInt(this.unreadNotificationsNumber),
      showTeamProfile: this.showTeamProfile,
    };
    const appEvent = new CustomEvent("clsevt", {
      detail: details,
    });
    this.dispatchEvent(appEvent);
  }
}