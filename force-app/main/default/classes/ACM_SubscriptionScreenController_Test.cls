/**
  @description It will test the ACM_CommunityApiController class 
  @className ACM_SubscriptionScreenController  
  @Author - Purna Unnagiri
  @email 	purna.unnagiri@standardbank.co.za
  @company  Standardbank    
  @date  Oct 25 2022
**/ 
@isTest
public class ACM_SubscriptionScreenController_Test {
    
    /**
     * @description Positive test for getApiProducts where 
	 * all the required information is provided
    **/
    @IsTest
    public static void testGetApiProducts() {
        
		ACM_SubscriptionScreenController.ACM_SubscriptionScreenWrapperCls subscriptWrap = new 
		ACM_SubscriptionScreenController.ACM_SubscriptionScreenWrapperCls();		
		subscriptWrap.apiProductName = 'test';
		subscriptWrap.apiProductDescription = 'test';
		subscriptWrap.apiProductIconUrl = 'test';
		subscriptWrap.apiProductId = 'test';

		Test.startTest();
		
        acm_pkg__CommunityApi__c apiProduct = new acm_pkg__CommunityApi__c();		
        apiProduct.acm_pkg__Name__c = 'Account Verification Service';
		apiProduct.acm_pkg__Description__c = 'Test Description';
        apiProduct.acm_pkg__ApiId__c = 'bdd1bbab-b9f2-4d92-9ce1-c09421fa021f:account-verification-services';
        apiProduct.acm_pkg__AssetVersion__c = '1.0.0';
        apiProduct.acm_pkg__AssetType__c = 'api-group';
        apiProduct.acm_pkg__VersionGroup__c = 'v1';
        apiProduct.acm_pkg__Visibility__c = 'Public';
        insert apiProduct;

        acm_pkg__CommunityApi__c communityApi = new acm_pkg__CommunityApi__c();		
        communityApi.acm_pkg__Name__c = 'Account Verification Service API';
        communityApi.acm_pkg__ApiId__c = 'bdd1bbab-b9f2-4d92-9ce1-c09421fa021f:account-verification-service-api';
        communityApi.acm_pkg__AssetVersion__c = '1.0.0';
        communityApi.acm_pkg__AssetType__c = 'rest-api';
        communityApi.acm_pkg__VersionGroup__c = 'v1';
        communityApi.acm_pkg__Visibility__c = 'Public';
        insert communityApi;	

		Network communityRec = [SELECT id FROM Network where name='Internal API Marketplace' limit 1];
								
		acm_pkg__CommunityAssetVersion__c parentGroupVersion = new acm_pkg__CommunityAssetVersion__c();
		parentGroupVersion.acm_pkg__CommunityId__c = communityRec.Id; 
		parentGroupVersion.acm_pkg__VersionGroup__c = 'v1';
		parentGroupVersion.acm_pkg__Version__c = '1.0.0';
		parentGroupVersion.acm_pkg__Visibility__c = 'Public';
		parentGroupVersion.acm_pkg__ParentAsset__c = apiProduct.Id;
		insert parentGroupVersion;								
								
		acm_pkg__CommunityAssetVersion__c assetVersion = new acm_pkg__CommunityAssetVersion__c();
		assetVersion.acm_pkg__CommunityId__c = communityRec.Id;
		assetVersion.acm_pkg__VersionGroup__c = 'v1';
		assetVersion.acm_pkg__Version__c = '1.0.0';
		assetVersion.acm_pkg__Visibility__c = 'Public';
		assetVersion.acm_pkg__ParentAsset__c = communityApi.id;
		assetVersion.acm_pkg__ParentGroupVersion__c = parentGroupVersion.Id; 
		insert assetVersion;
        
		acm_pkg__AnypointAssets__x mockedRequest = new acm_pkg__AnypointAssets__x(
			acm_pkg__Id__c = apiProduct.acm_pkg__ApiId__c,
			acm_pkg__Icon__c = 'test'
		);

		ACM_SubscriptionScreenController.mockedRequests.add(mockedRequest);	        
        				
		System.assert(communityApi.Id != null, 'CommunityApi record id should not be null');
		List<ACM_SubscriptionScreenController.ACM_SubscriptionScreenWrapperCls> subscriptWrapList = 
		ACM_SubscriptionScreenController.getApiProducts(communityApi.Id, communityRec.Id);
       	System.assert(subscriptWrapList != null, 'Api Products should not be null'); 
        Test.stopTest();
    }
}