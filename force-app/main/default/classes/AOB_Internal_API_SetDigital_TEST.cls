/**
* @description       : Test class for AOB_Internal_API_SetDigital
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 05-12-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification: SFP-25088
* 1.0   05-12-2023   Tukelo Moseamo   Initial Version
**/
@isTest
public class AOB_Internal_API_SetDigital_TEST {

    @isTest
    private static void testContractAPICompany() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = [SELECT Id,AOB_inflightData__c FROM AOB_Application__c WHERE Id = :applicationId];
        app.AOB_inflightData__c = AOB_Internal_SRV_SetDigital_TEST.getInflight();
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"{"0016":"2000"}"', '"{\\"0016\\":\\"2000\\"}"');
                                                                  
        update app;
        
        Test.startTest();
        AOB_Internal_API_SetDigital customerServiceCall = new AOB_Internal_API_SetDigital(applicationId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_SetDigital.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        Test.stopTest();
        Assert.areEqual(customerServiceCall.callResult.statusCode, String.valueOf(CMN_API_HttpBase.HTTP_OK), 'Callout was successful');
    }
    @isTest
    private static void testContractAPINew() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = [SELECT Id,AOB_inflightData__c FROM AOB_Application__c WHERE Id = :applicationId];
        app.AOB_inflightData__c = AOB_Internal_SRV_SetDigital_TEST.getInflight();
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"{"0016":"2000"}"', '"{\\"0016\\":\\"2000\\"}"');
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"NotifiedMean":"EMAIL"', '"NotifiedMean":"SMS"');
                                                                  
        update app;
        String data2 = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY","Complex":"parnandhi petals","StreetName":"sainagar"},"Deliver Address":"New","Delivery method":"Private Address"}';
        AOB_ApplicationLineItem__c lineItemCheq = [SELECT Id, Details__c FROM AOB_ApplicationLineItem__c WHERE Name ='Cheque Card'];
        lineItemCheq.Details__c = data2;
        update lineItemCheq;
        Test.startTest();
        AOB_Internal_API_SetDigital customerServiceCall = new AOB_Internal_API_SetDigital(applicationId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_SetDigital.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        Test.stopTest();
        Assert.areEqual(customerServiceCall.callResult.statusCode, String.valueOf(CMN_API_HttpBase.HTTP_OK), 'Callout was successful');
    }
    @isTest
    private static void testContractAPIResidential() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = [SELECT Id,AOB_inflightData__c FROM AOB_Application__c WHERE Id = :applicationId];
        app.AOB_inflightData__c = AOB_Internal_SRV_SetDigital_TEST.getInflight();
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"{"0016":"2000"}"', '"{\\"0016\\":\\"2000\\"}"');
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"NotifiedMean":"EMAIL"', '"NotifiedMean":"SMS"');
                                                                  
        update app;
        String data2 = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY","Complex":"parnandhi petals","StreetName":"sainagar"},"Deliver Address":"Residential","Delivery method":"Private Address"}';
        AOB_ApplicationLineItem__c lineItemCheq = [SELECT Id, Details__c FROM AOB_ApplicationLineItem__c WHERE Name ='Cheque Card'];
        lineItemCheq.Details__c = data2;
        update lineItemCheq;
        Test.startTest();
        AOB_Internal_API_SetDigital customerServiceCall = new AOB_Internal_API_SetDigital(applicationId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_SetDigital.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        Test.stopTest();
        Assert.areEqual(customerServiceCall.callResult.statusCode, String.valueOf(CMN_API_HttpBase.HTTP_OK),'Callout was successful');
    }
    @isTest
    private static void testContractAPINone() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
        
        Product2 marketLinkP = new Product2();
		marketLinkP.Name = 'MarketLink';
		marketLinkP.ProductCode = '4488';
        insert marketLinkP;
        
        AOB_ApplicationLineItem__c marketLink = new AOB_ApplicationLineItem__c();
		marketLink.Name = 'MarketLink';
		String data4 = '{"snapScanDetails":{"snapscanDetails":{"storeType":"O","merchantCategoryDesc":"ANTIQUE REPRODUCTION STORES","merchantCategoryCode":"5937","businessServiceDesc":"ANTIQUES","businessName":"MAFIA INC","businessEmail":"mafia@testemail.com","authPersonName":"GAMBINO LUCCHESE","authPersonIdNum":"6711205246099","authPersonEmail":"gambino@standardbank.co.za","authPersonCell":"0834167890","authPartner":null,"accountNbr":"0000010006844276"},"pricingOption":"ZPSP"}}';
		marketLink.Details__c = data4;
		marketLink.AOB_Status__c='Accepted';
		marketLink.SalesObjectItemId__c = '800';
		marketLink.AOB_Application__c = applicationId;
		marketLink.AOB_Product__c = marketLinkP.Id;
		insert marketLink;
        AOB_Application__c app = [SELECT Id,AOB_inflightData__c FROM AOB_Application__c WHERE Id = :applicationId];
        app.AOB_inflightData__c = AOB_Internal_SRV_SetDigital_TEST.getInflight();
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"{"0016":"2000"}"', '"{\\"0016\\":\\"2000\\"}"');
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"NotifiedMean":"EMAIL"', '"NotifiedMean":"SMS"');
                                                                  
        update app;
        String data2 = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY","Complex":"parnandhi petals","StreetName":"sainagar"},"Deliver Address":"None","Delivery method":"Private Address"}';
        AOB_ApplicationLineItem__c lineItemCheq = [SELECT Id, Details__c FROM AOB_ApplicationLineItem__c WHERE Name ='Cheque Card'];
        lineItemCheq.Details__c = Data2;
        update lineItemCheq;
        Test.startTest();
        AOB_Internal_API_SetDigital customerServiceCall = new AOB_Internal_API_SetDigital(applicationId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_SetDigital.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        Test.stopTest();
        Assert.areEqual(customerServiceCall.callResult.statusCode, String.valueOf(CMN_API_HttpBase.HTTP_OK),'Callout was successful');
    }
}