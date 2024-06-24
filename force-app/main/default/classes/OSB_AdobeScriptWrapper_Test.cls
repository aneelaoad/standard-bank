/**
 * Controller class for OSBAdobeScriptWrapper_CRTL
 *
 * @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date April 2021
 *
 */
@IsTest
private class OSB_AdobeScriptWrapper_Test {
    public static final String ANALYTICS_SCRIPT = 'assets.adobedtm';
    public static final String ANALYTICS_CDN_SCRIPT = 'cdn.krxd';
    
    @TestSetup
    static void setup() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();  
        
        OSB_URLs__c cdnScript = new OSB_URLs__c();
        cdnScript.Name = 'OSB_AnalyticsCdn';
        cdnScript.Value__c = 'https://cdn.krxd.net/controltag/vyptn00fz.js';
        osbUrls.add(cdnScript);
        
        OSB_URLs__c adobeScript = new OSB_URLs__c();
        adobeScript.Name = 'OSB_AdobeAnalytics';
        adobeScript.Value__c = 'https://assets.adobedtm.com/45b28ee1a4af/c5837b1f5061/launch-db0d8a4635e9-development.min.js';
        osbUrls.add(adobeScript);
        
    	Insert osbUrls;
    }

    @isTest
    static void shouldGetUrlAdobe() {
        Test.startTest();
        OSB_AdobeScriptWrapper_CTRL adobe = new OSB_AdobeScriptWrapper_CTRL();
        String output = adobe.scriptUrl;
        Test.stopTest();
        System.assertEquals(true, output.contains(ANALYTICS_SCRIPT));
    }
    
    @isTest
    static void shouldGetUrlCDN() {       
        Test.startTest();
        OSB_AdobeScriptWrapper_CTRL adobe = new OSB_AdobeScriptWrapper_CTRL();
        String output = adobe.scriptCdn;
        Test.stopTest();
        System.assertEquals(true, output.contains(ANALYTICS_CDN_SCRIPT));
    }
}