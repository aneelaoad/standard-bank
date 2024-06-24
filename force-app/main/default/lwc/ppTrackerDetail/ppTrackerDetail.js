import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import CHANNEL_MENU_EVENT from '@salesforce/messageChannel/ppTrackerMenuEvent__c';
import getPartnerInitialPartnership from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.getPartnerInitialPartnership'
import getRelatedFiles from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.getRelatedFiles'
import { getUiSettings } from 'c/ppTrackerUtils'
import Assets from '@salesforce/resourceUrl/PP_Assets';
import { NavigationMixin } from 'lightning/navigation'

const UI_SETTINGS = getUiSettings();
  
export default class PpTrackerDetail extends NavigationMixin(LightningElement)  {

    selectedMenuItem = null;
    phase;
    step;
    description;
    icon;
    completedIcon;
    accordionArrow;
    partnershipName;
    @track
    completedTasks = [];
    filesList = [];
    completedStepIcon;
    noRelatedFiles = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.getInitialPartnership(); 
        this.icon = Assets + '/Icons/tracker-detail-msg-icon.png';
        this.completedIcon = Assets + '/Icons/trackerCompleteIcon.png';
        this.completedStepIcon = Assets + '/Icons/completed-step-Icon.png';
        this.accordionArrow = Assets + '/Icons/chevron@3x.png';
    }

    subscribeToMessageChannel() {

        this.subscription = subscribe(
            this.messageContext,
            CHANNEL_MENU_EVENT,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.selectedMenuItem = message.item.name;
        this.phase = message.item.phase;
        this.step = message.item.step;
        this.description = message.item.description;
       // this.completedTasks = message.item.completedTasks;

        let tasks = []
        message.item.completedTasks.forEach(function (tsk) {
          let icon;

          if(tsk.PP_Step__c === 'Submit Application'){
            icon = Assets + '/Icons/submited-icon.png';
          }else if(tsk.PP_Step__c === 'Verification by Standard Bank'){
            icon = Assets + '/Icons/completed-step-Icon.png';
          }else if(tsk.PP_Step__c === 'NDA Signed'){
            icon = Assets + '/Icons/contracting-icon.png';
          }else if(tsk.PP_Step__c === 'Business Engagement'){
            icon = Assets + '/Icons/business-engagement-icon.png';
          }else if(tsk.PP_Step__c === 'Risk Review'){
            icon = Assets + '/Icons/completed-step-Icon.png';
          }else if(tsk.PP_Step__c === 'Follow Up Risk Questions'){
            icon = Assets + '/Icons/followup-icon.png';
          }else if(tsk.PP_Step__c === 'Commercials and Contracting'){
            icon = Assets + '/Icons/contracting-icon.png';
          }else if(tsk.PP_Step__c === 'Launch'){
            icon = Assets + '/Icons/launch-icon.png';
          }

          let task = {
            "PP_Step__c": tsk.PP_Step__c,
            "CompletedDateTime": tsk.CompletedDateTime,
            "Icon": icon,
          }
          tasks.push(task);
        });
        this.completedTasks = tasks;

        let partnerId = message.item.partnerId;
        getRelatedFiles({ recordId : partnerId }).then( data => {
            if (data) {
                this.filesList = Object.keys(data).map(item => ({
                    "label": data[item],
                    "value": item,
                    "url": `/sfc/servlet.shepherd/document/download/${item}`
                }));

                if(this.filesList.length == 0){
                 this.noRelatedFiles = true;
                }
            }
        });
    } 
    
    getInitialPartnership() {
        getPartnerInitialPartnership().then(response => {
            this.partnershipName = response.PP_PartnershipOpportunity__r.Name;
        });
    }

    handleAccordionClick(event) {
      let id = event.target.dataset.id;
      if (id) {

          let element = this.template.querySelectorAll('[data-id=' + event.target.dataset.id + ']')[1];
          let arrow = this.template.querySelectorAll('[data-id=' + event.target.dataset.id + ']')[0];
          if (element.className === 'show') {
              element.className = 'hide';
              arrow.className = 'acc-arrow';
          } else {
              element.className = 'show';
              arrow.className = 'acc-arrow acc-arrow-rotate';
          }
      }
  }
    
    get showSubmitApplication() {
        return this.selectedMenuItem == 'registration-submit-application';
    }

    get showNDASigned() {
        return this.selectedMenuItem == 'discovery-nda-signed';
    }

    get showBusinessEngagement() {
        return this.selectedMenuItem == 'discovery-business-engagement';
    }

    get showRiskReview() {
        return this.selectedMenuItem == 'discovery-risk-review';
    }

    get showFollowUpRiskQuestions() {
        return this.selectedMenuItem == 'onboarding-follow-up-risk-questions';
    }

    get showCommercialsAndContracting() {
        return this.selectedMenuItem == 'onboarding-commercials-and-contracting';
    }

    get showCompleted() {
        let showCompleted = false;
        if(this.selectedMenuItem == 'onboarding-launch'){
            showCompleted = true;
        }
        return showCompleted;
    }
}