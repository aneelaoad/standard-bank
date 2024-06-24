/**
  @description It will test the ACM_CommunityApiController class 
  @className ACM_CommunityApiController_Test  
  @Author - Purna Unnagiri
  @email 	purna.unnagiri@standardbank.co.za
  @company  Standardbank    
  @date  Sep 13 2022
**/ 
@isTest
public class ACM_CommunityApiController_Test {
    
    /**
     * @description Positive test for getAnypointAssetCategories where 
	 * all the required information is provided
    **/
    @IsTest
    public static void testGetAnypointAssetCategories() {
        
        acm_pkg__CommunityApi__c communityApi = new acm_pkg__CommunityApi__c();
        communityApi.acm_pkg__Name__c = 'Example API';
        communityApi.acm_pkg__ApiId__c = 'bdd1bbab-b9f2-4d92-9ce1-c09421fa021f:hello-world';
        communityApi.acm_pkg__AssetVersion__c = '2.0.0';
        communityApi.acm_pkg__AssetType__c = 'rest-api';
        communityApi.acm_pkg__VersionGroup__c = 'v2';
        communityApi.acm_pkg__Visibility__c = 'Public';        
        insert communityApi;
        
		Test.startTest();		
		System.assert(communityApi.Id != null, 'CommunityApi record id should not be null');
		List<acm_pkg__AnypointAssetCategories__x> anypointAssetCategories = ACM_CommunityApiController.getAnypointAssetCategories(communityApi.Id);
       	System.assert(anypointAssetCategories == null, 'AnypointAssetCategories should be null'); 
        Test.stopTest();
    }

    /**
     * @description Positive test for getAnypointAssets where 
	 * all the required information is provided
    **/	
    @IsTest
    public static void testGetAnypointAssets() {
        acm_pkg__CommunityApi__c communityApi = new acm_pkg__CommunityApi__c();
        communityApi.acm_pkg__Name__c = 'Example API';
        communityApi.acm_pkg__ApiId__c = 'bdd1bbab-b9f2-4d92-9ce1-c09421fa021f:hello-world';
        communityApi.acm_pkg__AssetVersion__c = '2.0.0';
        communityApi.acm_pkg__AssetType__c = 'rest-api';
        communityApi.acm_pkg__VersionGroup__c = 'v2';
        communityApi.acm_pkg__Visibility__c = 'Public';        
        insert communityApi;
        
		Test.startTest();
        System.assert(communityApi.Id != null, 'CommunityApi record id should not be null');
		List<acm_pkg__AnypointAssets__x> anypointAssets = ACM_CommunityApiController.getAnypointAssets(communityApi.Id);
       	System.assert(anypointAssets == null, 'anypointAssets should be null'); 
        Test.stopTest();
    }
    
    /**
     * @description Negative test for getAnypointAssetCategories where 
	 * all the required information is provided
    **/
    @IsTest
    public static void testGetAnypointAssetCategoriesNegative() {                
		Test.startTest();
            List<acm_pkg__AnypointAssetCategories__x> anypointAssetCategories = ACM_CommunityApiController.getAnypointAssetCategories(null);
            System.assert(anypointAssetCategories == null, 'AnypointAssetCategories should be null');
        Test.stopTest();
    }

    /**
     * @description Negative test for getAnypointAssets where 
	 * all the required information is provided
    **/	
    @IsTest
    public static void testGetAnypointAssetsNegative() {
		Test.startTest();
            List<acm_pkg__AnypointAssets__x> anypointAssets = ACM_CommunityApiController.getAnypointAssets(null);
            System.assert(anypointAssets == null, 'anypointAssets should be null');
        Test.stopTest();
    }    
}