import { LightningElement } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from "lightning/navigation";
import birthdayAssets from "@salesforce/resourceUrl/OHBirthdayPage";

export default class OsbBirthdayPage extends NavigationMixin(LightningElement) {
    authentifiLogo = birthdayAssets + "/BDaypage/authentifi.png";
    frdmLogo = birthdayAssets + "/BDaypage/frdm.png";
    iidentifiiLogo = birthdayAssets + "/BDaypage/iiDENTIFii.png";
    moneyMarketsLogo = birthdayAssets + "/BDaypage/moneymarket.png";
    payGateLogo = birthdayAssets + "/BDaypage/PayGate.png";
    pbvLogo = birthdayAssets + "/BDaypage/pbverify.png";
    relyComplyLogo = birthdayAssets + "/BDaypage/rely-comply_1.png";
    resistentLogo = birthdayAssets + "/BDaypage/resisten.png";
    searchWorksLogo = birthdayAssets + "/BDaypage/searchworks.png";
    sbLogo = birthdayAssets + "/BDaypage/Standardbank.png";
    transactioncapitalLogo =
        birthdayAssets + "/BDaypage/transactioncapital.png";
    transunionLogo = birthdayAssets + "/BDaypage/transunion.png";
    wyztalkLogo = birthdayAssets + "/BDaypage/wyzetalk.png";
    awards = birthdayAssets + "/BDaypage/Award.png";
    omajoproject = birthdayAssets + "/BDaypage/omajoproject.png";
    onehubProgress = birthdayAssets + "/BDaypage/OneHub-1.png";
    fontFamily = birthdayAssets + "/BDaypage/Antonio-Bold.ttf";
    omajopdf = birthdayAssets + "/BDaypage/Umoja.pdf";

    navigateToHome() {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: "RegistrationForm__c"
            }
        });
    }

    renderedCallback() {
        loadStyle(this, birthdayAssets + "/BDaypage/font.css").then(() => {});
    }
}