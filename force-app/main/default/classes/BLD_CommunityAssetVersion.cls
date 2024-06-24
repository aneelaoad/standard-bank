/**
 * @description buidler class for acm_pkg__CommunityAssetVersion__c
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class BLD_CommunityAssetVersion extends ABS_ObjectBuilderBase {
    public static final String COMMUNITY_NAME = 'TestCommunity';
    public static final String VERSION_GROUP = 'v1';
    public static final String PACKAGE_VERSION = '1.0.0';
    private Id parentAsset;

    /**
     * @description constructs a BLD_CommunityAssetVersion
     * 
     * @param workUnit
     */
    public BLD_CommunityAssetVersion(fflib_SObjectUnitOfWork workUnit) {
        super(acm_pkg__CommunityAssetVersion__c.SObjectType, workUnit);
    }

    /**
     * @description constructs a BLD_CommunityAssetVersion
     */
    public BLD_CommunityAssetVersion() {
        this(getNewUnitOfWork(new List<SObjectType>{acm_pkg__CommunityAssetVersion__c.SObjectType}));
    }

    /**
     * @description sets the default fields
     */
    protected override void setDefaultData() {
        setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__CommunityName__c, COMMUNITY_NAME)
            .setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__VersionGroup__c, VERSION_GROUP)
            .setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__Version__c, PACKAGE_VERSION)
            .setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__ParentAsset__c, parentAsset);
    }

    /**
     * @description sets the acm_pkg__ParentAsset__c field
     * 
     * @param parentAsset parent asset
     * @return BLD_CommunityAssetVersion object
     */
    public BLD_CommunityAssetVersion parentAsset(Id parentAsset) {
        return (BLD_CommunityAssetVersion) setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__ParentAsset__c, parentAsset);
    }

    /**
     * @description sets the acm_pkg__VersionGroup__c field
     * 
     * @param versionGroup version group
     * @return BLD_CommunityAssetVersion object
     */
    public BLD_CommunityAssetVersion versionGroup(string versionGroup) {
        return (BLD_CommunityAssetVersion) setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__VersionGroup__c, versionGroup);
    }

    /**
     * @description sets the acm_pkg__Version__c field
     * 
     * @param packageVersion package version
     * @return BLD_CommunityAssetVersion object
     */
    public BLD_CommunityAssetVersion packageVersion(string packageVersion) {
        return (BLD_CommunityAssetVersion) setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__Version__c, packageVersion);
    }

    /**
     * @description sets the acm_pkg__CommunityName__c field
     * 
     * @param communityName community name
     * @return BLD_CommunityAssetVersion object
     */
    public BLD_CommunityAssetVersion communityName(string communityName) {
        return (BLD_CommunityAssetVersion) setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__CommunityName__c, communityName);
    }

    /**
     * @description sets the acm_pkg__ParentGroupVersion__c field
     * 
     * @param parentGroupVersion parent group version
     * @return BLD_CommunityAssetVersion object
     */
    public BLD_CommunityAssetVersion parentGroupVersion(Id parentGroupVersion) {
        return (BLD_CommunityAssetVersion) setField(acm_pkg__CommunityAssetVersion__c.acm_pkg__ParentGroupVersion__c, parentGroupVersion);
    }
}