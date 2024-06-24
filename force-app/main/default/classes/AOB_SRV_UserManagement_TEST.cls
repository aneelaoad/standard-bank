/**
* Test class for AOB_SRV_UserManagement methods
* 
* <p></p>
*
* @author Asmae ESSBAI (aessbai@salesforce.com)
*
* @date Oct 26th 2021
*/
@IsTest
private class AOB_SRV_UserManagement_TEST {
    
	@TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
	 * @description Method used to Test create Account 
	 */
    @isTest
    public static void createAccountTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Map<String, String> attributeMap = new Map<String,String>();
        attributeMap.put(AOB_Constants.ID_STRING, 'XXXXX');
        attributeMap.put(AOB_Constants.PING_BPID, 'XXXXX');
        attributeMap.put(AOB_Constants.PING_SUB, 'sub@gmail.com');
        attributeMap.put(AOB_Constants.CUSTOMER_CC, 'XXXXXXXX');
        attributeMap.put(AOB_Constants.COMMERCE_SITE_ID, 'SB-COZA');
        attributeMap.put(AOB_Constants.NATIONAL_ID, 'XXXXXXXX');
        attributeMap.put(AOB_Constants.PING_BPGUID, AOB_Utils.generateGUID());
        attributeMap.put(AOB_Constants.PING_NAME, 'Test Name');
        Account acc = AOB_SRV_UserManagement.createAccount(attributeMap);
        System.assertNotEquals(null,acc);
    }
    
     /**
	 * @description Method used to Test create Contact 
	 */
    @isTest
    public static void createContactTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        //Create Test Account first, needed to link to Contact
        Map<String, String> accountAttributeMap = new Map<String,String>();
        accountAttributeMap.put(AOB_Constants.ID_STRING, 'XXXXX');
        accountAttributeMap.put(AOB_Constants.PING_BPID, 'XXXXX');
        accountAttributeMap.put(AOB_Constants.PING_SUB, 'sub@gmail.com');
        accountAttributeMap.put(AOB_Constants.CUSTOMER_CC, 'XXXXXXXX');
        accountAttributeMap.put(AOB_Constants.COMMERCE_SITE_ID, 'SB-COZA');
        accountAttributeMap.put(AOB_Constants.NATIONAL_ID, 'XXXXXXXX');
        accountAttributeMap.put(AOB_Constants.PING_BPGUID, AOB_Utils.generateGUID());
        accountAttributeMap.put(AOB_Constants.PING_NAME, 'Test Name');
        Account acc = AOB_SRV_UserManagement.createAccount(accountAttributeMap);

        //Create Test Contact
        Map<String, String> attributeMap = new Map<String,String>();
        attributeMap.put(AOB_Constants.PING_LAST_NAME, 'test');
        attributeMap.put(AOB_Constants.PING_FIRST_NAME, 'first');
        attributeMap.put(AOB_Constants.PING_EMAIL, 'a@gmail.com');
        attributeMap.put(AOB_Constants.ID_STRING, 'XXXXX');
        attributeMap.put(AOB_Constants.PING_BPID, 'XXXXX');
        attributeMap.put(AOB_Constants.PING_SUB, 'sub@gmail.com');
        attributeMap.put(AOB_Constants.CUSTOMER_CC, 'XXXXXXXX');
        attributeMap.put(AOB_Constants.COMMERCE_SITE_ID, 'SB-COZA');
        attributeMap.put(AOB_Constants.NATIONAL_ID, 'XXXXXXXX');
        attributeMap.put(AOB_Constants.PING_BPGUID, AOB_Utils.generateGUID());
        Contact contact = AOB_SRV_UserManagement.createContact(attributeMap, acc.Id);
        System.assertNotEquals(null,contact);
    }
    @isTest
    public static void assignPermUserTest(){
        List<User> communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Set<Id> userIds = new Set<Id>{communityUser[0].Id};
        Set<Id> contactIds = new Set<Id>{communityUser[0].contactId};
        AOB_OnboardingSetting__mdt setting=AOB_Utils.getOnboardingSettings('SB-COZA');
        String EXTERNAL_USER_PERMISSION = setting.AOB_PermissionSet__c;
        Test.startTest();
         AOB_SRV_UserManagement.assignPermissionSet(communityUser,userIds,contactIds);
        Test.stopTest();
    
        Map<Id,boolean> id2hasPermission = new  Map<Id,boolean>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        PermissionSet customerPerm = [SELECT Id FROM PermissionSet WHERE Name =:EXTERNAL_USER_PERMISSION];
        List<PermissionSetAssignment> permissionList = [SELECT Id,AssigneeId FROM PermissionSetAssignment
                                                	WHERE PermissionSetId =:customerPerm.Id AND AssigneeId IN :userIds]; 
        System.assertEquals(1, permissionList.size());
    }
    /**
	 * @description Method used to Test create Preson Account 
	 */
    @isTest
    public static void createUserTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        String EXTERNAL_USER_PROFILE = 'AOB_Authenticated Customer Community';
        //Create Test Account first, needed to link to Contact
        Map<String, String> accountAttributeMap = new Map<String,String>();
        accountAttributeMap.put(AOB_Constants.ID_STRING, 'XXXXX');
        accountAttributeMap.put(AOB_Constants.PING_BPID, 'XXXXX');
        accountAttributeMap.put(AOB_Constants.PING_SUB, 'sub@gmail.com');
        accountAttributeMap.put(AOB_Constants.CUSTOMER_CC, 'XXXXXXXX');
        accountAttributeMap.put(AOB_Constants.COMMERCE_SITE_ID, 'SB-COZA');
        accountAttributeMap.put(AOB_Constants.NATIONAL_ID, 'XXXXXXXX');
        accountAttributeMap.put(AOB_Constants.PING_BPGUID, AOB_Utils.generateGUID());
        accountAttributeMap.put(AOB_Constants.PING_NAME, 'Test Name');
        Account acc = AOB_SRV_UserManagement.createAccount(accountAttributeMap);
        //Create Test Contact
        Map<String, String> contactAttributeMap = new Map<String,String>();
        contactAttributeMap.put(AOB_Constants.PING_LAST_NAME, 'test');
        contactAttributeMap.put(AOB_Constants.PING_FIRST_NAME, 'first');
        contactAttributeMap.put(AOB_Constants.PING_EMAIL, 'a@gmail.com');
        contactAttributeMap.put(AOB_Constants.ID_STRING, 'XXXXX');
        contactAttributeMap.put(AOB_Constants.PING_BPID, 'XXXXX');
        contactAttributeMap.put(AOB_Constants.PING_SUB, 'sub@gmail.com');
        contactAttributeMap.put(AOB_Constants.CUSTOMER_CC, 'XXXXXXXX');
        contactAttributeMap.put(AOB_Constants.COMMERCE_SITE_ID, 'SB-COZA');
        contactAttributeMap.put(AOB_Constants.NATIONAL_ID, 'XXXXXXXX');
        contactAttributeMap.put(AOB_Constants.PING_BPGUID, AOB_Utils.generateGUID());
        Contact contact = AOB_SRV_UserManagement.createContact(contactAttributeMap, acc.Id);
        Map<String, String> attributeMap = new Map<String,String>();
        attributeMap.put(AOB_Constants.PING_LAST_NAME, 'test');
        attributeMap.put(AOB_Constants.PING_FIRST_NAME, 'first');
        attributeMap.put(AOB_Constants.PING_EMAIL, 'a@gmail.com');
        attributeMap.put(AOB_Constants.ID_STRING, 'XXXXX');
        attributeMap.put(AOB_Constants.PING_SUB, 'sub@gmail.com');
        User u = AOB_SRV_UserManagement.createUser(attributeMap, communityUser, contact.Id);
        System.assertEquals(u.FirstName,'first');
    }

     @isTest
    public static void createAccountContactRelationTest(){
        Map<String,String> accContactIds = AOB_DAL_TestFactory.createAccountWithContact();
        Boolean retValue = AOB_SRV_UserManagement.createAccountContactRelation(accContactIds.get('accountId'),accContactIds.get('contactId'));
    }
}