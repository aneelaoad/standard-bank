/*************************************************************************
    @ Author        : Jakub Oracki
    @ Date          : Feb 2017
    @ Description   : Controller class for sending client data to GoldTier via HTTP requests
    @ Enhancement   : US-1189
 *************************************************************************/

public with sharing class OnboardingService {
	
	private Id clientId;
	private String endpointPrefix = 'callout:GoldTier_';
	//private String clientCertName = 'Certificate_for_GoldTier';
	private Map<String, String> mapContext;
	private SObjectWrapper clientData;
	private Map<String, Set<String>> mapFieldsByObject;
	private Map<String, List<SFDC2GT_Xml_Stucture__c>> mapNodesByParent;
	private List<SFDC2GT_Xml_Stucture__c> xmlNodes;
	private String 	requestBody,
					requestCode;
	public static final String CRM_HELPDESK_PARAMETER_NAME = 'CRMHelpdeskEmail';

	//Custom exception
	public class OnboardingServiceException extends Exception{}

	//Constructor taking as a parameter identifier of client that should be sent to GoldTier/DataPower for onboarding
	public OnboardingService(Id clientId, String requestCode) {
		this.clientId = clientId; 
		this.requestCode = requestCode;

		User currentUser = [SELECT EmployeeNumber FROM User WHERE Id =: UserInfo.getUserId()];

		mapContext = new Map<String, String>();
		mapContext.put('User.EmployeeNumber', currentUser.EmployeeNumber);

	}

	//Method handle exeptional data structure adjustments
	@TestVisible
	private SObjectWrapper getClientData(){
		
		if(clientData!=null || clientId==null)
			return clientData;

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

	//Method  sends HTTP request to DataPower endpoint
	public void sendClientsData(){
		HttpRequest req = getClientDataRequest();
		if(req!=null){
		
			Http http = new Http();
			System.debug('>>> OnboardingService request: '+req.getBody());
			try{
     			HTTPResponse res = http.send(req);
     			
	     		if(res.getStatusCode()<200 || res.getStatusCode()>299) 
	     		{
	                String error = String.format(Label.HTTP_Request_Failed, new List<String>{String.valueOf(res.getStatusCode()),res.getStatus(), res.getBody()});

	                throw new OnboardingServiceException(error);
	            }

	            OnboardingResponse onboardingRes = getOnboardingResponse(res);
	            if(onboardingRes!=null)
	            {	
	            	if(!onboardingRes.success)
	            	{
	            		throw new OnboardingServiceException(onboardingRes.errorMessage);
	            	}
            	}else
            	{
            		throw new OnboardingServiceException(Label.Bad_Response_Structure);
            	}

     		}
     		catch(CalloutException ex){
     			sendCalloutExceptionEmail();
     			throw new OnboardingServiceException(Label.Onboarding_Callout_Failure);
     		}
            catch(Exception ex){
     			sendCalloutExceptionEmail();
     			throw new OnboardingServiceException(Label.Onboarding_Callout_Failure);
     		}
     	}
	}

	@testVisible private void sendCalloutExceptionEmail(){
		SB_Parameters__c crmHelpdeskEmail = SB_Parameters__c.getValues(CRM_HELPDESK_PARAMETER_NAME);
		String toAddress;
		if(crmHelpdeskEmail!=null)
			toAddress = crmHelpdeskEmail.Value__c;

		
		Messaging.SingleEmailMessage email;

		if(getClientData()!=null && getClientData().getRecord()!=null && !String.isEmpty(toAddress)){
			Account client = (Account)getClientData().getRecord();
			EmailTemplate[] emailTemplates = [SELECT Subject, Body 
											FROM EmailTemplate 
											WHERE DeveloperName = 'Onboarding_Request_Exception_Notification'];
			if(!emailTemplates.isEmpty()){
				email = new Messaging.SingleEmailMessage();

				EmailTemplate emailTemplate = emailTemplates[0];

				List<String> bodyMergeFields = new List<String>();
				
				bodyMergeFields.add(client.Name);
				bodyMergeFields.add(client.Id);
				bodyMergeFields.add(UserInfo.getName());
				bodyMergeFields.add(client.Client_Co_ordinator__r.Name);

				String emailBody = String.format(emailTemplate.Body, bodyMergeFields);

				String subject = String.format(emailTemplate.Subject, new List<String>{client.Name});

		        email.setSubject(subject);
		        email.setPlainTextBody(emailBody);
		        email.setToAddresses(new String[]{toAddress});

		        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		    }
	    }
	}

	//Method parses body of HTTP response returned from GoldTier
	private OnboardingResponse getOnboardingResponse(HttpResponse res){
		OnboardingResponse onboardingResponse;
		if(res!=null){
			Dom.Document dom = new Dom.Document();
			dom.load(res.getBody());
			Dom.XMLNode root = dom.getRootElement();
			
			if(root!=null)
			{

				Dom.XMLNode successElem = root.getChildElement('Success',null);
				
				if(successElem!=null)
				{
					onboardingResponse = new OnboardingResponse();
					onboardingResponse.success = Boolean.valueOf(successElem.getText());

					if(!onboardingResponse.success){
						Dom.XMLNode errorMessageElem = root.getChildElement('ErrorMessage',null);
						if(errorMessageElem!=null)
							onboardingResponse.errorMessage = errorMessageElem.getText();
					}
				}
			}

			return onboardingResponse;
		}

		return onboardingResponse;
	}

	// Method fetches data from database based on SOQL query, created in getSOQL method
	private Account fetchData(){
		
		String SOQL = getSOQL();
		Account client;
		Account[] clients;
		try{
				clients = Database.query(SOQL);
				if(!clients.isEmpty())
					client = clients[0];
				//clientData = new SObjectWrapper(client);
			}catch(QueryException ex){
				throw new OnboardingServiceException(ex.getMessage());
			}

		return client;
	}

	//Method constructs SOQL query based on request structure definition in 'SFDC to GT Xml Stucture' custom settings
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
		String SOQL = String.format('SELECT {0} FROM ACCOUNT WHERE ID =:clientId',new List<String>{String.join(accountFields,',')});
		return SOQL;
	}

	
	//Method fetches request definition from custom setting
	private List<SFDC2GT_Xml_Stucture__c> getXMLNodes(){
		if(xmlNodes==null && requestCode!=null){
			xmlNodes = [SELECT Object_Name__c 
								,Field_Name__c
								,Node_Item_Name__c 
								,Node_Name__c 
								,Default_Value__c
								,Order__c 
							FROM SFDC2GT_Xml_Stucture__c 
							WHERE Message_Code__c =: requestCode
							ORDER BY Object_Name__c
									, Order__c NULLS FIRST];
		}

		return xmlNodes;
	}

	//Nodes that are part of request definition are grouped by parent nodes
	private Map<String, List<SFDC2GT_Xml_Stucture__c>> getMapNodesByParent(){
		if(mapNodesByParent==null){
			mapNodesByParent = new Map<String, List<SFDC2GT_Xml_Stucture__c>>();
			for(SFDC2GT_Xml_Stucture__c xmlNode:getXMLNodes()){
				List<SFDC2GT_Xml_Stucture__c> childNodes = mapNodesByParent.get(xmlNode.Object_Name__c);
				if(childNodes==null){
					childNodes = new List<SFDC2GT_Xml_Stucture__c>();
					mapNodesByParent.put(xmlNode.Object_Name__c, childNodes);
				}
				childNodes.add(xmlNode);
			}
		}
		return mapNodesByParent;
	}

	//Fields that are part of request definition are grouped by object
	private Map<String, Set<String>> getFieldsByObject(){
		if(mapFieldsByObject==null){
			mapFieldsByObject = new Map<String, Set<String>>();
			mapFieldsByObject.put('Account', new Set<String>{'Name', 'Id', 'Client_Co_ordinator__r.Name'});
			for(SFDC2GT_Xml_Stucture__c xmlNode : getXMLNodes()){
				if(xmlNode.Object_Name__c!=null && xmlNode.Field_Name__c!=null && xmlNode.Node_Item_Name__c==null){
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

	//Method constructs HTTP request to be sent to GoldTier/DataPower
	private HttpRequest getClientDataRequest(){
		String requestBody = getRequestBody();
		HttpRequest req;
		if(!String.isEmpty(requestBody) && requestCode!=null){
			String endpoint = endpointPrefix+requestCode;
			req =  (new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,endpoint, requestBody)).getHttpRequest();
			
			req.setHeader('Content-Type', 'application/xml; charset=UTF-8');
			req.setHeader('Accept', 'application/xml');

			//req.setClientCertificateName(clientCertName);
		}
		return req;
	}

	//Recuring method that generates request payload based on request definition and actual client data
	private void addChildElements(Dom.XmlNode xmlElement, List<SFDC2GT_Xml_Stucture__c> childNodes, SObjectWrapper sObjWrapper){

		if(childNodes!=null){
			for(SFDC2GT_Xml_Stucture__c childNode:childNodes){
				Dom.XmlNode childElement = xmlElement.addChildElement(childNode.Node_Name__c, '', '');
				if(childNode.Node_Item_Name__c!=null){
					Sobject[] childRecords = sObjWrapper.getRelatedRecords().get(childNode.Field_Name__c);
					if(childRecords!=null){
						for(SObject childRecord:childRecords){
							Dom.XmlNode grandchildElement = childElement.addChildElement(childNode.Node_Item_Name__c,'','');
							addChildElements(grandchildElement,getMapNodesByParent().get(childNode.Field_Name__c), new SObjectWrapper(childRecord));
						}
					}
				}else{
					String nodeValue  = childNode.Default_Value__c;

					if(nodeValue!=null) {
						Pattern contextPattern = Pattern.compile('\\{\\!(.*)\\}');
						Matcher contextMatcher = contextPattern.matcher(nodeValue);
						while (contextMatcher.find()) {
                            String contextValue = mapContext.get(contextMatcher.group(1));
                            contextValue = contextValue!=null?contextValue:'';
							nodeValue = nodeValue.replace(contextMatcher.group(),contextValue);
						}
					}

					if(childNode.Field_Name__c!=null){
						List<String> splittedFieldName = childNode.Field_Name__c.split('\\.');
						SObject sobj = sObjWrapper.getRecord();
						for(Integer i=0; i<splittedFieldName.size()-1; i++){
							sobj = sobj.getSObject(splittedFieldName[i]);
						}
						nodeValue = (String)sobj.get(splittedFieldName[splittedFieldName.size()-1]);

					}
					nodeValue= nodeValue==null?'':nodeValue;
					childElement.addTextNode(nodeValue);
				}
				
			}
		}
	}

	//Method encapsulates creation process for body of onboarding request 
	public String getRequestBody(){
		if(requestBody==null){
			List<SFDC2GT_Xml_Stucture__c>  rootNodes = getMapNodesByParent().get(null);
			SObjectWrapper client = getClientData();
			if(client!=null && client.getRecord()!=null && rootNodes!=null && !rootNodes.isEmpty()){
				SFDC2GT_Xml_Stucture__c  rootNode = rootNodes[0];
				Dom.Document xmlDoc = new Dom.Document();
				Dom.XmlNode rootElement = xmlDoc.createRootElement(rootNode.Node_Name__c,'','');
				List<SFDC2GT_Xml_Stucture__c> childNodes = getMapNodesByParent().get(rootNode.Field_Name__c);
				addChildElements(rootElement, childNodes, client);
					
				requestBody = xmlDoc.toXmlString();
			}
		}

		return requestBody;
	}

	//Represents structure of response for HTTP onboarding request 
	public class OnboardingResponse{
		public String operation;
		public Boolean success;
		public String errorMessage;
	}

	public class SObjectWrapper{
		private SObject sobj;
		private Map<String,List<sObject>> mapRelatedObjects;

		public SObject getRecord(){
			return sobj;
		}

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

		public Map<String,List<sObject>> getRelatedRecords(){
			if(mapRelatedObjects==null){
				mapRelatedObjects = new Map<String,List<sObject>>();
			}
			return mapRelatedObjects;
		}
	}
}