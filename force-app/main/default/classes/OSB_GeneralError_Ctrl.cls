/**
 * OSB_GeneralError class for OSB_GeneralError Visualforce Page
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date July 2020
 *
 **/
public with sharing class OSB_GeneralError_Ctrl {
    private static final String CUSTOM_SETTING_BASE_URL = 'OSB_Base_URL';
    private static OSB_URLs__c osbURL;

    public PageReference getHomePageURL() {
        osbURL = OSB_URLs__c.getValues(CUSTOM_SETTING_BASE_URL);
        PageReference pageRef = new PageReference(osbURL.Value__c);
        return pageRef;
    }
}