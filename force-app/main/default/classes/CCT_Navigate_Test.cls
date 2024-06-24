/**************************************************************************************
    @ Created By      :   Abhishek V
    @ Created On      :   23.09.2016
    @ Description     :   US:1528,Test class for CCT_Navigate class
***************************************************************************************/

@isTest
public class CCT_Navigate_Test{
    public static TestMethod void testnavigate1(){
        PageReference pageRef = Page.CCT_Add_New_Navigate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','019234829291');
        CCT_Navigate ctrl = new CCT_Navigate();
        String urlval = ctrl.navigateViewURL;
        ctrl.getIsLightning();
        ctrl.getIsClassic();
        System.assertnotEquals(urlval,null);
    }
}