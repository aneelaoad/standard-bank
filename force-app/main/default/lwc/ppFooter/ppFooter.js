/**
* @description  : Partner Portal Partner Footer Component
* User Story : SFP-4962
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date June 2021
*/
import { LightningElement } from 'lwc';
import userId from '@salesforce/user/Id';
import { trackLink } from 'c/ppEventUtils'

export default class PpFooter extends LightningElement {
   usrId = userId;

   tracker(event) {
      trackLink(event);
  }
}