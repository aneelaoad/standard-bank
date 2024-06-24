import { LightningElement } from 'lwc';
import ReadytoMovetoStandardBank from '@salesforce/label/c.PBP_ZA_ReadytoMovetoStandardBank';
import OpenYourAccountwhoAreSerious from '@salesforce/label/c.PBP_ZA_OpenYourAccountwhoAreSerious';
import Switch from '@salesforce/label/c.PBP_ZA_Switch';
import StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
export default class Pbp_comp_switch_component extends LightningElement {

    isEventFired;
    adobePageTag = {
        dataId: "link_content",
        dataIntent: "Informational",
        dataScope: "Content links",
        switchButtonText: "mymobiz business account | business home page|  switch button click",
    };
    label = {
        ReadytoMovetoStandardBank,
        OpenYourAccountwhoAreSerious,
        Switch,
    };
    handleswitchOpen(event) {
        window.fireButtonClickEvent(this, event);
        window.open(StandardBankUrl + "/southafrica/business/products-and-services/bank-with-us/switch-your-bank-account", StandardBankUrl);
    }
}