/**
 * @description Domain test class for DMN_CMN_AccountContactRelationshipDetail
 * @author		Emmanuel Mulea(Nocks)
 * @date		March 2022
 */
@isTest
public class DMN_CMN_AccountContactRelationship_Test {
	public static final String TEST_USER_NAME_1 = 'test.partnerSync@test.com';
    public static final String DEF_ACC_NAME = 'Def Name for Acc';
    public static final String GROUP_NUMBER = '1234';
    public static final String EXTERNAL_ID_1 = '12344321';
    public static final String EXTERNAL_ID_2 = '98765678';
    public static final List<String> accountNameList = new List<String>();
    private static User testUser1;
    private static void getUsers() {
        for(User usr : [SELECT Username FROM User WHERE UserName =: TEST_USER_NAME_1]){
            if(usr.UserName == TEST_USER_NAME_1){
                testUser1 = usr;
            }
        }
    }
   	@testSetup
	private static void setup(){
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            testUser1 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_1).useAPIONLYUser().syncContact().getRecord();
            uow.commitWork();
        }
        System.runAs(testUser1) {

            
			fflib_SObjectUnitOfWork newUow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            ABS_ObjectBuilderBase[] builders = new ABS_ObjectBuilderBase[]{};
                for (Integer i=0; i<5; i++) {
                    accountNameList.add(DEF_ACC_NAME+i);
                    builders.add(new BLD_Account(newUow)
                                 .useGroupParent()
                                 .bpid(i+'0000'+i)
                                 .name(DEF_ACC_NAME+i)
                                 .useBB());
                    builders.add(new BLD_Account(newUow)
                                 .useGroupParent()
                                 .bpid(i+'0000'+i+i)
                                 .name(DEF_ACC_NAME+i+i)
                                 .addContact(new BLD_Contact(newUow).useClientContact())
                                 .useBB());
                    builders.add(new BLD_Contact(newUow).useClientContact());
                    
                }
            newUow.commitWork();
        List<CMN_Account_Contact_Relationship_Detail__c> acrLst = new List<CMN_Account_Contact_Relationship_Detail__c>();
        List<Contact> conList = [SELECT Id,AccountId FROM Contact WHERE AccountId!=null];
        List<Account> accList = [SELECT Id FROM Account WHERE Name IN:accountNameList];
        
        fflib_SObjectUnitOfWork uow1 = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Integer count=0;
        Integer count2=0;
        for(Account acc : [SELECT Id FROM Account]){
            for(Contact con : [SELECT Id FROM Contact WHERE AccountId!=null]){
                CMN_Account_Contact_Relationship_Detail__c accCR = (CMN_Account_Contact_Relationship_Detail__c)new BLD_CMN_AccountContactRelationshipDetail(uow1)
                    .role('Evaluator')
                    .clientId(acc.Id)
                    .contactId(con.Id)
                    .externalIdentifier(count+EXTERNAL_ID_1+count2)
                    .getRecord();  
                acrLst.add(accCR);
                    count2++;
            }
            count++;
		}
        uow1.commitWork();
         
        }
    }
    
    @isTest
    public static void deleteAccountContactRelationshipTest() {
         List<CMN_Account_Contact_Relationship_Detail__c> dataList = [SELECT Id,Role__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                    WHERE Role__c='Evaluator'];
        for(CMN_Account_Contact_Relationship_Detail__c acr:dataList){
            acr.Role__c = 'Economic Buyer';
        }
        getUsers();
        Test.startTest();
        System.runAs(testUser1) {
            delete dataList;
        }
        Test.stopTest();
        dataList = [SELECT Id,Role__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                     WHERE Role__c='Evaluator'];
        System.assertEquals(dataList.size(), 0);
    }
    
    @isTest
    public static void getListofFieldValueTest() {
        List<CMN_Account_Contact_Relationship_Detail__c> dataList = [SELECT Id,Role__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                    WHERE Role__c='Evaluator'];
        Test.startTest();
			List<String> iDList = DMN_CMN_AccountContactRelationshipDetail.getListofFieldValue(dataList,'Id');
        Test.stopTest();
        System.assertEquals(iDList.size(), dataList.size());
    }
    @isTest
    public static void updateAccountContactRelationshipTest() {
        List<CMN_Account_Contact_Relationship_Detail__c> dataList = [SELECT Id,Role__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                    WHERE Role__c='Evaluator'];
        for(CMN_Account_Contact_Relationship_Detail__c acr:dataList){
            acr.Role__c = 'Economic Buyer';
        }
        getUsers();
        Test.startTest();
        System.runAs(testUser1) {
            update dataList;
        }
        Test.stopTest();
        List<CMN_Account_Contact_Relationship_Detail__c> updatedDataList = [SELECT Id,Role__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                    WHERE Role__c='Economic Buyer'];
        System.assertEquals(updatedDataList.size(), dataList.size());
    }
    @isTest
    public static void updateAccountContactRelationshipClient() {
        List<CMN_Account_Contact_Relationship_Detail__c> dataList = [SELECT Id,Role__c,Client__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                    WHERE Role__c='Evaluator'];
        String errorException;
        List<Account> accList = [SELECT Id FROM Account];
        for(CMN_Account_Contact_Relationship_Detail__c acr:dataList){
            acr.Role__c = 'Economic Buyer';
            acr.Client__c = accList[0].Id;
        }
        getUsers();
        Test.startTest();
        System.runAs(testUser1) {
            
            try{
                update dataList;
            }
            catch(Exception ex){
                errorException = ex.getMessage();
            }
        }
        Test.stopTest();
        List<CMN_Account_Contact_Relationship_Detail__c> updatedDataList = [SELECT Id,Role__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                    WHERE Role__c='Economic Buyer'];
        System.assertEquals(updatedDataList.size(), 0);
        System.assertNotEquals(errorException, null);
    }
    @isTest
    public static void updateAccountContactRelationshipExpired() {
        List<CMN_Account_Contact_Relationship_Detail__c> dataList = [SELECT Id,Role__c,Client__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                    WHERE Role__c='Evaluator'];
        List<Account> accList = [SELECT Id FROM Account];
        for(CMN_Account_Contact_Relationship_Detail__c acr:dataList){
            acr.Status__c = 'Expired';
        }
        getUsers();
        Test.startTest();
        System.runAs(testUser1) {
            update dataList;
        }
        Test.stopTest();
        List<CMN_Account_Contact_Relationship_Detail__c> updatedDataList = [SELECT Id,Role__c FROM CMN_Account_Contact_Relationship_Detail__c
                                                                    WHERE Role__c='Evaluator' AND Status__c='Expired'];
        System.assertEquals(updatedDataList.size(), dataList.size());
    }
    @isTest
    public static void createAccountContactRelationshipTest() {
        List<Contact> conList = [SELECT Id,AccountId FROM Contact];
        String errorException;
        List<CMN_Account_Contact_Relationship_Detail__c> acrList = new List<CMN_Account_Contact_Relationship_Detail__c>();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        for (Integer i=0; i<conList.size(); i++){
            CMN_Account_Contact_Relationship_Detail__c accCR = (CMN_Account_Contact_Relationship_Detail__c)new BLD_CMN_AccountContactRelationshipDetail(uow)
                .role('Influencer')
                .clientId(conList[i].AccountId)
                .contactId(conList[i].Id)
                .externalIdentifier(EXTERNAL_ID_1+i)
                .getRecord();
                
            CMN_Account_Contact_Relationship_Detail__c accCR2 = (CMN_Account_Contact_Relationship_Detail__c)new BLD_CMN_AccountContactRelationshipDetail(uow)
                .role('Business User')
                .clientId(conList[i].AccountId)
                .contactId(conList[i].Id)
                .externalIdentifier(EXTERNAL_ID_2+i)
                .getRecord();
            
        acrList.add(accCR);
        acrList.add(accCR2);
        }
        getUsers();
        Test.startTest();
        System.runAs(testUser1) {
            try{
                insert acrList;
            }
            catch(Exception ex){
                errorException = ex.getMessage();
            }
        }
        Test.stopTest();
        List<AccountContactRelation> stdAcr = [SELECT Id FROM AccountContactRelation];
        
        System.assertNotEquals(errorException, null);
        System.assertNotEquals(stdAcr.size(), 0);
    }
}