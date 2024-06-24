import { api, LightningElement, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { getRecord } from "lightning/uiRecordApi";
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import { publish, MessageContext } from 'lightning/messageService';
import CHANNEL_MENU_EVENT from '@salesforce/messageChannel/ppTrackerMenuEvent__c';
import getOnboardingTasks from '@salesforce/apex/PP_TrackerMenu_CTRL.getOnboardingTasks';
import { getUiSettings } from 'c/ppTrackerUtils'
import Assets from '@salesforce/resourceUrl/PP_Assets';
import getParnerRecordOnwer from '@salesforce/apex/PP_Support_CTRL.getParnerRecordOnwer';

const MENU_STRUCTURE = getUiSettings();

export default class PpTrackerMenu extends LightningElement {

    @api
    heading;
    hasError = false;
    tasks;
    phaseCompletedIcon;
    stepCompletedIcon;
    accordionArrow;
    phaselabel;
    completedTasks = [];
    user = '';
    userImgUrl;
    imgUrl;
    emailIcon;
    phoneIcon;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: userId, fields: [USER_CONTACT_ID] })
    wiredUserRecord({ error, data }) {
        if (error) {
            this.hasError = true;
        }
        else if (data) {
            getOnboardingTasks({ contactId: data.fields.ContactId.value }).then(result => {
                this.tasks = result;
            }).catch(error => {
                this.hasError = true;
            });
            getParnerRecordOnwer({ contactId: data.fields.ContactId.value }).then(result => {
                this.user = result;
                this.userImgUrl = result.FullPhotoUrl;
            });
        }
    }

    get menuItems() {

        let totalSteps = 0;
        let highestStepCount = 0;
        let highestPhase = 0;
        let highestStep = 0;
        let selectMenuItem;
        let phaseTotalCompletedSteps = 0;

        MENU_STRUCTURE.forEach((phase, phaseIndex) => {

            phase.steps.forEach((step, stepIndex) => {

                totalSteps = totalSteps + 1;
                let task = this.tasks[step.key];

                if (task) {
                    if (task.IsClosed) {
                        phaseTotalCompletedSteps++;
                        this.completedTasks.push(task);
                    }
                    step.completed = task.IsClosed;

                    if (task.IsClosed && step.sequence > highestStep) {
                        highestPhase = phaseIndex;
                        highestStep = stepIndex;
                        highestStepCount = totalSteps;
                    }
                }
            });

            if (phaseTotalCompletedSteps == phase.steps.length) {
                phase.completed = true;
                phase.status = 'Completed';
            } 
            phaseTotalCompletedSteps = 0;
        });

        //Is nothing completed, then default first item.
        if (highestPhase == 0 && highestStep == 0) {
            MENU_STRUCTURE[highestPhase].steps[highestStep].default = true;
            selectMenuItem = MENU_STRUCTURE[highestPhase].steps[highestStep].key;
            this.phaselabel = MENU_STRUCTURE[highestPhase].label;
             MENU_STRUCTURE[highestPhase].status = 'In Progress';
        }
        //Does we have a next step in Phase?
        else if (MENU_STRUCTURE[highestPhase].steps[highestStep + 1]) {
            MENU_STRUCTURE[highestPhase].steps[highestStep + 1].default = true;
            selectMenuItem = MENU_STRUCTURE[highestPhase].steps[highestStep + 1].key;
            this.phaselabel = MENU_STRUCTURE[highestPhase].label;
            MENU_STRUCTURE[highestPhase].status = 'In Progress';
        }
        //Do we have another phase?
        else if (MENU_STRUCTURE[highestPhase + 1]) {
            MENU_STRUCTURE[highestPhase + 1].steps[0].default = true;
            selectMenuItem = MENU_STRUCTURE[highestPhase + 1].steps[0].key;
            this.phaselabel = MENU_STRUCTURE[highestPhase + 1].label;
            MENU_STRUCTURE[highestPhase + 1].status = 'In Progress';
        }
        else {
            MENU_STRUCTURE[highestPhase].steps[highestStep].default = false;
            selectMenuItem = MENU_STRUCTURE[highestPhase].steps[highestStep].key;
            this.phaselabel = MENU_STRUCTURE[highestPhase].label;
            MENU_STRUCTURE[highestPhase].status = 'Completed';
        }

        this.publishMenuItemEvent(selectMenuItem);

        return MENU_STRUCTURE;
    }

    handleItemClick(event) {
        this.publishMenuItemEvent(event.target.dataset.menuitem);
    }

    publishMenuItemEvent(menuItem) {
        this.completedTasks.sort(this.dynamicsort('CompletedDateTime','desc'))
        let selectedMenuItem = {
            'name': menuItem,
            'step': this.tasks[menuItem].PP_Step__c,
            'phase': this.tasks[menuItem].PP_Phase__c,
            'description': this.tasks[menuItem].Description,
            'partnerId': this.tasks[menuItem].WhatId,
            'completedTasks': this.completedTasks
        };
        let payload = { item: selectedMenuItem };
        publish(this.messageContext, CHANNEL_MENU_EVENT, payload);
    }


    handleAccordionClick(event) {
        let stageId = event.target.dataset.id;
        if (stageId) {

            let subItems = this.template.querySelectorAll('[data-id=' + event.target.dataset.id + ']')[2];
            let arrow = this.template.querySelectorAll('[data-id=' + event.target.dataset.id + ']')[1];
            if (subItems.className === 'show panel') {
                subItems.className = 'hide panel';
                arrow.className = 'acc-arrow';
            } else {
                subItems.className = 'show panel';
                arrow.className = 'acc-arrow acc-arrow-rotate';
            }
        }
    }

    connectedCallback() {
        this.phaseCompletedIcon = Assets + '/Icons/tracker-phase-complete-icon.png';
        this.stepCompletedIcon = Assets + '/Icons/tracker-step-complete-icon.png';
        this.accordionArrow = Assets + '/Icons/chevron@3x.png';
        this.imgUrl = Assets + '/images' + this.imgUrl;
        this.emailIcon = Assets + '/Icons/em-Icon.png';
        this.phoneIcon = Assets + '/Icons/ph-Icon.png';
    }

    renderedCallback() {
        let subItems = this.template.querySelectorAll('[data-id=' + this.phaselabel + ']')[2];
        let arrow = this.template.querySelectorAll('[data-id=' + this.phaselabel + ']')[1];
        if (subItems) {
            if (subItems.className === 'show panel') {
                subItems.className = 'hide panel';
                arrow.className = 'acc-arrow';
            } else {
                subItems.className = 'show panel';
                arrow.className = 'acc-arrow acc-arrow-rotate';
            }
        }
    }


    dynamicsort(property,order) {
        var sort_order = 1;
        if(order === "desc"){
            sort_order = -1;
        }
        return function (a, b){
            if(a[property] < b[property]){
                    return -1 * sort_order;
            }else if(a[property] > b[property]){
                    return 1 * sort_order;
            }else{
                    return 0 * sort_order;
            }
        }
    }
}