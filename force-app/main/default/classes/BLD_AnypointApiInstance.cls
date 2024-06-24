/**
 * @description buidler class for acm_pkg__AnypointApiInstances__x
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date February 2023
 */
public without sharing class BLD_AnypointApiInstance extends ABS_ObjectBuilderBase {
    public static final String ENDPOINT = 'www.testurl.co.za/testendpoint';
    public static final String ENVIRONMENT = 'testenv';

    /**
     * @description constructs a BLD_AnypointApiInstance
     *
     * @param workUnit
     */
    public BLD_AnypointApiInstance() {
        this(
            getNewUnitOfWork(
                new List<SObjectType>{
                    acm_pkg__AnypointApiInstances__x.SObjectType
                }
            )
        );
    }

    /**
     * @description constructs a BLD_AnypointApiInstance
     *
     * @param workUnit
     */
    public BLD_AnypointApiInstance(fflib_SObjectUnitOfWork workUnit) {
        super(acm_pkg__AnypointApiInstances__x.SObjectType, workUnit);
    }

    /**
     * @description sets the default fields
     */
    protected override void setDefaultData() {
        setField(
                acm_pkg__AnypointApiInstances__x.acm_pkg__Endpoint__c,
                ENDPOINT
            )
            .setField(
                acm_pkg__AnypointApiInstances__x.acm_pkg__EnvironmentName__c,
                ENVIRONMENT
            );
    }

    /**
     * @description sets the acm_pkg__Endpoint__c field
     *
     * @param endpoint
     * @return BLD_AnypointApiInstance object
     */
    public BLD_AnypointApiInstance endpoint(string endpoint) {
        return (BLD_AnypointApiInstance) setField(
            acm_pkg__AnypointApiInstances__x.acm_pkg__Endpoint__c,
            endpoint
        );
    }

    /**
     * @description sets the acm_pkg__EnvironmentName__c field
     *
     * @param environment
     * @return BLD_AnypointApiInstance object
     */
    public BLD_AnypointApiInstance environment(string environment) {
        return (BLD_AnypointApiInstance) setField(
            acm_pkg__AnypointApiInstances__x.acm_pkg__EnvironmentName__c,
            environment
        );
    }
}