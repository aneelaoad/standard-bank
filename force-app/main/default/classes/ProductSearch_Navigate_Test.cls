/*********************************************************
 @ CreatedBy By  :   Upender Nath Sharma
 @ Created On    :   Feb 2017
 @ User Story#   :   Test class for ProductSearch_Navigate

**********************************************************/


@isTest
public class ProductSearch_Navigate_Test{
    public static TestMethod void testnavigate1(){
        PageReference pageRef = Page.ProductSearch_Navigate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','019234829291');
        ProductSearch_Navigate ctrl = new ProductSearch_Navigate();
        System.assertnotEquals(null,ctrl.redirect());
    }
}