/****************************************************************
* @description Controller class for sending client data to GoldTier via HTTP requests in JSON FORMAT
* @author Khushmeet Kaur
* @Test class OMF_API_OnboardMyFundServiceJSONTest
* **************************************************************
* @description added a new invocable method to be called from screen flow to resend the request
* @author Raja Kumar(raja.kumar@standardbank.co.za)
* @date Jan 2024
*/
@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')//due to complex requirement to craete the payload we had to use nested ifs and thats why suppressed the PMD here.
public without sharing class OMF_API_OnboardMyFundServiceJSON extends CMN_API_HttpBase{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_API_OnboardMyFundServiceJSON');
    private Id clientId;
    private Id managedFundId;
    private Map<String, List<SFDCToJSONStructure__c>> mapNodesByParent;
    private List<SFDCToJSONStructure__c> xmlNodes;
    private SObjectWrapper clientData;
    private Map<String, String> mapContext;
    private Map<String, Set<String>> mapFieldsByObject;
    private String requestBody,
        requestCode;
    
    /**
* @description Extends exception class
*/
    //Custom exception
    public class OMF_API_OnboardMyFundServiceJSONException extends Exception{}
    
    /**
* @description Constructor taking as a parameter identifier of client that should be sent to GoldTier/DataPower for onboarding
* @param clientId
* @param managedFundId
* @param requestCode
*/
    public OMF_API_OnboardMyFundServiceJSON(String clientId,String managedFundId, String requestCode) {
        this.clientId = clientId; 
        this.requestCode = requestCode;
        this.managedFundId=managedFundId;
        User[] listCurrentUser = new SEL_Users().selectByUserId(UserInfo.getUserId());
        User currentUser;
        if(listCurrentUser.size()>0){
            currentUser = listCurrentUser[0];
        }
        mapContext = new Map<String, String>();
        mapContext.put('User.EmployeeNumber', currentUser.EmployeeNumber);
    }
    /**
* @description invocableMethod to be called from flow to resend the request.
* @param lstManagedFundIds
* @author Raja Kumar(raja.kumar@standardbank.co.za)
*/
    @InvocableMethod(label='reInitiate KYC' description='Send KYC detials to GoldTier and pass list of managed fund ids' category= 'Managed Fund Onboarding')
    public static void reInitiateKyc(List<Id> lstManagedFundIds){
        if(!lstManagedFundIds.isEmpty() ){
            String managedFundId = lstManagedFundIds[0];
            list<OMF_ManagedFund__c> omfRecordList= new SEL_OMF_ManagedFunds().selectedByRecordId(managedFundId);
            String fundRecordId  =omfRecordList[0].Fund__c;
            OMF_API_OnboardMyFundServiceJSON service = new OMF_API_OnboardMyFundServiceJSON(fundRecordId,managedFundId,'SA');
            service.sendRequest();
        }
    }
    
    /**
* @description send request to the gold tier
*/
    public void sendRequest(){
        HttpRequest req = getClientDataRequest();
        if(req!=null){
            Http http = new Http();
            try{
                HTTPResponse res = http.send(req);
                getOnboardingResponse(res);
            }
            catch(CalloutException ex){ 
                callPlatformEventForUpdate();
                throw new OMF_API_OnboardMyFundServiceJSONException(Label.Onboarding_Callout_Failure);
            }
            catch(Exception ex){
                callPlatformEventForUpdate();
                throw new OMF_API_OnboardMyFundServiceJSONException(Label.Onboarding_Callout_Failure);
            }
        }
    }
    /** @description platform event to update field and send email when exception is thrown*/
    private void callPlatformEventForUpdate(){
        OMF_ManagedFundRecordUpdate__e asyncDmlForOMF = new OMF_ManagedFundRecordUpdate__e();
        asyncDmlForOMF.ManagedFundRecordId__c = managedFundId;
        asyncDmlForOMF.NewOnboardingStatus__c = 'KYC Submission Failed';
        EventBus.publish(asyncDmlForOMF);
    }
    /** @description Funcation used by platform event to send notification and update field
* @param managedFundRecId
*/
    public static void handleKYCAPIFailureNotification(Id managedFundRecId){
        OMF_ManagedFund__c[] listManagedFundRecord = new SEL_OMF_ManagedFunds().selectedByRecordId(managedFundRecId);
        if(listManagedFundRecord != null && !listManagedFundRecord.isEmpty()){
            OMF_ManagedFund__c fundToUpdate = new OMF_ManagedFund__c
                (Id = listManagedFundRecord[0].Id, 
                 Onboarding_Status__c= 'KYC Submission Failed');
            Database.update(fundToUpdate);
            
            EmailTemplate[] listEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName('OMF_KYCAPISubmissionFailureNotification');
            EmailTemplate objEmailTemplate;
            if(listEmailTemplate.size()>0){
                objEmailTemplate = listEmailTemplate[0];
            }
            
            //send email
            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(objEmailTemplate.Id, listManagedFundRecord[0].CreatedById, listManagedFundRecord[0].Id);
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setTargetObjectId(listManagedFundRecord[0].CreatedById);
            singleEmail.setSaveAsActivity(false); // Optional: Set to true if you want to save the email as an activity in Salesforce
            singleEmail.setSubject(message.getSubject());
            singleEmail.setPlainTextBody(message.getPlainTextBody());
            singleEmail.setHtmlBody(message.getHtmlBody());
            if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ singleEmail });
            }else {
                LOGGER.INFO('Email limit exceeded, cannot send email at this time.');
            }
            //insert chatter Post
            FeedItem objFeedItem = new FeedItem();
            objFeedItem.ParentId = listManagedFundRecord[0].Id;
            objFeedItem.Body = message.getPlainTextBody();
            try {
                Database.insert(objFeedItem,false);
            } catch (DmlException e) {
                LOGGER.error('An error occured while inserting the FeedItem record:',e);
            }
            
        }
    }
    
    private OnboardingResponse getOnboardingResponse(HttpResponse res){
        OnboardingResponse onboardingResponse  = new OnboardingResponse();
        if(res!=null){
            String responseJson = res.getBody();
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
            String salesforceId = (String)jsonMap.get('salesforce_id');
            Map<String, Object> requestStatusCode = (Map<String, Object>) jsonMap.get('RequestStatusCode');
            String success = (String) requestStatusCode.get('Success');
            onboardingResponse.success = Boolean.valueOf(success);
            if(success == 'false'){
                String errorMessage = (String) requestStatusCode.get('ErrorMessage');
                if(String.isNotBlank(errorMessage)){
                    onboardingResponse.errorMessage = errorMessage;
                    updateErrorRecord(salesforceId,errorMessage);
                }
            }
            else {
                updateSuccessRecord(salesforceId);
            }
            return onboardingResponse;
        }
        return onboardingResponse;
    }
    
    private void updateErrorRecord(String salesforceId,String errorMessage){
        OMF_ManagedFund__c objManagedFundRecord = new OMF_ManagedFund__c();
        objManagedFundRecord.Id = managedFundId;
        objManagedFundRecord.RejectionReason__c = errorMessage;
        try {
            database.update(objManagedFundRecord,false);
        } catch (DmlException e) {
            LOGGER.error('An error occured while updating the record:',e);
        }
    }
    
    private void updateSuccessRecord(String salesforceId){
        OMF_ManagedFund__c objManagedFundRecord = new OMF_ManagedFund__c();
        objManagedFundRecord.Id = managedFundId;
        objManagedFundRecord.Onboarding_Status__c = 'KYC';
        objManagedFundRecord.RejectionReason__c = '';
        objManagedFundRecord.RejectionDetails__c='';
        try {
            database.update(objManagedFundRecord,false);
        } catch (DmlException e) {
            LOGGER.error('An error occured while updating the record:',e);
        }
        EmailTemplate objEmailTemplate;
        List<OMFSetting__mdt> omfSetting = OMFSetting__mdt.getAll().values();
        
        EmailTemplate[] listEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName('Managed_Fund_KYC_Onboarding_Request');
        if(listEmailTemplate.size()>0){
            objEmailTemplate = listEmailTemplate[0];
        }
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setToAddresses(omfSetting.size() > 0 ? new String[] {omfSetting[0].KYCEmailAddress__c} : new String[] {});
        
        singleEmail.setTemplateId(objEmailTemplate.Id);
        singleEmail.setTargetObjectId(UserInfo.getUserId());
        singleEmail.setWhatId(managedFundId);
        singleEmail.setSaveAsActivity(false);
        if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ singleEmail });
        }else {
            LOGGER.INFO('Email limit exceeded, cannot send email at this time.');
        }
        
        sendKYCEmailDocuments(objManagedFundRecord.Id);
        sendCreditEmailDocument(objManagedFundRecord.Id);
    }
    
    
    //Method constructs HTTP request to be sent to GoldTier/DataPower
    private HttpRequest getClientDataRequest(){
        String requestBody = getRequestBody();
        LOGGER.debug('requestBody'+requestBody);
        HttpRequest req;
        if(!String.isEmpty(requestBody) && requestCode!=null){
            String endpoint = 'callout:OMF_KYC_GOLDTIER';
            req =  (new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,endpoint, requestBody)).getHttpRequest();
            req.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        }
        return req;
    }
    
    /**
* @description create the request body
* @return String as the prepared as the requets body
*/
    public String getRequestBody(){
        if(requestBody==null){	
            List<OMF_ManagedFund__c> lstManagedFunds = new SEL_OMF_ManagedFunds().selectManagedFundRecordWithAssetManagerDetails(clientId,managedFundId);
            
            AdditionalData additionalData = new AdditionalData();
            additionalData.listManagedFund = lstManagedFunds;
            
            if(!lstManagedFunds.isEmpty() && String.isNotBlank(lstManagedFunds[0].AssetManager__c)){
                additionalData.clientCoordinatorDivision = lstManagedFunds[0].AssetManager__r.Owner.Division;
                additionalData.clientCoordinatorName = lstManagedFunds[0].AssetManager__r.Owner.Name;
                additionalData.clientCoordinatorEmail = lstManagedFunds[0].AssetManager__r.Owner.Email;
                
                User objUser = new User();
                objUser.FirstName = lstManagedFunds[0].AssetManager__r.CreatedBy.FirstName;
                objUser.LastName = lstManagedFunds[0].AssetManager__r.CreatedBy.LastName;
                objUser.Phone = lstManagedFunds[0].AssetManager__r.CreatedBy.Phone;
                objUser.Email = lstManagedFunds[0].AssetManager__r.CreatedBy.Email;
                objUser.Title = lstManagedFunds[0].AssetManager__r.CreatedBy.Title;
                additionalData.internalContact = objUser;
                List<Contact> lstCustContacts = SEL_Contacts.newInstance().selectByClientId(new Set<Id>{lstManagedFunds[0].AssetManager__c});
                additionalData.lstCustContacts = lstCustContacts;
            }
            
            List<SFDCToJSONStructure__c>  rootNodes = getMapNodesByParent().get(null);
            SObjectWrapper client = getClientData();
            if(client!=null && client.getRecord()!=null && rootNodes!=null && !rootNodes.isEmpty()){
                SFDCToJSONStructure__c  rootNode = rootNodes[0];	
                List<SFDCToJSONStructure__c> childNodes = getMapNodesByParent().get(rootNode.Field_Name__c);
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                addChildElements(gen, childNodes, client,additionalData);
                gen.writeEndObject();
                requestBody = gen.getAsString();
            }
        }
        return requestBody;
    }
    
    //Recuring method that generates request payload based on request definition and actual client data
    @SuppressWarnings('PMD.ExcessiveParameterList,NcssMethodCount,CyclomaticComplexity')//suppressed this as we can't avoid having more parameters for this function and due to complexity of logic to get data we need to supress this warnings.
    private void addChildElements(JSONGenerator gen, List<SFDCToJSONStructure__c> childNodes, SObjectWrapper sObjWrapper,AdditionalData additionalData){
        
        if(childNodes!=null){
            for(SFDCToJSONStructure__c childNode:childNodes){
                if(childNode.Node_Name__c == 'request_type'){
                    String requestType;
                    if(String.isBlank(additionalData.listManagedFund[0].Fund__r.CIF__c)){
                        for(OMF_ManagedFund__c objManagedFund : additionalData.listManagedFund){
                            if(objManagedFund.Onboarding_Status__c == 'KYC' || objManagedFund.Onboarding_Status__c == 'Document Upload' || objManagedFund.Onboarding_Status__c == 'KYC Submission Failed'){
                                requestType = 'New Managed Fund';
                                break;  
                            }
                        }  
                    } 
                    else{
                        requestType = 'Update Managed Fund';
                    }
                    if(!String.isBlank(additionalData.listManagedFund[0].RejectionReason__c)){
                        if(additionalData.listManagedFund[0].RejectionReason__c.contains('was not found in Goldtier')){
                            requestType = 'New Managed Fund';
                        }
                        if(additionalData.listManagedFund[0].RejectionReason__c.contains('already exists in Goldtier')){
                            requestType = 'Update Managed Fund';
                        }
                    }
                    
                    gen.writeStringField(childNode.Node_Name__c, requestType);
                }
                else if(childNode.Node_Item_Name__c == null){
                    String nodeValue  = childNode.Default_Value__c;
                    String defaultValue = childNode.Default_Value__c;
                    if(childNode.Field_Name__c!=null){
                        List<String> splittedFieldName = childNode.Field_Name__c.split('\\.');
                        SObject sobj = sObjWrapper.getRecord();
                        for(Integer i=0; i<splittedFieldName.size()-1; i++){
                            sobj = sobj.getSObject(splittedFieldName[i]);
                        }
                        nodeValue = (String)sobj.get(splittedFieldName[splittedFieldName.size()-1]);
                    }
                    
                    // Updated by Naveen for Handling Default Value on 01/11/2022
                    if(String.isBlank(nodeValue)){
                        nodeValue = defaultValue;
                    }
                    nodeValue= (String.isBlank(nodeValue)) ?'':nodeValue;
                    gen.writeStringField(childNode.Node_Name__c, nodeValue);
                }
            }
            gen.writeFieldName('party_requirements');
            gen.writeStartObject();
            
            for(SFDCToJSONStructure__c childNode:childNodes){
                if(childNode.Node_Item_Name__c == 'party_requirements'){
                    if(childNode.Node_Name__c =='Client_Coordinator_Name__c'){
                        if(additionalData != null && String.isNotBlank(additionalData.clientCoordinatorName)){
                            gen.writeStringField(childNode.Node_Name__c,additionalData.clientCoordinatorName);
                        }
                        else{
                            gen.writeNullField(childNode.Node_Name__c);
                        }
                    }
                    else if(childNode.Node_Name__c =='Client_Coordinator_Division__c'){
                        
                        if(additionalData != null && String.isNotBlank(additionalData.clientCoordinatorDivision)){
                            gen.writeStringField(childNode.Node_Name__c,additionalData.clientCoordinatorDivision);
                        }
                        else{
                            gen.writeStringField(childNode.Node_Name__c,'');
                        }
                    }
                    else if(childNode.Node_Name__c =='Client_Coordinator_Email__c'){
                        
                        if(additionalData != null && String.isNotBlank(additionalData.clientCoordinatorEmail)){
                            gen.writeStringField(childNode.Node_Name__c,additionalData.clientCoordinatorEmail);
                        }
                        else{
                            gen.writeStringField(childNode.Node_Name__c,'');
                        }
                    }
                    else if(childNode.Node_Name__c =='Cust_Contacts'){
                        if(additionalData != null && additionalData.lstCustContacts != null){
                            //Method for preparing cust contacts data
                            getCustContactElements(gen, additionalData.lstCustContacts, childNode.Node_Name__c,childNode.Node_Item_Child_Name__c);
                        }
                    }
                    else if(childNode.Node_Name__c =='Internal_Contacts'){
                        if(additionalData != null && additionalData.internalContact != null){
                            getInternalContactElements(gen, additionalData.internalContact, childNode.Node_Name__c,childNode.Node_Item_Child_Name__c);
                        }
                    }
                    else if(childNode.Node_Name__c == 'Work_Request_Instruction'){
                        String notes = getNotes(childNode, sObjWrapper);
                        if(String.isNotBlank(notes)){
                            gen.writeStringField(childNode.Node_Item_Child_Name__c,notes);
                        }
                        else{
                            String noteString = 'Managed Fund - Add Investment Advisor CIFID '+ additionalData.listManagedFund[0].AssetManager__r.CIF__c;
                            gen.writeStringField(childNode.Node_Item_Child_Name__c,noteString);
                        }
                    }
                    else{
                        if(childNode.Node_Item_Child_Name__c!=null){
                            Sobject[] childRecords = sObjWrapper.getRelatedRecords().get(childNode.Field_Name__c);
                            if(childRecords!=null && childNode.Node_Name__c !='Cust_Contacts'){
                                for(SObject childRecord:childRecords){
                                    getProducts(gen,getMapNodesByParent().get(childNode.Field_Name__c), new SObjectWrapper(childRecord));
                                }
                            }
                        }
                        if(childNode.Node_Item_Child_Name__c == null){
                            String nodeValue  = childNode.Default_Value__c;
                            String defaultValue = childNode.Default_Value__c;
                            if(childNode.Field_Name__c!=null){
                                List<String> splittedFieldName = childNode.Field_Name__c.split('\\.');
                                SObject sobj = sObjWrapper.getRecord();
                                for(Integer i=0; i<splittedFieldName.size()-1; i++){
                                    sobj = sobj.getSObject(splittedFieldName[i]);
                                }
                                nodeValue = (String)sobj.get(splittedFieldName[splittedFieldName.size()-1]);
                                
                            }
                            
                            // Updated by Naveen for Handling Default Value on 01/11/2022
                            if(String.isBlank(nodeValue)){
                                nodeValue = defaultValue;
                            }
                            nodeValue= (String.isBlank(nodeValue)) ?'':nodeValue;
                            if(childNode.Data_Type__c == 'String'){
                                gen.writeStringField(childNode.Node_Name__c,nodeValue);
                            }
                            if(childNode.Data_Type__c == 'Number'){
                                gen.writeNumberField(childNode.Node_Name__c,0);
                            } 
                        }
                    }
                }
            }
            gen.writeEndObject();
        }
    }
    
    private List<SFDCToJSONStructure__c> getXMLNodes(){
        if(xmlNodes==null && requestCode!=null){
            xmlNodes = [SELECT 
                        Object_Name__c 
                        ,Field_Name__c
                        ,Node_Item_Name__c 
                        ,Node_Name__c ,
                        Node_Item_Child_Name__c
                        ,Default_Value__c,
                        Data_Type__c
                        ,Order__c 
                        FROM SFDCToJSONStructure__c 
                        WHERE Message_Code__c =: requestCode
                        ORDER BY Object_Name__c
                        , Order__c NULLS FIRST];
        }
        return xmlNodes;
    }
    
    private Map<String, List<SFDCToJSONStructure__c>> getMapNodesByParent(){
        if(mapNodesByParent==null){
            mapNodesByParent = new Map<String, List<SFDCToJSONStructure__c>>();
            for(SFDCToJSONStructure__c xmlNode:getXMLNodes()){
                List<SFDCToJSONStructure__c> childNodes = mapNodesByParent.get(xmlNode.Object_Name__c);
                if(childNodes==null){
                    childNodes = new List<SFDCToJSONStructure__c>();
                    mapNodesByParent.put(xmlNode.Object_Name__c, childNodes);
                }
                childNodes.add(xmlNode);
            }
        }
        return mapNodesByParent;
    }
    
    @TestVisible
    private SObjectWrapper getClientData(){
        
        if(clientData!=null || clientId==null){
            return clientData;
        }
        Map<String, Set<String>> mapFieldsByObject = getFieldsByObject();
        Set<String> clientFields = mapFieldsByObject.get('Account');
        Set<String> contactsFields = mapFieldsByObject.get('Contacts');
        if(clientFields!=null){
            if(contactsFields!=null){
                for(String contactField:contactsFields){
                    clientFields.add('KYC_Contact__r.'+contactField);
                }
            }
        }
        
        Account client = fetchData();
        clientData = new SObjectWrapper(client);
        clientData.getRelatedRecords().put('Products', new SObject[]{new Asset()});
        
        if(contactsFields!=null && clientData.getRecord()!=null && clientData.getRecord().getSObject('KYC_Contact__r')!=null){
            SObject[] clientContacts = clientData.getRelatedRecords().get('Contacts');
            
            if(clientContacts==null){
                clientContacts = new Contact[]{};
                    clientData.getRelatedRecords().put('Contacts', clientContacts);
            }
            
            clientContacts.add(clientData.getRecord().getSObject('KYC_Contact__r'));
            
        }
        return clientData;
        
    }
    
    // Method fetches data from database based on SOQL query, created in getSOQL method
    private Account fetchData(){
        
        String soql = getSOQL();
        Account client;
        Account[] clients;
        try{
            clients = Database.query(soql);
            if(!clients.isEmpty()){
                client = clients[0];
            }
        }catch(QueryException ex){
            LOGGER.debug('Eror occurred while fetching data'+ex.getMessage());
            throw new OMF_API_OnboardMyFundServiceJSONException(ex.getMessage());
        }
        return client;
    }
    
    //Method constructs SOQL query based on request structure definition custom settings
    private String getSOQL(){
        Map<String, Set<String>> mapFieldsByObject = getFieldsByObject();
        List<String> accountFields = new List<String>();
        String fields;
        for(String objectName:mapFieldsByObject.keySet()){
            List<String> fieldsList = new List<String>(mapFieldsByObject.get(objectName));
            if(objectName == 'Account'){
                fields=String.join(fieldsList, ',');
            }
            else{
                fields=String.format('(SELECT {0} FROM {1})', new List<String>{String.join(fieldsList,','),objectName});
            }
            accountFields.add(fields);
        }
        String soql = String.format('SELECT {0} FROM ACCOUNT WHERE ID =:clientId',new List<String>{String.join(accountFields,',')});
        return soql;
    }
    
    //Fields that are part of request definition are grouped by object
    private Map<String, Set<String>> getFieldsByObject(){
        if(mapFieldsByObject==null){
            mapFieldsByObject = new Map<String, Set<String>>();
            mapFieldsByObject.put('Account', new Set<String>{'Name', 'Id', 'Client_Co_ordinator__r.Name'});
            for(SFDCToJSONStructure__c xmlNode : getXMLNodes()){
                if(xmlNode.Object_Name__c!=null && xmlNode.Field_Name__c!=null && xmlNode.Node_Item_Child_Name__c==null){
                    Set<String> objectFields = mapFieldsByObject.get(xmlNode.Object_Name__c);
                    if(objectFields==null){ 
                        objectFields = new Set<String>();
                        mapFieldsByObject.put(xmlNode.Object_Name__c,objectFields);
                    }
                    objectFields.add(xmlNode.Field_Name__c);
                }
            }
        }
        return mapFieldsByObject;
    }
    /**
* @description Sobject wrapper class to store object and their related objects
*/
    public class SObjectWrapper{
        private SObject sobj;
        private Map<String,List<sObject>> mapRelatedObjects;
        
        /**
* @description getRecord
* @return SObject
*/
        public SObject getRecord(){
            return sobj;
        }
        /**
* @description Sobject wrapper class to store object and their related objects
* @param sobj
*/
        public SObjectWrapper(SObject sobj){
            this.sobj = sobj;
            DescribeSObjectResult objDescribe = sobj.getSObjectType().getDescribe();
            for(ChildRelationship relationShip:objDescribe.getChildRelationships()){
                String relationShipName = relationShip.getRelationshipName();
                if(sobj.getPopulatedFieldsAsMap().containsKey(relationShipName)){
                    SObject[] relatedObjects = sobj.getSObjects(relationShipName);
                    getRelatedRecords().put(relationShipName,relatedObjects);
                }
            }
        }
        /**
* @description Sobject wrapper class to store object and their related objects
* @return mapRelatedObjects
*/        
        public Map<String,List<sObject>> getRelatedRecords(){
            if(mapRelatedObjects==null){
                mapRelatedObjects = new Map<String,List<sObject>>();
            }
            return mapRelatedObjects;
        }
    }
    
    //Methods to retrieve all the data
    //Method prepares the Notes for Kyc Initiation from Managed Fund Records, Added by Naveen on 31/10/2022
    @TestVisible private String getNotes(SFDCToJSONStructure__c childNode, SObjectWrapper sObjWrapper){
        Sobject[] childRecords = sObjWrapper.getRelatedRecords().get(childNode.Field_Name__c);		
        if(childRecords!=null){	
            List<String> lstNotes = new List<String>();						
            for(SObject childRecord:childRecords){
                List<SFDCToJSONStructure__c> grandChildNodes = getMapNodesByParent().get(childNode.Field_Name__c);
                if(!grandChildNodes.isEmpty()){
                    String gChildFieldName = grandChildNodes[0].Field_Name__c;
                    if(childRecord.get(gChildFieldName) != NULL){
                        lstNotes.add(String.valueOf(childRecord.get(gChildFieldName)));
                    }	
                }				
            }
            if(!lstNotes.isEmpty()){
                return String.join(lstNotes, ',');
            }
        }		
        return null;
    }
    
    @TestVisible private JSONGenerator getProducts(JSONGenerator gen,List<SFDCToJSONStructure__c> childNodes, SObjectWrapper sObjWrapper){
        gen.writeFieldName('Products');
        gen.writeStartObject();
        
        gen.writeFieldName('Product');
        gen.writeStartObject();
        
        for(SFDCToJSONStructure__c childNode:childNodes){
            if(childNode.Node_Item_Name__c != null){
                String nodeValue  = childNode.Default_Value__c;
                String defaultValue = childNode.Default_Value__c;
                if(childNode.Field_Name__c!=null){
                    List<String> splittedFieldName = childNode.Field_Name__c.split('\\.');
                    SObject sobj = sObjWrapper.getRecord();
                    for(Integer i=0; i<splittedFieldName.size()-1; i++){
                        sobj = sobj.getSObject(splittedFieldName[i]);
                    }
                    nodeValue = (String)sobj.get(splittedFieldName[splittedFieldName.size()-1]);
                }
                
                // Updated by Naveen for Handling Default Value on 01/11/2022
                if(String.isBlank(nodeValue)){
                    nodeValue = defaultValue;
                }
                nodeValue= (String.isBlank(nodeValue)) ?'':nodeValue;
                gen.writeStringField(childNode.Node_Name__c, nodeValue);
            }
        }
        gen.writeEndObject();
        gen.writeEndObject();
        return gen;
    }
    
    // Method prepares the related contacts such as cust contact elements 
    @SuppressWarnings('PMD.ExcessiveParameterList')//suppressed this as we can't avoid having more parameters for this function
    @TestVisible private JSONGenerator getCustContactElements(JSONGenerator gen, List<Contact> lstRelatedContacts, String childNode,String childItemNode){ 
        
        gen.writeFieldName(childNode);
        gen.writeStartObject();
        
        Map<String,String> mapRelatedContacts = new Map<String,String>{
            'First_Name' => 'FirstName',
                'Designation'=>'Contact_Category__c',
                'Email' => 'Email',    
                'Phone_Country'=>'Phone_Country__c',
                'Phone_Num' => 'Phone',
                'Initials' => 'Initials__c',
                'Last_Name' => 'LastName'
                };
                    if(lstRelatedContacts != null && !lstRelatedContacts.isEmpty()){
                        for(Contact objContact :lstRelatedContacts){
                            gen.writeFieldName(childItemNode);
                            gen.writeStartObject();
                            for(String node : mapRelatedContacts.keySet()){
                                if(objContact.get(mapRelatedContacts.get(node)) != null){
                                    gen.writeObjectField(node, String.valueOf(objContact.get(mapRelatedContacts.get(node))));
                                }
                                else{
                                    gen.writeObjectField(node,'');
                                }
                            }
                            gen.writeEndObject();
                        }
                    }
        
        gen.writeEndObject();
        return gen;
    }
    @SuppressWarnings('PMD.ExcessiveParameterList')//suppressed this as we can't avoid having more parameters for this function
    @TestVisible private JSONGenerator getInternalContactElements(JSONGenerator gen, User objUser,String childNode,String childItemNode){ 
        gen.writeFieldName(childNode);
        gen.writeStartObject();
        
        gen.writeFieldName(childItemNode);
        gen.writeStartObject();
        
        Map<String,String> mapInternalContacts = new Map<String,String>{
            'First_Name' => 'FirstName',
                'Designation'=>'Title',
                'Email' => 'Email',  
                'Phone_Num' => 'Phone',
                'Last_Name' => 'LastName'
                };
                    if(objUser != null){	
                        for(String node : mapInternalContacts.keySet()){
                            if(String.isNotBlank(mapInternalContacts.get(node)) && objUser.get(mapInternalContacts.get(node)) != null){
                                gen.writeObjectField(node, String.valueOf(objUser.get(mapInternalContacts.get(node))));
                            }
                            else{
                                gen.writeObjectField(node,'');
                            }
                        }
                    }
        gen.writeEndObject();
        gen.writeEndObject();
        return gen;
    }
    /**
* @description Represents structure of response for HTTP onboarding request 
*/
    public class OnboardingResponse{
        public String operation;
        public Boolean success;
        public String errorMessage;
    }
    /**
* @description description This class represents additional data related to a customer.
*/
    public class AdditionalData{
        public List<Contact> lstCustContacts;
        public User internalContact;
        public String clientCoordinatorName;
        public String clientCoordinatorDivision;
        public String clientCoordinatorEmail;
        public List<OMF_ManagedFund__c>listManagedFund;
    }
    
    private static void sendKYCEmailDocuments(String managedFundRecordId){
        KYC_Status__c[] objKYCStatus = new SEL_KYCStatuses().selectKYCStatusByManagedFund(managedFundRecordId);
        list<KYC_Required_Documents__c>listKycRequiredDocument = new list<KYC_Required_Documents__c>();
        
        list<Id>setContentDocumentId = new list<Id>();
        List<String>listKycDocument = new list<String>();
        listKycDocument.add('Shared Client Certificate');
        listKycDocument.add('Proof of Fund Registration');
        listKycDocument.add('Supplemental Deed');
        
        if(objKYCStatus.size()>0){
            //Get kyc required document
            listKycRequiredDocument = new SEL_KYCRequiredDocuments().selectByKYCRequiredDocumentWithReceivedDocument(objKYCStatus[0].Id,listKycDocument);
            
        }
        set<id>setKycDocumentsId = new set<id>();
        if(listKycRequiredDocument.size()>0){
            for(KYC_Required_Documents__c objKYCRequiredDocument : listKycRequiredDocument){
                setKycDocumentsId.add(objKYCRequiredDocument.Id);
            }
        }
        if(setKycDocumentsId.size()>0){
            for(ContentDocumentLink objContentDocumentLink :new SEL_ContentDocumentLink().selectByLinkedEntityIdAllFields(setKycDocumentsId)){
                setContentDocumentId.add(objContentDocumentLink.ContentDocumentId);
            }
        }
        if(setContentDocumentId.size()>0){
            OMF_SendKYCDocuments.sendEmailWithAttachments(setContentDocumentId,managedFundRecordId,'KYC');
        }
        
    }
    
    private static void sendCreditEmailDocument(String managedFundRecordId){
        KYC_Status__c[] objKYCStatus = new SEL_KYCStatuses().selectKYCStatusByManagedFund(managedFundRecordId);
        list<KYC_Required_Documents__c>listKycRequiredDocument = new list<KYC_Required_Documents__c>();
        
        list<Id>setContentDocumentId = new list<Id>();
        List<String>listKycDocument = new list<String>();
        listKycDocument.add('Fund Fact Sheet');
        
        if(objKYCStatus.size()>0){
            //Get kyc required document
            listKycRequiredDocument = new SEL_KYCRequiredDocuments().selectByKYCRequiredDocumentWithReceivedDocument(objKYCStatus[0].Id,listKycDocument);
        }
        set<id>setCreditDocumentId = new set<id>();
        if(listKycRequiredDocument.size()>0){
            for(KYC_Required_Documents__c objKYCRequiredDocument : listKycRequiredDocument){
                setCreditDocumentId.add(objKYCRequiredDocument.Id);
            }
        }
        if(setCreditDocumentId.size()>0){
            for(ContentDocumentLink objContentDocumentLink :new SEL_ContentDocumentLink().selectByLinkedEntityIdAllFields(setCreditDocumentId)){
                setContentDocumentId.add(objContentDocumentLink.ContentDocumentId);
            }
        }
        if(setContentDocumentId.size()>0){
            OMF_SendKYCDocuments.sendEmailWithAttachments(setContentDocumentId,managedFundRecordId,'Credit');
        }
        
    }
}