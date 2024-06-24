/**
  @description It will read the communityApi and related records 
  @className ACM_CommunityApiController  
  @Author - Purna Unnagiri
  @email 	purna.unnagiri@standardbank.co.za
  @company  Standardbank    
  @date  Sep 13, 2022
**/
public with sharing class ACM_CommunityApiController {

    /**
	 * @description - It will read the communityApi related AnypointAssetCategories.
     * @param apiId  - CommunityApi record id.
	 * @return List of acm_pkg__AnypointAssetCategories__x records.
    **/    
    @AuraEnabled(cacheable=true)
    public static List<acm_pkg__AnypointAssetCategories__x> getAnypointAssetCategories(String apiId){
        if(String.isNotBlank(apiId)){
            
            acm_pkg__CommunityApi__c communityApi = [SELECT acm_pkg__ApiId__c, acm_pkg__AssetVersion__c, 
                                                     acm_pkg__Name__c 
                                                     FROM acm_pkg__CommunityApi__c 
                                                     WHERE id =:apiId limit 1];				
            if(communityApi != null && communityApi.acm_pkg__ApiId__c != null 
               && communityApi.acm_pkg__ApiId__c != '' 
               && communityApi.acm_pkg__AssetVersion__c != null 
               && communityApi.acm_pkg__AssetVersion__c != ''){
                   
                   String assetVersionId = communityApi.acm_pkg__ApiId__c +':'+ communityApi.acm_pkg__AssetVersion__c;
                   
                   List<acm_pkg__AnypointAssetCategories__x> anypointAssetCategories = [select Id, acm_pkg__DisplayName__c,
                                                                                        acm_pkg__Category__c, 
                                                                                        acm_pkg__AssetVersionId__c 
                                                                                        from acm_pkg__AnypointAssetCategories__x 
                                                                                        where acm_pkg__AssetVersionId__c =: assetVersionId ];																	   
                   if(!anypointAssetCategories.isEmpty()){
                       return anypointAssetCategories;
                   }else{
                       return null;
                   }
               }else{
                   return null;
               }
        }else{
            return null;
        }		
    }
    
    /**
	 * @description - It will read the communityApi related AnypointAssets.
     * @param apiId  - CommunityApi record id.
	 * @return List of acm_pkg__AnypointAssets__x records.
    **/	
    @AuraEnabled(cacheable=true)
    public static List<acm_pkg__AnypointAssets__x> getAnypointAssets(String apiId){
        if(String.isNotBlank(apiId)){
            
            acm_pkg__CommunityApi__c communityApi = [SELECT acm_pkg__ApiId__c, acm_pkg__Name__c 
                                                     FROM acm_pkg__CommunityApi__c 
                                                     WHERE id =:apiId limit 1];
													 
            if(communityApi != null && communityApi.acm_pkg__ApiId__c != null && communityApi.acm_pkg__ApiId__c != '' )
			{                   
				String assetApiId = communityApi.acm_pkg__ApiId__c;

				List<acm_pkg__AnypointAssets__x> anypointAssets = [SELECT Id, acm_pkg__Name__c, 
																			acm_pkg__Id__c, 
																			acm_pkg__ContactEmail__c 
																			FROM acm_pkg__AnypointAssets__x 
																			WHERE acm_pkg__Id__c=:assetApiId];
																			
				if(!anypointAssets.isEmpty()){
				   return anypointAssets;
				}else{
				   return null;
				}
            }else{
                return null;
            }
        }else{
            return null;
        }		
    }	
}