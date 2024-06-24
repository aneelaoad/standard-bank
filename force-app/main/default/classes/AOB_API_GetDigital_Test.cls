/**
* @description:- Test class to test the Outbound AOB_API_GetRpConfig
* @author:- Dayakar
*/
@isTest
public class AOB_API_GetDigital_Test {   
   /**
   * @description To setup the List of Webservice Call Queue
   * @return A list of queue items
   */
   private static List<CMN_WebserviceCallQueue__c> setup() {
         CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_DigitalOffers.SERVICE_NAME,
            UserInfo.getUserId()
         );        
         return new List<CMN_WebserviceCallQueue__c>{ queueItem };
   }

   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @isTest
   public static void AOB_API_DigitalOffers_test(){
      String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      // String json='{ "applicationID": "0045375115","appStatus": [{ "mainStatus": true,"statusCode": "E0041", "statusDesc": "Draft"}],"initiatorUUID": "A142403","channel": "Z009","maintOfferId": "0600045723","productItems": [{"expiryDate": "2022-11-08","itemID": 100,"productID": "4648","mainProduct": "R","itemStatus": [{"mainStatus": false, "statusCode": "E0006", "statusDesc": "Accepted" }, {"mainStatus": false, "statusCode": "E0008","statusDesc": "Conditions Outstanding"},{"mainStatus": true,"statusCode": "E0071",  "statusDesc": "Draft"} ],"tnxDetails": {"priceOption": "ZMMB","myUpdates": {"recipientName": "KARABO MODISE","cellphone": null, "email": "karabo.modise@standardbank.co.za", "msgType": "E" }},"chequeCardDetails": null,"merchantDeviceDetails": null,"snapScanDetails": null }, {"expiryDate": "2022-11-08","itemID": 400, "productID": "ZBCH", "mainProduct": "X","itemStatus": [{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"},{"mainStatus": false,"statusCode": "E0008","statusDesc": "Conditions Outstanding"}, {"mainStatus": false,"statusCode": "E0033", "statusDesc": "Txn acnt details not Active"},{"mainStatus": true, "statusCode": "E0071", "statusDesc": "Draft"}],"tnxDetails": null, "chequeCardDetails": { "cardOption": "4108","deliveryDetail": {"deliveryMethod": "F", "deliveryBranch": null, "deliveryBranchName": null, "city": "JOHANNESBURG","streetNumber": null,"streetName": null, "province": "GP","postalCode": "2001"}, "cardHolderUUID": null},"merchantDeviceDetails": null,"snapScanDetails": null}, {"expiryDate": "2022-11-08", "itemID": 500,"productID": "4488","mainProduct": "X","itemStatus": [{"mainStatus": false, "statusCode": "E0006", "statusDesc": "Accepted"},{"mainStatus": false, "statusCode": "E0008", "statusDesc": "Conditions Outstanding" },{"mainStatus": true,"statusCode": "E0071","statusDesc": "Draft"}],"tnxDetails": null,"chequeCardDetails": null,"merchantDeviceDetails": null, "snapScanDetails": null},{"expiryDate": "2022-11-08","itemID": 600,"productID": "ZPOB","mainProduct": "X","itemStatus": [ { "mainStatus": false, "statusCode": "E0006", "statusDesc": "Accepted"},{"mainStatus": false,"statusCode": "E0008", "statusDesc": "Conditions Outstanding" },{"mainStatus": false, "statusCode": "E0033", "statusDesc": "Txn acnt details not Active" },{"mainStatus": true,"statusCode": "E0071", "statusDesc": "Draft" }],"tnxDetails": null,"chequeCardDetails": null,"merchantDeviceDetails": { "pricingOption": "ZPBP", "prodDetails": { "merchantCategoryCode": "7996","businessEmailAddr": "tktrading@webmail.com", "businessMobileNbr": "0839876543", "businessTelephoneNbr": "0784585896","registrationEmailAddr": "karabo.modise@standardbank.co.za","accountNbr": "0000010006844276", "merchantCategoryDesc": "AMUSEMENT PARKS, CARNIVALS, CIRCUSES", "consents": null, "numberOfDevices": 1,"serviceDescription": "TRADING IN ENTERTAINMENT COMMODITIES", "acceptAmExpressNum": null,"acceptDinersNum": null, "acceptRCSNum": null} },"snapScanDetails": null},{ "expiryDate": "2022-11-08", "itemID": 700,"productID": "ZPSS","mainProduct": "X","itemStatus": [{ "mainStatus": false, "statusCode": "E0006", "statusDesc": "Accepted" },{"mainStatus": false, "statusCode": "E0008","statusDesc": "Conditions Outstanding"},{"mainStatus": false,"statusCode": "E0033","statusDesc": "Txn acnt details not Active"},{"mainStatus": true,"statusCode": "E0071","statusDesc": "Draft"}],"tnxDetails": null,"chequeCardDetails": null,"merchantDeviceDetails": null,"snapScanDetails": {"pricingOption": "ZPSP","snapscanDetails": {"authPartner": null,"businessName": "MAFIA INC","storeType": "O","accountNbr": "0000010006844276","authPersonIdNum": "6711205246099","authPersonName": "GAMBINO LUCCHESE","authPersonEmail": "gambino@standardbank.co.za","authPersonCell": "0834167890","businessEmail": "mafia@testemail.com","businessServiceDesc": "ANTIQUES","merchantCategoryCode": "5937","merchantCategoryDesc": "ANTIQUE REPRODUCTION STORES"}}}]}';
      
      Test.startTest();
      AOB_SRV_GetDigital.fetchResponse(applicationId); 
      Test.stopTest();
   }
   
   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @isTest
   public static void AOB_API_DigitalOffers_PocketBiztest(){
      String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      // String pckbizstr = '{"PocketBiz":{"visaCheck":true,"masterCheck":true,"unionCheck":true,"numOfDvs":"03","dinersCheck":true,"dinersNumber":"testlokesh","americanCheckbox":true,"americanNumber":"testlokeshamerica","rcsCheckbox":true,"rcsNumber":"tetloekshmerchant","goodsdescribe":"testsercisgoods","test":"63040"}}';
      Test.startTest();  
      AOB_SRV_GetDigital.fetchResponse(applicationId);
      Test.stopTest();
   }
   
   
   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @istest
   public static void AOB_API_DigitalOffers_snapScanDetailstest(){
      String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      // String snapscanstr = '{"SnapScan":{"COMPANY TRADING NAME":"testcmptradingname","EMAIL ADDRESS":"test@snapscan.com","DESCRIBE YOUR GOODS/SERVICES":"testgoodsandaservices","MERCHANT CATEGORY":"16","Receive payments in-store":true,"Receive payments online":true}}';     
      Test.startTest();
      AOB_SRV_GetDigital.fetchResponse(applicationId);
      Test.stopTest();
   }
   
   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @isTest
   public static void AOB_API_DigitalOffers_cardtedt(){
      String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      // String residential = '{"Card Delivery":{"RRResidential Address ":{"Street":"testresiaddr","UnitNumber":"testunnres","province":"ZAF.NW","suburb":"ALEXANDER BAY","city":"ABBOTSFORD","Complexe":"testcmpres","PostalCode":"9876"}}}';
      Test.startTest();  
      AOB_SRV_GetDigital.fetchResponse(applicationId);
      Test.stopTest();
   }
   
   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @isTest
   public static void AOB_API_DigitalOffers_card(){
      String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      // String company = '{"Card Delivery":{"CCCompany Trading Address ":{"StreetName":"testresiaddr", "UnitNumber":"testunnres", "Complex":"testcmpres", "city":"ABBOTSFORD", "PROVINCE":"ZAF.NW", "SUBURB":"ALEXANDER BAY", "PostalCode":"9876"}}}';
      Test.startTest();  
      AOB_SRV_GetDigital.fetchResponse(applicationId);
      Test.stopTest();
   }

   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @isTest
   public static void AOB_API_DigitalOffers_cardPref(){
      AOB_Application__c eachapp = new AOB_Application__c();
      eachapp.Name = 'test app';
      insert eachapp;
      Test.startTest();  
      AOB_SRV_GetDigital.fetchResponse(eachapp.Id);
      Test.stopTest();
   }

   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @isTest
   public static void AOB_API_DigitalOffers_cardCCC(){
      String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      // String company = '{"ChequeCardDetails":null}';
      // string cmpdetailschequrec = '{"Company Trading Address ":{"StreetName":"testresiaddr", "UnitNumber":"testunnres", "Complex":"testcmpres", "city":"ABBOTSFORD", "PROVINCE":"ZAF.NW", "SUBURB":"ALEXANDER BAY", "PostalCode":"9876"}}';
      Test.startTest();  
      AOB_SRV_GetDigital.fetchResponse(applicationId);
      Test.stopTest();
   }
   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @isTest
   public static void AOB_API_DigitalOffers_cardNNN(){
      String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      // String company = '{"ChequeCardDetails":{"NNNew Address ":{"StreetNumberAndName":"testresiaddr", "unitNumber":"testunnres", "building Name":"testcmpres", "cityPicklist":"ABBOTSFORD", "undefined":"ZAF.NW", "suburbPicklist":"ALEXANDER BAY", "postalCode":"9876"}}}';
      Test.startTest();  
      AOB_SRV_GetDigital.fetchResponse(applicationId);
      Test.stopTest();
   }

   /**
   * @description test method for AOB_SRV_GetDigital.fetchResponse
   * author dayakar
   */
   @isTest
   public static void AOB_API_DigitalOffers_cardRRR(){
      String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      // String company = '{"ChequeCardDetails":{"Company Trading Address":{"streetNumber":"123","streetName":"Main St","province":"ZAF.NW","postalCode":"9876","Complex":"testcmpres","city":"ABBOTSFORD"}}}';
      Test.startTest();  
      AOB_SRV_GetDigital.fetchResponse(applicationId);
      Test.stopTest();
   }
}