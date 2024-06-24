import { api, LightningElement, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { getRecord } from "lightning/uiRecordApi";
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import getOnboardingTasks from '@salesforce/apex/PP_TrackerMenu_CTRL.getOnboardingTasks';
import getPartnerInitialPartnership from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.getPartnerInitialPartnership';
import { getUiSettings } from 'c/ppTrackerUtils';
import { NavigationMixin } from 'lightning/navigation';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

const MENU_STRUCTURE = getUiSettings();

export default class PpDashboardTracker extends NavigationMixin(LightningElement) {

    @api
    heading;
    @api
    linkText;
    @api
    linkUrl;
    hasError = false;
    tasks;
    currentStep = '';
    partnershipName;
    img;
    icon;

    @wire(getRecord, { recordId: userId, fields: [USER_CONTACT_ID] })
    wiredUserRecord({ error, data }) {
        if (error) {
            this.hasError = true;
        }
        else if (data) {
            getOnboardingTasks({ contactId: data.fields.ContactId.value }).then(result => {
                this.tasks = result;
                this.getCurrentStep();
            })
                .catch(error => {
                    this.hasError = true;
                });
        }
    }

    getCurrentStep() {

        let totalSteps = 0;
        let highestStepCount = 0;
        let highestPhase = 0;
        let highestStep = 0;
        let selectMenuItem;

        MENU_STRUCTURE.forEach((phase, phaseIndex) => {

            phase.steps.forEach((step, stepIndex) => {

                totalSteps = totalSteps + 1;
                let task = this.tasks[step.key];

                if (task) {

                    step.completed = task.IsClosed;

                    if (task.IsClosed && step.sequence > highestStep) {
                        highestPhase = phaseIndex;
                        highestStep = stepIndex;
                        highestStepCount = totalSteps;
                    }
                }
            });

        });

        //Is nothing completed, then default first item.
        if (highestPhase == 0 && highestStep == 0) {
            MENU_STRUCTURE[highestPhase].steps[highestStep].default = true;
            selectMenuItem = MENU_STRUCTURE[highestPhase].steps[highestStep].key;
        }
        //Does we have a next step in Phase?
        else if (MENU_STRUCTURE[highestPhase].steps[highestStep + 1]) {
            MENU_STRUCTURE[highestPhase].steps[highestStep + 1].default = true;
            selectMenuItem = MENU_STRUCTURE[highestPhase].steps[highestStep + 1].key;
        }
        //Do we have another phase?
        else if (MENU_STRUCTURE[highestPhase + 1]) {
            MENU_STRUCTURE[highestPhase + 1].steps[0].default = true;
            selectMenuItem = MENU_STRUCTURE[highestPhase + 1].steps[0].key;
        }
        else {
            MENU_STRUCTURE[highestPhase].steps[highestStep].default = true;
            selectMenuItem = MENU_STRUCTURE[highestPhase].steps[highestStep].key;
        }         
        this.currentStep = this.tasks[selectMenuItem];
    }

    connectedCallback() {
        this.img = Assets + '/images/dashboardTrackerImg.png';
        this.icon = Assets + '/Icons/tracker-detail-msg-icon.png';
        let path = basePath.split('/s')[0];
        if (path === '') {
            this.linkUrl = '/s' + this.linkUrl;
        } else {
            this.linkUrl = path + '/s' + this.linkUrl;
        }
        this.getInitialPartnership();
    }

    getInitialPartnership() {
        getPartnerInitialPartnership().then(response => {
            this.partnershipName = response.PP_PartnershipOpportunity__r.Name;
        });
    }

    tracker(event) {
        trackLink(event);
    }

}