/**
 * @description       : Builder class for EAP_EventVenue__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-30-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-28-2021   TCK   Initial Version
**/
public without sharing class BLD_EAP_EventVenue extends ABS_ObjectBuilderBase {
    public static final String DEF_NAME = 'testEAP_EventVenue';
    private static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_EventVenue(fflib_SObjectUnitOfWork uow) {
        super(EAP_EventVenue__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_EventVenue__c.Name, counter + DEF_NAME + counter);
        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_EventVenue 
    **/
    public BLD_EAP_EventVenue event(BLD_EAP_AppEvent eventBuilder) {
        return (BLD_EAP_EventVenue) setRelation(EAP_EventVenue__c.EAP_AppEvent__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param venueBuilder 
    * @return BLD_EAP_EventVenue 
    **/
    public BLD_EAP_EventVenue venue(BLD_EAP_Venue venueBuilder) {
        return (BLD_EAP_EventVenue) setRelation(EAP_EventVenue__c.EAP_Venue__c, venueBuilder);
    }
}