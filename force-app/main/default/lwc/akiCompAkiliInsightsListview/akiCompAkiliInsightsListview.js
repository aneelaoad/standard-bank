import { LightningElement, wire, api, track} from 'lwc';
import dashboardUrl from '@salesforce/label/c.aki_TrackMyOpportunities';
import { refreshApex } from '@salesforce/apex';
import changeProdSpecialist from '@salesforce/apex/AKI_COMP_AkiliInsightsListviewController.changeProdSpecialist';
import snoozeInsightRec from '@salesforce/apex/AKI_COMP_AkiliInsightsListviewController.snoozedInsights';
import getInsightsData from '@salesforce/apex/AKI_COMP_AkiliInsightsListviewController.getInsightsData';
import { NavigationMixin ,CurrentPageReference} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import getInsightDetails from '@salesforce/apex/AKI_COMP_AkiliInsightsListviewController.getInsightDetails';//Added by Chandrasekhar
import getFeedbackOptions from '@salesforce/apex/AKI_COMP_AkiliInsightsListviewController.getFeedbackOptions';//Added by Chandrasekhar

//insight feedback
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import INSIGHTACTION_OBJECT from '@salesforce/schema/Insight_Action__c';
import INSIGHTQUALITY_FIELD from '@salesforce/schema/Insight_Action__c.Insight_Quality__c';
import INSIGHTSTATUS_FIELD from '@salesforce/schema/Insight_Action__c.Insight_Status__c';
import feedbackInsights from '@salesforce/apex/AKI_COMP_AkiliInsightsListviewController.feedbackInsights';

//update Insight record
import INSIGHTS_ID from '@salesforce/schema/Insight__c.Id';
import INSIGHTS_Revenue from '@salesforce/schema/Insight__c.Potential_Insight_Revenue__c';
import INSIGHTS_Comment from '@salesforce/schema/Insight__c.Comment__c';

//CreateOpportunity
import createOpportunity from '@salesforce/apex/AKI_COMP_AkiliInsightsListviewController.createOpportunity';

const columns=[
   
    {
      label: 'Date Created',
      fieldName: 'Lead_Date__c'
  },
  {
      label: 'Expiry Date',
      fieldName: 'Expiry_Date__c',
      cellAttributes:{
        class:{fieldName:'expiryDateColor'},
        style:{fieldName:'expiryDateColorStyle'}
    }
  },
  {
      label: 'Category',
      fieldName: 'Category__c'
  },
  {
      label: 'Sub Category',
      fieldName: 'Sub_Category__c'
  },
  {
      label: 'Client Name',
      fieldName: 'ClientName'
  },
  {
      label: 'SmartNudge summary',
      type: "button",        
      typeAttributes: { label: { fieldName: "insightSubString" }, name: "InsightNameModalOpen", wrapText: true, variant: "base" }    
  },
  {
      label: 'Accepted/Rejected',
      fieldName: 'status',
      cellAttributes:{
        class:{fieldName:'statusColor'},
        style:{fieldName:'statusColorStyle'}
    }
  },
  {
        
        type: 'button-icon',
        initialWidth: 50,
        typeAttributes: {
            name: "addOpportunity",
            iconName: 'action:new',
            title: 'Add Opportunity',            
            size: 'large',
            variant: 'brand',
            alternativeText: 'Add Opportunity',
            iconClass: 'add-opportunity-css' 
                               
        }
    },
    {
        type: 'button-icon',
        initialWidth: 50,
        typeAttributes: {
            name: "snoozeInsight",
            iconName: { fieldName: "snoozeIcon" },
            title: { fieldName: "snoozeTitle" },
            variant: 'brand',
            size: 'large',
            alternativeText: { fieldName: "snoozeTitle" }
        }
    },
    {
        type: 'button-icon',
        initialWidth: 50,
        typeAttributes: {
            name: "accept",
            iconName: 'utility:like',
            title: 'Accept',
            variant: 'brand',
            size: 'large',
            alternativeText: 'Accept',
            disabled:{ fieldName: "isDisable" }
        }
    },
    {
        type: 'button-icon',
        initialWidth: 50,
        typeAttributes: {
            name: "reject",
            iconName: 'utility:dislike',
            title: 'Reject',
            variant: 'brand',
            size: 'large',
            alternativeText: 'Reject',
            disabled:{ fieldName: "isDisable" }
        }
    }
];

export default class akiCompAkiliInsightsListview extends NavigationMixin(LightningElement) {
   
    @track value;
    @track error;
    @track data;
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
    @api searchKey = '';
    @track tableContent;
    @track modalContainer = false;
    @track selectedRow={};
    result;
    wiredActivities;
    
    //variables for paginations
    @track page = 1; 
    @track currentPage = 1;
    @track items = []; 
    @track data = []; 
    @track columns = columns; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 10; 
    @track totalRecountCount = 0;
    @track totalPage = 0;

    //variable for insight record update
    @track recPotentialRev ='';
    @track recComments = '';
    inputLabel;
    inputValue;

    // variable for change owner
    @track changeOwnerModalFlag = false;
    @track sendEmailOwnerChange = false;


    //variables for stateful filter buttons 
    @track myInsightsSelected=true;
    @track myInsightsVarient = 'brand';
    @track allInsightsSelected=false;
    @track allInsightsVarient = 'neutral';
    @track expiringSoonSelected=false;
    @track expiringSoonVarient = 'neutral';
    @track snoozedInsightsSelected=false;
    @track snoozedInsightsVarient = 'neutral';


    //variable for lookup    
    @track looupRecordName;  
    @track lookupRecordId; 
    @track changeOwnerBottonFlag = true;


    //CreateOpportunity
    @track createOppFlag;
    @track createOppName;
    @track createOppDesc;
    @track createOppProb;
    @track  createOppStartDate;
    @track createOppCloseDate;
    @track createOppClientName;  
    @track createOppClientId;
    @track createOppButtonFlag=true;
    @track createOppMnpi = false;
    @track createOppProbability = 10;

    //variable for Snooze Insight
    @track snoozeModalFlag;
    snoozedIconName = 'utility:preview';
    snoozedButtonLabel = 'Snooze';

    //variable for send feedback
    @track sendFeedbackFlag = false;
    @track insightQualityVal = '';
    @track insightStatusVal = '';
    @track submitSendFeedbackFlag = true;
    insightlinkid = '';
    loactionURL;
    

    //Filter varibles
    @track categoryList = [];
    @track subCategoryList = [];
    @track clientNameList = [];
    @track selectedCategory = '';
    @track selectedSubCategory = '';
    @track selectedClient = '';

    @track acceptFlag = false;
    @track rejectFlag = false;
    @track reasonForAcceptComments = '';
    @track reasonForRejectComments = '';
    @track acceptReasonRelevant = false;
    @track acceptReasonOther = false;
    @track acceptReasonInsightful = false;
    @track selectedAcceptValues = [];
    @track selectedRejectValues = [];
    @track feedbackOptions = [];
    @track selectedAcceptOption = '';
    @track selectedRejectOption = '';
    @track isDisableAcceptRejectButtos = false;
    @track isDisableSaveUnsaveAddOppButtos = false;
    @track isOpportunityFormOpenedFromAccept = false;

    pageReference;//Added by Chandrasekhar
    isTabChanged = true;//Added by Chandrasekhar

    commentCharsCount = 0; //Added by Chandrasekhar
    countClass= 'slds-text-color_success';//Added by Chandrasekhar
    isRequiredComments = false;

    @track getInsightParam = '{"searchKey": " ",    "myInsightsSelected": '+this.myInsightsSelected+',    "client": " ",    "subcategory": " ",    "category": " ",    "allInsightsSelected": '+this.allInsightsSelected+',    "expiringSoonSelected": '+this.expiringSoonSelected+',    "snoozedInsightsSelected": '+this.snoozedInsightsSelected+'}';
    @track today = new Date();;
    //Added by Chandrasekhar
    constructor() {
        super();
        this.loactionURL = window.location.href;
        const urlParams = new URL(this.loactionURL).searchParams;
        const currentTab = urlParams.get('c__currentTab');
        if(currentTab && currentTab == 'MyInsights'){
            this.isTabChanged = false;
            this.myInsightsSelected =  true;
            this.onMyInsightsClick();
        }
        else if(currentTab && currentTab == 'All'){
            this.isTabChanged = false;
            this.allInsightsSelected =  true;
            this.onAllInsightsClick();
        }
        else if(currentTab && currentTab == 'ExpiringSoon'){
            this.isTabChanged = false;
            this.expiringSoonSelected =  true;
            this.onExpiringSoonClick();
        }
        else if(currentTab && currentTab == 'Saved'){
            this.isTabChanged = false;
            this.snoozedInsightsSelected =  true;
            this.onSnoozedInsightsClick();
        }
        let dd    = this.today.getDate();
        let mm    = this.today.getMonth()+1; //January is 0!
        let yyyy  = this.today.getFullYear(); 

        if(dd<10){dd='0'+dd};
        if(mm<10){mm='0'+mm};
       // 2021-07-14
        this.today = yyyy+'-'+mm+'-'+dd;
        this.getInsightParam = '{"searchKey": " ",    "myInsightsSelected": '+this.myInsightsSelected+',    "client":  "'+this.selectedClient +'",    "subcategory":  "'+this.selectedSubCategory +'",    "category":  "'+this.selectedCategory+'",    "allInsightsSelected": '+this.allInsightsSelected+',    "expiringSoonSelected": '+this.expiringSoonSelected+',    "snoozedInsightsSelected": '+this.snoozedInsightsSelected+'}';

    }

    @wire(getInsightsData, { getInsightParamVal:  '$getInsightParam'})
    wiredInsights({ error, data }) {
        if (data) {    
            this.data = data;   
            this.addColumnToReturnTable();
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }

    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        this.loactionURL = window.location.href;
        this.pageReference = pageRef;
        if(pageRef.state.c__id != undefined){
            this.insightlinkid = pageRef.state.c__id;
            this.getInsightRecord(pageRef.state.c__id);
            
        }
    }
    getInsightRecord(insightId){
        getInsightDetails({insightId : insightId}).then(result => {
            this.selectedRow = {
                ...result
            }; 
            if (this.selectedRow.Client__r) { /** will return true if exist */
                this.selectedRow.ClientName = this.selectedRow.Client__r.Name;
                this.selectedRow.createOppStyle = 'padding-bottom: 4px;';
            } else {
                this.selectedRow.Client__r = '{"Name":"","Client_Sector__c":"","Id":"","Description":""}';
                this.selectedRow.createOppStyle = 'padding-bottom: 28px;';
            }
            if (this.selectedRow.Owner) { /** will return true if exist */
                this.selectedRow.ProductSpecialist = this.selectedRow.Owner.Name;
            }
            if (this.selectedRow.Client_Coordinator__r) { /** will return true if exist */
                this.selectedRow.ClientCoordinator = this.selectedRow.Client_Coordinator__r.Name;
            } else {
                this.selectedRow.Client_Coordinator__r = '{"Name":""}';
            }

            if (this.selectedRow.Potential_Insight_Revenue__c) {
            } else {
                this.selectedRow.Potential_Insight_Revenue__c = '';
            }
            if (this.selectedRow.Comment__c) {
            } else {
                this.selectedRow.Comment__c = '';
            }
            if(this.selectedRow.Status__c){
                if(this.selectedRow.Status__c == 'Accepted'){
                    this.isDisableAcceptRejectButtos = true;
                }
            }
            if(this.selectedRow.Expiry_Date__c < this.today) {
                this.isDisableAcceptRejectButtos = true;
                this.isDisableSaveUnsaveAddOppButtos = true;
            } else {
                if(this.selectedRow.Status__c != 'Accepted'){
                    this.isDisableAcceptRejectButtos = false;
                }
                this.isDisableSaveUnsaveAddOppButtos = false;
            }
            this.modalContainer = true;
            this.setSnoozeLable();
        })
        .catch(error => {
        });
    } 

    get isDisableUpdateButton(){
        if(this.recComments){
            return false;
        }
        return true;
    } 

    get submitAcceptFlag(){
        if(this.acceptReasonInsightful == true || this.acceptReasonOther == true || this.acceptReasonRelevant == true){
            return false;
        }
        return true;
    }

    get submitRejectFlag(){
        if(this.insightQualityVal || (this.feedbackOptions.length == 0 && this.reasonForRejectComments)){
            if(!this.insightQualityVal.includes('Other') || (this.insightQualityVal.includes('Other') && this.reasonForRejectComments)){
                return false;
            }                       
        }
        return true;
    }

    invokeRefreshApex(){
        this.isTabChanged = true;
        this.getInsightParam = '{"searchKey": "'+this.searchKey+'",    "myInsightsSelected": '+this.myInsightsSelected+',    "client":  "'+this.selectedClient +'",    "subcategory":  "'+this.selectedSubCategory +'",    "category":  "'+this.selectedCategory+'",    "allInsightsSelected": '+this.allInsightsSelected+',    "expiringSoonSelected": '+this.expiringSoonSelected+',    "snoozedInsightsSelected": '+this.snoozedInsightsSelected+'}';
        return refreshApex(this.data);
    }
    addColumnToReturnTable(){
        this.data = JSON.parse(JSON.stringify(this.data));
        let categoryOptions = [{label:'All',value:''}];
        let categories = [];
        let clientOptions = [{label:'All',value:''}];
        let clientNames = [];
        let subCategoryOptions = [{label:'All',value:''}];
        let subCategories = [];
        
        //Add Custom column to table to display related obkect details
        this.data.forEach(function(e){
                if (typeof e === "object" ){
                    if("Client__r" in e){ /** will return true if exist */
                        e.ClientName = e.Client__r.Name;
                        e.createOppStyle = 'padding-bottom: 4px;';
                    }else{
                        e.Client__r = '{"Name":"","Client_Sector__c":"","Id":"","Description":""}'; 
                        e.createOppStyle = 'padding-bottom: 28px;';                       
                    }
                    if("Owner" in e){ /** will return true if exist */
                        e.ProductSpecialist = e.Owner.Name;
                    }
                    if("Client_Coordinator__r" in e){ /** will return true if exist */
                        e.ClientCoordinator = e.Client_Coordinator__r.Name;
                    }else{
                        e.Client_Coordinator__r = '{"Name":""}';
                    }
                    if("Insight__c" in e){ //added to trim insight text so button will be short
                        if(e.Insight__c.length > 35){
                            e.insightSubString = e.Insight__c.slice(0, 33)+'...';
                        }else{
                            e.insightSubString = e.Insight__c;
                        }
                    }
                    if("Potential_Insight_Revenue__c" in e){
                        
                    }else{
                        e.Potential_Insight_Revenue__c = '';
                    }
                    if("Comment__c" in e){
                        
                    }else{
                        e.Comment__c = '';
                    }
                    
                    var today           =  new Date();
                    var betweenTwo      = new Date();
                    var betweenThree    =  new Date();
                    var betweenSeven    = new Date();
                    var dd    = today.getDate();
                    var mm    = today.getMonth()+1; //January is 0!
                    var yyyy  = today.getFullYear();

                    if(dd<10){dd='0'+dd};
                    if(mm<10){mm='0'+mm};
                   // 2021-07-14
                    today = yyyy+'-'+mm+'-'+dd;
                    betweenTwo =  yyyy+'-'+mm+'-'+(dd+2);

                    //between 5 to 7
                    betweenThree = yyyy+'-'+mm+'-'+(dd+3);
                    betweenSeven = yyyy+'-'+mm+'-'+(dd+7);
                    if( e.Expiry_Date__c >= today && e.Expiry_Date__c <= betweenTwo){
                        e.expiryDateColor = "slds-text-color_error";  
                    }else if(e.Expiry_Date__c >= betweenThree && e.Expiry_Date__c <= betweenSeven){
                        e.expiryDateColorStyle = "color:orange;"; 
                        e.expiryDateColor = "td-orangeColor";  
                    }  

                    //Filters logic
                    if("Client__r" in e){
                        if(!clientNames.includes(e.Client__r.Name)){
                            clientOptions.push({label:e.Client__r.Name,value:e.Client__c});
                            clientNames.push(e.Client__r.Name);
                        }
                    }
                    if("Category__c" in e){
                        if(!categories.includes(e.Category__c)){
                            categoryOptions.push({label:e.Category__c,value:e.Category__c});
                            categories.push(e.Category__c);
                        }
                        
                    }
                     if("Sub_Category__c" in e){
                        if(!subCategories.includes(e.Sub_Category__c)){
                            subCategoryOptions.push({label:e.Sub_Category__c,value:e.Sub_Category__c});
                            subCategories.push(e.Sub_Category__c);
                        }
                    }

                    if("Is_Snoozed__c"in e){
                        if(e.Is_Snoozed__c){
                            e.snoozeIcon = 'utility:delete';
                            e.snoozeTitle = 'Remove from saved list';
                        }
                        else{
                            e.snoozeIcon = 'utility:bookmark';
                            e.snoozeTitle = 'Save nudge';
                        }
                    }

                    
                    
                    if("Status__c" in e){
                        e.status = e.Status__c;
                        if(e.Status__c == 'Accepted'){
                            e.statusColor = "slds-text-color_success";
                            e.statusColorStyle = "color:green;"; 
                        }
                        else{
                            e.statusColor = "slds-text-color_error";
                            e.statusColorStyle = "color:red;";
                        }
                    }
                    else if( "Insight_Actions__r" in e){
                        e.Insight_Actions__r.forEach(function(insAction){
                            if("Insight_Status__c" in e){
                                e.status = (e.Insight_Status__c == 'Insight actioned') ? 'Accepted': '';                                
                            }
                            else{
                                e.status = '';
                            }
                        });
                    }
                    else{
                       e.status = ''; 
                    }  

                    if(e.status == 'Accepted' ){
                        e.statusColor = "slds-text-color_success";
                        e.statusColorStyle = "color:green;";
                        e.isDisable = true;
                    }
                    else{
                        e.statusColor = "slds-text-color_error";
                        e.statusColorStyle = "color:red;";
                        e.isDisable = false;
                    }
                }
          });          
          
          this.categoryList = categoryOptions;
          this.clientNameList = clientOptions;
          this.subCategoryList = subCategoryOptions;
          this.assignTableContentData(this.data);
    }

    assignTableContentData(detailtableContent){

        this.items = detailtableContent;
        this.totalRecountCount = detailtableContent.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.page = 1;         
        if(this.isTabChanged == false && this.pageReference.state.c__currentPage != undefined && this.pageReference.state.c__currentPage > 1 
            && this.totalPage >= this.pageReference.state.c__currentPage ){
            this.page = this.pageReference.state.c__currentPage; 
            this.displayRecordPerPage(this.page);
        }
        else if(this.isTabChanged == false && this.pageReference.state.c__currentPage != undefined && this.pageReference.state.c__currentPage > 1 
            && this.totalPage < this.pageReference.state.c__currentPage ){
            this.page = this.pageReference.state.c__currentPage - 1; 
            this.displayRecordPerPage(this.page);
        }
        else{
            this.tableContent = this.items.slice(0,this.pageSize); 
        }
        this.endingRecord = this.pageSize;
    }

    //clicking on previous button this method will be called
    previousHandler() {
        this.isTabChanged = false;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        this.isTabChanged = false;        
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = parseInt(this.page) + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.tableContent = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }    
    
    sortColumns( event ) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.invokeRefreshApex();
        
    }
  
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        this.invokeRefreshApex();
    }

    clearAllFilters(){
        this.clearFilters();
        this.invokeRefreshApex();
    }

    clearFilters(){
        this.selectedCategory = '';
        this.selectedSubCategory = '';
        this.selectedClient = '';
    }
    handleFilterChange(event){
        if(event.target.name == 'category'){
            this.selectedCategory = event.detail.value;
        }
        else if(event.target.name == 'subcategory'){
            this.selectedSubCategory = event.detail.value;
        }
        else if(event.target.name == 'client'){
            this.selectedClient = event.detail.value;
        }
        
        this.invokeRefreshApex();
    }

    handleRowAction(event){    
        this.isDisableSaveUnsaveAddOppButtos = false; 
        const dataRow = event.detail.row;
        this.selectedRow=dataRow;

        this.recComments = this.selectedRow.Comment__c;
        this.recPotentialRev = this.selectedRow.Potential_Insight_Revenue__c;
        if(this.selectedRow.status == 'Accepted'){
            this.isDisableAcceptRejectButtos = true;
        }
        else{
            this.isDisableAcceptRejectButtos = false;
        }
              
        if (event.detail.action.name === "InsightNameModalOpen") {
            this.modalContainer=true;
            this.setSnoozeLable();
        }
        if (event.detail.action.name === "changeOwner") {
            this.changeOwnerModalFlag=true;
        }
        if(event.detail.action.name === "addOpportunity"){
            //CreateOpportunity SFP-6639
            this.isOpportunityFormOpenedFromAccept = false;
            this.modalContainer=false;
            this.createOppFlag=true;
        }
        if(event.detail.action.name === "snoozeInsight"){
            this.setSnoozeLable();
            this.handleSnoozedToggleClick();
        }
        if(event.detail.action.name === "insightFeedback"){
            this.sendFeedbackFlag = true;
        }
        if(event.detail.action.name === "accept"){
            this.openAccept();

        }
        if(event.detail.action.name === "reject"){
            this.openReject();
        }
     }
     openAccept(){  
        this.insightQualityVal = '';
        this.insightStatusVal = '';  
        this.modalContainer=false;
        this.acceptFlag = true;  
        this.isRequiredComments = false;      
     }

     sendAcceptFeedback(){
        this.acceptFlag = false;
        this.insightStatusVal = 'Accepted';
        this.insightQualityVal = 'Please give me more';
        this.submitSendFeedback('');
     }

     createNewOpportunity(){
        this.isOpportunityFormOpenedFromAccept = true;
        this.acceptFlag = false;
        this.insightStatusVal = 'Accepted';
        this.insightQualityVal = 'Please give me more';
        this.createOppFlag = true;
     }


     
     handleRejectOptions(event){
        this.isRequiredComments = false;
        this.feedbackOptions.forEach(option=>{
            if(option.label == event.target.name){
                option.isSelected = event.target.checked;
            }
            else{
                option.isSelected = false;
            }
        });

        let selectedValue = '';
        this.feedbackOptions.forEach(option=>{
            if(option.isSelected){
                selectedValue = option.label;
            }
        });
        this.insightQualityVal = selectedValue;
        this.insightStatusVal = 'Rejected';
        if(this.insightQualityVal.includes('Other')){
            this.isRequiredComments = true;
        }
     }
     openReject(){
        this.insightQualityVal = '';
        this.insightStatusVal = '';
        this.reasonForRejectComments = '';
        this.commentCharsCount = 0;
        this.modalContainer=false;
        getFeedbackOptions({insightId : this.selectedRow.Id,typeOfFeedback : 'Reject'})
                .then(result=> {
                    this.feedbackOptions = result;
                    this.rejectFlag = true;

                })
                .catch(error => {
                    this.feedbackOptions = [];
                    this.rejectFlag = true;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message:  'Failed to fetch feedback options.',
                            variant: 'error',
                        }),
                    );
            });
        
     }
     closeReject(){
        this.rejectFlag = false;
     }
     closeAccept(){
        this.acceptFlag = false;
     }

     handleRejectComments(event){
        this.countClass= 'slds-text-color_success';
        this.reasonForRejectComments = event.detail.value;
        this.commentCharsCount = (this.reasonForRejectComments.length);
        if(this.commentCharsCount == 250){
            this.countClass= 'slds-text-color_error';
        }
    }

    
     
     submitAccept(){
        this.acceptFlag = false;
        this.submitSendFeedback(this.reasonForAcceptComments);
     }
     submitReject(){
        this.rejectFlag = false;
        this.insightStatusVal = 'Rejected';
        if(this.feedbackOptions.length == 0){
            this.insightQualityVal = 'I would like to see less of these';
        }
        this.submitSendFeedback( this.reasonForRejectComments);
     }
     
     handleRecChanges(event){
        this.inputLabel = event.target.label;
        this.inputValue = event.target.value;

        if( this.inputLabel === "My notes" && this.inputValue !== null && this.inputValue !=='' && this.inputValue !== undefined){         
            this.recComments = event.target.value;

        }   
        if( this.inputLabel === "Potential Insight Revenue" && this.inputValue !== null && this.inputValue !=='' && this.inputValue !== undefined){
            this.recPotentialRev = event.target.value;
        }
    }

    saveRecAction(){
        const fields = {};
        let isReady = false;

        fields[INSIGHTS_ID.fieldApiName] = this.selectedRow.Id;

        if(this.recPotentialRev !== null && this.recPotentialRev !=='' && this.recPotentialRev !== undefined){
            fields[INSIGHTS_Revenue.fieldApiName] = this.recPotentialRev;
            this.selectedRow.Potential_Insight_Revenue__c = this.recPotentialRev;
            
            isReady = true;
            this.recPotentialRev = '';
        }
        if(this.recComments !== null && this.recComments !=='' && this.recComments !== undefined){            
            fields[INSIGHTS_Comment.fieldApiName] = this.recComments;
            this.selectedRow.Comment__c = this.recComments;
            isReady = true;
            this.recComments = '';
        }
        const recordInput = { fields };
        
        if(isReady){
            updateRecord(recordInput)
                .then(()=> {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record has been updated successfully.',
                            variant: 'success',
                        }),
                    );
                    if(this.insightlinkid != ''){
                        this.reloadPage();
                    }
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Updating Error',
                            message:  'Record Update failed, Please contact system administrator.',
                            variant: 'error',
                        }),
                    );
            });
            isReady = false;
        }
        this.closeModalAction();
    }
    reloadPage(){
        let url = window.location.href;
        if(url.includes('?')){
            url = url.split('?')[0];
        }
        setTimeout(function(){
            window.location.href = url;
         }, 3000);
    }
    reloadPage1(){
        let url = window.location.href;
        if(url.includes('?')){
            url = url.split('?')[0];
        }
        setTimeout(function(){
            window.location.href = url;
         }, 8000);
    }

     navigateInsigtDetailPage(){        
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.selectedRow.Id,
                objectApiName: 'Insight__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });        
     }

     navigateClientDetailPage(){        
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.selectedRow.Client__r.Id,
                objectApiName: 'Account',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });    
    }
    navigateTrackMyOpportunities(){
        this[NavigationMixin.GenerateUrl]({
            type : 'standard__webPage',
            attributes: {
                url : dashboardUrl
            }
        }).then(url => {
            window.open(url, "_blank");
        }); 
    }

     closeModalAction(){
        this.modalContainer=false;
        this.recComments = '';
    }
    onProductSpecSelection(event){  
        this.looupRecordName = event.detail.selectedValue;  
        this.lookupRecordId = event.detail.selectedRecordId; 
        if(this.lookupRecordId == '' || this.lookupRecordId == null){
            this.changeOwnerBottonFlag = true;
        } else{
            this.changeOwnerBottonFlag = false;
        }

    } 
    handleSendEmailOwnerChange(event){
        this.sendEmailOwnerChange = event.target.checked;        
    }
    openChangeOwner() {
        this.modalContainer=false;
        // to open modal set changeOwnerModalFlag tarck value as true
        this.changeOwnerModalFlag = true;
    }
    closeChangeOwner() {
        // to close modal set changeOwnerModalFlag tarck value as false
        this.changeOwnerModalFlag = false;
    }
    submitChangeOwner() {      
        let changepsParam = '{"recId":"'+ this.selectedRow.Id+'","psId": "'+this.lookupRecordId+'","oldRecOwnerId":"'+ this.selectedRow.OwnerId+'","sendEmailOwnerChange": '+this.sendEmailOwnerChange+',"leadId": "'+this.selectedRow.External_Lead_ID__c+'"}';

        changeProdSpecialist({ changepsParamVal: changepsParam  })
        .then(result=>{                     
            
            const toastEvent = new ShowToastEvent({
              title:'Success!',
              message:'Product specialist has been updated successfully.',
              variant:'success'
            });
            this.dispatchEvent(toastEvent);
            this.sendEmailOwnerChange = false;
            this.reloadPage();       
        })
        .catch(error=>{
            this.error=error.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Updating Error',
                    message:  'Product specialist update failed, Please contact system administrator.',
                    variant: 'error',
                }),
            );
        });
        
        // to close modal set changeOwnerModalFlag tarck value as false
        //Add your code to call apex method or do some processing
        this.changeOwnerModalFlag = false;
        
          
    }
        
    handleMyInsightsClick(){
        this.clearFilters();
        this.myInsightsSelected = !this.myInsightsSelected;
        this.onMyInsightsClick();//Added by Chandrasekhar
        this.invokeRefreshApex();
    }
    //Added by Chandrasekhar
    onMyInsightsClick(){
        if(this.myInsightsSelected){
            this.myInsightsVarient='brand';
            this.allInsightsVarient='neutral';
            this.expiringSoonVarient='neutral';
            this.snoozedInsightsVarient='neutral';
            this.allInsightsSelected=false;
            this.expiringSoonSelected=false;
            this.snoozedInsightsSelected=false;
            this.searchKey = '';
        }else{
            this.myInsightsVarient='neutral';
        }
    }
    handleAllInsightsClick(){
        this.clearFilters();
        this.allInsightsSelected = !this.allInsightsSelected;
        this.onAllInsightsClick();//Added by Chandrasekhar
        this.invokeRefreshApex();
    }  

    //Added by Chandrasekhar
    onAllInsightsClick(){
        if(this.allInsightsSelected){
            this.allInsightsVarient='brand';
            this.myInsightsVarient='neutral';
            this.expiringSoonVarient='neutral';
            this.snoozedInsightsVarient='neutral';
            this.myInsightsSelected=false;
            this.expiringSoonSelected=false;
            this.snoozedInsightsSelected=false;
            this.searchKey = '';
        }else{
            this.allInsightsVarient='neutral';
        }
    }  
    //Added by Chandrasekhar
    handleExpiringSoonClick(){
        this.clearFilters();
        this.expiringSoonSelected = !this.expiringSoonSelected;
        this.onExpiringSoonClick();//Added by Chandrasekhar
        this.invokeRefreshApex();
    }

    //Added by Chandrasekhar
    onExpiringSoonClick(){
        if(this.expiringSoonSelected){
            this.expiringSoonVarient='brand';
            this.myInsightsVarient='neutral';
            this.allInsightsVarient='neutral';
            this.snoozedInsightsVarient='neutral';
            this.myInsightsSelected=false;
            this.allInsightsSelected=false;
            this.snoozedInsightsSelected=false;
            this.searchKey = '';
        }else{
            this.expiringSoonVarient='neutral';
        }
    }
    //Added by Chandrasekhar
    handleSnoozedInsightsClick(){
        this.clearFilters();
        this.snoozedInsightsSelected = !this.snoozedInsightsSelected;
        this.onSnoozedInsightsClick();//Added by Chandrasekhar
        this.invokeRefreshApex();
    }

    //Added by Chandrasekhar
    onSnoozedInsightsClick(){
        if(this.snoozedInsightsSelected){
            this.snoozedInsightsVarient='brand';
            this.expiringSoonVarient='neutral';
            this.myInsightsVarient='neutral';
            this.allInsightsVarient='neutral';
            this.myInsightsSelected=false;
            this.allInsightsSelected=false;
            this.expiringSoonSelected=false;
            this.searchKey = '';
        }else{
            this.snoozedInsightsVarient='neutral';
        }
    }


    //createOpportunity SFP-6639

    toggleCOSubmit()
    {
        var filled=true;
        var coFields=this.template.querySelectorAll('lightning-input.coFields');
        coFields.forEach(function(element){
            if(element.value)
            {
                if(element.value.length===0)
                {
                    filled=false;
                }
            }
            else{
                filled=false;
            }
        },this);        
        if(filled && this.createOppProbability && this.createOppProbability <= 100)
        {
            this.createOppButtonFlag=false;
        }
        else{
            this.createOppButtonFlag=true;
        }
    }

    handleCOName(event)
    {
        this.createOppName=event.detail.value;
        this.toggleCOSubmit();
    }

    handleMNPIChange(event) {
        this.createOppMnpi = event.target.checked;        
        this.toggleCOSubmit();
    }

    onClientSelection(event){  
        this.createOppClientName= event.detail.selectedValue;
        this.createOppClientId = event.detail.selectedRecordId; 
        if(this.createOppClientId == '' || this.createOppClientId == null){
            this.createOppButtonFlag = true;
        } else{
            this.createOppButtonFlag = false;
        }
        this.toggleCOSubmit();
    }

    handleCODesc(event)
    {
        this.createOppDesc=event.detail.value;
        this.toggleCOSubmit();
    }
    handleCOStartDate(event)
    {
        this.createOppStartDate=event.detail.value;
        this.toggleCOSubmit();
    }
    handleCOCloseDate(event)
    {
        this.createOppCloseDate=event.detail.value;
        this.toggleCOSubmit();
    }

    handleProbabilityChange(event){
        this.createOppProbability=event.detail.value;
        this.toggleCOSubmit();
    }

    openCreateOpp()
    {
        this.modalContainer=false;
        this.createOppFlag=true;
    }

    closeCreateOpp()
    {
        this.createOppFlag=false;
        this.createOppButtonFlag=true;
        if(this.isOpportunityFormOpenedFromAccept == true){
            this.sendAcceptFeedback();
        }
    }

    submitCreateOpp()
    {
        this.createOppFlag=false;
        this.createOppButtonFlag=true;
       let createOpptyPrams = '{"recId":"'+this.selectedRow.Id+'","coClientId":'+( this.selectedRow.Client__c ? '"'+this.selectedRow.Client__c+'"' : null)+',"coName":"'+this.createOppName+'","coDescription":"'+this.createOppDesc+'","coStartDate":"'+this.createOppStartDate+'","coCloseDate":"'+this.createOppCloseDate+'","coProbability":"'+this.createOppProbability+'","coMnpi":'+this.createOppMnpi+',"leadId":"'+this.selectedRow.External_Lead_ID__c+'"}';
       createOpportunity({createOpptyPramsVal: createOpptyPrams})
        .then(result=>{                     
            const toastEvent = new ShowToastEvent({
            title:'Success!',
            message:'New Opportunity Created',
            variant:'success'
            });
            this.dispatchEvent(toastEvent);
            this.createOppClient = false;
            this.landOnTheSamePage(3000);   
        })
        .catch(error=>{
            this.error=error.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Updating Error',
                    message:  'Opportunity creation failed, Please contact system administrator.',
                    variant: 'error',
                }),
            );
        });
    }

    handleSnoozedToggleClick() {          

        this.closeSnoozeInsight();

        let snoozeInsightParam = '{"recId":"'+this.selectedRow.Id+'","recComments":"'+ this.selectedRow.Comment__c+'","isSnoozed":'+!this.selectedRow.Is_Snoozed__c +',"leadId":"'+this.selectedRow.External_Lead_ID__c+'"}';

        snoozeInsightRec({ snoozeInsightParamVal: snoozeInsightParam  })
                .then(result=>{     
                    let titleMsg = this.selectedRow.Is_Snoozed__c ? 'You have successfully removed the nudge from saved view' : 'You have successfully saved the nudge';                
                    let msg  = this.selectedRow.Is_Snoozed__c ? '' :'Note: This nudge will be moved to saved view and still will be required to be actoined' ; 
                    const toastEvent = new ShowToastEvent({
                        message:msg,
                        title:titleMsg,
                        variant:'success',
                        mode:'sticky'
                    });
                    this.dispatchEvent(toastEvent);
                    this.landOnTheSamePage(8000);
                })
                .catch(error=>{
                    this.error=error.message;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Updating Error',
                            message:  'Snooze Insight action failed, Please contact system administrator.',
                            variant: 'error',
                        }),
                    );
                });       
             
    }
    
    openSnoozeInsight(){
        this.modalContainer = false;
        this.recComments = '';
        this.handleSnoozedToggleClick();
    }

    closeSnoozeInsight(){
        this.snoozeModalFlag = false;        
    }
    setSnoozeLable(){
        if(this.selectedRow.Is_Snoozed__c){
            this.snoozedButtonLabel = 'Remove from saved list';
            this.isInsightSnoozed = true;
        }else{
            this.snoozedButtonLabel = 'Save nudge';
            this.isInsightSnoozed = false;
        }
     }

     //methodes for send feedback action
     // to get the default record type id, if you dont' have any recordtypes then it will get master

    @wire(getObjectInfo, { objectApiName: INSIGHTACTION_OBJECT })
    InsActionMetadata;

     // now get the industry picklist values
     @wire(getPicklistValues,
        {
            recordTypeId: '$InsActionMetadata.data.defaultRecordTypeId', 
            fieldApiName: INSIGHTQUALITY_FIELD
        }
    )
    insQualityPicklist;
    
     // now get the industry picklist values
     @wire(getPicklistValues,
        {
            recordTypeId: '$InsActionMetadata.data.defaultRecordTypeId', 
            fieldApiName: INSIGHTSTATUS_FIELD
        }
    )
    insStatusPicklist;

    // on select picklist value to show the selected value
    insQualityPicklistHandleChange(event) {
        this.insightQualityVal = event.detail.value;
        if((this.insightQualityVal == '' || this.insightQualityVal == null) || (this.insightStatusVal == '' || this.insightStatusVal == null)){
            this.submitSendFeedbackFlag = true;
        }else{
            this.submitSendFeedbackFlag = false;
        }
    }

    insStatusPicklistHandleChange(event) {
        this.insightStatusVal = event.detail.value;
        if((this.insightQualityVal == '' || this.insightQualityVal == null) || (this.insightStatusVal == '' || this.insightStatusVal == null)){
            this.submitSendFeedbackFlag = true;
        }else{
            this.submitSendFeedbackFlag = false;
        }
    }
    
    openSendFeedback(){
        this.sendFeedbackFlag = true;
        this.modalContainer = false;
    }

    closeSendFeedback(){
        this.sendFeedbackFlag = false;
        this.insightQualityVal = '';
        this.insightStatusVal = '';
    }

    submitSendFeedback(reason){
        this.sendFeedbackFlag = false;
        let feedbackInsight = '{"recId":"'+this.selectedRow.Id+'","insightStatusVal":"'+this.insightStatusVal+'","insightQualityVal":"'+this.insightQualityVal+'","leadId":"'+this.selectedRow.External_Lead_ID__c+'"}';
        let actionType = this.insightStatusVal;
        feedbackInsights({ feedbackInsightVal : feedbackInsight,comments : reason  })
        .then(result=>{
            let titleMsg = (actionType == 'Accepted') ? 'You have successfully accepted the nudge.' : 'You have rejected the nudge.';
            const toastEvent = new ShowToastEvent({
                message: '',
                title: titleMsg,
                variant: 'success',
                mode: 'sticky'
            });
            this.dispatchEvent(toastEvent);
            
            //Added by Chandrasekhar
            this.landOnTheSamePage(3000);
        })
        .catch(error=>{
            this.error=error.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Updating Error',
                    message:  'Failed to send feedback, Please contact system administrator.',
                    variant: 'error',
                }),
            );
        });
        
        this.insightQualityVal = '';
        this.insightStatusVal = '';
    }

    //Added by Chandrasekhar
    landOnTheSamePage(noOfMilliSeconds){

        let url = window.location.href;
        if (url.includes('?')) {
            url = url.split('?')[0];
        }
        let currentTab = this.returnTabName();
        let pageNumber = this.page;
        setTimeout(function () {
            window.location.href = url + '?c__currentPage=' + pageNumber+'&c__currentTab='+currentTab;
        }, noOfMilliSeconds);
    }

    //Added by Chandrasekhar
    returnTabName(){
        if(this.myInsightsSelected){
            return 'MyInsights';
        }
        else if(this.expiringSoonSelected){
            return 'ExpiringSoon';
        }
        else if(this.snoozedInsightsSelected){
            return 'Saved';
        }
        else if(this.allInsightsSelected){
            return 'All';
        }
    }

}