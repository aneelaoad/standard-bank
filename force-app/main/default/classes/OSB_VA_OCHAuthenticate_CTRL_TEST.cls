/**
 * @description Test class for OSB_VA_OCHAuthenticate_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 *  
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@IsTest
public with sharing class OSB_VA_OCHAuthenticate_CTRL_TEST {
    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static final String BALANCE_INQUIRY = 'Balance inquiry';
    private static final String EMAIL_STATEMENT = 'Email statement';
    private static final String COMPANY_NAME = 'Company1';
    
    @TestSetup
    @SuppressWarnings('PMD.UnusedLocalVariable')
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account accBld1 = new BLD_Account(uow).CIF('12345').Name(COMPANY_NAME);
        BLD_Contact conBld = new BLD_Contact(uow)
                .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                .email(TEST_USER_EMAIL)
                .ownerId(UserInfo.getUserId())
                .cifNumber('12345')
                .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                .account(
                        accBld1
                );
        uow.commitWork();
    }

    @IsTest
    public static void testNoTokenResponseError() {
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(400, 'Bad Request', '', null);
        OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput input = new OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput();
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenOutput> outputs = OSB_VA_OCHAuthenticate_CTRL.authenticate(new List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput>{
                input
        });
        Test.stopTest();
        System.assertEquals(1, outputs.size(), 'Should return 1 output');
        System.assertEquals(System.Label.OSB_VA_BA_TechnicalErrorSingle, outputs.get(0).errorMessage, 'Should return Error message: ' + System.Label.OSB_VA_BA_TechnicalErrorSingle);
        System.assertEquals(null, outputs.get(0).accessToken, 'Should return null');
        System.assertEquals(true, outputs.get(0).hasError, 'Should return true');
    }

    @IsTest
    public static void testNoTokenSuccess() {
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3","token_type":"bearer","expires_in":20}';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'OK', responseBody, null);
        OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput input = new OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput();
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenOutput> outputs = OSB_VA_OCHAuthenticate_CTRL.authenticate(new List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput>{
                input
        });
        Test.stopTest();
        System.assertEquals(1, outputs.size(), 'Should return 1 output');
        System.assertEquals(null, outputs.get(0).errorMessage, 'Should return null');
        System.assertEquals('B684723E8E51DD98FA6BBF83BBBEA462D5342E84', outputs.get(0).accessToken, 'Should return B684723E8E51DD98FA6BBF83BBBEA462D5342E84');
    }

    @IsTest
    public static void testError500() {
        DCS_API_Token__c accessToken = new DCS_API_Token__c(Name='OCH Token');
        accessToken.Access_Token__c = 'AccessToken';
        accessToken.Refresh_Token__c = 'RefreshToken';
        accessToken.Created_Time__c = null;
        insert accessToken;
        
        OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput input = new OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput();
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        String responseBody = '{"access_token":"C784723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3","token_type":"bearer","expires_in":20}';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(500, 'Error', responseBody, null);        
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenOutput> outputs = OSB_VA_OCHAuthenticate_CTRL.authenticate(new List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput>{
                input
        });
        Test.stopTest();
        System.assertEquals(1, outputs.size(), 'Should return 1 output');
    }

    @IsTest
    public static void testNoValidInput() {
        String responseBody = '{"access_token":"C784723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3","token_type":"bearer","expires_in":20}';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'OK', responseBody, null);
        
        OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput input = new OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput();
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenOutput> outputs = OSB_VA_OCHAuthenticate_CTRL.authenticate(new List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput>{
                input
        });
        Test.stopTest();
        System.assertEquals(1, outputs.size(), 'Should return 1 output');
    }
}