/**
 * Builder class for Service Type SObject
 * <br/>US-4178
 *
 * @author		Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date		March 2020
 */
@IsTest
public without sharing class BLD_ServiceType extends ABS_ObjectBuilderBase {
    public static final String CATEGORY = 'Test CATEGORY';
    public static final String SERVICE_TYPE = 'Service Request';
    public static final String SUB_CATEGORY = 'Test SUB_CATEGORY';
    public BLD_ServiceType() {
        this(getNewUnitOfWork());
    }

    public BLD_ServiceType(fflib_SObjectUnitOfWork uow) {
        super(Service_Type__c.SObjectType, uow);
    }

    public BLD_ServiceType entitlementId(Id entitlementId) {
        return (BLD_ServiceType) setField(Service_Type__c.Entitlement__c, entitlementId);
    }
	public BLD_ServiceType setRequiredFields() {
        return (BLD_ServiceType) setField(Service_Type__c.Category__c, CATEGORY)
                                .setField(Service_Type__c.ServiceType__c, SERVICE_TYPE)
                                .setField(Service_Type__c.Sub_Category__c, SUB_CATEGORY);
    }
    public BLD_ServiceType cibServiceTier(String ServiceTier) {
        return (BLD_ServiceType) setField(Service_Type__c.CIB_Service_Tier__c, ServiceTier);
    }
    public BLD_ServiceType useTeam(String user_team) {
        return (BLD_ServiceType) setField(Service_Type__c.User_Team__c, user_team);
    }

    public BLD_ServiceType serviceType(String pickServiceType) {
        return (BLD_ServiceType) setField(Service_Type__c.ServiceType__c, pickServiceType);
    }

}