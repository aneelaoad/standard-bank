/**
 * @description       : Test class for SEL_Products2
 * @author            : Tukelo Moseamo
 * @group             : Standard Bank 
 * @last modified on  : 04-09-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   04-06-2023   Tukelo Moseamo   Initial Version
**/
@isTest 
public with sharing class SEL_Products2_TEST {
 
    @TestSetup
    static void makeData(){
        Product2 pro = AOB_DAL_TestFactory.createProduct('Product', 'productCode');
        pro.Grand_Parent_Product__c = 'Grand Parent Product';
        pro.Product_Division__c = 'Product Division';
        pro.IsActive = True;
        update pro;
        
    }

    @isTest
    static void testSelectByProductName() {

        Test.startTest();
        List<Product2> products = SEL_Products2.newInstance().selectByProductName(new Set<String>{'Product'});
        Test.stopTest();
        Assert.areEqual(products.size(), 1);
        Assert.areEqual(products[0].Name, 'Product');
    }
    @isTest
    static void testselectByIds() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        List<Product2> products = SEL_Products2.newInstance().selectByIds(new Set<Id>{prod.Id});
        Test.stopTest();
        Assert.areEqual(products.size(), 1);
        Assert.areEqual(products[0].Name, 'Product');
    }
    @isTest
    static void testselectByProductCodes() {
        Product2 prod = [SELECT Id,ProductCode FROM Product2 LIMIT 1];
        Test.startTest();
        List<Product2> products = SEL_Products2.newInstance().selectByProductCodes(new Set<String>{prod.ProductCode});
        Test.stopTest();
        Assert.areEqual(products.size(), 1);
        Assert.areEqual(products[0].Name, 'Product');
    }
    @isTest
    static void testSelectCIBRelatedProducts2() {

        Test.startTest();
        List<Product2> products = SEL_Products2.newInstance().selectCIBRelatedProducts2(new String[]{'Product Division'});
        Test.stopTest();
        Assert.areEqual(products.size(), 1);
        Assert.areEqual(products[0].Product_Division__c, 'Product Division');
    }
}