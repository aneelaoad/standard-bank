/**
* @description       : Test class for SEL_AOBReferencedData
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 05-17-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-17-2023   Tukelo Moseamo   SFP-25090-Initial Version
**/
@isTest
public class SEL_AOBReferencedData_TEST {

    @isTest
    public static void testSelectBySapFieldAndCode() {
        AOB_ReferencedData__c ref = new AOB_ReferencedData__c();
        ref.Name = 'MERCHANT CATEGORY';
        ref.AOB_Code__c = 'MRCHT_CAT';
        ref.AOB_SAPField__c = 'MERCHANT CATEGORY';
        
        insert ref;
        
        Test.startTest();
        List<AOB_ReferencedData__c> refs = new SEL_AOBReferencedData().selectBySapFieldAndCode('MERCHANT CATEGORY', 'MRCHT_CAT');
        Test.stopTest();
        Assert.areEqual(refs[0].Id, ref.Id, 'Reference Id match');
    }
}