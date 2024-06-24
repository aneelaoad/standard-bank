/**
 * @description buidler class for acm_pkg__AnypointApiPages__x
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class BLD_AnypointApiPage extends ABS_ObjectBuilderBase {
    public static final string PAGE_CONTENT = 'test page content';
    public static final string PAGE_NAME = 'test page';
    private string assetVersionId;

    /**
     * @description constructs a BLD_AnypointApiPage
     * 
     * @param workUnit
     */
    public BLD_AnypointApiPage(fflib_SObjectUnitOfWork workUnit) {
        super(acm_pkg__AnypointApiPages__x.SObjectType, workUnit);
    }

    /**
     * @description constructs a BLD_AnypointApiPage
     */
    public BLD_AnypointApiPage() {
        this(getNewUnitOfWork(new List<SObjectType>{acm_pkg__AnypointApiPages__x.SObjectType}));
    }

    /**
     * @description sets the default fields
     */
    protected override void setDefaultData() {
        setField(acm_pkg__AnypointApiPages__x.acm_pkg__AssetVersionId__c, assetVersionId)
            .setField(acm_pkg__AnypointApiPages__x.acm_pkg__PageContent__c, PAGE_CONTENT)
            .setField(acm_pkg__AnypointApiPages__x.acm_pkg__PageName__c, PAGE_NAME);
    }

    /**
     * @description sets the acm_pkg__AssetVersionId__c field
     * 
     * @param assetVersionId asset version id
     * @return BLD_AnypointApiPage object
     */
    public BLD_AnypointApiPage assetVersionId(string assetVersionId) {
        return (BLD_AnypointApiPage) setField(acm_pkg__AnypointApiPages__x.acm_pkg__AssetVersionId__c, assetVersionId);
    }

    /**
     * @description sets the acm_pkg__PageContent__c field
     * 
     * @param pageContent page content
     * @return BLD_AnypointApiPage object
     */
    public BLD_AnypointApiPage pageContent(string pageContent) {
        return (BLD_AnypointApiPage) setField(acm_pkg__AnypointApiPages__x.acm_pkg__PageContent__c, pageContent);
    }

    /**
     * @description sets the acm_pkg__PageName__c field
     * 
     * @param pageName page name
     * @return BLD_AnypointApiPage object
     */
    public BLD_AnypointApiPage pageName(string pageName) {
        return (BLD_AnypointApiPage) setField(acm_pkg__AnypointApiPages__x.acm_pkg__PageName__c, pageName);
    }
}