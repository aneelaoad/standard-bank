import { LightningElement, track, wire } from 'lwc';
import getFooterItems from '@salesforce/apex/SBGFooterBarController.getFooterItems';
import { addAnalyticsInteractions } from 'c/mallAnalyticsTagging';
import { MallTranslationService, getTranslatedLabelByMetadataId } from 'c/mallTranslationService';
import { NavigationMixin } from "lightning/navigation";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";

export default class SbgFooterBar extends NavigationMixin(LightningElement) {

    footerItems = [];
    customLabels = {};
    copyRight = new Date().getFullYear();
    navigateToWebPage = navigateToWebPage.bind(this);

    @track showFooterItems = false;

    connectedCallback() {
        this.getTranslatedLabels();
    }

    @wire(getFooterItems, {})
    topLeftNavigationItems({data, error}){
        if(data){
            this.footerItems = data;
            this.footerItems = this.setUpTranslatedLabels([...this.footerItems]);
            if(this.footerItems && this.footerItems.length > 0) {
              this.showFooterItems =true;
            }
        }
        else if (error) {
            this.footerItems = [];
            this.showFooterItems =false;
        }
    }

    renderedCallback() {
        setTimeout(() => {
            if (this.template) {
                addAnalyticsInteractions(this.template);
            }
          }, 200);
    }

    async getTranslatedLabels() {
      try {
        const translatedLabelsInstance = MallTranslationService.getInstance();
        const translatedLabels = await translatedLabelsInstance.getTranslatedLabels();
        this.customLabels = {...translatedLabels};
      } catch (error) {
        this.error = error;
      }
    }
      
  setUpTranslatedLabels(navItems) {
    let customlabels = { ...this.customLabels };
    let navItemList = [];
    //Set Up Parent level translation for footer
    for(let row=0; row < navItems.length; row++) {
      let value = getTranslatedLabelByMetadataId(navItems[row].id, customlabels);
      let navItem = {...navItems[row]};
      if(value) {
        navItem.translatedLabel = value;
      } else {
        navItem.translatedLabel = navItem.name;
      }
      //Set Up children level translation for footer
      let navItemsChildren = navItems[row].footerChildItems;
      let navItemsChildrenList = [];
      if(navItemsChildren && navItemsChildren.length > 0) {
        for(let i=0; i < navItemsChildren.length; i++) {
            let navItemChild = {...navItemsChildren[i]};
            let valueChild = getTranslatedLabelByMetadataId(navItemsChildren[i].id, customlabels);
            if(valueChild) {
              navItemChild.translatedLabel = valueChild;
            } else {
              navItemChild.translatedLabel = navItemsChildren[i].name;  
            }
            navItemsChildrenList.push(navItemChild);
        }
      }
      navItem.footerChildItems = [...navItemsChildrenList];
      navItemList.push(navItem);
    }
    return navItemList;
  }

    //Navigation Item click handler method
    handleFooterItemClick(event) {
      event.preventDefault();
      event.stopPropagation();
      const link = event.target.dataset.link;
      if(link && !link.includes("http")) {
        this.navigateToWebPage(getBaseUrl() + link);
      }
      if(link && link.includes("http")) {
        this.navigateToWebPage(link);
      }
    }

}