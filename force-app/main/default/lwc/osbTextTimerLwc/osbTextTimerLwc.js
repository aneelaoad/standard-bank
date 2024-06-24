import { LightningElement, api } from 'lwc';

export default class OsbTextTimerLwc extends LightningElement {
    @api timerstepcirle;

    timerCountdown = '3:00';
    TotalintervalId = 0;
    totalProgress = 180;
    actualProgress = 180;
    totalPerc = 100;
    cirDeg = 0;
    perText = 0;
    barstyle;

    connectedCallback(){
        this.startTimer();
    }

    computeProgress(totalVal,actualVal){
        if(totalVal && (actualVal || actualVal === 0) && !isNaN(parseInt(totalVal)) && isFinite(totalVal) && !isNaN(parseInt(actualVal)) && isFinite(actualVal)){
            let percVal = parseInt(actualVal) / parseInt(totalVal) ;
            let progressVal = parseInt(  percVal * 360  ) ;
            this.cirDeg =  progressVal;
            this.timerCountdown = this.intToSecondString(actualVal);
        }
    }

    intToSecondString(seconds){
        let formattedMinutes = parseInt(seconds / 60);
        let formattedSeconds = String(seconds - formattedMinutes * 60);
        if (formattedSeconds.length < 2){
            formattedSeconds = "0" + formattedSeconds;
        }
        return formattedMinutes + ":" + formattedSeconds;
    }

    startTimer(){
        let helper = this;
        clearInterval(parseInt(this.TotalintervalId));
        let totalValue = this.totalProgress;
        let actualValue = this.totalProgress;
        this.computeProgress(totalValue,actualValue);
        this.TotalintervalId = setInterval(function() {
            actualValue--;
            this.computeProgress(totalValue,actualValue);
            if(actualValue === 0){
                const selectedEvent = new CustomEvent("timerevent", {
                    detail: actualValue
                });
                this.dispatchEvent(selectedEvent);
                clearInterval(parseInt(this.TotalintervalId));
            }else{
                if(this.timerstepcirle){
                    if(this.cirDeg < 184){
                        let containerdiv =  this.template.querySelector('[data-id="containerdegree"]');
                        if(containerdiv.classList.contains("p50plus")){
                            containerdiv.classList.remove("p50plus");
                        }
                   } 
                }
            }

            if(this.timerstepcirle == true){
                let barStyle = '-webkit-transform: rotate('+this.cirDeg+
                'deg); -moz-transform: rotate('+this.cirDeg+
                'deg); -ms-transform: rotate('+this.cirDeg+
                'deg); -o-transform: rotate('+this.cirDeg+
                'deg); transform: rotate('+this.cirDeg+
                'deg); -ms-transform: rotate('+this.cirDeg+'deg);'; 

                this.template.querySelector('[class="bar"]').style = barStyle;
            }
        }.bind(this), 1000);
    }

    @api handleStopTimer(){
        clearInterval(parseInt(this.TotalintervalId));
        this.timerCountdown = '0:00'
        if(this.timerstepcirle){
            this.cirDeg = 0;
            let barStyle = '-webkit-transform: rotate('+this.cirDeg+
            'deg); -moz-transform: rotate('+this.cirDeg+
            'deg); -ms-transform: rotate('+this.cirDeg+
            'deg); -o-transform: rotate('+this.cirDeg+
            'deg); transform: rotate('+this.cirDeg+
            'deg); -ms-transform: rotate('+this.cirDeg+'deg);';             
            this.template.querySelector('[class="bar"]').style = barStyle;
        }
    }

    @api handleRestart(){
        this. timerCountdown = '3:00';
        this.actualProgress = 180;
        this.startTimer();
    }
}