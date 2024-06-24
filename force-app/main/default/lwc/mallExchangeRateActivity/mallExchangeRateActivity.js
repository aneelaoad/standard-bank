import { LightningElement } from 'lwc';
import mallActivityImages from "@salesforce/resourceUrl/MallActivityImages";
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";

export default class MallExchangeRateActivity extends LightningElement {

    dArrowIcon = sbgIcons + "/OTHER/icn_darrowicon.svg";
    zar = mallActivityImages + "/zar.svg";
    usd = mallActivityImages + "/usd.svg";
    arrow = mallActivityImages + "/arrow.svg";
}