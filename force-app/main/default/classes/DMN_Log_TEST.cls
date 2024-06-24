/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-12-2022
 * @last modified by  : TCK
**/
@IsTest
public with sharing class DMN_Log_TEST {
    @IsTest
    public static void testConstructedLog() {
        Test.startTest();
        DMN_Log inst = new DMN_Log();
        Test.stopTest();

        System.assertEquals('Digisign_CommB', DMN_Log.AREA_COMMB);
        System.assertEquals('Account Onboarding', DMN_Log.AREA_AOB);
        System.assertEquals('OneHub', DMN_Log.AREA_ONEHUB);
        System.assertEquals('PartnerPortal', DMN_Log.AREA_PARTNERPORTAL);
        System.assertEquals('IB_DCP', DMN_Log.AREA_IB_DCP);
        System.assertEquals('RegistrationHandler', DMN_Log.AREA_REGISTRATION_HANDLER);
        System.assertEquals('EventsApp', DMN_Log.AREA_EVENTSAPP);
        System.assertEquals('PBB Gateway API integration', DMN_Log.AREA_PBB_GATEWAY);
        System.assertEquals('Partner Sync Merge Integration', DMN_Log.AREA_PBB_PARTNER_SYNC);
        System.assertEquals('ServiceCloud', DMN_Log.AREA_SERVICECLOUD);
        System.assertEquals('ERROR', DMN_Log.TYPE_ERROR);
        System.assertEquals('INFO', DMN_Log.TYPE_INFO);
        System.assertEquals('RelatedParty', DMN_Log.AREA_RELATEDPARTY);
        System.assertEquals('CIB CCAP Integration', DMN_Log.AREA_CIB_CCAP);
    }
}