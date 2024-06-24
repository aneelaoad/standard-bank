import { LightningElement, track, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';


export default class Acm_progressIndicator extends LightningElement {
    @api title = 'ACM APPLICATION';
    @api currentstagenumber;
    @api stagenames;
    @api progressIndicatorsStages = [];
    @api currentstagestatus;
    @api mobilesubheading;
    @api currentsectionnumber;
    @api totalsectionnumber;

    @track progressPercentage = 0;
    @track progressPercentageWidth = 'width:0%';
    @track isComplete = false;
    @track isDesktopDevice = false;
    @track isTabDevice = false;
    @track isMobileDevice = false;
    @track mobilestagename;
    @track mobilestagevaluenow = 0;
    @track mobilestatename;
    
    


    connectedCallback() {
        this.initializeProgressRing();
    }

    initializeProgressRing() {
        var currentStagePercentage = (parseFloat(this.currentsectionnumber) / parseFloat(this.totalsectionnumber) * 100);
  
        //checking the device type
        

        if (FORM_FACTOR && FORM_FACTOR === 'Large') {
            this.isDesktopDevice = true;
        
        } else if (FORM_FACTOR && FORM_FACTOR === 'Small') {
            this.isMobileDevice = true;
        }

        //creating the progressIndicatorStages array required for progressRing
        if (this.stagenames && this.stagenames.includes(',')) {
            var stageNamelst = this.stagenames.split(',');
            for (var i = 0; i < stageNamelst.length; i++) {
                this.progressIndicatorsStages.push({ 
                    progressWidth: 'width:0%', 
                    stagenumber: i + 1, 
                    stagename: stageNamelst[i], 
                    stagevaluenow: 0, 
                    statename: "active", 
                    middleStage: true, 
                    lastStage: false, 
                    firstStage: false 
                });

            }
        }

        var totalSetps = this.progressIndicatorsStages.length;
        if (totalSetps > 0) {
            this.progressIndicatorsStages[totalSetps - 1].lastStage = true;
            this.progressIndicatorsStages[totalSetps - 1].middleStage = false;
            this.progressIndicatorsStages[0].firstStage = true;
            this.progressIndicatorsStages[0].middleStage = false;
        }


        for (var i = 0; i < totalSetps; i++) {

            if (this.currentstagenumber > this.progressIndicatorsStages[i].stagenumber) {
                this.progressIndicatorsStages[i].progressWidth = 'width:100%;background: #0062E1;';
            }
           
            if (this.currentstagenumber == totalSetps) {
                this.progressIndicatorsStages[i].progressWidth = 'width:100%;background: #0062E1;';
            }
        }

        if (totalSetps == 2) {
            this.progressIndicatorsStages[0].progressWidth = 'width:100%;background: #0062E1;';
            this.progressIndicatorsStages[1].progressWidth = 'width:100%;background: #0062E1;';
        }

        for (var i = 0; i < totalSetps; i++) {
            if (this.currentstagenumber == this.progressIndicatorsStages[i].stagenumber) {
                if (this.currentstagestatus) {
                    if (this.currentstagestatus == 'New') {
                        //for mobile
                        if (this.isMobileDevice) {
                            this.mobilestagename = this.progressIndicatorsStages[this.currentstagenumber - 1].stagename;
                            this.mobilestagevaluenow = currentStagePercentage;
                            this.mobilestatename = 'active';
                        }
                        this.progressIndicatorsStages[i].stagevaluenow = currentStagePercentage;
                        this.progressIndicatorsStages[i].statename = 'active';
                    } else if (this.currentstagestatus == 'In Progress') {
                        //for mobile
                        if (this.isMobileDevice) {
                            this.mobilestagename = this.progressIndicatorsStages[this.currentstagenumber - 1].stagename;
                            this.mobilestagevaluenow = currentStagePercentage;
                            this.mobilestatename = 'normal';
                        }
                        this.progressIndicatorsStages[i].stagevaluenow = currentStagePercentage;
                        this.progressIndicatorsStages[i].statename = 'normal';
                    } else if (this.currentstagestatus == 'Completed') {
                        //for mobile
                        if (this.isMobileDevice) {
                            this.mobilestagename = this.progressIndicatorsStages[this.currentstagenumber - 1].stagename;
                            this.mobilestagevaluenow = 100;
                            this.mobilestatename = 'complete';
                        }
                        this.progressIndicatorsStages[i].stagevaluenow = 100;
                        this.progressIndicatorsStages[i].statename = 'complete';
                    }
                }else{
                    //for mobile
                    if (this.isMobileDevice) {
                        this.mobilestagename = this.progressIndicatorsStages[this.currentstagenumber - 1].stagename;
                        this.mobilestagevaluenow = currentStagePercentage;
                        this.mobilestatename = 'normal';
                    }
                    this.progressIndicatorsStages[i].stagevaluenow = currentStagePercentage;
                    this.progressIndicatorsStages[i].statename = 'normal';
                }

            } else if (parseInt(this.currentstagenumber) > i) {
                this.progressIndicatorsStages[i].stagevaluenow = 100;
                this.progressIndicatorsStages[i].statename = 'complete';
            }

        }

        if (this.currentstagestatus && this.currentstagestatus == 'Completed') {
            this.isComplete = true;
        }
    }

}