/**
 * @description Test class to test the AOB_ReferencedDataTrigger
 * 
 * <p></p>
 * 
 * @author narendra.rompilli@standardbank.co.za
 *
 * @date 02 March 2023
 */
@IsTest(SeeAllData=false) 
public with sharing class AOB_TRH_ReferencedData_TEST {
    @TestSetup
    public static void testSetUp(){
        AOB_ReferencedData__c aob=new AOB_ReferencedData__c();
        aob.AOB_SAPField__c='SOURC_OF_FUNDS';
        aob.AOB_Code__c='0031';
        insert aob;
    }
    
    /**
	 * @description Emulates INSTY SapFiled
	*/
	@IsTest
    public static void referencedDataUpdate1(){
        AOB_ReferencedData__c aob=[select ID,AOB_SAPField__c, AOB_Code__c, AOB_isActive__c from  AOB_ReferencedData__c Limit 1];
        aob.AOB_SAPField__c='INSTY';
        aob.AOB_Code__c='00000';
        Test.startTest();
        Update aob;
        Assert.areEqual(true, aob.AOB_isActive__c);
        Test.stopTest();
    }
    /**
	 * @description Emulates a MRCHT_CAT SapField
	*/
	@IsTest
    public static void referencedDataUpdate2(){
        AOB_ReferencedData__c aob=[select ID,AOB_SAPField__c, AOB_Code__c, AOB_isActive__c from  AOB_ReferencedData__c Limit 1];
        aob.AOB_SAPField__c='MRCHT_CAT';
        aob.AOB_Code__c='10000';
        Test.startTest();
        Update aob;
        Assert.areEqual(true, aob.AOB_isActive__c);
        Test.stopTest();
    }
    /**
	 * @description Emulates TAX_TYPE SapField
	*/
	@IsTest
    public static void referencedDataUpdate3(){
        AOB_ReferencedData__c aob=[select ID,AOB_SAPField__c, AOB_Code__c, AOB_isActive__c from  AOB_ReferencedData__c Limit 1];
        aob.AOB_SAPField__c='TAX_TYPE';
        aob.AOB_Code__c='ZAo67';
        Test.startTest();
        Update aob;
        Assert.areEqual(true, aob.AOB_isActive__c);
        Test.stopTest();
    }
}