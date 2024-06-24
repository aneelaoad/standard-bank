/**
    @ Author: Pradeep Jangid
    @ Date: 25th May, 2022
    @description: Test Class for AcmUserProfileInfoController
 */

@isTest
public with sharing class AcmUserProfileInfoControllerTest {
    
    @isTest
    private static void TestgetUserDetail_N() {
        Test.startTest();
            User usr = AcmUserProfileInfoController.getUserDetail('0053O123454voB1234');
            System.assertEquals(null, usr, 'user not found');
        Test.stopTest();
    }
    
    @isTest
    private static void TestgetUserDetail_P() {
        Test.startTest();
            Id userId = Userinfo.getUserId();
            User usr = AcmUserProfileInfoController.getUserDetail(userId);
            System.assertNotEquals(null, usr, 'user found');
        Test.stopTest();
    }

    @isTest
    private static void TestupdateUserDetail() {
        Test.startTest();
            Id userId = Userinfo.getUserId();
            User usr = AcmUserProfileInfoController.getUserDetail(userId);
            usr.CompanyName = 'Std Bank';
            String result = AcmUserProfileInfoController.updateUserDetail(usr);
            System.assertEquals('success', result, 'user has been updated');
        Test.stopTest();
    }
}