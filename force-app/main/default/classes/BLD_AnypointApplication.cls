/**
 * @description buidler class for acm_pkg__AnypointApplications__x
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class BLD_AnypointApplication extends ABS_ObjectBuilderBase {
    public static final String EXTERNAL_ID = 'test123';

    /**
     * @description constructs a BLD_AnypointApplication
     */
    public BLD_AnypointApplication() {
        this(getNewUnitOfWork(new List<SObjectType>{ acm_pkg__AnypointApplications__x.SObjectType }));
    }

    /**
     * @description constructs a BLD_AnypointApplication
     * 
     * @param workUnit
     */
    public BLD_AnypointApplication(fflib_SObjectUnitOfWork workUnit) {
        super(acm_pkg__AnypointApplications__x.SObjectType, workUnit);
    }

    /**
     * @description sets the default fields
     */
    protected override void setDefaultData() {
        setField(acm_pkg__AnypointApplications__x.ExternalId, EXTERNAL_ID);
    }

    /**
     * @description sets the ExternalId field
     * 
     * @param externalId exteral id
     * @return BLD_AnypointApplication object
     */
    public BLD_AnypointApplication externalId(string externalId) {
        return (BLD_AnypointApplication) setField(acm_pkg__AnypointApplications__x.ExternalId, externalId);
    }
}