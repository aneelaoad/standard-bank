import { LightningElement } from "lwc";
import logo from "@salesforce/resourceUrl/PBP_ThemeOverrides";
import getreward from '@salesforce/label/c.PBP_ZA_GetRewarded';
import tellmemore from '@salesforce/label/c.PBP_ZA_TellMeMore';
import number1 from '@salesforce/label/c.PBP_ZA_Number1';
import number2 from '@salesforce/label/c.PBP_ZA_Number2';
import number3 from '@salesforce/label/c.PBP_ZA_Number3';
import join from '@salesforce/label/c.PBP_ZA_Join';
import signup from '@salesforce/label/c.PBP_ZA_SignUP';
import earn from '@salesforce/label/c.PBP_ZA_Earn';
import collect from '@salesforce/label/c.PBP_ZA_CollectRewards';
import spend from '@salesforce/label/c.PBP_ZA_Spend';
import use from '@salesforce/label/c.PBP_ZA_UseYourBusiness';
import UcountStandardbankUrl from '@salesforce/label/c.PBP_ZA_UcountStandardbankUrl';
import standardbankurl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
export default class Pbp_comp_product_business_ucount_rewards extends LightningElement {
  logo = logo + "/assets/images/dsk-u-count-rewards-logo@2x.png";
  label = {
    getreward,
    tellmemore,
    number1,
    number2,
    number3,
    join,
    signup,
    earn,
    collect,
    spend,
    use,
  }
  adobePageTag = {
    dataId: "link_content",
    dataIntent: "Informational",
    dataScope: "Content Button",
    cancelButtonText: "Join Ucounts Rewards|  Tell Me More button click",
  };
  tellMeMore(event) {
    window.fireButtonClickEvent(this, event);
    window.open(
      UcountStandardbankUrl + "/business/earn-points/how-to-earn-points/",standardbankurl
    );
  }
}