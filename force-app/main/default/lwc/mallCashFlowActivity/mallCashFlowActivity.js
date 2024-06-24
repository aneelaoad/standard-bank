import { LightningElement } from 'lwc';
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";
import mallActivityImages from "@salesforce/resourceUrl/MallActivityImages";

export default class MallCashFlowActivity extends LightningElement {
    dArrowIcon = sbgIcons + "/OTHER/icn_darrowicon.svg";
    mallActivityImages = mallActivityImages + "/cash_flow_chart.svg";
}