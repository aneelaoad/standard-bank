/**
 * @description APEX Class for AKILI Listview to perform differet insights actions
 * 
 * @author Vipeen Sarode
 * @date octomber 2021
 * ==========================================================================
 * ModifiedDate  modifiedby     		Story    	Description
 * ===========================================================================
 * 2023-03-24   Chandrasekhar  		SFP-18266	SmartNudge- Accept and Reject insight functionality	 
 * 2023-04-24  	Chandrasekhar 		SFP-24531	SmartNudge: User is unable to save text feedback due to string parsing issue
 * 2023-09-20	Chandrasekhar		SFP-30019   Removing nudge access to other users when one of th user(Owners) accept the nudge  
*/

public with sharing class AKI_COMP_AkiliInsightsListviewController {
    //Added by Chandrasekhar
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AKI_COMP_AkiliInsightsListviewController');
    
    @AuraEnabled(cacheable=true)
       /******
      * @description This method will return Insight record
      * @param insightId
      * @return Insight__c
      ******/    
     public static Insight__c getInsightDetails(string insightId){
         LOGGER.info('Fetching insight record to display on the SmartNudge page');
         List<Insight__c> insightList =  new SEL_Insights().getInsightsByIds(new Set<String>{insightId} );
         LOGGER.debug('Insight Record::'+insightList[0].Id);
         return insightList[0];
     }
    
    @AuraEnabled(cacheable=true)
    /**
    * @description This method return the akili list view data based on multiple filter and search values
    * @param getInsightParamVal the parameter wrapper String 
    * @return List<Insight__c>
    */
     public static List<Insight__c> getInsightsData(String getInsightParamVal){ 
		List<Insight__c> returnList = new List<Insight__c>();
        ParamData paramVals = (ParamData) System.JSON.deserialize(getInsightParamVal, ParamData.class);
        
        List<Insight__c> insightList = new SEL_Insights().selectInsightsBySearchKey(paramVals.searchKey,paramVals.category,paramVals.subcategory,paramVals.client, paramVals.myInsightsSelected, paramVals.expiringSoonSelected, paramVals.snoozedInsightsSelected);
         if(!insightList.isEmpty() ){
        	LOGGER.debug('Total insights count::'+insightList.size());
             for(Insight__c ins : insightList){
                 Boolean rejectedInsight = false;
                 for(Insight_Action__c insAction : ins.Insight_Actions__r){
                     if(insAction.Insight_Status__c == 'Rejected' || insAction.Insight_Status__c == 'Insight needed no action'){
                         rejectedInsight = true;
                     }                     
                 }
                 if(!rejectedInsight){
                   returnList.add(ins);  
                 }             
        	}
         }
         
        LOGGER.debug('Filterd insights count::'+returnList.size());
        return returnList;
    }
 
    /**
      * @description This method change the insight product specialist and send insight action detials to akili
      * 
      * @param  changepsParamVal  the parameter wrapper string 
      * 
      */
    @AuraEnabled
     public static void changeProdSpecialist(string changepsParamVal){

        ParamData paramVals = (ParamData) System.JSON.deserialize(changepsParamVal, ParamData.class);

        Insight__c insightRec = New Insight__c();

        insightRec.id = paramVals.recId;
        insightRec.ownerId = paramVals.psId;
        insightRec.Previous_Owner__c = paramVals.oldRecOwnerId;        

        WrapperShareRec shareWrap = New WrapperShareRec();
        shareWrap.insightRecId = paramVals.recId;
        shareWrap.oldRecOwnerId = paramVals.oldRecOwnerId;

        list<WrapperInsightActions> wrapperInsightActionsList = New list<WrapperInsightActions>();

        WrapperInsightActions instWrap = new WrapperInsightActions();
        instWrap.actionType = 'Owner Changed';
        instWrap.actionedUser = userInfo.getUserId();
        instWrap.insightId = paramVals.recId;
        instWrap.extleadId = paramVals.leadId;
        instWrap.wrapperShareRecData = shareWrap; 
        wrapperInsightActionsList.add(instWrap);    

        Map<string,Id> insertedActionMap = createInsightAction(wrapperInsightActionsList);

        for(WrapperInsightActions rec : wrapperInsightActionsList){
            rec.insightActId = insertedActionMap.get(rec.actionType);
        }


        Database.DmlOptions options = new Database.DmlOptions();
        options.emailHeader.triggerUserEmail = boolean.valueOf(paramVals.sendEmailOwnerChange);
        Database.SaveResult srRec = Database.update(insightRec, options);
        if(srRec.isSuccess()){
            String dataSet = JSON.serialize(wrapperInsightActionsList);
            if(wrapperInsightActionsList[0].actionType == 'Owner Changed'){
                shareInsightRecord(dataSet);
            }            
            aki_comp_FutureCreateInsightAction.createInsightActionSendFeedback(dataSet);
        }else{
            list<Insight_Action__c> insertedActions = New list<Insight_Action__c>();
            for (Id idInst : insertedActionMap.keyset()) {
                Insight_Action__c iaRecInst = new Insight_Action__c();
                iaRecInst.id = insertedActionMap.get(idInst);
                insertedActions.add(iaRecInst);
            }
            if (Schema.sObjectType.Insight_Action__c.isDeletable()) {
                delete insertedActions;
            }
        }
 
     }
 
     /**
      *  @description This method create opportunity based on user input and send insight action detials to akili
      * 
      * @param  createOpptyPramsVal  the parameter wrapper string 
      * 
      */
     @AuraEnabled
     public static void createOpportunity(String createOpptyPramsVal){
 
        ParamData paramVals = (ParamData) System.JSON.deserialize(createOpptyPramsVal, ParamData.class);
 
        Opportunity opp=new Opportunity();
        opp.Name=paramVals.coName;
        opp.Description=paramVals.coDescription;             
        if(paramVals.coClientId!=null){
            opp.AccountId=paramVals.coClientId;
        }
        opp.Start_Date__c=date.valueOF(paramVals.coStartDate); 
        opp.CloseDate=date.valueOF(paramVals.coCloseDate);
        opp.StageName='1 - Lead';
        opp.Probability = paramVals.coProbability; 
        opp.Price_Sensitive__c =  paramVals.coMnpi;
        opp.Lead_Source__c='Smart Nudge';  //Set Lead Source as 'Smart Nudge' as part of SFP-15206 story
        Database.SaveResult srRec = Database.insert(opp);

        if(srRec.isSuccess()){
            Insight__c ins = new Insight__c();            
            ins.id = paramVals.recId;
            ins.Opportunity__c=opp.Id;
            ins.Status__c = 'Accepted';//Added by Chandrasekhar - SFP-18266
            ins.Is_Provided_Feedback__c = true;//Added by Chandrasekhar - SFP-18266
            if (Schema.sObjectType.Insight__c.fields.Opportunity__c.isUpdateable()) {
                update ins;
            }

            list<WrapperInsightActions> wrapperInsightActionsList = New list<WrapperInsightActions>();

            WrapperInsightActions instWrap = new WrapperInsightActions();
            instWrap.actionType = 'Opportunity Created';
            instWrap.actionedUser = userInfo.getUserId();
            instWrap.insightId = paramVals.recId;
            instWrap.extleadId = paramVals.leadId;
            instWrap.opportunityId = opp.Id;//Added by Chandrasekhar
            wrapperInsightActionsList.add(instWrap);    

            WrapperInsightActions instWrap1 = new WrapperInsightActions();
            instWrap1.actionType='Rating';
            instWrap1.insightStatus='Accepted';//Value changed from 'Insight actioned' to 'Accepted'  - SFP-18266
            instWrap1.insightQuality='Please give me more';             
            instWrap1.actionedUser = userInfo.getUserId();
            instWrap1.insightId = paramVals.recId;
            instWrap1.extleadId = paramVals.leadId;            
            wrapperInsightActionsList.add(instWrap1);   

            Map<String,Id> insertedActionMap = createInsightAction(wrapperInsightActionsList);

            for(WrapperInsightActions rec : wrapperInsightActionsList){
                rec.insightActId = insertedActionMap.get(rec.actionType);
            }
          
            String dataSet = JSON.serialize(wrapperInsightActionsList);

            aki_comp_FutureCreateInsightAction.createInsightActionSendFeedback(dataSet);
        }
             
     }
 
     /**
      * @description This method will snooze and unsnooze insight and send insight action detials to akili
      * 
      * @param  snoozeInsightParamVal  the parameter wrapper string  
      * 
      */
     @AuraEnabled
     public static void snoozedInsights(String snoozeInsightParamVal){
 
         ParamData paramVals = (ParamData) System.JSON.deserialize(snoozeInsightParamVal, ParamData.class);
 
         Insight__c inst = new Insight__c();            
         inst.id = paramVals.recId;
         inst.Comment__c=paramVals.recComments;
         inst.Is_Snoozed__c = paramVals.isSnoozed;
         Database.SaveResult srRec = Database.update(inst);
 
         if(srRec.isSuccess()){
             list<WrapperInsightActions> wrapperInsightActionsList = New list<WrapperInsightActions>();
 
             WrapperInsightActions instWrap = new WrapperInsightActions();
             instWrap.actionType = 'Is Snoozed';
             instWrap.actionedUser = userInfo.getUserId();
             instWrap.insightId = paramVals.recId;
             instWrap.extleadId = paramVals.leadId;            
             instWrap.actionValue = paramVals.isSnoozed ? '1' : '0';            
             wrapperInsightActionsList.add(instWrap);  
             
             Map<String,Id> insertedActionMap = createInsightAction(wrapperInsightActionsList);
 
             for(WrapperInsightActions rec : wrapperInsightActionsList){
                 rec.insightActId = insertedActionMap.get(rec.actionType);
             }
             
             String dataSet = JSON.serialize(wrapperInsightActionsList);
 
             aki_comp_FutureCreateInsightAction.createInsightActionSendFeedback(dataSet);
 
         }
     }
 /**
      * @description  This method  create feedback insight action and send insight action detials to akili
      * 
      * @param   feedbackInsightVal  the parameter wrapper string 
      * @param   comments 
      */
     @AuraEnabled
    public static void feedbackInsights(string feedbackInsightVal,String comments){
        if(String.isNotBlank(comments)){
            comments = comments.replace('\r\n', ' ');
            comments = comments.replace('\n', ' ');
            comments = comments.replace('\r', ' ');
        }
        LOGGER.debug('Additional Comments::'+comments);
        ParamData paramVals = (ParamData) System.JSON.deserialize(feedbackInsightVal, ParamData.class);
        paramVals.reason = comments;
        
        Insight__c inst = new Insight__c ();
        inst.id = paramVals.recId;
        inst.Is_Provided_Feedback__c=True;
        inst.Status__c = paramVals.insightStatusVal;//Added by Chandrasekhar - SFP-18266
        inst.OwnerId = UserInfo.getUserId();//Added by Chandrasekhar - SFP-18266
        Database.update(inst);
        
        
        list<WrapperInsightActions> wrapperInsightActionsList = New list<WrapperInsightActions>();
        
        WrapperInsightActions instWrap = new WrapperInsightActions();
        instWrap.actionType = 'Rating';
        instWrap.actionedUser = userInfo.getUserId();
        instWrap.insightId = paramVals.recId;
        instWrap.extleadId = paramVals.leadId;
        instWrap.insightQuality = paramVals.insightQualityVal;
        instWrap.insightStatus = paramVals.insightStatusVal;
        //Added by Chandrasekhar - SFP-18266 
        if(String.isNotBlank(paramVals.reason)){
            instWrap.actionValue = paramVals.reason;
        }
        //End
        wrapperInsightActionsList.add(instWrap); 
        
        Map<string,Id> insertedActionMap = createInsightAction(wrapperInsightActionsList);
        
        if( paramVals.insightStatusVal == 'Accepted'){
        	Insight_Sharing.deleteInsightShareedRecords(paramVals.recId,'Client_Analyst_Sharing__c');
        }
        
        for(WrapperInsightActions rec : wrapperInsightActionsList){
            rec.insightActId = insertedActionMap.get(rec.actionType);
            LOGGER.debug('Feedback - InsightAction record::'+rec);
        }
        
        String dataSet = JSON.serialize(wrapperInsightActionsList);
        
        aki_comp_FutureCreateInsightAction.createInsightActionSendFeedback(dataSet);
        LOGGER.info('Successfully Sent Feedback ');
        
    }
    
     /**
      *  @description This method will share insight with previous product specialist as insight transfer to new product specialist
      * 
      * @param   wrapperDetail detail insight record in string wrap format 
      * 
      */
     @future
     public static void shareInsightRecord(String wrapperDetail){
 
         List<aki_comp_AkiliInsightsListviewController.WrapperInsightActions> wrapInsightActionRecList = (List<aki_comp_AkiliInsightsListviewController.WrapperInsightActions>) System.JSON.deserialize(wrapperDetail, List<aki_comp_AkiliInsightsListviewController.WrapperInsightActions>.class);
         Insight__Share insightShare  = new Insight__Share();    
         insightShare.ParentId = wrapInsightActionRecList[0].wrapperShareRecData.insightRecId;            
         insightShare.UserOrGroupId = wrapInsightActionRecList[0].wrapperShareRecData.oldRecOwnerId;            
         insightShare.AccessLevel = 'Edit';            
         
         insightShare.RowCause = Schema.Insight__Share.RowCause.Manual;                     
         Database.insert(insightShare,false);
    }
 
     /**
      *  @description This method create insight action based on insight action type
      * 
      * @param   wrapInsightActionRec detail insight record in string wrap format 
      * 
      * @return Map<string,Id>  map of insight action type and insight action id
      */
 public static Map<string,Id> createInsightAction(List<WrapperInsightActions> wrapInsightActionRec){ 
     Map<string,Id> typeActionIdMap = New Map<string,string>();
     list<Insight_Action__c> insightActList = New list<Insight_Action__c>();
     for(WrapperInsightActions rec : wrapInsightActionRec){
         Insight_Action__c iaRecInst = new Insight_Action__c();
         switch on rec.actionType {
             when 'Owner Changed' {		// when block 1
                 iaRecInst.Action_Type__c = rec.actionType;
                 iaRecInst.User__c = rec.actionedUser;
                 iaRecInst.Insight__c = rec.insightId;
             }
             when 'Opportunity Created' {		// when block 2
                 iaRecInst.Action_Type__c = rec.actionType;
                 iaRecInst.User__c = rec.actionedUser;
                 iaRecInst.Insight__c = rec.insightId;            
             }
             when 'Rating' {
                 iaRecInst.Action_Type__c = rec.actionType;
                 iaRecInst.User__c = rec.actionedUser;
                 iaRecInst.Insight__c = rec.insightId;
                 iaRecInst.Insight_Quality__c = rec.insightQuality;
                 iaRecInst.Insight_Status__c = rec.insightStatus; 
                 iaRecInst.Reason__c = rec.actionValue;
             }
             when 'Is Snoozed' {
                 iaRecInst.Action_Type__c = rec.actionType;
                 iaRecInst.User__c = rec.actionedUser;
                 iaRecInst.Insight__c = rec.insightId;
             }
         }
         insightActList.add(iaRecInst);
     }
     if (Schema.sObjectType.Insight_Action__c.fields.Action_Type__c.isCreateable()) {
         insert insightActList;
     }
     
 
     for(Insight_Action__c rec : insightActList){
         typeActionIdMap.put(rec.Action_Type__c,rec.Id);
     }
     return typeActionIdMap;
 }
 
 	/**
      * @description   hold data of insight action opportunity and insight share details
      */
     public class WrapperInsightActions {
         /**
          * @description  insightActId
          */
         public String insightActId {get; set;}
         /**
          * @description  opportunityId
          */
         public String opportunityId {get; set;}
         /**
          * @description  actionType
          */
         public String actionType {get; set;}
         /**
          * @description  insightId
          */
         public String insightId {get; set;}
         /**
          * @description  extleadId
          */
         public String extleadId {get; set;} 
         /**
          * @description  actionValue
          */
         public String actionValue {get; set;} 
         /**
          * @description  insightQuality
          */
         public String insightQuality {get; set;}
         /**
          * @description  insightStatus
          */
         public String insightStatus {get; set;}
         /**
          * @description  actionedUser
          */
         public String actionedUser {get; set;}
         /**
          * @description  createdByUser
          */
         public String createdByUser {get; set;}         
         /**
          * @description  wrapperShareRecData
          */
         public WrapperShareRec wrapperShareRecData {get; set;}
        
         /**
         *@description This is the contructor method. When we create a new wrap object. We also set the all value to null;
         */
         public WrapperInsightActions() {
             insightActId = null;
             opportunityId  = null;
             actionType  = null;
             insightId  = null;
             extleadId = null;
             insightQuality = null;
             insightStatus  = null;
             actionedUser  = null;
             createdByUser  = null;
         }
     }
    /**
    *@description hold data of insight share details
    */
     public class WrapperShareRec {
         /**
        *@description insightRecId
        */
         public String insightRecId {get; set;}
         /**
        *@description oldRecOwnerId
        */
         public String oldRecOwnerId {get; set;}        
  
         /**
         * @description This is the contructor method. When we create a new wrap object. We also set the all value to null;
         */
         public WrapperShareRec() {
             insightRecId  = null;
             oldRecOwnerId  = null;
         }
     }
     
    /**
    *@description hold data of insight parameters
    */
     public class ParamData{
        public String searchKey;
        public Boolean myInsightsSelected;
        public String category; //Filters
         public String subcategory; //Filters
         public String client; //Filters
        public Boolean allInsightsSelected;
        public Boolean expiringSoonSelected;
        public Boolean snoozedInsightsSelected;

        //pram for change owner
        public String recId;
        public String leadId;
        public String psId;	
        public String oldRecOwnerId;
        public String sendEmailOwnerChange;	

        //params for opportunity creation
        public String coClientId;	
        public String coName;	
        public String coDescription;	
        public String coStartDate;
        public String coCloseDate;
        public Integer coProbability; 
        public Boolean coMnpi; 
        
        //params for isSnooze
        public String recComments;
        public Boolean isSnoozed;

        //paramsfor Insight feedback
        public String insightStatusVal;	//Insight previously actioned
	    public String insightQualityVal;
        public String actionType;//Added by Chandrasekhar - SFP-18266
        public String reason;//Added by Chandrasekhar - SFP-18266
                  
     }
    
    @AuraEnabled
       /******
      * @description This method will fetch return Feedback options
      * @param insightId
      * @param typeOfFeedback
      * @return List<feedbackoption>
      ******/    
     public static List<feedbackoption> getFeedbackOptions(String insightId,String typeOfFeedback){
         List<String> options = new List<String>();
         List<Insight__c> insightList =  new SEL_Insights().getInsightsByIds(new Set<String>{insightId} );
         Map<String, List<String>> picklistValuesMap = AKI_COMP_AkiliInsightsListviewController.getDependentPicklistValues(Insight_Action__c.Insight_Quality__c);
         if(!picklistValuesMap.isEmpty()){
             
             for(String key : picklistValuesMap.KeySet()){
                 if(String.isNotBlank(insightList[0].Category__c) && key.startsWith(insightList[0].Category__c)){
                     options.addAll(picklistValuesMap.get(key));
                 }
             }
         }
         return setFeedbackOptions(options);
     }
     /******
      * @description This method used to prepare options and then return
      * @param options
      * @return List<feedbackoption>
      ******/  
    public static List<feedbackoption> setFeedbackOptions(List<String> options){
        List<feedbackoption> fbOptions = new List<feedbackoption>();
        for(String option : options){
            feedbackoption optionRec = new feedbackoption();
            optionRec.label = option.trim();
            optionRec.value = option.trim();
            optionRec.isSelected = false;
            fbOptions.add(optionRec);
        }
        return fbOptions;
    }
    
    /**
    *@description To hold feedback options
    */
    public class feedbackoption{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
        @AuraEnabled public Boolean isSelected;
    }
    
    /******
      * @description This method will return depedent values
      * @param dependToken
      * @return Map<String, List<String>>
      ******/  
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0){
                        continue;
                    }
                        
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
    
 }