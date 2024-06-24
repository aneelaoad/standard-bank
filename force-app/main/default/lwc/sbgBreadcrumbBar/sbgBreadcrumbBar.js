import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { navigateToPage, navigateToWebPage, navigateToRecordPage } from "c/mallNavigation";
import IS_GUEST from "@salesforce/user/isGuest";
import loggedInUserId from '@salesforce/user/Id';
import getUserProfile from '@salesforce/apex/MallProfileManagementController.getUserProfile';

export default class SbgBreadcrumbBar extends NavigationMixin(
  LightningElement
) {
  @api navigationTrail;
  navigateToWebPage = navigateToWebPage.bind(this);
  navigateToPage = navigateToPage.bind(this);
  navigateToRecordPage = navigateToRecordPage.bind(this);
  userProfile;

  get navigationPathItems() {
    let result = this.navigationTrail ? JSON.parse(this.navigationTrail) : null;
    return result;
  }

  homeIcon = mallIcons + "/home_icon.svg";
  rightIcon = mallIcons + "/ic_chevron-right.svg";
  pageMap = {
    "Account Detail": "Store detail",
    "Contact Detail": "Representative detail",
    "Tag Detail": "Solutions detail"
  };

  get currentPageName() {
    let currentPageTitle = window.document.title;
    if (this.pageMap.hasOwnProperty(currentPageTitle)) {
      currentPageTitle = this.pageMap[currentPageTitle];
    }
    //There are some pages for which the document title is not setup properly
    //we use the url of the page to generate the title in th breadcrumb component
    else if(currentPageTitle == "Widget") {
      const pathName = location.pathname.split('/s/')[1].split('/')[0];
      const pathNameSplitCaseAdjusted = pathName.replace(/^\w/, c => c.toUpperCase());
      currentPageTitle = pathNameSplitCaseAdjusted;
    }
    return currentPageTitle;
  }

  navigateToInternalPage() {
    //for Store profiles when edit mode is true
    //we want to redirect to the Account page else home page of the site
    if(!IS_GUEST && this.userProfile.user.Profile.Name.includes('Store') && this.userProfile.user.Edit_Mode__c) {
      this.navigateToRecordPage(this.userProfile.user.AccountId);
    } else {
      let name = "Home";
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: name
        }
      });
    }
  }

  connectedCallback() {
    if(!this.userProfile && !IS_GUEST) {
      this.fetchUserProfile();
    }
  }


  async fetchUserProfile() {
    this.userProfile = await getUserProfile({ currentUserId: loggedInUserId });
  }

  navigateToUrl(evt) {
    evt.preventDefault;
    let name = evt.target.text;
    let url = evt.target.href ? evt.target.href : "";

    if (!url) {
      this.navigateToPage(name);
    } else {
      this.navigateToWebPage(url);
    }
  }

  renderedCallback() {
    addAnalyticsInteractions(this.template);
  }
}