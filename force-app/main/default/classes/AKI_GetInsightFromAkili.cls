/**
*@description  API Class to get insight in salesforce insight object from akili datdabse
* 
* @author Vipeen Sarode
* @date october 2021
* 
* ModifiedBy       			ModifiedDate   	Story Number    Description
* Chandrasekhar Mokkala		20 August 2022	SFP-16434		SmartNudge - Share insight records with multiple owners
* Chandrasekhar Mokkala		31 August 2022	SFP-16901		SmartNudge - Pagination Implementation
* Chandrasekhar Mokkala		2nd June 2023	SFP-22526		Smart Nudge: Add Optimisation rank field
* Chandrasekhar Mokkala		23 August 2023	SFP-28741		SmartNudge External Pilot 1a
*/
public without sharing class AKI_GetInsightFromAkili {
    //Added by Chandrasekhar
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AKI_GetInsightFromAkili');
    private static final String ERROR_MSG_FAILED_CALLOUT = 'Get Insights API failed';
    private static final String ERROR_MSG_FAILED_INISIGHTS_CREATION = 'There was a technical issue while creating insights';
    
    /**
    * @description  This method make callout to get insight from akili insight
    */
    @future(callout=true)
    public static void makeWebserviceCallout(){
        try{
            LOGGER.info('AKI_GetInsightFromAkili:makeWebserviceCallout initiated at :'+System.now());   
            String accessToken = AKI_COMP_FutureCreateInsightAction.getAccessToken();
            AKILI_Insights_API__mdt insightGetInsights =new SEL_AkiliInsightApiMetadatas().selectInsightApiByDeveloperName('Get_Insights');
            String apiType = insightGetInsights.x_api_type__c;
            List<String> apiTypeparams = apiType.split('=');
            Integer totalRecords = 0;
            Integer limitParam = Integer.valueOf(apiTypeparams[1]);
            Integer offSet = 0;
            
            List<AkiliInsightAPIDataWrap> leadList = new List<AkiliInsightAPIDataWrap>();
            if(totalRecords == 0){
                leadList =  makeCalloutToAkili(insightGetInsights,offSet,accessToken);
                LOGGER.debug('AKI_GetInsightFromAkili:makeWebserviceCallout Insights size :'+leadList.size());
                if(!leadList.isEmpty()){
                    totalRecords = leadList[0].full_count;
                }
            }
            if(limitParam > 0 && totalRecords > limitParam){
                
                Integer calloutCount = (totalRecords/limitParam);
                for(Integer i=0; i < calloutCount ; i++){
                    offSet = offSet + limitParam;
                    leadList.addAll(makeCalloutToAkili(insightGetInsights,offSet,accessToken));
                }
            }
            if(!leadList.isEmpty()){
               insertInsightsRecords(leadList);
            }
        }
        catch(Exception exp){
            LOGGER.error('AKI_GetInsightFromAkili:makeWebserviceCallout Error While getting nudges from SmartNudge :',exp);
            throw new CustomException(ERROR_MSG_FAILED_CALLOUT);
        }
    }
    
    /**
    * @description  : This method used to make callout to Akili to get insights
    * @param insightGetInsights
    * @param offSetParam
    * @param accessToken
    * @return List<AkiliInsightAPIDataWrap>
    */
    private static List<AkiliInsightAPIDataWrap> makeCalloutToAkili(AKILI_Insights_API__mdt insightGetInsights,Integer offSetParam,String accessToken){
        LOGGER.info('AKI_GetInsightFromAkili:makeCalloutToAkili Get insights API call initiated at :'+System.now());
        List<AkiliInsightAPIDataWrap> leadsList = new List<AkiliInsightAPIDataWrap>();
        try{
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint('callout:SmartNudge_API/insights-permissions/insights');
            request.setHeader('Accept','application/json'); 
            request.setHeader('x-fapi-interaction-id',insightGetInsights.x_fapi_interaction_id__c); 
            request.setHeader('x-apigw-api-id',insightGetInsights.x_apigw_api_id__c); 
            request.setHeader('Authorization','Bearer '+accessToken); 
            request.setHeader('x-client-certificate',insightGetInsights.Certificate_Key__c); 
            String utcTime = 'param_lastupdated='+String.valueOfGmt(System.now().addHours(-1));
            String paginationParams = 'param_offset='+String.valueOf(offSetParam);
            String apiType = insightGetInsights.x_api_type__c+'&'+paginationParams+'&'+utcTime;
            request.setHeader('x-api-type',apiType); 
            
            Http httpInst = new Http(); 
            HttpResponse response = new HttpResponse();
            response = httpInst.send(request);
            String resBody  = response.getBody();
            LOGGER.debug('AKI_GetInsightFromAkili:makeCalloutToAkili Response body :'+resBody);
            AkiliInsightAPIDataList obj = (AkiliInsightAPIDataList) System.JSON.deserialize(resBody, AkiliInsightAPIDataList.class);
            
            if(!obj.leads.isEmpty()){                
                LOGGER.debug('AKI_GetInsightFromAkili:makeCalloutToAkili Nudges size :'+obj.leads.size());
                leadsList.addAll(obj.leads);
            }
            return leadsList;
        }
        catch (Exception ex) {
            LOGGER.error('AKI_GetInsightFromAkili:makeCalloutToAkili Exception logged : ',ex);
            throw new CustomException(ERROR_MSG_FAILED_CALLOUT);
        }
    }
    
    /**
    * @description This method will insert all akili insight records return by akili engine
    * @param nudgeList
    */
    public static void insertInsightsRecords(List<AkiliInsightAPIDataWrap> nudgeList){
        LOGGER.info('AKI_GetInsightFromAkili:insertInsightsRecords initiated with size :'+nudgeList.size()); 
        try{
            List<AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> contactNudges = new List<AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap>();
            Map<String,AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> contactNudgesMap = new Map<String,AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap>();
            List<sObject> insertSharedInsightList = new List<sObject>();
            Map<String,AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> externalLeadIdWithNudgeMap = new Map<String,AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap>();
            for(AkiliInsightAPIDataWrap  nudgeRecord : nudgeList){
                if(nudgeRecord.persona == 'Client' && nudgeRecord.isclientdealer){
                    externalLeadIdWithNudgeMap.put(nudgeRecord.leadid,nudgeRecord);
                }
                else if(nudgeRecord.persona == 'Client'){
                    contactNudges.add(nudgeRecord);
                    contactNudgesMap.put(nudgeRecord.leadid,nudgeRecord);
                }
                else if(externalLeadIdWithNudgeMap.containsKey(nudgeRecord.leadid)){ 
                    insertSharedInsightList.add(prepareShareRecord(nudgeRecord.leadid,nudgeRecord.productspecialistid));
                }
                else{
                    externalLeadIdWithNudgeMap.put(nudgeRecord.leadid,nudgeRecord);
                }
            }
            
            addClientInsightsWithoutDearlerToTheInsightMap(externalLeadIdWithNudgeMap,contactNudgesMap);
            
            Map<String,id> clientAndCifNoMap = fetchClientsBasedOnTheCIFNumber(externalLeadIdWithNudgeMap);
            processInsights(externalLeadIdWithNudgeMap,clientAndCifNoMap,insertSharedInsightList,contactNudges);
        }
        catch (Exception ex){
            LOGGER.error('AKI_GetInsightFromAkili:insertInsightsRecords Exception logged : ',ex);
            throw new CustomException(ERROR_MSG_FAILED_INISIGHTS_CREATION);
        }
    }
    
    /**
    * @description This method will add client isnights without dealer to insight map 
    * @param externalLeadIdWithNudgeMap
    * @param contactNudgesMap
    */
    private static void addClientInsightsWithoutDearlerToTheInsightMap(Map<String,AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> externalLeadIdWithNudgeMap,Map<String,AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> contactNudgesMap){
        if(!contactNudgesMap.isEmpty()){
            for(String externalLeadId : contactNudgesMap.keySet()){
                if(!externalLeadIdWithNudgeMap.containsKey(externalLeadId)){
                    externalLeadIdWithNudgeMap.put(externalLeadId,contactNudgesMap.get(externalLeadId));
                }
            }
        }
    }
    
    /**
    * @description This method will fetch the clients based on th CIF numbers
    * @param externalLeadIdWithNudgeMap
    * @return Map<String,id>
    */
    private static Map<String,id> fetchClientsBasedOnTheCIFNumber(Map<String,AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> externalLeadIdWithNudgeMap){
        LOGGER.info('AKI_GetInsightFromAkili:fetchClientsBasedOnTheCIFNumber initiated'); 
        Map<String,id> clientCIFWithClientIdMap = New Map<String,id>();
        try{
            Set<String> cifNumberSet = New Set<String>();
            for(AkiliInsightAPIDataWrap leadRecord : externalLeadIdWithNudgeMap.values()){
                cifNumberSet.add(leadRecord.customercif);
            }
            
            List<Account> accountList = new SEL_Accounts().selectByCIFNumber(cifNumberSet);
            LOGGER.debug('AKI_GetInsightFromAkili:fetchClientsBasedOnTheCIFNumber Client size :'+accountList.size()); 
            for(account accountRecord:accountList){
                clientCIFWithClientIdMap.put(accountRecord.CIF__c,accountRecord.id);
            } 
        }
        catch (Exception ex){
            LOGGER.error('AKI_GetInsightFromAkili:fetchClientsBasedOnTheCIFNumber Exception logged : ',ex);
        }
        return clientCIFWithClientIdMap;
    }
    /**
    * @description This method will insert all akili insight records return by akili engine
    * @param externalLeadIdWithNudgeMap
    * @param clientAndCifNoMap
    * @param insertSharedInsightList
    * @param contactNudges
    */
    private static void processInsights(Map<String,AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> externalLeadIdWithNudgeMap, Map<String,id> clientAndCifNoMap,List<sObject> insertSharedInsightList,List<AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> contactNudges){
        LOGGER.info('AKI_GetInsightFromAkili:processInsights initiated'); 
        try{
            Map<String,String> insightExternalIdWithInsightIdMap = new Map<String,String>();
            List<Insight__c> insightList = New List<Insight__c>();
            
            for(AkiliInsightAPIDataWrap leadRecord : externalLeadIdWithNudgeMap.values()){
                insightList.add(prepareInsightRecord(leadRecord,clientAndCifNoMap));
            }
            LOGGER.debug('AKI_GetInsightFromAkili:processInsights Insight size before records insert :'+insightList.size());
            Schema.SObjectField ftoken = Insight__c.Fields.External_Lead_ID__c;
            Database.UpsertResult[] srList = Database.upsert(insightList,ftoken,false);
            for(Integer index = 0; index < srList.size(); index++) {
                if(srList[index].isSuccess() && srList[index].isCreated()) {
                    insightExternalIdWithInsightIdMap.put(insightList[index].External_Lead_ID__c, insightList[index].Id);
                }
                else{
                    List<Database.Error> errors = srList[index].getErrors();
                    for(Database.Error error : errors) {
                        LOGGER.debug('AKI_GetInsightFromAkili:processInsights Error occured :'+insightList[index].External_Lead_ID__c+' : '+error.getMessage());
                    }
                }
            }
            
            if(!insightExternalIdWithInsightIdMap.isEmpty()){
                LOGGER.debug('AKI_GetInsightFromAkili:processInsights Insight size after records insert :'+insightExternalIdWithInsightIdMap.keyset().size());
                shareInsightWithProductSpeciallists(insightExternalIdWithInsightIdMap,insertSharedInsightList);
                createInsightClientRelationshipRecordsForContacts(insightExternalIdWithInsightIdMap,contactNudges);
            }
        }
        catch (Exception ex){
            LOGGER.error('AKI_GetInsightFromAkili:processInsights Exception logged : ',ex);
            throw new CustomException(ERROR_MSG_FAILED_INISIGHTS_CREATION);
        }
    }
    /**
    * @description preparing insight record with the details coming from the smartnudge
    * @param leadRecord 
    * @param clientCIFWithClientIdMap  
    * @return Insight__c
    */
    private static Insight__c prepareInsightRecord(AkiliInsightAPIDataWrap leadRecord,Map<String,id> clientCIFWithClientIdMap){
        Insight__c insRec = New Insight__c();
        insRec.External_Lead_ID__c = leadRecord.leadid;
        insRec.Client__c = clientCIFWithClientIdMap.get(leadRecord.customercif);
        if(String.isNotBlank(leadRecord.clientcoordinatorid)){
            insRec.Client_Coordinator__c= leadRecord.clientcoordinatorid;
        }
        if((leadRecord.persona != 'Client' || (leadRecord.persona == 'Client' && leadRecord.isclientdealer )) && String.isNotBlank(leadRecord.productspecialistid)) {
            insRec.OwnerId= leadRecord.productspecialistid;
        }
        
        if(String.isNotBlank(leadRecord.salesforceopportunityid)){
            insRec.Id= leadRecord.salesforceleadid;
        }
        insRec.Event_Date__c= date.valueOf(leadRecord.eventdate);
        insRec.Lead_Date__c= date.valueOf(leadRecord.leaddate);
        insRec.Expiry_Date__c= date.valueOf(leadRecord.expirydate);
        insRec.Category__c= leadRecord.category;
        insRec.Sub_Category__c= leadRecord.subcategory;
        insRec.Insight__c= leadRecord.insights;
        insRec.Next_Steps__c= leadRecord.nextbestaction;
        insRec.Is_Snoozed__c= leadRecord.issnoozed;
        insRec.Optimisation_Ranking__c = leadRecord.optimizationrank; //Added by Chandrasekhar - SFP-22526
        insRec.Persona__c = leadRecord.persona; //Added by Chandrasekhar - SFP-28741
        return insRec;
    }
    
    /**
    * @description wrapper class to hold list of records return by akili engine
    *     
    */
    public class AkiliInsightAPIDataList{
        /**
    * @description leads
    */
        public AkiliInsightAPIDataWrap[] leads;
    }
    /**
    * @description wrapper class to hold record return by akili engine
    *     
    */
    public class AkiliInsightAPIDataWrap {
        /***
        * @description leadid
        * **/
        public String leadid {get; set;}
        /***
        * @description customercif
        * **/
        public String customercif {get; set;}
        /***
        * @description clientcoordinatorid
        * **/
        public String clientcoordinatorid {get; set;}
        /***
        * @description productspecialistid
        * **/
        public String productspecialistid {get; set;}
        /***
        * @description salesforceopportunityid
        * **/
        public String salesforceopportunityid {get; set;}
        /***
        * @description salesforceleadid
        * **/
        public String salesforceleadid {get; set;}	
        /***
        * @description eventdate
        * **/
        public String eventdate {get; set;}	
        /***
        * @description leaddate
        * **/
        public String leaddate {get; set;}	
        /***
        * @description expirydate
        * **/
        public String expirydate {get; set;}
        /***
        * @description opportunitycreatedtimestamp
        * **/
        public String opportunitycreatedtimestamp {get; set;}
        /***
        * @description visibility
        * **/
        public String visibility {get; set;}
        /***
        * @description category
        * **/
        public String category {get; set;}
        /***
        * @description subcategory
        * **/
        public String subcategory {get; set;}
        /***
        * @description insights
        * **/
        public String insights {get; set;}
        /***
        * @description nextbestaction
        * **/
        public String nextbestaction {get; set;}
        /***
        * @description insightstatus
        * **/
        public String insightstatus {get; set;}	
        /***
        * @description insightquality
        * **/
        public String insightquality {get; set;}
        /***
        * @description insightcreatedbyid
        * **/
        public String insightcreatedbyid {get; set;}
        /***
        * @description insightcreatedtimestamp
        * **/
        public String insightcreatedtimestamp {get; set;}
        /***
        * @description issnoozed
        * **/
        public boolean issnoozed {get; set;}
        /***
        * @description isexpired
        * **/
        public string isexpired {get; set;}
        /***
        * @description lastupdatedtimestamp
        * **/
        public String lastupdatedtimestamp {get; set;}
        /***
        * @description full_count
        * **/
        public Integer full_count {get; set;}
        /***
        * @description optimisationrank
        * **/
        public Decimal optimizationrank {get;set;} //Added by Chandrasekhar - SFP-22526
        /***
        * @description persona
        * **/
        public String persona {get;set;} //Added by Chandrasekhar - SFP-28741
        /***
        * @description isclientdealer
        * **/
        public Boolean isclientdealer {get;set;} //Added by Chandrasekhar - SFP-28741                
    }
    
    /******************
    * @description Instantiating the sharing record 
    * @param leadId 
    * @param userId
    * @return sObject
    * ****************/
    private Static sObject prepareShareRecord(String leadId,String userId){
        sObject shareRecord = new Insight__Share();
        shareRecord.put('ParentId', leadId);
        shareRecord.put('AccessLevel','Edit');
        shareRecord.put('UserOrGroupId',userId);
        shareRecord.put('RowCause','Client_Analyst_Sharing__c');
        LOGGER.debug('AKI_GetInsightFromAkili:prepareShareRecord Sharing nudge to the user :'+shareRecord);
        return shareRecord;
    }
    
    /************
    * @description creating insight client relationship records for contact nudges
    * @param insertedLeadIdWithInsightIdMap
    * @param contactNudges
    * ************/
    private Static void createInsightClientRelationshipRecordsForContacts(Map<String,String> insertedLeadIdWithInsightIdMap,List<AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap> contactNudges){
        LOGGER.info('AKI_GetInsightFromAkili:createInsightClientRelationshipRecordsForContacts initiated');
        try{
            List<Insight_Client_Relationship__c> insertInsightClientRelationshipRecords = new List<Insight_Client_Relationship__c>();
            for(AKI_GetInsightFromAkili.AkiliInsightAPIDataWrap nudgeRecord : contactNudges){
                if(insertedLeadIdWithInsightIdMap.containsKey(nudgeRecord.leadid)){
                    
                    Insight_Client_Relationship__c insightClientRelationship = new Insight_Client_Relationship__c();
                    insightClientRelationship.Contact__c = nudgeRecord.productspecialistid;
                    insightClientRelationship.Insight__c = insertedLeadIdWithInsightIdMap.get(nudgeRecord.leadid);
                    insertInsightClientRelationshipRecords.add(insightClientRelationship);
                }
            }
            if(!insertInsightClientRelationshipRecords.isEmpty()){
                LOGGER.debug('AKI_GetInsightFromAkili:createInsightClientRelationshipRecordsForContacts InsightClientRelationship records size before insert :'+insertInsightClientRelationshipRecords.size());
                List<Database.SaveResult> saveResults = Database.insert(insertInsightClientRelationshipRecords, false);
                for (Integer i = 0; i < saveResults.size() ; i++) {
                    if (!saveResults[i].isSuccess()) {
                        List<Database.Error> errors = saveResults[i].getErrors();
                        for(Database.Error error : errors) {
                            LOGGER.error('AKI_GetInsightFromAkili:createInsightClientRelationshipRecordsForContacts Error occured while creating Insight Client Relationship :'+insertInsightClientRelationshipRecords[i].Contact__c +' : '+insertInsightClientRelationshipRecords[i].Insight__c+' : '+error.getMessage());  
                        }
                    }
                }                
            }
        }
        catch (Exception ex){
            LOGGER.error('AKI_GetInsightFromAkili:createInsightClientRelationshipRecordsForContacts Exception logged : ',ex);
        }
    }
    
    /************
    * @description Sharing created insight with the ProductSpecialists 
    * @param insightExternalIdWithInsightIdMap
    * @param insertSharedInsightList
    * ************/
    private Static void shareInsightWithProductSpeciallists(Map<String,String> insightExternalIdWithInsightIdMap,List<sobject> insertSharedInsightList){
        LOGGER.info('AKI_GetInsightFromAkili:shareInsightWithProductSpeciallists initiated');
        try{
            List<Insight__share> insertSharedInsights = new List<Insight__share>();
            for(sObject shareRecord : insertSharedInsightList){
                if(insightExternalIdWithInsightIdMap.containsKey(String.valueOf(shareRecord.get('ParentId')))){
                    Insight__share insightShre = new Insight__share();
                    insightShre.UserOrGroupId = String.valueOf(shareRecord.get('UserOrGroupId'));
                    insightShre.ParentId = insightExternalIdWithInsightIdMap.get(String.valueOf(shareRecord.get('ParentId')));
                    insightShre.AccessLevel = String.valueOf(shareRecord.get('AccessLevel'));
                    insightShre.RowCause = String.valueOf(shareRecord.get('RowCause'));
                    insertSharedInsights.add(insightShre);
                }
            }
            if(!insertSharedInsights.isEmpty()){
                LOGGER.debug('AKI_GetInsightFromAkili:shareInsightWithProductSpeciallists Insight Share size :'+insertSharedInsights.size());
                List<Database.SaveResult> saveResults = Database.insert(insertSharedInsights, false);
                for (Integer i = 0; i < saveResults.size() ; i++) {
                    if (!saveResults[i].isSuccess()) {
                        List<Database.Error> errors = saveResults[i].getErrors();
                        for(Database.Error error : errors) {
                            LOGGER.error('AKI_GetInsightFromAkili:shareInsightWithProductSpeciallists Error occured while sharing nudge :'+insertSharedInsights[i].ParentId+' with the user :'+insertSharedInsights[i].UserOrGroupId);  
                        }
                    }
                }
            }
        }catch (Exception ex){
            LOGGER.error('AKI_GetInsightFromAkili:shareInsightWithProductSpeciallists Exception logged : ',ex);
        }
    }
    
    /*******
    * @description custom exception class
    ******/ 
    private class CustomException extends Exception {}

}