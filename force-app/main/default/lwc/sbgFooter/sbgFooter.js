import { LightningElement,api } from 'lwc';
import { addAnalyticsInteractions } from 'c/acm_AdobeAnalytics';
import RESOURCE_BASE_PATH from '@salesforce/resourceUrl/sbgVisualAssets';


export default class SbgFooter extends LightningElement {

    

    @api disclaimerText;
    @api socialMenuUrls;
    @api socialMenuIcons;
    @api footerMenuLabels;
    @api footerMenuUrls;

    get socialMenu() {
       
        let urlArray = this.socialMenuUrls != undefined && this.socialMenuUrls != "" ? this.socialMenuUrls.split(',') : [];

        let iconArray = this.socialMenuIcons != undefined ? this.socialMenuIcons.split(',') : [];

          let socialArray = [];
          let count = urlArray.length;
          if (count > urlArray.length) {
            count = urlArray.length;
          }

          for (let i = 0; i < count; i++) {
            let url = urlArray[i] != undefined ? urlArray[i].trim() : '';
            let icon = iconArray[i] != undefined ? iconArray[i].trim() : '';
           
            socialArray.push({
              id: i,
              url: url,
              icon: RESOURCE_BASE_PATH + icon,
             
            });
          }
          return socialArray;
    }

    get footerMenu() {
       
        let urlArray = this.footerMenuUrls != undefined ? this.footerMenuUrls.split(',') : [];

        let labelArray = this.footerMenuLabels != undefined ? this.footerMenuLabels.split(',') : [];

          let footerArray = [];
          let count = urlArray.length;
          if (count > urlArray.length) {
            count = urlArray.length;
          }

          for (let i = 0; i < count; i++) {
            let url = urlArray[i] != undefined ? urlArray[i].trim() : '';
            let label = labelArray[i] != undefined ? labelArray[i].trim() : '';
            footerArray.push({
              id: i,
              url: url,
              label: label,
            });
          }
          return footerArray;
    }
  
    get useDisclaimerText() {
        return this.disclaimerText;
    }

    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }

    
}