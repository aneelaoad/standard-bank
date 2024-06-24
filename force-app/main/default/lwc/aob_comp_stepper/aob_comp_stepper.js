import { LightningElement, api } from 'lwc';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';

export default class Aob_comp_stepper extends LightningElement {
    greenCheckIcon = THEME_OVERRIDES + '/assets/images/greenCheck.png';
    @api recordId;
    error;
    @api currentScreen;
    @api currentScreenNum;
    @api numOfScreens;
    @api previousScreen;
    @api productName;
    currentProgressPercentage = '';

    get getProgressBarStyle(){
        var progressBarStyle = '';
        if(this.currentScreenNum && this.numOfScreens){
            this.currentProgressPercentage = `${(this.currentScreenNum - 1) / (this.numOfScreens) * 100}%`;
            progressBarStyle = `width: ${this.currentProgressPercentage};`;
        }
        return progressBarStyle;
    }

}