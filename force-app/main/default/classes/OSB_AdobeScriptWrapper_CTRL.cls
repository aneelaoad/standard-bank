/**
 * Controller class for OSBAdobeScriptWrapper  visualforce page
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date April 2020
 *
 */
public with sharing class OSB_AdobeScriptWrapper_CTRL {
    public static final String ANALYTICS_SCRIPT = 'OSB_AdobeAnalytics';
    public static final String ANALYTICS_CDN_SCRIPT = 'OSB_AnalyticsCdn';
    public String scriptUrl {
        get {
            if (OSB_URLs__c.getValues(ANALYTICS_SCRIPT) != null && scriptUrl == null) {
                scriptUrl = OSB_URLs__c.getValues(ANALYTICS_SCRIPT).Value__c;
            }
            return scriptUrl;
        }
        private set;
    }
    public String scriptCdn {
        get {
            if (OSB_URLs__c.getValues(ANALYTICS_CDN_SCRIPT) != null && scriptCdn == null) {
                scriptCdn = OSB_URLs__c.getValues(ANALYTICS_CDN_SCRIPT).Value__c;
            }
            return scriptCdn;
        }
        private set;
    }
}