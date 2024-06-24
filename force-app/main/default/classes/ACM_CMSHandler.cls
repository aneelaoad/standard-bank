/**
@description       : This class is used to retrieve data from CMS
@author            : Vuyo Xhamfu 
@email 	           : vuyo.xhamfu@standardbank.co.za
@company  Standardbank    
@date  September 28th, 2023
 * 
**/
public without sharing class ACM_CMSHandler {
private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ACM_CMSHandler');
 /**
     * @description Fetching content with help of content id
     * @param communityId,managedContentIds
	 * @return list of managedContentVersions
    **/
    @AuraEnabled(Cacheable=true)
    public static List<ConnectApi.ManagedContentVersion> getManagedContentByContentKeys(String communityId, List<String> managedContentIds){
        try{
            LOGGER.INFO('Fetch managed content with passed content id ');
            ConnectApi.ManagedContentVersionCollection contentKeyCollection = ConnectApi.ManagedContent.getManagedContentByContentKeys(
            communityId,
            managedContentIds,
            null,
            null,
            null,
            null,
            true
          );
      
        LOGGER.INFO('Content List Retrieved' + contentKeyCollection.items);
        return contentKeyCollection.items;
    }catch(exception e){
        LOGGER.ERROR('Error retrieving data' + e);
        List<ConnectApi.ManagedContentVersion> mcnvMap1 = new List<ConnectApi.ManagedContentVersion>();
        return mcnvMap1;
    }
  }
  }