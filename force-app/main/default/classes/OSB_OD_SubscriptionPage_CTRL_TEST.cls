/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description test class for OSB_OD_SubscriptionPage_CTRL
 */
@IsTest
private class OSB_OD_SubscriptionPage_CTRL_TEST {
    private static final String APP_DISPLAY_NAME = 'Test App';
    private static final String APPLICATION = 'application';
    private static final String ANYPOINT_EXTERNAL_ID = '123Test';

    @IsTest
    static void shouldGetUserSubscriptionByAnypointId() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_AnypointApplications anypointAppSel = (SEL_AnypointApplications) mocks.mock(SEL_AnypointApplications.class);
        SEL_AcmSubscribers subsciberSel = (SEL_AcmSubscribers) mocks.mock(SEL_AcmSubscribers.class);

        Contact userContact = (Contact) new BLD_Contact().mock();
        ACM_Subscription__c subscription = (ACM_Subscription__c) new BLD_AcmSubscriber()
            .appDisplayName(APP_DISPLAY_NAME)
            .application(APPLICATION)
            .subscriber(userContact.Id)
            .mock();

        acm_pkg__AnypointApplications__x anypointApp = (acm_pkg__AnypointApplications__x) new BLD_AnypointApplication()
            .externalId(ANYPOINT_EXTERNAL_ID)
            .mock();

        mocks.startStubbing();
        mocks.when(subsciberSel.SObjectType()).thenReturn(ACM_Subscription__c.SObjectType);
        mocks.when(anypointAppSel.SObjectType()).thenReturn(acm_pkg__AnypointApplications__x.SObjectType);
        mocks.when(anypointAppSel.selectAnypointAppById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<acm_pkg__AnypointApplications__x>{ anypointApp });
        mocks.when(subsciberSel.selectSubscriptionsByAnypointAppId((Set<string>) fflib_Match.anyObject()))
            .thenReturn(new List<ACM_Subscription__c>{ subscription });
        mocks.stopStubbing();

        ORG_Application.selector.setMock(subsciberSel);
        ORG_Application.selector.setMock(anypointAppSel);

        Test.startTest();
        ACM_Subscription__c subscriber = OSB_OD_SubscriptionPage_CTRL.getUserSubscriptionByAnypointId((string) anypointApp.Id);
        Test.stopTest();

        System.assertEquals(subscription, subscriber, 'did not fetch the correct subscriber');
    }
}