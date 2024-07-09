/***************************************************************************************
* @Name of the Component :zaf_comp_clientLetter
* @description           :SFP-36983 Component to sent the Emails based on the appropriate letter  
* @Author                :Likhitha Karusala  
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By  : Likhitha Karusala 
*@Last Modified On  : 08 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
import { LightningElement, track, api, wire } from 'lwc';
import sendEmailToControllers from '@salesforce/apex/ZAF_CTRL_StandardPricingLetter.sendEmailToController';
import sendFullStandardCustomEmail from '@salesforce/apex/ZAF_CTRL_StandardPricingLetter.sendFullStandardCustomEmail';
import sendSpecificStandardCustomEmail from '@salesforce/apex/ZAF_CTRL_StandardPricingLetter.sendSpecificStandardCustomEmail';
import getClientLetterJSON from '@salesforce/apex/ZAF_CTRL_FullStandardPricingLetter.getClientLetterJSON';
import sendCustomEmail from '@salesforce/apex/ZAF_CTRL_StandardPricingLetter.sendCustomEmail';
import getThePricingArrangement from '@salesforce/apex/ZAF_CTRL_StandardPricingLetter.getThePricingArrangement';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class Zaf_comp_clientLetter extends LightningElement {

  @api recordId;
  value = '';
  screenNumber = 0;
  formData = {};
  checkedValue;
  clientName;
  roles = [];
  message = "The Client doesn't have an active Pricing Arrangements associated to proceed. Please create a 'Pricing Arrangement'.";
  checkedEmail = [];
  isLoading = false;
  header = "Send Client Pricing Letter";
  showModal = false;
  dynamicCss = 'slds-align_absolute-center concessionerror';
  showconcessionerror = false;
  @track ListOfContacts = [];
  @track NoEmailmsg = false;
  @track NoEmail;
  @track Concessionerror;
  @track showTable =true;
  @track ispreview=false;
  options = [
    {
      label: 'Client Specific Letter - Standard Pricing',
      value: 'Standard',
      index: 0,

    },
    {
      label: 'Client Specific Letter - Standard and Concessioned Pricing',
      value: 'Concession',
      index: 0,

    },
    {
      label: 'Full Standard Price Letter',
      value: 'FullStandard',
      index: 0,

    },
    
    {
      label: 'Ad-hoc',
      value: 'Monthly Environmental Letter',
      index: 1,

    },
    {
      label: 'Annual',
      value: 'Corporate Annual Pricing Letter',
      index: 1,

    },
    { label: 'Bank', value: 'Bank', index: 2 },
    {
      label: 'Corporate',
      value: 'Corporate',
      index: 2,
    }
  ]
  filteredOptions;
  isdisable = true;
  isConsession;
  isClientSetText;



  /**
	 * @description wire to get the Pricing Arrangement
	*/
  @wire(getThePricingArrangement, { recordId: "$recordId" })
  wiredData({ error, data }) {
    if (data) {
      this.isConsession = data;
    } else if (error) {
    }
  }
  ClientLetterData = {};
    /**
      *@description Method i used to get the custom meta data
      */
    handleClientLetterData() {
      getClientLetterJSON({ developerName: 'Client_sector' })
        .then(result => {
          this.ClientLetterData = JSON.parse(result.Description__c);
        })
        .catch(error => {
        this.logger.error('An error occured in handleClientLetterData :', error);

        });
    }
    /**
     * @description handles to render metadata and options
     */
  connectedCallback() {
    this.filteredOptions = this.options.filter(option => option.index === this.screenNumber);
    this.handleClientLetterData();
  }
/**
     * @description handles to check option monthly environment letter
     */
   handleRadio(event) {
    this.checkedValue = event.detail.value;
    if (this.checkedValue == 'Monthly Environmental Letter') {
      delete this.formData[3];
    }

    this.formData[this.screenNumber] = event.detail.value;
  }
/**
     * @description handles screens for showing next and calling apex for sending Emails
     */
  handleClickNext() { 
    if (this.screenNumber != 3) {
      if (this.checkedValue == 'Concession') {
        if (this.isConsession) {
          this.nextMethod();
        } else {
          this.showModal = true;
        }
      } else {
        this.nextMethod();

      }

    } else {
    if(this.checkedEmail.length>0 )
    {
      this.showTable =false;
      this.isLoading=true;
      if (this.formData[0] == 'Standard') {
        sendSpecificStandardCustomEmail({ recordId: this.recordId, customEmail: this.checkedEmail, adhoc: this.formData[1], bank: this.formData[2] })
          .then((result) => {
            this.showModal = true;
            if (result == "success") {
              this.dynamicCss = 'slds-align_absolute-center ';
              this.message = "Email sent Successfully";
            } else {
              this.message = "Email sent Was UnSuccessful";
            }
          this.isLoading=false;
          })
          .catch((error) => {
            this.showModal = true;
             this.isLoading=false;
                     this.logger.error('An error occured in sendSpecificStandardCustomEmail :', error);

          });
      } else if (this.formData[0] == 'FullStandard') {
        sendFullStandardCustomEmail({ recordId: this.recordId, customEmail: this.checkedEmail, adhoc: this.formData[1], bank: this.formData[2] })
          .then((result) => {
            this.showModal = true;
            if (result == "success") {
              this.dynamicCss = 'slds-align_absolute-center';
              this.message = "Email sent Successfully";
             

            } else {
              this.message = "Email sent Was UnSuccessful";
            }
             this.isLoading=false;
          })
          .catch((error) => {
            this.showModal = true;
             this.isLoading=false;
            this.logger.error('An error occured in sendFullStandardCustomEmail :', error);

          });
      } else if (this.formData[0] == 'Concession') {
        sendCustomEmail({ recordId: this.recordId, customEmail: this.checkedEmail, adhoc: this.formData[1], bank: this.formData[2] })
          .then((result) => {
            this.showModal = true;
            if (result == "success") {
              this.dynamicCss = 'slds-align_absolute-center';
              this.message = "Email sent Successfully";
            } else {
              this.message = "Email sent Was UnSuccessful";
            }
             this.isLoading=false;
          })
          .catch((error) => {
            this.showModal = true;
 this.isLoading=false;
             this.logger.error('An error occured in sendCustomEmail :', error);

          });
      }
     }
    }
  }
  /**
     * @description handles getListOfContacts from apex
     */
  get getListOfContacts() {
    return (this.ListOfContacts.length > 0)
  }
/**
     * @description handles to go previous screen options
     */
  handleClickBack(event) {
    debugger
    if (this.screenNumber === 3) {
      this.ListOfContacts = [];
    }
    this.screenNumber--;
    this.filteredOptions = this.options.filter(option => option.index === this.screenNumber);
    if (this.filteredOptions.some(item => item.value === this.formData[this.screenNumber])) {
      this.value = this.formData[this.screenNumber]
    } else {
      this.screenNumber--;
      this.filteredOptions = this.options.filter(option => option.index === this.screenNumber);
      this.value = this.formData[this.screenNumber]
    }
    if (this.screenNumber == 0) {
      this.isdisable = true;
    }
    if (this.screenNumber == 2) {
      this.isClientSetText = 'Client Sector';
    } else {
      this.isClientSetText = '';
    }
    if(this.screenNumber === 3){
      this.ispreview = true;
    }else{
      this.ispreview = false;
    }
  }

/**
     * @description handles toget all contacts related to accounts
     */
  getTheContacts() {
    this.isLoading = true;
    sendEmailToControllers({ recordId: this.recordId })
      .then((result) => {

        if (result.length > 0) {
          let res = JSON.parse(JSON.stringify(result));
          res.map(f => { f.index = 3 })
          this.options = [...this.options, ...res];
          this.filteredOptions = res.map(obj => ({ ...obj, index: 3 }));
          this.ListOfContacts = res;
          let e = JSON.stringify(res);
          this.clientName = res[0].Account.Name;
          for (let i = 0; i < res.length; i++) {
            const contactRoles = res[i].Contact_Role_s_at_Client__c;
            this.roles = contactRoles.split(';').map(role => role.trim());
            this.ListOfContacts[i].roles=this.roles;
          }

        } else {
          this.showModal=true;
          this.NoEmailmsg = true;
          this.NoEmail = this.ClientLetterData.EmailEmptyMsg;
        }
        this.isLoading = false;
      }).catch(error => {
        this.logger.error('An error occurred in sendEmailMethod:', error);
        this.isLoading = false;
      })
  }
/**
	 * @description handles to collect data in array of checked boxes and to enable/disable button
	*/
  changeHandler(event) {

    if (event.target.checked) {
      this.checkedEmail.push(event.currentTarget.dataset.text);
    }
    else {
      this.checkedEmail = this.checkedEmail.filter(item => item !== event.currentTarget.dataset.text);
    }
  }
 /**
	 * @description handles to close the model Popup
	*/
  closeModal() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
/**
     * @description handles to go to next screen
     */
  nextMethod() {
  if(this.formData[this.screenNumber]){
  this.screenNumber++;
    if (this.screenNumber > 0) {
      this.isdisable = false;
    }
    if (this.screenNumber != 3) {
      if (this.screenNumber === 2 && this.checkedValue === 'Monthly Environmental Letter') {
        this.screenNumber++;
        this.getTheContacts();
      }
      this.filteredOptions = this.options.filter(option => option.index === this.screenNumber);
      if (this.filteredOptions.some(item => item.value === this.formData[this.screenNumber])) {
        this.value = this.formData[this.screenNumber]
      }
    } else {
      this.getTheContacts();
    }
    if(this.screenNumber === 3){
      this.ispreview = true;
    }else{
      this.ispreview = false;
    }
    if (this.screenNumber == 2) {
      this.isClientSetText = 'Client Sector';
    }else {
      this.isClientSetText = undefined;
    }
  }
   }
/**
     * @description handles to preview PDF on other tab
     */
   handleGeneratePDF(){
    if(this.screenNumber===3)
    {

      if (this.formData[0] == 'Standard') {
        window.open('/apex/ZAF_FullStandardPricingLetterVFPage?id=' + this.recordId);
      }else if (this.formData[0] == 'FullStandard') {
        window.open('/apex/ZAF_FullStandardPricingLetterVFPage');
      } else if (this.formData[0] == 'Concession') {
        window.open('/apex/ZAF_ClientPricingLetterVFPage?id=' + this.recordId);
      }
    }
    }
  
}