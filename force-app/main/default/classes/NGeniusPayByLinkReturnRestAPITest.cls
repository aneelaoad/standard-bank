@IsTest
public with sharing class NGeniusPayByLinkReturnRestAPITest {
    @testSetup
    static void setup() {
        // Create common test 
        Atonit_Mktplace__Seller__c sellerRec = NamMktPlaceTestDataFactory.createSeller();
        Atonit_Mktplace__Marketplace_Order__c marketPlaceRec = new Atonit_Mktplace__Marketplace_Order__c(Name = 'Test 29182');
        insert marketPlaceRec;

        Atonit_Mktplace__Customer__c customer = NamMktPlaceTestDataFactory.createCustomer();
        Atonit_Mktplace__Seller_Order__c sellerOrderRec = NamMktPlaceTestDataFactory.createSellerOrder(sellerRec.Id, marketPlaceRec.Id, customer.Id);
        Atonit_Mktplace__Line_Item__c lineItem = NamMktPlaceTestDataFactory.createOrderLineItem(sellerOrderRec.Id);
        Atonit_Mktplace__PaymentLot__c paymentLot = NamMktPlaceTestDataFactory.createPaymentLot(sellerRec.Id);
        Atonit_Mktplace__FinancialTransaction__c financialTranscRec = NamMktPlaceTestDataFactory.createFinancialTransaction(sellerOrderRec.Id, sellerRec.Id, paymentLot.Id);
        Marketplace_Payment__c payment = NamMktPlaceTestDataFactory.createMarketplacePayment(marketPlaceRec.Id, paymentLot.Id, 'b7b06cf7-e505-49c7-a802-2aa02e9e29d3');   
    }

    static testMethod void testParse() {
		String json = '{'+
		'  "eventId": "edab4142-993e-4780-83b5-8809e367f5a9",'+
		'  "eventName": "AUTHORISED",'+
		'  "order": {'+
		'    "id": "urn:order:b7b06cf7-e505-49c7-a802-2aa02e9e29d3",'+
		'    "links": {'+
		'      "cancel": {'+
		'        "href": "http://transaction-service/transactions/outlets/e1049580-8974-4d67-9e1f-8481346ac791/orders/b7b06cf7-e505-49c7-a802-2aa02e9e29d3/cancel"'+
		'      },'+
		'      "self": {'+
		'        "href": "http://transaction-service/transactions/outlets/e1049580-8974-4d67-9e1f-8481346ac791/orders/b7b06cf7-e505-49c7-a802-2aa02e9e29d3"'+
		'      },'+
		'      "tenant-brand": {'+
		'        "href": "http://config-service/config/outlets/e1049580-8974-4d67-9e1f-8481346ac791/configs/tenant-brand"'+
		'      },'+
		'      "merchant-brand": {'+
		'        "href": "http://config-service/config/outlets/e1049580-8974-4d67-9e1f-8481346ac791/configs/merchant-brand"'+
		'      }'+
		'    },'+
		'    "type": "SINGLE",'+
		'    "merchantDefinedData": {},'+
		'    "action": "AUTH",'+
		'    "amount": {'+
		'      "currencyCode": "NAD",'+
		'      "value": 100'+
		'    },'+
		'    "language": "en",'+
		'    "merchantAttributes": {'+
		'      "redirectUrl": "https://google.com"'+
		'    },'+
		'    "reference": "b7b06cf7-e505-49c7-a802-2aa02e9e29d3",'+
		'    "outletId": "e1049580-8974-4d67-9e1f-8481346ac791",'+
		'    "createDateTime": "2022-10-21T07:05:24.587Z",'+
		'    "paymentMethods": {'+
		'      "card": ['+
		'        "MASTERCARD",'+
		'        "VISA",'+
		'        "DINERS_CLUB_INTERNATIONAL"'+
		'      ]'+
		'    },'+
		'    "referrer": "urn:Ecom:b7b06cf7-e505-49c7-a802-2aa02e9e29d3",'+
		'    "merchantOrderReference": "CKK-9124555",'+
		'    "formattedAmount": "NAD 1",'+
		'    "formattedOrderSummary": {},'+
		'    "embedded": {'+
		'      "payment": ['+
		'        {'+
		'          "_id": "urn:payment:acc0d3c9-6afd-427f-80c6-3320c024c7a7",'+
		'          "_links": {'+
		'            "cnp:capture": {'+
		'              "href": "http://transaction-service/transactions/outlets/e1049580-8974-4d67-9e1f-8481346ac791/orders/b7b06cf7-e505-49c7-a802-2aa02e9e29d3/payments/acc0d3c9-6afd-427f-80c6-3320c024c7a7/captures"'+
		'            },'+
		'            "self": {'+
		'              "href": "http://transaction-service/transactions/outlets/e1049580-8974-4d67-9e1f-8481346ac791/orders/b7b06cf7-e505-49c7-a802-2aa02e9e29d3/payments/acc0d3c9-6afd-427f-80c6-3320c024c7a7"'+
		'            },'+
		'            "cnp:cancel": {'+
		'              "href": "http://transaction-service/transactions/outlets/e1049580-8974-4d67-9e1f-8481346ac791/orders/b7b06cf7-e505-49c7-a802-2aa02e9e29d3/payments/acc0d3c9-6afd-427f-80c6-3320c024c7a7/cancel"'+
		'            },'+
		'            "curies": ['+
		'              {'+
		'                "name": "cnp",'+
		'                "href": "http://transaction-service/docs/rels/{rel}",'+
		'                "templated": true'+
		'              }'+
		'            ]'+
		'          },'+
		'          "reference": "acc0d3c9-6afd-427f-80c6-3320c024c7a7",'+
		'          "paymentMethod": {'+
		'            "expiry": "2026-01",'+
		'            "cardholderName": "adf sdf",'+
		'            "name": "VISA",'+
		'            "pan": "411111******1111"'+
		'          },'+
		'          "savedCard": {'+
		'            "maskedPan": "411111******1111",'+
		'            "expiry": "2026-01",'+
		'            "cardholderName": "adf sdf",'+
		'            "scheme": "VISA",'+
		'            "cardToken": "dG9rZW5pemVkUGFuLy92MS8vU0hPV19OT05FLy8xMTExMTExNDExMTExMTEx",'+
		'            "recaptureCsc": true'+
		'          },'+
		'          "state": "AUTHORISED",'+
		'          "amount": {'+
		'            "currencyCode": "NAD",'+
		'            "value": 100'+
		'          },'+
		'          "updateDateTime": "2022-10-21T07:06:06.272Z",'+
		'          "outletId": "e1049580-8974-4d67-9e1f-8481346ac791",'+
		'          "orderReference": "b7b06cf7-e505-49c7-a802-2aa02e9e29d3",'+
		'          "merchantOrderReference": "CKK-9124555",'+
		'          "authResponse": {'+
		'            "authorizationCode": "AB0012",'+
		'            "success": true,'+
		'            "resultCode": "00",'+
		'            "resultMessage": "Successful approval/completion or that VIP PIN verification is valid",'+
		'            "mid": "141516000121",'+
		'            "rrn": "229307088232"'+
		'          },'+
		'          "secure3ds": {'+
		'            "status": "SUCCESS",'+
		'            "eci": "05",'+
		'            "eciDescription": "Card holder authenticated",'+
		'            "summaryText": "The card-holder has been successfully authenticated by their card issuer."'+
		'          }'+
		'        }'+
		'      ]'+
		'    }'+
		'  }'+
		'}';

		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/PayByLink/';
        req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json);
        RestContext.request = req;
        RestContext.response = res;
		String reference = 'acc0d3c9-6afd-427f-80c6-3320c024c7a7';
        
        Test.startTest();
        NGeniusPayByLinkReturnRestAPI.payByLinkReturn();
        Test.stopTest(); 
		
		System.assertEquals(reference, NamMktPlaceTestDataFactory.getMarketplacePayment(reference).Payment_Reference__c, 'Error on Payment_Reference__ct');
		System.assertEquals('Success', NamMktPlaceTestDataFactory.getMarketplacePayment(reference).Status__c, 'Error on Status__c');
	}
}