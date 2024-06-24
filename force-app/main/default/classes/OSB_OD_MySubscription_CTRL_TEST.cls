/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for OSB_OD_MySubscription_CTRL
 */
@IsTest
private class OSB_OD_MySubscription_CTRL_TEST {
    private static final String APP_DISPLAY_NAME = 'Test App';
    private static final String APPLICATION = 'application';
    private static final String ANYPOINT_EXTERNAL_ID = '123Test';

    @IsTest
    static void shouldGetUserSubscriptions() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_AcmSubscribers subsciberSel = (SEL_AcmSubscribers) mocks.mock(SEL_AcmSubscribers.class);
        SEL_Contacts contactSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact userContact = (Contact) new BLD_Contact().mock();
        ACM_Subscription__c subscription = (ACM_Subscription__c) new BLD_AcmSubscriber()
            .appDisplayName(APP_DISPLAY_NAME)
            .application(APPLICATION)
            .subscriber(userContact.Id)
            .mock();

        mocks.startStubbing();
        mocks.when(subsciberSel.SObjectType()).thenReturn(ACM_Subscription__c.SObjectType);
        mocks.when(contactSel.SObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(subsciberSel.selectSubscriptionsByUserContactId((Set<string>) fflib_Match.anyObject()))
            .thenReturn(new List<ACM_Subscription__c>{ subscription });
        mocks.when(contactSel.selectByUserId((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Contact>{ userContact });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(subsciberSel);
        ORG_Application.selector.setMock(contactSel);

        Test.startTest();
        List<ACM_Subscription__c> subscriptions = OSB_OD_MySubscription_CTRL.getUserSubscriptions();
        Test.stopTest();

        System.assertEquals(APP_DISPLAY_NAME, subscriptions[0].Application_Display_Name__c, 'Did not get the correct subscription');
    }

    @IsTest
    static void shouldGetAnypointApplication() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_AnypointApplications anypointAppSel = (SEL_AnypointApplications) mocks.mock(SEL_AnypointApplications.class);

        acm_pkg__AnypointApplications__x anypointApp = (acm_pkg__AnypointApplications__x) new BLD_AnypointApplication()
            .externalId(ANYPOINT_EXTERNAL_ID)
            .mock();

        mocks.startStubbing();
        mocks.when(anypointAppSel.SObjectType()).thenReturn(acm_pkg__AnypointApplications__x.SObjectType);
        mocks.when(anypointAppSel.selectAnypointAppByExternalId((Set<string>) fflib_Match.anyObject())).thenReturn(new List<acm_pkg__AnypointApplications__x>{anypointApp});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(anypointAppSel);

        Test.startTest();
        acm_pkg__AnypointApplications__x testAnypointApp = OSB_OD_MySubscription_CTRL.getAnypointApplication(ANYPOINT_EXTERNAL_ID);
        Test.stopTest();

        System.assertEquals(anypointApp.Id, testAnypointApp.Id, 'Did not get the correct subscription');
    }
}