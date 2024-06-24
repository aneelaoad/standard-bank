import { LightningElement, track, api, wire } from 'lwc';
import getMeetings from '@salesforce/apex/EAP_CTRL_SendEmailMeetings.getMeetings';
import getEmailBody from '@salesforce/apex/EAP_CTRL_ManageEmailBody.getEmailBody';
import updateEmailBodyAndSendEmail from '@salesforce/apex/EAP_CTRL_ManageEmailBody.updateEmailBodyAndSendEmail';

export default class EapSendMeetingsEvents extends LightningElement {
  @track hasLoaded = false;
  @track hasSent = false;
  @track hasClicked = false;
  @track isError = false;
  meetingList;
  @api recordId;
  body = "";
  cc = [];
  bcc = [];

  @wire(getEmailBody, {eventId: '$recordId'})
  getBody({ error, data }) {
      if (data) {
          this.body = data;
          this.hasLoaded = true;
          this.error = undefined;
      } else if (error) {
          this.error = error;
          this.body = undefined;
      }
  }

  @wire(getMeetings, {eventId: '$recordId'})
  getMeetingList({ error, data }) {
      if (data) {
          this.meetingList = data;
          this.hasLoaded = true;
          this.error = undefined;
      } else if (error) {
          this.error = error;
          this.meetingList = undefined;
      }
  }

  handleInputChange(e){
    let field = e.target.name;
    let value = e.target.value;
    
    if (field === "emailCC") {
        this.cc = value;

    } else {
        this.bcc = value;
    }
  }

  async sendEmailButton() {
    this.hasClicked = true;
    this.body = this.template.querySelector('lightning-textarea').value;
    this.body.replace('\n\r', '<br />');
    if (this.cc.length > 0) {
      this.cc = this.cc.split(",");
    }

    if (this.bcc.length > 0) {
      this.bcc = this.bcc.split(",");
    }

    try {
      await updateEmailBodyAndSendEmail({eventId: this.recordId, body: this.body, meetingList: this.meetingList, ccEmail: this.cc, bccEmail: this.bcc});
      this.hasClicked = false;
      this.hasSent = true;
    } catch (err) {
      this.isError = true;
    }
  }
  
  get hasntClickedAndSent() {
    if (!this.hasClicked && !this.hasSent) {
      return true;
    
    } else {
       return false;
    }
  }
}