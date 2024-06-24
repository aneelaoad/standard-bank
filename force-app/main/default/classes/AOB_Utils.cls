/**
 * Utility methods for AOB project
 *
 * <p></p>
 *
 * @author Salesforce
 *
 * @date Oct 2021
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed MVP1 Copy 19-11-2022 Gill Lumley   Copied getAccessToken and getWFRError methods from MVP1 
 */
public with sharing class AOB_Utils {
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = AOB_Utils.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Utils');
	/**
	 * @description Get Access token without checking expiry date
	 * @return accessToken
	 */
	@AuraEnabled
	public static String getFreshAccessToken() {
		if (Test.isRunningTest()) {
			return AOB_TestConstants.TOKEN;
		} else {
			String authProviderId = getAppSettingByCategory(AOB_Constants.PING).get(AOB_Constants.Ping_Id);
			String authProviderType = getAppSettingByCategory(AOB_Constants.PING).get(AOB_Constants.Ping_Type);
			String accessToken = Auth.AuthToken.getAccessToken(authProviderId, authProviderType);
			if (!String.isBlank(accessToken)) {
				Map<String, String> accessTokenMap = Auth.AuthToken.refreshAccessToken(
					authProviderId,
					authProviderType,
					accessToken
				);
				if (accessTokenMap.get('RefreshError') == null) {
					accessToken = accessTokenMap.get('AccessToken');
				} else {
                    LOGGER.info('AOB_Utils.getFreshAccessToken: '+accessTokenMap.get('RefreshError'));
					return '';
				}
			}

			return accessToken;
		}
	}

	/**
	 * @description Get Access token from the current session - A required method to call APIs
	 * @return accessToken
	 */
	@AuraEnabled
	public static String getAccessToken() {
        if (Test.isRunningTest()) {
			return AOB_TestConstants.TOKEN;
        } else {
			return CMN_SRV_OAuth.getUserAccessToken('AOB_Ping');
    	}
	}

	/**
	 * @description  method used to get the app setting by Category (custom metadata type)
	 * @param  category
	 * @return  Map<String, String>
	 */
	public static Map<String, String> getAppSettingByCategory(String category) {
		Map<String, String> result = new Map<String, String>();
		list<AOB_AppSettings__mdt> techSettings = [
			SELECT MasterLabel, AOB_Value__c
			FROM AOB_AppSettings__mdt
			WHERE AOB_Category__c = :category
		];
		for (AOB_AppSettings__mdt techSetting : techSettings) {
			result.put(techSetting.MasterLabel, techSetting.AOB_Value__c);
		}
		return result;
	}

    /**
	 * @description Method used to get the app setting (custom metadata type)
	 * @param  label
	 * @return  String
	 */
	public static String getAppSettingByLabel(String label) {
		list<AOB_AppSettings__mdt> techSettings = [
			SELECT MasterLabel, AOB_Value__c
			FROM AOB_AppSettings__mdt
			WHERE MasterLabel = :label
		];
        
		return techSettings[0].AOB_Value__c;
	}

    /**
     * @description method to fetch the picklist values from the refrenced Data Table
     * @param   sapFields List<String> containing Object Names
     * @return  List<AOB_DTO_SelectOption>
     */
    @AuraEnabled
    public static Map<String, List<AOB_DTO_SelectOption>> getAllPicklistEntriesCodes(List<String> sapFields) {
        Map<String, List<AOB_DTO_SelectOption>> result = new Map<String, List<AOB_DTO_SelectOption>>();
        List<AOB_ReferencedData__c> referencedDataList = [
            SELECT Id, AOB_Code__c, Name, AOB_Default__c, AOB_SAPField__c
            FROM AOB_ReferencedData__c
            WHERE AOB_SAPField__c IN :sapFields AND AOB_Language__c = :UserInfo.getLanguage() AND AOB_isActive__c = TRUE
            WITH SECURITY_ENFORCED
            ORDER BY AOB_Sequence__c ASC
        ];
        for (AOB_ReferencedData__c data : referencedDataList) {
            if (result.containskey(data.AOB_SAPField__c)) {
                result.get(data.AOB_SAPField__c).add(new AOB_DTO_SelectOption(data.AOB_Code__c, data.Name, data.AOB_Default__c));
            } else {
                result.put(data.AOB_SAPField__c, new List<AOB_DTO_SelectOption>{ new AOB_DTO_SelectOption(data.AOB_Code__c, data.Name, data.AOB_Default__c) });
            }
        }
        return result;
    }
    
    /**
     * @description method used to transert String to date Time
     * @param dateString
     * @return  String
     */
    public static DateTime formatDateTime(String dateString) {
        datetime dateObj = null;
        if (dateString.contains('T')) {
            dateString = dateString.replace('T', ' ');
            if (dateString.contains('.')) {
                dateString = dateString.subString(0, dateString.indexOf('.'));
            }
            dateObj = datetime.valueof(dateString);
        } else {
            dateObj = datetime.valueof(dateString);
        }
        return dateObj;
    }

    /**
     * @description method used to transert DateTime format to M Month Y
     * @param dateT
     * @return  String
     */
    public static String formatDate(String dateT) {
        DateTime dt = formatDateTime(dateT);
        String monthName = dt.format('MMMMM');
        Integer day = dt.day();
        Integer year = dt.year();
        return day + ' ' + monthName + ' ' + year;
    }

    /**
     * @description method used to transert DateTime format to M Month Y
     * @param dateT
     * @return  String
     */
    public static Integer remainingDays(String dateT) {
        DateTime d = formatDateTime(dateT);
        Date dt = (d).date();
        Date currentDate = system.today();
        Integer numberDaysDue = currentDate.daysBetween(dt);
        return numberDaysDue;
    }

    /**
     * @description method used to generate a GUID
     * @return  String
     */
    public static String generateGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.subString(20);
    }
    
     
    /**
     * @description method used to parse jwt
     * @param jwtToken String
     * @return  String
     */
    public static String parseJWT(String jwtToken) {
        if (String.isNotBlank(jwtToken)) {
            String base64Url = jwtToken.split('\\.')[1];
            String base64 = base64Url.replace('-', '+').replace('_', '/');
            String jsonPayload = EncodingUtil.base64Decode(base64).toString();
            return jsonPayload;
        }
        return '';
    }

    /**
     * @description method to read through the XML
     * @param reader XmlStreamReader
     * @param sxmltag String
     * @return  String
     */
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        String retValue;
        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (reader.getLocalName() == sxmltag) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.characters) {
                        retValue = reader.getText();
                    }
                }
            }
            reader.next();
        }
        return retValue;
    }
    
    /**
     * Method used to determine if its an existing to bank or new to bank
     * @return	Boolean
     */
    public static Boolean isUserExistingToBank() {
        //check ping token and check for BPID in it
        return true;
    }

    /**
     * @description method to format GUID
     * @param   h String  unFormatted Guid String
     * @return  String
     */
    public static String formatGUID(String h) {
        h = h.replace('-', '');
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.subString(20);
        return guid.toLowerCase();
    }
    
    /**
     * @description method to fetch an object url
     * @param   sfobject salesforce object record
     * @return  String containing the url to access that object via api
     */
    public static String getObjectUrl(object sfobject) {
        String appjson = JSOn.serialize(sfobject);
        Map<String, object> deserializedApp = (Map<String, Object>) System.JSON.deserializeUntyped(appjson);
        Map<String, Object> attributes = (Map<String, Object>) deserializedApp.get('attributes');
        return (String) attributes.get('url');
    }
    
    /**
     * @description	method used to get the app setting by Category (custom metadata type)
     * @param	category
     * @return	Map<String, String> 
     */
    @AuraEnabled
    public static AOB_OnboardingSetting__mdt getOnboardingSettings(String siteId) {
        list<AOB_OnboardingSetting__mdt> techSettings = [SELECT MasterLabel, AOB_AccountOwner__c ,AOB_AccountRecordType__c ,AOB_accountsUrl__c , 
                                                         AOB_ContactOwnerId__c, AOB_ContactRecordType__c ,AOB_Country__c ,AOB_CountryCode__c ,
                                                         AOB_Currency__c , AOB_PermissionSet__c ,AOB_Profile__c ,AOB_SandboxSuffix__c ,
                                                         AOB_SiteId__c ,AOB_SystemId__c, AOB_Language__c, AOB_Locale__c,
                                                         AOB_emailEncodingKey__c, AOB_TimeZone__c FROM AOB_OnboardingSetting__mdt  WHERE AOB_siteId__c = :siteId];
        if(!techSettings.isEmpty()){
           return techSettings[0];
        }
        else
        {
            throw new AuraHandledException('There are no Onboarding settings for this site Id '+siteId);
        }         
    } 

    /**
    * @description	method to get the current flow names of an application
    * @param 	applicationId : application Id
    * @return	String : flowNames field
    */
    public static Map<Id, AOB_Application__c> getApplicationsMap(List<CMN_WebserviceCallQueue__c> webserviceList) {
        Map<Id, AOB_Application__c> applicationsMap = new Map<Id, AOB_Application__c>();
        if (webserviceList != null && !webserviceList.isEmpty()) {
            Set<Id> applicationsIds = new Set<Id>();
            for (CMN_WebserviceCallQueue__c eachWebService : webserviceList) {
                applicationsIds.add(eachWebService.CMN_TriggeringObjectId__c);
            }
            applicationsMap = new Map<Id, AOB_Application__c>([SELECT Id, AOB_Client__c FROM AOB_Application__c WHERE Id IN :applicationsIds]);
        }
        return applicationsMap;
    }

    /**
     * Method used to get the business segment record type
     * @param	label
     * @return	AOB_BusinessSegment__mdt
     */
    public static AOB_BusinessSegment__mdt getBusinessSegmentRecordTypeByLabel(String label) {
        AOB_BusinessSegment__mdt businessSegmentRecordType = [SELECT Id, MasterLabel, DeveloperName FROM AOB_BusinessSegment__mdt WHERE MasterLabel = :label];
        return businessSegmentRecordType;
    }
    
    /**
    * returns user language
    */
    public static String getUserLanguage(){
        String language = UserInfo.getLanguage();
        Integer count = 0;
        count = [SELECT count() from AOB_FlowScreen__c where AOB_Language__c = :language];
        if(count==0){
           language = AOB_CONSTANTS.LANG_ENG_US;
        }
        return language;
    }  


	/**
	 * @description	method used to get the ws setting by name (custom metadata type)
	 * @param	name
	 * @return	Map<String, String>
	 */
	public static CMN_WebserviceSetting__mdt getWebServiceSettingsByName(String name) {
		List<CMN_WebserviceSetting__mdt> wsSettings = [
			SELECT MasterLabel, AOB_Action__c, AOB_Channel__c
			FROM CMN_WebserviceSetting__mdt
			WHERE MasterLabel = :name
			LIMIT 1
		];
		if (!wsSettings.isEmpty()) {
			return wsSettings.get(0);
		} else {
			throw new AuraHandledException('Error on AOB_Utils.getWebServiceSettingsByName');
		}
	}

	/**
	 * @description Method used to get a specific WFR error code (custom metadata type)
	 * @author Gill Lumley - SFP-9129
	 * @param errorCode
	 * @return AOB_WFR_Error__mdt
	 */
	public static AOB_WFR_Error__mdt getWFRError(String errorCode) {
		AOB_WFR_Error__mdt wfrError = [
			SELECT MasterLabel, AOB_Error_Description__c, AOB_Reason_Type__c, AOB_Retry__c
			FROM AOB_WFR_Error__mdt
			WHERE MasterLabel = :errorCode
		];
		return wfrError;
	}      

}