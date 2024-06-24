/**
 * @description buidler class for ACM_Subscription__c
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class BLD_AcmSubscriber extends ABS_ObjectBuilderBase {
    public static final String APP_DISPLAY_NAME = 'Test App';

    /**
     * @description constructs a BLD_AcmSubscriber
     */
    public BLD_AcmSubscriber() {
        this(getNewUnitOfWork(new List<SObjectType>{ ACM_Subscription__c.SObjectType }));
    }

    /**
     * @description constructs a BLD_AcmSubscriber
     * 
     * @param workUnit
     */
    public BLD_AcmSubscriber(fflib_SObjectUnitOfWork workUnit) {
        super(ACM_Subscription__c.SObjectType, workUnit);
    }

    /**
     * @description sets the default fields
     */
    protected override void setDefaultData() {
        setField(ACM_Subscription__c.Application_Display_Name__c, APP_DISPLAY_NAME);
    }

    /**
     * @description sets the Application_Display_Name__c field
     * 
     * @param appDisplayName application display name
     * @return BLD_AcmSubscriber object
     */
    public BLD_AcmSubscriber appDisplayName(string appDisplayName) {
        return (BLD_AcmSubscriber) setField(ACM_Subscription__c.Application_Display_Name__c, appDisplayName);
    }

    /**
     * @description sets the Application_T__c field
     * 
     * @param application application
     * @return BLD_AcmSubscriber object
     */
    public BLD_AcmSubscriber application(string application) {
        return (BLD_AcmSubscriber) setField(ACM_Subscription__c.Application_T__c, application);
    }

    /**
     * @description sets the ACM_Subscriber__c field
     * 
     * @param subscriber subscriber
     * @return BLD_AcmSubscriber object
     */
    public BLD_AcmSubscriber subscriber(Id subscriber) {
        return (BLD_AcmSubscriber) setField(ACM_Subscription__c.ACM_Subscriber__c, subscriber);
    }
}