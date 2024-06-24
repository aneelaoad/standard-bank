/**
  @description It will read the Api Products related to community APIs
  @className ACM_SubscriptionScreenController  
  @Author - Purna Unnagiri
  @email 	purna.unnagiri@standardbank.co.za
  @company  Standardbank    
  @date  Oct 25, 2022
**/
public with sharing class ACM_SubscriptionScreenController {
    
	@TestVisible 
    private static List<acm_pkg__AnypointAssets__x> mockedRequests = new List<acm_pkg__AnypointAssets__x>();
    
    /**
	 * @description - It will provide the communityApi record info.
     * @param apiId  - CommunityApi record id of type API.
     * @param communityId  - community record id.
	 * @return List of API Products acm_pkg__CommunityApi__c records.
    **/    
    @AuraEnabled(cacheable=true)
    public static List<ACM_SubscriptionScreenWrapperCls> getApiProducts(String apiId, String communityId){
		
		List<ACM_SubscriptionScreenWrapperCls> subscriptionWrapperList = new List<ACM_SubscriptionScreenWrapperCls>();	

        if( String.isNotBlank(apiId) && String.isNotBlank(communityId) ){

			Id eighteenDigitCommunityId = communityId; 

			List<acm_pkg__CommunityAssetVersion__c> communityAssetVersionList;
			communityAssetVersionList = [SELECT Id, 
										acm_pkg__CommunityId__c, 
										acm_pkg__ParentAsset__c, 
										acm_pkg__ParentGroupVersion__c, 
										acm_pkg__ParentGroupVersion__r.acm_pkg__ParentAsset__c,
										acm_pkg__VersionGroup__c, 
										acm_pkg__Version__c 
										FROM acm_pkg__CommunityAssetVersion__c 
										WHERE 
										acm_pkg__ParentAsset__c =: apiId 
										AND 
										acm_pkg__ParentGroupVersion__c != null 
										AND 
										acm_pkg__ParentGroupVersion__r.acm_pkg__ParentAsset__c != null
										AND 
										acm_pkg__CommunityId__c =: eighteenDigitCommunityId ];										
			
			if( !communityAssetVersionList.isEmpty() ){
				
				Set<String> parentGroupVersionParentAssetIds = new Set<String>();													
				
				for(acm_pkg__CommunityAssetVersion__c communityAssetVersion : communityAssetVersionList){
					
					parentGroupVersionParentAssetIds.add(communityAssetVersion.acm_pkg__ParentGroupVersion__r.acm_pkg__ParentAsset__c);					
				}				
				
				if( !parentGroupVersionParentAssetIds.isEmpty() ){
					
					List<acm_pkg__CommunityApi__c> communityApis = [SELECT Id, acm_pkg__Name__c, acm_pkg__Description__c,
																	acm_pkg__ApiId__c, acm_pkg__AssetVersion__c,
																	acm_pkg__VersionGroup__c 
																	FROM acm_pkg__CommunityApi__c 
																	WHERE id =:parentGroupVersionParentAssetIds];																
					
					if( !communityApis.isEmpty() ){
						
						Set<String> apiIdSet = new Set<String>();
						
						for(acm_pkg__CommunityApi__c commuApi : communityApis){	
						
							apiIdSet.add(commuApi.acm_pkg__ApiId__c);							
						}				
						
						if( !apiIdSet.isEmpty() ){
							
							List<acm_pkg__AnypointAssets__x> anypointAssets = (!mockedRequests.isEmpty()) ? mockedRequests :[SELECT Id, acm_pkg__Name__c, 
																			acm_pkg__Id__c, 
																			acm_pkg__Icon__c,
																			acm_pkg__Description__c 
																			FROM acm_pkg__AnypointAssets__x 
																			WHERE acm_pkg__Id__c =: apiIdSet];
							
							if( !anypointAssets.isEmpty() ){
								
								Map<String, String> assetcustomIdAndIconMap = new Map<String, String>();

								for(acm_pkg__AnypointAssets__x anypointAsset : anypointAssets){
									
									assetcustomIdAndIconMap.put(anypointAsset.acm_pkg__Id__c, anypointAsset.acm_pkg__Icon__c);
								}								
								
								for(acm_pkg__CommunityApi__c communityApi : communityApis){									
																											
									ACM_SubscriptionScreenWrapperCls subscriptionWrapper = new ACM_SubscriptionScreenWrapperCls();
									
									subscriptionWrapper.apiProductId = communityApi.Id;
									subscriptionWrapper.apiProductName = communityApi.acm_pkg__Name__c;
									subscriptionWrapper.apiProductDescription = communityApi.acm_pkg__Description__c;
									
									if( assetcustomIdAndIconMap.containsKey(communityApi.acm_pkg__ApiId__c) ){
										subscriptionWrapper.apiProductIconUrl = assetcustomIdAndIconMap.get(communityApi.acm_pkg__ApiId__c);
									}
									
									subscriptionWrapperList.add(subscriptionWrapper);
									
								}
							}
						}
					}
				}
			}
        }
		return subscriptionWrapperList;
    }

    /**
	 * @description - This inner class will hold the Subscription Screen UI Related info.
	 * @className ACM_SubscriptionScreenWrapperCls 
	*/
	public class ACM_SubscriptionScreenWrapperCls {
    		
		/** 
		* @description - This apiProductName field will hold the api product name.
		*/
		@AuraEnabled
		public String apiProductName { get; set; }

		/**
		* @description - This apiProductDescription field will hold the api product description.
		*/
		@AuraEnabled
		public String apiProductDescription { get; set; }

 		/**
		 * @description - This apiProductIconUrl field will hold the api product icon url.
		*/		
		@AuraEnabled
		public String apiProductIconUrl { get; set; }

 		/**
		 * @description - This apiProductId field will hold the api product id.
		*/		
		@AuraEnabled
		public String apiProductId { get; set; }
		
	}
}