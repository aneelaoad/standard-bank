import { LightningElement,api } from 'lwc';

export default class Omf_dynamicProgressBar extends LightningElement {
    @api count;
    @api currentStep;
    get steps(){
        let steps =[];
        if(this.count){
            for(let i=1; i<= this.count; i++){
                let step = {};
                step.label = 'Step '+i;
                step.value = i.toString();
                steps.push(step);
            }
        }
        return steps;
    }
}