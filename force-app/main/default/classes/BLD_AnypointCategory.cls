/**
 * @description buidler class for acm_pkg__AnypointAssetCategories__x
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class BLD_AnypointCategory extends ABS_ObjectBuilderBase {
    public static final string CATEGORY = 'Category:testCategory';

    /**
     * @description constructs a BLD_AnypointCategory
     */
    public BLD_AnypointCategory() {
        this(getNewUnitOfWork(new List<SObjectType>{ acm_pkg__AnypointAssetCategories__x.SObjectType }));
    }

    /**
     * @description constructs a BLD_AnypointCategory
     * 
     * @param workUnit
     */
    public BLD_AnypointCategory(fflib_SObjectUnitOfWork workUnit) {
        super(acm_pkg__AnypointAssetCategories__x.SObjectType, workUnit);
    }
    /**
     * @description sets the default fields
     */
    protected override void setDefaultData() {
        setField(acm_pkg__AnypointAssetCategories__x.acm_pkg__Category__c, CATEGORY);
    }

    /**
     * @description sets the acm_pkg__Category__c field
     * 
     * @param category category
     * @return BLD_AnypointCategory object
     */
    public BLD_AnypointCategory category(string category) {
        return (BLD_AnypointCategory) setField(acm_pkg__AnypointAssetCategories__x.acm_pkg__Category__c, category);
    }

    /**
     * @description sets the acm_pkg__AssetId__c field
     * 
     * @param assetId asset id
     * @return BLD_AnypointCategory object
     */
    public BLD_AnypointCategory assetId(string assetId) {
        return (BLD_AnypointCategory) setField(acm_pkg__AnypointAssetCategories__x.acm_pkg__AssetId__c, assetId);
    }
}