/**
 * @description buidler class for acm_pkg__CommunityApi__c
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class BLD_CommunityApi extends ABS_ObjectBuilderBase {
    public static final String ASSET_VERSION = '1.0.0';
    public static final String PKG_NAME = 'Test Api';
    public static final String ASSET_TYPE = 'api-group';
    public static final String COMMUNITY_NAME = 'TestCommunity';
    public static final String API_ID = 'test123test';

    /**
     * @description constructs a BLD_CommunityApi
     * 
     * @param workUnit
     */
    public BLD_CommunityApi() {
        this(getNewUnitOfWork(new List<SObjectType>{acm_pkg__CommunityApi__c.SObjectType}));
    }

    /**
     * @description constructs a BLD_CommunityApi
     * 
     * @param workUnit
     */
    public BLD_CommunityApi(fflib_SObjectUnitOfWork workUnit) {
        super(acm_pkg__CommunityApi__c.SObjectType, workUnit);
    }  

    /**
     * @description sets the default fields
     */
    protected override void setDefaultData() {
        setField(acm_pkg__CommunityApi__c.acm_pkg__AssetVersion__c, ASSET_VERSION)
        .setField(acm_pkg__CommunityApi__c.acm_pkg__Name__c, PKG_NAME)
        .setField(acm_pkg__CommunityApi__c.acm_pkg__AssetType__c, ASSET_TYPE)
        .setField(acm_pkg__CommunityApi__c.acm_pkg__ApiId__c, API_ID)
        .setField(acm_pkg__CommunityApi__c.acm_pkg__CommunityName__c, COMMUNITY_NAME);
    }

    /**
     * @description sets the acm_pkg__Name__c field
     * 
     * @param packageName package name
     * @return BLD_CommunityApi object
     */
    public BLD_CommunityApi packageName(string packageName) {
        return (BLD_CommunityApi)setField(acm_pkg__CommunityApi__c.acm_pkg__Name__c, packageName);
    }

    /**
     * @description sets the acm_pkg__AssetVersion__c field
     * 
     * @param assetVersion asset version
     * @return BLD_CommunityApi object
     */
    public BLD_CommunityApi assetVersion(string assetVersion) {
        return (BLD_CommunityApi)setField(acm_pkg__CommunityApi__c.acm_pkg__AssetVersion__c, assetVersion);
    }

    /**
     * @description sets the acm_pkg__AssetType__c field
     * 
     * @param assetType asset type
     * @return BLD_CommunityApi object
     */
    public BLD_CommunityApi assetType(string assetType) {
        return (BLD_CommunityApi)setField(acm_pkg__CommunityApi__c.acm_pkg__AssetType__c, assetType);
    }

    /**
     * @description sets the acm_pkg__CommunityName__c field
     * 
     * @param communityName community name
     * @return BLD_CommunityApi object
     */
    public BLD_CommunityApi communityName(string communityName) {
        return (BLD_CommunityApi)setField(acm_pkg__CommunityApi__c.acm_pkg__CommunityName__c, communityName);
    }

    /**
     * @description sets the acm_pkg__ApiId__c field
     * 
     * @param apiId api id
     * @return BLD_CommunityApi object
     */
    public BLD_CommunityApi apiId(string apiId) {
        return (BLD_CommunityApi)setField(acm_pkg__CommunityApi__c.acm_pkg__ApiId__c, apiId);
    }
}