/**
 * @description       : Builder class for EAP_Venue__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-28-2021   TCK   Initial Version
**/
public without sharing class BLD_EAP_Venue extends ABS_ObjectBuilderBase {
    public static final String DEF_NAME = 'testEAP_EventVenue';
    public static final String DEF_LOCATION = 'testLocation';
    public static final String DEF_DESCRIPTION = 'testDescription';
    public static final String DEF_BUILDING_NAME = 'testBuildingName';
    public static final String DEF_WEBSITE = 'testWebsite';
    public static final String DEF_CONTACT_PHONE = '123456789';
    public static final String DEF_SERVICE_CAPABILITY = 'Private Rooms;Free Wifi;Food and Beverage';
    public static final String DEF_PARKING = 'testParking';
    public static final String DEF_TRAVEL_ADVICE = 'testTravelAdvice';

    private static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_Venue(fflib_SObjectUnitOfWork uow) {
        super(EAP_Venue__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_Venue__c.Name, counter + DEF_NAME + counter)
        .setField(EAP_Venue__c.EAP_Location__c, DEF_LOCATION)
        .setField(EAP_Venue__c.EAP_Description__c, DEF_DESCRIPTION)
        .setField(EAP_Venue__c.EAP_BuildingName__c, DEF_BUILDING_NAME)
        .setField(EAP_Venue__c.EAP_Address__c, DEF_LOCATION)
        .setField(EAP_Venue__c.EAP_Website__c, DEF_WEBSITE)
        .setField(EAP_Venue__c.EAP_ContactPhone__c, DEF_CONTACT_PHONE)
        .setField(EAP_Venue__c.EAP_ServiceCapability__c, DEF_SERVICE_CAPABILITY)
        .setField(EAP_Venue__c.EAP_Parking__c, DEF_PARKING)
        .setField(EAP_Venue__c.EAP_TravelAdvice__c, DEF_TRAVEL_ADVICE);

        counter++;
    }
}