/**
 *  @description : SFP-25090 - Service class for Contract Specific logic
 *
 * @author : Tukelo Moseamo
 *
 * @group : StandardBank BCC
 * @last modified on  : 09-12-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   03-17-2023   Tukelo Moseamo   Initial Version
 */
public with sharing class AOB_Internal_SRV_CreateContract
{

	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Internal_SRV_CreateContract');
	private static final String CONTENTTYPE = 'application/pdf';
	private static final String LINK = '/servlet/servlet.FileDownload?file=';
	private static final String NAME = 'Document.pdf';

	/**
	* @description method to call StaffAssistContractAPI 
	* @param  applicationId 
	* @return Integer
	* @author Tukelo Moseamo | 07-03-2023 
	**/
	@AuraEnabled
	public static AOB_Internal_DTO_CreateContract.DTO_ResponseStatus callStaffAssistContractAPI(String applicationId)
	{

		try {
			AOB_Internal_DTO_CreateContract.DTO_ResponseStatus resposeStatus = new AOB_Internal_DTO_CreateContract.DTO_ResponseStatus();
			AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse createContractRes = getContractResponse(applicationId);
			//Only run when inflight data does not have contracts
			if (createContractRes?.contracts == null || createContractRes?.contracts.isEmpty()) {
				AOB_Application__c application = new SEL_AOBApplication().selectAppsById(applicationId).iterator()?.next();

				AOB_Internal_API_CreateContract customerServiceCall = new AOB_Internal_API_CreateContract(applicationId);
				CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_CreateContract.SERVICE_NAME);
				obj.CMN_TriggeringObjectId__c = applicationId;
				customerServiceCall.process(obj);
				insert obj;

				if (customerServiceCall.getResponseStatusCode() == 200) {
					AOB_Internal_DTO_CreateContract.DTO_Response responseData = (AOb_Internal_DTO_CreateContract.DTO_Response)JSON.deserialize(customerServiceCall.getResponseBody(),AOb_Internal_DTO_CreateContract.DTO_Response.class);
					
					Map<String, Object> inflightDataMap = AOB_Internal_Utils.getInflightDataMap(applicationId);
					if (inflightDataMap.get(AOB_Internal_Constants.CREATE_CONTRACT_RESPONSE) != null) {
						inflightDataMap.remove(AOB_Internal_Constants.CREATE_CONTRACT_RESPONSE);
					}
					inflightDataMap.put(AOB_Internal_Constants.CREATE_CONTRACT_RESPONSE, responseData.createContractResponse); 

					application.AOB_inflightData__c = JSON.serialize(inflightDataMap);
					application.AOB_Retry_Count__c = 0;

					update application;

					if (responseData?.createContractResponse?.contracts != null) {
						resposeStatus = responseData?.createContractResponse?.orchestrationHeaderResponse?.responseStatus;
						resposeStatus.variant = AOB_Internal_Constants.SUCCESSFUL.toLowerCase();
					}
					else {
						resposeStatus.statusCode = responseData?.createContractResponse?.orchestrationHeaderResponse?.errorResponse[0]?.stepStatus;
						resposeStatus.statusDescription = responseData?.createContractResponse?.orchestrationHeaderResponse?.errorResponse[0]?.responseMessage;
						resposeStatus.variant = AOB_Internal_Constants.WARNING.toLowerCase();
					}
				}
				else {
					//Server failure
					resposeStatus.statusCode = String.valueOf(customerServiceCall.getResponseStatusCode());
					resposeStatus.statusDescription = AOB_API_StaffAssistedOnboarding.UNSUCCESSFUL_CALLOUT_ERROR;
					resposeStatus.variant = AOB_Internal_Constants.ERROR.toLowerCase();
				}
			}
			else {
				//contracts already exist therefor return mimic success response
				resposeStatus.statusCode = AOB_Internal_Constants.SUCCESSFUL_CODE;
				resposeStatus.statusDescription = AOB_Internal_Constants.CONTRACTS_EXISTS;
				resposeStatus.variant = AOB_Internal_Constants.INFO.toLowerCase();
			}

			return resposeStatus;
		}
		catch(Exception ex) {
			LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_SRV_CreateContract', ex.getMessage()}, ex);
			throw new AuraHandledException(ex.getMessage());
		}

	}

	/**
	* @description method Runs the get Contract API
	* @param applicationId
	* @param itemId
	* @return String base64Encode format of the document
	**/
	@AuraEnabled
	public static String callStaffAssistGetDocumentAPI(String applicationId, String itemId)
	{
		try
		{
			AOB_Internal_API_GetDocument customerServiceCall = new AOB_Internal_API_GetDocument(applicationId, itemId);
			CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_GetDocument.SERVICE_NAME);
            obj.CMN_TriggeringObjectId__c = applicationId;
			customerServiceCall.process(obj);

			insert obj;
			String base64Pdf = '';
			if(customerServiceCall.getResponseStatusCode() == 200)
			{
				Blob document = customerServiceCall.getResponseBlobBody();
				if(document != null)
				{
					base64Pdf = EncodingUtil.base64Encode(document);
				}
			}

			return base64Pdf;
		}
		catch(Exception ex)
		{
			LOGGER.error(ex.getMessage(), new String[] {'AOB_Internal_SRV_CreateContract', ex.getMessage()}, ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}


	/**
	* @description method creates of map of document Name by ItemId
	* @param  applicationId
	* @return Map<String, String> documentName by ItemId
	**/
	@AuraEnabled
	public static Map<String, String> getDocumentList(String applicationId)
	{
		AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse contractResponse = getContractResponse(applicationId);

		Map<String, String> docNameByItemId = new Map<String, String>();

		Boolean docsExists = contractResponse?.contracts == null ? false : true;

		if (docsExists) {
			for (AOB_Internal_DTO_CreateContract.DTO_Contracts docItem : contractResponse?.contracts) {
				docNameByItemId.put((String)docItem.itemId, (String)docItem.documentName);
			}
		}
		else {
			throw new AuraHandledException(AOB_Internal_Constants.NO_CONTRACTS);
		}
		
		return docNameByItemId;
	}

	/**
	* @description get the createContractResponse object from inflight Data
	* @author Tukelo Moseamo | 07-12-2023 
	* @param applicationId 
	* @return AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse 
	**/
	public static AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse getContractResponse(String applicationId) {
		
		Map<String, Object> inflightDataMap = AOB_Internal_Utils.getInflightDataMap(applicationId);		

		AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse contractResponse = (AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse)JSON.deserialize(
			JSON.serialize(inflightDataMap.get(AOB_Internal_Constants.CREATE_CONTRACT_RESPONSE)),
			AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse.class);

		return contractResponse;

	}

	

}