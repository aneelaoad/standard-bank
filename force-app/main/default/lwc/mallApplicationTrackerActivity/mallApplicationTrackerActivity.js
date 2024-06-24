import { LightningElement } from 'lwc';
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";
import mallActivityImages from "@salesforce/resourceUrl/MallActivityImages";

export default class MallApplicationTrackerActivity extends LightningElement {
    dArrowIcon = sbgIcons + "/OTHER/icn_darrowicon.svg";
    appTrackerEdit = sbgIcons + "/OTHER/icn_apptrackeredit.svg";
    appTrackerPeople = sbgIcons + "/OTHER/icn_apptrackerpeople.svg";
    appTrackerArrowLeft = sbgIcons + "/OTHER/icn_apptrackerleftarrow.svg";
    appTrackerArrowRight = sbgIcons + "/OTHER/icn_apptrackerrightarrow.svg";
    progressBar = mallActivityImages + "/application_progress.svg";
}