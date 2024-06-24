import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getItemsToAction from '@salesforce/apex/StdBank_Ltn_ActionItems.getItemsToAction';
import CSI_Case_reminder_subject from '@salesforce/label/c.CSI_Case_reminder_subject';
import itaItem_to_Action from '@salesforce/label/c.itaItem_to_Action';
import itaCsiCases from '@salesforce/label/c.itaCsiCases';
import itaNbacTasks from '@salesforce/label/c.itaNbacTasks';
import itaOppWithZeroRev from '@salesforce/label/c.itaOppWithZeroRev';

export default class ItemsToAction extends NavigationMixin(LightningElement) {

    label = {
        CSI_Case_reminder_subject,
        itaItem_to_Action,
        itaCsiCases,
        itaNbacTasks,
        itaOppWithZeroRev
    }

    @track activeSection = [];
    @track csiTasks = [];
    @track nbacTasks = [];
    @track opportunities = [];

    @track labelCsi = '';
    @track labelNbac = '';
    @track labelOpp = '';
    @track error;
    showSpinner = true;

    @wire(getItemsToAction)
    result({error, data}) {
        if(data) {
            if(data.opportunities) {
                this.labelOpp = this.label.itaOppWithZeroRev + ' (' + data.opportunities.length + ')';
                this.opportunities = data.opportunities;
            }else {
                this.labelOpp = this.label.itaOppWithZeroRev + ' (0)';
                this.opportunities = [];
            }
            let currentDate = new Date;
            if(data.tasks){
                data.tasks.forEach(task => {
                    let tempTask = {...task};
                    if(Date.parse(tempTask.ActivityDate) < currentDate) {
                        tempTask['style'] = 'dueDateRed';
                    }else {
                        tempTask['style'] = 'dueDateBlack';
                    }
                    if(tempTask.Type === 'NBAC Action Item') {
                        this.nbacTasks.push(tempTask);
                    }else if(tempTask.Subject.includes(this.label.CSI_Case_reminder_subject)) {
                        this.csiTasks.push(tempTask);
                    }
                });
                this.labelCsi = this.label.itaCsiCases + ' (' + this.csiTasks.length + ')';
                this.labelNbac = this.label.itaNbacTasks + ' (' + this.nbacTasks.length + ')';
            }else {
                this.labelCsi = this.label.itaCsiCases + ' (0)';
                this.labelNbac = this.label.itaNbacTasks + ' (0)';
                this.csiTasks = [];
                this.nbacTasks = [];
            }
            this.error = false;
            this.showSpinner = false;
        }else if (error) {
            this.error = error;
            this.showSpinner = false;
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if(openSections.length === 0) {
            this.activeSection = [];
        }else {
            this.activeSection = [];
            openSections.forEach(item => {
                this.activeSection.push(item);
            })
        }
    }

    viewRecord(event) {
        let recordId = event.currentTarget.value;
        let objectApiName;
        if(recordId.startsWith('006')){
            objectApiName = 'Opportunity';
        }else if(recordId.startsWith('00T')){
            objectApiName = 'Task';
        }else {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName,
                actionName: 'view'
            }
        });
    }
}