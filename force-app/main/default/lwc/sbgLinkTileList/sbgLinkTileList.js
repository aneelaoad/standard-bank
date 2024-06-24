import { LightningElement, api } from "lwc";
import RESOURCE_BASE_PATH from '@salesforce/resourceUrl/sbgVisualAssets';
import { addAnalyticsInteractions } from 'c/acm_AdobeAnalytics';

export default class Acm_TileMenu extends LightningElement {
  @api tileTexts;
  @api tileUrls;
  @api tileIcons;

  get tiles() {
    let titleArray =
      this.tileTexts != undefined ? this.tileTexts.split(",") : [];
    let urlArray = this.tileUrls != undefined ? this.tileUrls.split(",") : [];
    let iconArray =
      this.tileIcons != undefined ? this.tileIcons.split(",") : [];

    let tileArray = [];
    let count = titleArray.length;
    if (count > urlArray.length) {
      count = urlArray.length;
    }

    for (let i = 0; i < count; i++) {
      let title = titleArray[i] != undefined ? titleArray[i].trim() : "";
      let url = urlArray[i] != undefined ? urlArray[i].trim() : "";
      let icon = iconArray[i] != undefined ? iconArray[i].trim() : "";
      tileArray.push({
        id: i,
        title: title,
        url: url,
        icon: RESOURCE_BASE_PATH + icon,
      });
    }
    return tileArray;
  }

  renderedCallback(){
    addAnalyticsInteractions(this.template);
  }
}