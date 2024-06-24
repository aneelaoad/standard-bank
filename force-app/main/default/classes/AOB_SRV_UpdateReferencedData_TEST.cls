/**
* @description  Test class for AOB_SRV_UpdateReferencedData
*  
* @author Narendra Teja
* 
* @date April 14th 2023
*/
@IsTest
public with sharing class AOB_SRV_UpdateReferencedData_TEST {
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        AOB_referencedData__c redfData = new AOB_referencedData__c(name='Industry', 
                                                                  AOB_Default__c=true, 
                                                                  AOB_SAPField__c='INSTY', 
                                                                  AOB_isActive__c=true, 
                                                                  AOB_Code__c='4668', 
                                                                  AOB_Value__c='4668',
                                                                  AOB_Language__c = 'en_US');
        Insert redfData;
    }
    /**
    * @description Test method for AOB_SRV_UpdateReferencedData.updateIndustryPicklistValues
    */
    @IsTest
    private static void updateIndustryPicklistValuesTest(){
        List<AOB_ReferencedData__c> refList=[Select id,AOB_Code__c,Name,  AOB_CountryCode__c,AOB_SAPField__c,AOB_Parent__r.Name,AOB_Value__c,  AOB_isActive__c from AOB_ReferencedData__c ];
            Test.startTest();
            AOB_SRV_UpdateReferencedData.updateIndustryPicklistValues();
            Test.stopTest();
            List<AOB_ReferencedData__c> ref = [SELECT id,AOB_Code__c,Name,  AOB_CountryCode__c,AOB_SAPField__c,AOB_Parent__r.Name,AOB_Value__c,  AOB_isActive__c FROM AOB_ReferencedData__c WHERE Id = :refList[0].Id];
            Assert.areEqual(false, ref[0].AOB_isActive__c);
        }  
    }