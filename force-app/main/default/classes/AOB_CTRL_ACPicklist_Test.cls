/**
 * @description       : 
 * @author            : Chibuye Kunda
 * @group             : 
 * @last modified on  : 10-14-2021
 * @last modified by  : Chibuye Kunda
**/
@isTest
public with sharing class AOB_CTRL_ACPicklist_Test {
    /** this is the  name used for the first record*/
    private static final String NAME_1 = AOB_Constants.test1;

    /**this is the name  used for the second record*/
    private static final String NAME_2 = 'TEST_2';

    /**this is the name used for the third record*/
    private static final String NAME_3 = 'TEST_3';

    /**this is the SAP field user for the first record*/
    private static final String SAP_FIELD_1 = 'FIELD_1'; 

    /**this is the SAP field used for the second record*/
    private static final String SAP_FIELD_2 = 'FIELD_2';

    /**this is the Code field used for first record*/
    private static final String CODE_1 = 'CODE_1';  

    /** this is the  */
    private static final String CODE_2 = 'CODE_2';  


    /**
    * @description This function will create test data
    * @author Chibuye Kunda | 10-12-2021 
    **/
    @TestSetup
    static void createTestData(){  
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
           List<AOB_referencedData__c> ref = AOB_DAL_TestFactory.createRefData();
        }    
    }
    
    /**
     * @description testLoadData will test AOB_CTRL_ACPicklist.loadData
     */
    @isTest
    public static void testLoadData(){
        
        List<AOB_referencedData__c> ref = [SELECT name,AOB_SAPField__c from AOB_referencedData__c];        
        AOB_referencedData__c refData = new AOB_referencedData__c(name=AOB_Constants.NOTEXT, 
                                                                  AOB_Default__c=true, 
                                                                  AOB_SAPField__c=AOB_Constants.YESNORDIO, 
                                                                  AOB_isActive__c=true, 
                                                                  AOB_Code__c=AOB_Constants.FALESTEXT, 
                                                                  AOB_Language__c =AOB_Constants.LANG_ENG_US);
        insert refData;
        Boolean exceptionOccured=false;
        List<AOB_referencedData__c> results;
        try{
            results = AOB_CTRL_ACPicklist.loadData(ref[0].AOB_SAPField__c);
        }catch(Exception e){
            exceptionOccured=true;
            System.assertEquals(true, exceptionOccured);
        }
        
    }

    /**
     * @description testLoadData will test AOB_CTRL_ACPicklist.loadData negative scenario
     */
    @isTest
    public static void testLoadDataNegative(){ 
        
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like :AOB_Constants.testorg LIMIT 1];
        List<AOB_referencedData__c> ref = [SELECT name,AOB_SAPField__c from AOB_referencedData__c];
        AOB_referencedData__c refData = new AOB_referencedData__c(name=AOB_Constants.NOTEXT, 
                                                                  AOB_Default__c=true, 
                                                                  AOB_SAPField__c=AOB_Constants.YESNORDIO, 
                                                                  AOB_isActive__c=true, 
                                                                  AOB_Code__c=AOB_Constants.FALESTEXT, 
                                                                  AOB_Language__c =AOB_Constants.LANG_ENG_US);
        insert refData;
        Boolean exceptionOccured=false;
        System.runAs(communityUser){
            try {
                 Test.startTest();
                List<AOB_ReferencedData__c> results = AOB_CTRL_ACPicklist.loadData(refData.AOB_SAPField__c);
                Test.stopTest();
            } catch (Exception e) {
                exceptionOccured=true;
            }   
        }
        System.assertEquals(true,exceptionOccured);
    }
}