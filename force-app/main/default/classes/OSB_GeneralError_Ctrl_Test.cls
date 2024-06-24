/**
 * Test class for the OSB_sendApEmail class
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date July 2020
 *
 **/
@IsTest
public class OSB_GeneralError_Ctrl_Test {

    @testSetup
    static void testSetup(){
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
    }
    
    @isTest
    static void shouldGetHomePageURL(){
        OSB_GeneralError_Ctrl osbGenError = new OSB_GeneralError_Ctrl();
        String pageReference = String.valueOf(osbGenError.getHomePageURL());
        System.assertNotEquals(null, pageReference);
    }
}