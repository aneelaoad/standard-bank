import { LightningElement } from 'lwc';
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";

export default class MallStocksActivity extends LightningElement {
    dArrowIcon = sbgIcons + "/OTHER/icn_darrowicon.svg";
    stockArrowGreen = sbgIcons + "/OTHER/icn_stocksgreenarrow.svg";
    stockArrowRed = sbgIcons + "/OTHER/icn_stocksredarrow.svg";
}