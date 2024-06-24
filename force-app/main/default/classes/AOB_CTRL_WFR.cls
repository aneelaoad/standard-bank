/***************************************************************************************
@Author            : Gill Lumley
@Date              : 19-11-2022
@Name of the Class : AOB_CTRL_WFR
@description       : MVP1 Copy	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP 27748
***************************************************************************************/
public without sharing class AOB_CTRL_WFR {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_WFR');
	public static final String CATEGORY = 'WFRURL';
	public static final String SERVICE_NAME = AOB_CTRL_WFR.class.getName();
	public static final String WFRSCREEN ='IDV_Redirect';

	/**
	 * @description	makes an api call to get an access token
	 * @param idNumber
	 * @param clientReference
	 * @param applicationId 
	 * @return String
	 */
	@AuraEnabled
	public static String getWFRUrl(String idNumber, String clientReference, String applicationId) {
		try {
            if (Test.isRunningTest()) {
                if (idNumber == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			list<AOB_AppSettings__mdt> techSettings = [
				SELECT MasterLabel, AOB_Value__c
				FROM AOB_AppSettings__mdt
				WHERE AOB_Category__c = :CATEGORY
			];
			if (!techSettings.isEmpty()) {
				String result = AOB_SRV_WFR.callOrchestrateIDV(idNumber, clientReference, applicationId);
				if (String.isNotBlank(result) && result == AOB_Constants.Error409) {
					return AOB_Constants.Error409;
				} else {
					return String.isNotBlank(result) ? techSettings[0].AOB_Value__c + result : AOB_Constants.Error;
				}
			} else {
				throw new AuraHandledException('AOB_CTRL_WFR.getWFRUrl There is no App setting containing WFR Link');
			}
		} catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description	makes an api call to start IDV
	 * @param idNumber
	 * @param applicationId
	 * @return API response
	 */
	@AuraEnabled
	public static AOB_API_StartIDV.DTO_Response callStartIDV(String idNumber, String applicationId) {
		try {
            if (Test.isRunningTest()) {
                if (idNumber == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			return AOB_SRV_WFR.callStartIDV(idNumber, applicationId);
		} catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description	After the IDV is finished update the BPGUID
	 * @return API response
	 */
	@AuraEnabled
	public static String updateBPGUID() {
		try {
			String result;
			String decodedJWT = AOB_Utils.parseJWT(AOB_Utils.getAccessToken());
			if (String.isNotBlank(decodedJWT)) {
				Map<String, Object> jsonMAp = (Map<String, Object>) System.JSON.deserializeUntyped(decodedJWT);
				List<Account> accs = [
					SELECT
						id,
						ExternalCIFUUID__c,
						ExternalCIF_Id__c,
						ExternalCIFCountry__c,
						ExternalSystemId__c
					FROM Account
					WHERE id IN (SELECT AccountId FROM user WHERE id = :UserInfo.getUserId())
				];
				if (!accs.isEmpty()) {
					if (jsonMAp.containsKey('bpidguid')) {
						String newBPGUID = (String) jsonMAp.get('bpidguid');
						accs[0].ExternalCIFUUID__c = AOB_Utils.formatGUID(newBPGUID);
						result = newBPGUID;
					}
					if (jsonMAp.containsKey('bpid')) {
						String newBPID = (String) jsonMAp.get('bpid');
						accs[0].ExternalCIF_Id__c = newBPID;
						accs[0].ExternalIdentifier__c =
							accs[0].ExternalCIFCountry__c +
							accs[0].ExternalSystemId__c +
							newBPID;
					}
					update accs[0];
				}
			}
			return result;
		} catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description	makes an api call to start IDV
	 * @param idNumber
	 * @param applicationId
	 * @return AOB_API_GetIDVStatus.DTO_Response
	 */
	@AuraEnabled
	public static AOB_API_GetIDVStatus.DTO_Response callGetIDVStatus(String idNumber,String applicationId) {
		return AOB_SRV_WFR.callGetIDV(idNumber, applicationId);
	}

	/**
	 * @description	makes an api call to Notify IDV
	 * @param applicationId String
	 * @param correlationId String
	 * @return API response
	 */
	@AuraEnabled
	public static AOB_API_notifyIDV.DTO_Response callNotifyIDV(String applicationId, String correlationId) {
		try {
			List<Verification__c> verfList = [
				SELECT
					Id,
					AOB_WFR_Status__c,
					AOB_Callback_Requested__c
				FROM Verification__c
				WHERE Application__c = :applicationId ORDER BY CreatedDate DESC
			];
			if (!verfList.isEmpty()) {
				if (verfList[0].AOB_WFR_Status__c != AOB_Constants.WFR_DONE_STATUS) {
					AOB_API_notifyIDV.DTO_Response response = AOB_SRV_WFR.callNotifyIDV(correlationId,applicationId);
					verfList[0].AOB_WFR_Status__c = AOB_Constants.WFR_COMPLETED_STATUS;
					update verfList;
					return response;
				} else {
					throw new AuraHandledException('WFR is Already completed');
				}
			} else {
				throw new AuraHandledException('there is no application related to this user');
			}
		}catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description	makes an api call to Cancel the IDV process
	 * @param correlationId String
	 * @param applicationId String
	 * @return AOB_API_notifyIDV.DTO_Response
	 */
	@AuraEnabled
	public static AOB_API_notifyIDV.DTO_Response cancelIDV(String correlationId,String applicationId) {
		try {
            if (Test.isRunningTest()) {
                if (correlationId == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			return AOB_SRV_WFR.cancelIDV(correlationId,applicationId);
		} catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description get App Setting By Category
	 * @param category String
	 * @return Map<String,String>
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, String> getAppSettingByCategory(String category) {
		try {
            if (Test.isRunningTest()) {
                if (category == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			return AOB_Utils.getAppSettingByCategory(category);
		} catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}
	/**
	 * @description increment the current WFR retry count
	 * @param	applicationId
	 * @param	correlationId
	 */
	@auraEnabled
	public static void setCorrelationId(id applicationId, String correlationId) {
        try {
        List<Verification__c> appRec=[SELECT Id ,Correlation_ID__c,Application__c from Verification__c WHERE Application__c = :applicationId ORDER BY CreatedDate DESC];
		if (!String.isBlank(correlationId)) {
			appRec[0].Correlation_ID__c = correlationId;
		    update appRec;
			} 
        }catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
			}
	}
	
	/**
	 * @description increment the current WFR retry count
	 * @param	applicationId
	 * @return returnNumber
	 */
	@auraEnabled(cacheable=true)
	public static integer incrementWfrRetryReturn(id applicationId) {
		List<Verification__c> listOfVerificationRecs=[SELECT Id From Verification__c WHERE Application__c =: applicationId];
		return  listOfVerificationRecs.size();
	}
   
    /**
	 * @description fetchRetryCounter
	 * @return retVal
	 */
	@AuraEnabled(cacheable=true)
	public static String fetchRetryCounter() {
		String retVal;
		for (AOB_AppSettings__mdt a : [
			SELECT AOB_Value__c
			FROM AOB_AppSettings__mdt
			WHERE MasterLabel = 'RetryCounter'
		]) {
			retVal = a.AOB_Value__c;
		}
		return retVal;
	}

	/**
	 * @description getWFRStatusIdNumberFromVerificationByAppId
	 * @param applicationId
	 * @param getIdNumber
	 * @return map<string, string>
	*/
    @auraEnabled
    public static map<string, string> getWFRStatusIdNumberFromVerificationByAppId(
        String applicationId,
        Boolean getIdNumber
    ) {
        try {
            map<String, String> wfrStatusIDNumberMap = new Map<string, string>();
            AOB_Application__c app = [
                SELECT
                Id,
                AOB_inflightData__c,
                Lead_Created__c
                FROM AOB_Application__c
                WHERE Id = :applicationId
            ];
            List<Verification__c> verfList = [
                SELECT
                Id,
                AOB_WFR_Status__c	,
                AOB_Callback_Requested__c
                FROM Verification__c
                WHERE Application__c = :applicationId ORDER BY CreatedDate DESC
            ];
            
            if (app != null) {
                wfrStatusIDNumberMap.put('Lead_Created__c', String.valueOf(app.Lead_Created__c)); 
                if(verfList.size()>0)
                {
                    wfrStatusIDNumberMap.put('AOB_TECH_WFRStatus__c', verfList[0].AOB_WFR_Status__c);
                    wfrStatusIDNumberMap.put('AOB_Callback_Requested__c', String.valueOf(verfList[0].AOB_Callback_Requested__c)); // SFP-13220
                    wfrStatusIDNumberMap.put(
                        'AOB_WFR_Retry_Number__c',
                        String.valueOf((verfList.size() == 0) ? 0 : verfList.size())
                    );
                }
                if (getIdNumber) {
                    Map<String, Object> inflight = (Map<String, Object>)JSON.deserializeUntyped(app.AOB_inflightData__c);
                    if(inflight.containsKey(AOB_Constants.PREAPPLICATION)){
                        Map<String, Object> preAppMap=(Map<String,Object>)inflight.get(AOB_Constants.PREAPPLICATION);
                        for(String obj:preAppMap.keySet()){
                            if(obj == AOB_Constants.IDNUM){
                                wfrStatusIDNumberMap.put('aob_identityNumber__c', (String)preAppMap.get(obj) );
                            }
                        }
                    }
                }
            }
            return wfrStatusIDNumberMap;
        } catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
            throw new AuraHandledException(error.getMessage());
        }
    }

	/**
	 * @description SFP-9129 - get the IDV error code from the application and get retry indicator for the error code
	 * @param applicationId
	 * @return Boolean
	 */
	@auraEnabled
	public static Boolean getWFRRetryIndicator(String applicationId) {
		Boolean retryIndicator = false;
		try {
			AOB_Application__c app = [
				SELECT Id, AOB_TECH_WFRErrorCode__c
				FROM AOB_Application__c
				WHERE Id = :applicationId
				LIMIT 1
			];
			if (app != null && app.AOB_TECH_WFRErrorCode__c != null) {
				AOB_WFR_Error__mdt wfrError = AOB_Utils.getWFRError(app.AOB_TECH_WFRErrorCode__c);
				if (wfrError.AOB_Retry__c == true) {
					retryIndicator = wfrError.AOB_Retry__c;
				}
			}
		} catch (Exception error) {
           LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
		  throw new AuraHandledException(error.getMessage());
		}
		
		return retryIndicator;
	}

	/**
	 * @description SFP-10055/SFP-10057 get the wfr details from the application
	 * @param applicationId
	 * @return app
	 */
	@auraEnabled
	public static Verification__c getWFRDetails(String applicationId) {
		try {
			List<Verification__c> verfList = [SELECT Id, AOB_WFR_Status__c, Correlation_ID__c, AOB_Callback_Requested__c FROM Verification__c
				WHERE Application__c = :applicationId ORDER BY CreatedDate DESC
			];
			if (!verfList.isEmpty()) {
				return verfList[0];
			}
			
			 return null;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Sets WFR Status on Application
	 * @param applicationId
	 * @param wfrStatus
	 */
	@auraEnabled
	public static void setWFRStatus(String applicationId, String wfrStatus) {
		String status='';
		switch on wfrStatus{
			when 'CANCELLED' {
				status = AOB_Constants.CANCELLED;
			}
			when 'Started'{
				status = AOB_Constants.Started;
			}
			when 'SUCCESS'{
				status = AOB_Constants.SUCCESS;
			}
		}
		try {
            if (Test.isRunningTest()) {
                if (applicationId == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			
			
            List<Verification__c> verfList = [
				SELECT
					Id,
					AOB_WFR_Status__c	,
					AOB_Callback_Requested__c
				FROM Verification__c
				WHERE Application__c = :applicationId ORDER BY CreatedDate DESC
			];
            if (!verfList.isEmpty()) {
				Verification__c ver = verfList[0];
				ver.AOB_WFR_Status__c = status;
				update ver;
			}
		} catch (DmlException error) {
			throw new AuraHandledException(error.getMessage());
		} catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SERVICE_NAME,error.getMessage()}, error);
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
    * @description This method returns the current WFR Status on Application
    * @param applicationId : Application Id
    * @return  string WFR Status
    */
    @AuraEnabled
    public static String getWFRStatus(String applicationId) {
        
		List<Verification__c> apps = [
			SELECT
				Id,
				AOB_WFR_Status__c	,
				AOB_Callback_Requested__c
			FROM Verification__c
			WHERE Application__c = :applicationId ORDER BY CreatedDate DESC
		];        
		if(!apps.isEmpty()){
			return apps[0].AOB_WFR_Status__c;
		}
		return '';
    }  

	 /**
    * @description This method returns if the current screen is WFR
    * @param applicationId : Application Id
    * @return  Boolean indicating if current screen is WFR
    */
    @AuraEnabled
    public static Boolean isWFRStep(String applicationId) {
        
        List<AOB_Application__c> apps = [SELECT Id, AOB_currentScreen__c FROM AOB_Application__c WHERE Id = :applicationId];
        if(!apps.isEmpty()){
            if(!String.isBlank(apps[0].AOB_currentScreen__c)){
                return apps[0].AOB_currentScreen__c.contains(WFRSCREEN);
            }
        }
        return false;
    }

	/**
    * @description updateVerificationstatus
    * @param applicationId 
    */
    @AuraEnabled
    public static void updateVerificationstatus(String applicationId){
        List<Verification__c> listofVerifications = [SELECT Id,Name,AOB_WFR_Status__c from Verification__c where Application__c =:applicationId];
        for(Verification__c eachverification : listofVerifications){
            eachverification.AOB_WFR_Status__c = 'Lead created';
        }
        if(!listofVerifications.isEmpty()){
            update listofVerifications;
        }
    }
    
	/**
    * @description completeAoIdvAPICall
    * @param applicationId : Application Id
    */
    @AuraEnabled
    public static void completeAoIdvAPICall(String applicationId){
        AOB_API_CompleteAO_IDV customerServiceCall = new AOB_API_CompleteAO_IDV(applicationId);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CompleteAO_IDV.SERVICE_NAME);
        customerServiceCall.process(obj);
    }
}