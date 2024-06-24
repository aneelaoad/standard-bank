/**
@description Querues for access type for each API
@className ACM_LeadOrSubscribe
@Author - Vuyo Xhamfu
@email 	vuyo.xhamfu@standardbank.co.za
@company  Standardbank    
@date  June 7th, 2023
**/
public with sharing class ACM_LeadOrSubscribe {
    private final static String API_ASSET_TYPE = 'access-type';
    private final static String SUBSCRIPTION = 'subscription';
    private final static String NONE = 'none';
    /**
* @description to log the global info/Errors
**/
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ACM_LeadOrSubscribe');
    
    /**
* @description This retrieves the access type of the API
* @param recordId  - API ID   
* @return  Access type: String
**/ 
    @AuraEnabled(cacheable=true)
    public static String getAPIAccessType(String recordId){
        if(recordId !=null && recordId !=''){
            acm_pkg__CommunityApi__c communityApi = [SELECT acm_pkg__ApiId__c,acm_pkg__AssetVersion__c FROM acm_pkg__CommunityApi__c WHERE id =:recordId limit 1];	
            LOGGER.info('Record succesully retrieved.');

            String apiId = communityApi.acm_pkg__ApiId__c;
            acm_pkg__AnypointAssetCustomFields__x cfv;
            if(Test.isRunningTest()){
                List<acm_pkg__AnypointAssetCustomFields__x> mockDataList = mockData();
                for(acm_pkg__AnypointAssetCustomFields__x md:mockDataList){
                     cfv = md;
                }
            }
            else{
                cfv = [SELECT acm_pkg__CustomFieldValue__c FROM acm_pkg__AnypointAssetCustomFields__x WHERE acm_pkg__AssetId__c =:apiId AND acm_pkg__CustomFieldId__c =:API_ASSET_TYPE];  
				LOGGER.INFO('Custom field value record succesully retrieved.');

            }
            String accessType = cfv.acm_pkg__CustomFieldValue__c;
            
            if(accessType !=null && accessType !=''){
				LOGGER.INFO('Return access type: ' + accessType);
                return accessType;
            }else{ LOGGER.INFO('Assigning subscription as default value.');return SUBSCRIPTION; }
        }else{
			LOGGER.ERROR('Record Id is null');
            return NONE;
        }
    }
     /**
* @description This mock data type of type acm_pkg__AnypointAssetCustomFields__x    
* @return acm_pkg__AnypointAssetCustomFields__x  mockObj
**/ 
    public static List<acm_pkg__AnypointAssetCustomFields__x> mockData() {
        List<acm_pkg__AnypointAssetCustomFields__x> mockList= new List<acm_pkg__AnypointAssetCustomFields__x>{new acm_pkg__AnypointAssetCustomFields__x(acm_pkg__CustomFieldValue__c = 'TestRun'),
                                                                                                              new acm_pkg__AnypointAssetCustomFields__x(acm_pkg__CustomFieldValue__c =null),
            																								  new acm_pkg__AnypointAssetCustomFields__x(acm_pkg__CustomFieldValue__c = 'both')};
        return mockList;
    }
}