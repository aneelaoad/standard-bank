/**
 * 
 * @description Test Class for MallProfileManagementController
 * @author Ankit Kumar
 * @since 
 */
@isTest
public with sharing class MallProfileManagementControllerTest {
    
    @IsTest
    static void getUserProfileTest(){
        Test.startTest();
        MallProfileManagementController.UserProfile userProfile = MallProfileManagementController.getUserProfile(UserInfo.getUserId());
        Assert.areEqual(UserInfo.getUserId(), userProfile.user.Id, 'profile does not exist');
        Test.stopTest();
    }
    
    @IsTest
    static void updateRecordsTest() {
        provider__c provider = new Provider__c();
        provider.Name = 'Test provider';
        provider.Status__c = 'Draft';
        insert provider;

        Test.startTest();
        provider.Name += ' updated';
        MallProfileManagementController.updateRecords(new List<Provider__c>{provider});
        List<Provider__c> providers = SEL_Providers.newInstance().selectByIds(new Set<Id>{(Id)provider.Id});
        MallProfileManagementController.updateRecords(new List<Provider__c>{provider});
        assert.areEqual(true, String.IsNotBlank(providers[0].Name), 'should not be blank');
        Test.stopTest();
    }
}