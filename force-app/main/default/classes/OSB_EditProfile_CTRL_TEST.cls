/**
 * Test class for OSB_EditProfile_CTRL
 * <br/>
 *
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date June 2020
 *
 **/
@isTest
public class OSB_EditProfile_CTRL_TEST {
    
    @isTest
    static void shouldCheckLoginStatus(){
        Test.startTest();
        Boolean isLoggedIn = OSB_EditProfile_CTRL.isUserLoggedIn();
        Test.stopTest();
        System.assert(isLoggedIn);
    }
    
    @isTest
    static void shouldGetUserDetails(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_PingIntegration serviceMock = (OSB_SRV_PingIntegration) mocks.mock(OSB_SRV_PingIntegration.class);
        ORG_Application.service.setMock(OSB_SRV_PingIntegration.IService.class, serviceMock);
        
        Test.startTest();
        Map<String,Map<String, String>> responseMap = OSB_EditProfile_CTRL.getUserDetails();
        Test.stopTest();
        ((OSB_SRV_PingIntegration) mocks.verify(serviceMock, 1)).
            getUserDetails();
        System.assert(responseMap.get(OSB_EditProfile_CTRL.KEY_PROFILE_PIC_INFO).get(OSB_EditProfile_CTRL.KEY_PROFILE_PIC).contains('profilephoto'));
    }
    
    @isTest
    static void shouldGetIndustryPicklistValues(){
        Test.startTest();
        List<String> resultIndustries = OSB_EditProfile_CTRL.getIndustryPicklistValues();
        Test.stopTest();
        System.assertEquals(UTL_Picklist.getPicklistValues(Contact.Company_Industry__c).size(), resultIndustries.size());
    }
    
    @isTest
    static void shouldGetCountryPicklistValues(){
        Test.startTest();
        List<String> resultCountryCodes = OSB_EditProfile_CTRL.getCountryCodes();
        Test.stopTest();
        System.assertEquals(UTL_Picklist.getPicklistValues(Contact.Phone_Country__c).size(), resultCountryCodes.size());
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    static void shouldUpdateUserProfile(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_PingIntegration serviceMock = (OSB_SRV_PingIntegration) mocks.mock(OSB_SRV_PingIntegration.class);
        ORG_Application.service.setMock(OSB_SRV_PingIntegration.IService.class, serviceMock);
       
        Test.startTest();
        OSB_EditProfile_CTRL.updateUserProfile(new Map<String,String>());
        Test.stopTest();
        ((OSB_SRV_PingIntegration) mocks.verify(serviceMock, 1)).
            updateUserProfile((Map<String,String>) fflib_Match.anyObject());
    }

    @SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
    @isTest(seeAllData=true)
    static void shouldUpdateUserProfilePicture(){
        String profilePicString = '/9j/4AAQSkZJRgABAQEAeAB4AAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwYHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAALAAgDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAn/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFAEBAAAAAAAAAAAAAAAAAAAAAP/EABQRAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AL+AA//Z';
        Test.startTest();
        OSB_EditProfile_CTRL.updateUserProfilePic(profilePicString,UserInfo.getUserId());
        Integer numberOfDMLStatements = Limits.getDMLStatements(); //Connect Api counts towards dml limit
        Test.stopTest();
        System.assertEquals(1, numberOfDMLStatements);
    }
}