/**
* @description Test class for RemoveMultiSelectValues
* @author		Sipho Mbulawa
* @date		March 2022
*/
@isTest
public class RemoveMultiSelectValues_Test {
    public static final String TEST_USER_NAME_1 = 'api_marketplace@bcwbcdev-standardbankgroupcommunity.cs128.force.com';
    public static final String DEF_ACC_NAME = 'Test Account Number11';
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
    
    @TestSetup
    private static void testSetup(){
        
        fflib_SObjectUnitOfWork newUow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        ABS_ObjectBuilderBase[] builders = new ABS_ObjectBuilderBase[]{};
            for (Integer i=0; i<10; i++) {
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
                
            }
        newUow.commitWork();
        
        List<CMN_Account_Contact_Relationship_Detail__c> acrLst = new List<CMN_Account_Contact_Relationship_Detail__c>();
        List<Account> accList = [SELECT Id FROM Account WHERE Name IN:accountNameList];
        
        fflib_SObjectUnitOfWork uow1 = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Integer count=0;
        Integer count2=0;
        for(Account acc : [SELECT Id FROM Account]){
            for(Contact con : [SELECT Id FROM Contact]){
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
    
    @IsTest
    public static void removeValue(){
        List<CMN_Account_Contact_Relationship_Detail__c>  lstAccountContactRelationDetail = [Select Id, Role__c,Client__c,Contact__c,Valid_From__c,Valid_To__c
                                                                                             from CMN_Account_Contact_Relationship_Detail__c where Status__c ='Active'];
        for(CMN_Account_Contact_Relationship_Detail__c acr:lstAccountContactRelationDetail){
            acr.Valid_To__c = System.Today().addDays(-1);
            acr.Valid_From__c = System.Today().addDays(-2);
        }
        update lstAccountContactRelationDetail;
        Test.startTest();  
        RemoveMultiSelectValues.callRemoveMultiSelectValuesBatch();
        Test.stopTest(); 
        lstAccountContactRelationDetail = [Select Id, Role__c,Client__c,Contact__c from CMN_Account_Contact_Relationship_Detail__c where Status__c ='Active'];
        System.assertEquals(lstAccountContactRelationDetail.size(),0);
        
        
    }
    
    
}