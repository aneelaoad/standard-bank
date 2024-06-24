/**
* Class for static constants used during the AOB project
*
* <p></p>
* @description Common class with constants
* @author Salesforce
*
* @date Oct 21th 2020

* @Modification Description : SFP-25088
*/
public with sharing class AOB_Constants {
    //Global variables
    public static final String ID_STRING = 'id';
     public static final String ID_TYPE = '01';
    public static final String NONE_STRING = 'None';
    public static final String UTF8 = 'UTF-8';
    public static final String TIME_ZONE = 'Africa/Johannesburg'; 
    public static final String PBB_USER_NAME = System.Label.AOB_PBB_USER;
    //Permission Sets 
    public static final String PS_COMMUNITYUSER = 'AOB_SAAuthenticatedCommunityUsers';
    //Object names
    public static final String PROFILE = 'Profile';
    public static final String PERMISSION = 'Permission Set';
    public static final String ACCOUNT = 'Account';
    public static final String ACCOUNT_OWNER = 'Account Owner';
    public static final String CONTACT_OWNER = 'Contact Owner';
    public static final String ACCOUNT_RT = 'Account Record Type';
    public static final String CONTACT_RT = 'Contact Record Type';
    public static final String COMMUNITY = 'Community';
    //temporary Variables
    public static final String CREDITCARD = 'Credit Card';
    /*THIS IS ONLY USED UNTIL CORRECT PARAM IS BUILT TO HOST IT IN PRODUCT */
    public static final String DEFAULTCATEG = 'ZBRW';
    //IDV
    public static final String IDV_DONE = 'IDV_DONE';
    public static final String IDV_NOT_DONE = 'IDV_NOT_DONE';
    public static final String APPLICATIONID = 'CB5CFB27-B2D4-4C2D-B60B-BE5A67A5C806';
    // Certificate
    public static final String API_TESTCERTIFICATE = AOB_Certificate__mdt.getInstance('SBG_IBM_API_Connect').AOB_Body__c;   
    //API Calls Constants
    public static final String NC_CUSTOMERS = 'callout:AOB_API_PersonalDetails';
    public static final String API_METHOD_POST = 'POST';
    public static final String API_METHOD_PUT = 'PUT';
    public static final String API_ACCEPT_JSON = 'application/json';
    public static final String API_CONTENTTYPE_URL = 'application/x-www-form-urlencoded';
    public static final String API_CONTENT_TYPE = 'Content-Type';
    //Ping params 
    public static final String PING = 'PING';
    public static final String PING_ID = 'Ping Id';
    public static final String PING_TYPE = 'Ping Type';
    public static final String PING_FIRST_NAME = 'first_name';
    public static final String PING_LAST_NAME = 'last_name';
    public static final String PING_EMAIL = 'email';
    public static final String PING_BPID = 'bpid';
    public static final String PING_DIGITALID = 'digitalId';
    public static final String PING_BPGUID = 'bpidguid';
    public static final String PING_SUB = 'sub';
    public static final String COUNTRY_CODE = 'countryCode';
    public static final String NATIONAL_ID = 'nationalId';
    public static final String CUSTOMER_CC = 'customerCCId';
    public static final String PHONE = 'phoneNumber';
    public static final String PING_NAME = 'name';
    public static final String AOB_DUMMY_NAME = 'Temporary user for AOB';
    public static final String SANDBOX_SUFIX = AOB_Utils.getOnboardingSettings('SB-COZA').AOB_SandboxSuffix__c;
    public static final String COMMERCE_SITE_ID = 'commerceSiteId';
    public static final String SB_COZA = 'SB-COZA';
    public static final String PRODUCTCODENOTFOUND = 'Can not create applicatoin line item. No product found for product code: ';
    public static final String SA = 'SA';
    public static final String PREAPPRESPONSENOTFOUND = 'PreApplication Response is not found for this application';
    public static final String LEADCREATED = 'isSFCreateLead';
    //WFR
    public static final String WFR_DEFAULT_CODE = '004';
    public static final String WFR_DONE_STATUS = 'Identity successfully verified';
    public static final String WFR_FLOW = 'AOB_WebFaceRecognition';
    public static final String WFR_GUIDATT = 'bpidguid';
    public static final String WFR_ERROR = 'ERROR';
    public static final String WFR_COMPLETED_STATUS = 'Completed by Customer';
    public static final String WFR_STATUS_SUCCESS_MESSAGE = 'Verification WFR Status updated successfully';
    public static final String WFR_STATUS_VERIFICATION_NOT_FOUND = 'Verification records were not found for this Application';
    public static final String WFR_STATUS_ERROR_MESSAGE = 'Something is wrong';
    //Exceptions
    public static final String SCRIPT_THROWN_EXCEPTION = 'Script-thrown exception';
    public static final String NO_PRODUCTS_DATA_EXCEPTION = 'There are no data related to current products';
    // HTTP header
    public static final String HTTP_ENCODING_XML = 'text/xml';
    public static final String LANG_ENG_US = 'en_US';
    // PreApplication
    public static final String NEW_APP = 'NEW';
    public static final String EXISTING_APP = 'EXISTING';
    public static final String PRODUCTNAME = 'MyMoBiz';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String NAME = 'Name';
    public static final String SURNAME = 'Surname';
    public static final String IDNUM = 'IdNum';
    public static final String PHONENUM = 'PhoneNumber';
    public static final String EMAIL = 'EmailAddress';
    public static final String BUSINESS_NAME = 'businessName';
    public static final String BUSINESS_TURN_OVER = 'businessTurnover';
    public static final String BUSINESS_REG_NUM = 'businessRegistrationNumber';
    public static final String BUSINESS_PROVINCE = 'businessProvince';
    public static final String BUSINESS_CITY = 'businessCity';
    public static final String PRODUCT_NUMBER = 'productNumber';
    public static final String PRICING_OPTION = 'pricingOption';
    public static final String APP_NAME = 'appName';
    public static final String PRE_APP_RESPONSE = 'PreApplicationResponse';
    public static final String INITIATORS = 'initiators';
    public static final String INITIATOR_BPID = 'initiatorBPID';
    public static final String INITIATOR_BPGUID = 'initiatorBPGUID';
    public static final String INITIATOR_DIGID = 'initiatorDigitalID';
    public static final String BUSINESS_REG_NAME = 'businessRegisteredName';
    public static final String BUSINESS_BPID = 'businessBPID';
    public static final String BUSINESS_BPGUID = 'businessBPGUID';
    public static final String PROCESSID = 'processId';
    public static final String DIGITALOFFERID = 'digitalOfferId';
    public static final String INFLIGHT_CUSTID = 'inflightCustomerDataId';
    public static final String BUSINESS_STATUS = 'businessStatus';
    public static final String PRE_APP_RES = '{"PreApplication":';
    public static final String PRE_APP_RESPONSEBODY = '{"PreApplicationResponse":';
    public static final String PREAPP_RES_BRACE = '}';
    public static final String CONSENT = 'consent';
    public static final String SAID = 'SAID';
    public static final String ZA = 'ZA';
    public static final String SOLE_SHAREHOLDER = 'soleShareholder';
    public static final String BUSINESS_TYPE = 'businessType';
    public static final String PRODUCT_NUMBER_1  = '4648';
    public static final String MYMO_BIZ_ACCOUNT  = 'MyMo Biz Account';
    public static final String OPTIONAL  = 'optional';
    public static final String ZMMB  = 'ZMMB';
    public static final String NULL_VALUE = null;
    public static final String PROCESS_DATA = 'ProcessData';
    //System Token
    public static final String GRANT_TYPE = 'grant_type=';
    public static final String CLIENT_CREDENTIALS = 'client_credentials';
    public static final String CLIENTID = '&client_id=';
    public static final String CLIENTSECRET = '&client_secret=';
    public static final String CODEVERIFIER = '&code_verifier=';
    public static final String INVALID_VERB = 'Invalid Verb';
    public static final String MESSAGE='Result should not be null';
    public static final String BASE_URL='Invalid base URL';
    public static final String ZACCOF='ZACCOF';
    public static final string ZBUSIN='ZBUSIN';
    public static final string ZMEMBE='ZMEMBE';
    //Personal Details API
    public static final String PERSONAL_DETAILS = 'Personal Details';
    public static final String RESIDENTIAL_ADDRESS = 'Residential Address';
    public static final String EMPLOYMENT_DETAILS = 'Employment Details';
    public static final String PRE_APPLICATION = 'PreApplication';
    public static final String PUBLIC_OFFICIAL = 'PublicOfficial';
    public static final String RELATED = 'Related';
    public static final String STREET = 'Street';
    public static final String COMPLEXE='Complexe';
    public static final String SUBUR_B='suburb';
    public static final String CITIZEN_SHIP='citizenship';
    public static final String NATIONALITY='Nationality';
    public static final String RELATION_TYPE='RelationType';
    public static final String RELATION_NAME='RelationName';
    public static final String SURNAME_RELATION_NAME='SurnameRelationName';
    public static final String INDUSTRY='INDUSTRY';
    public static final String JOB_TITLE='jobTitle';
    public static final String COMPANY_DETAILS = 'Company Details';
    public static final String COMPANY_TRADING_ADDRESS = 'Company Trading Address';
    public static final String COMPANY_FINANCIAL_ADDRESS = 'Company Financial Details';
    public static final String MARKETING_CONSENT = 'Marketing Consent';
    public static final String TAX_INPUTS = 'taxInputs';
    public static final String IDENTIFICATION_TYPE = '01';
    public static final String NATURE_OF_BUSINESS = 'NATURE OF THE BUSINESS';
    public static final String INDUSTRY_CLASSIFICATION='INDUSTRY CLASSIFICATION';
    public static final String PREFERRED_BRANCH='PREFERRED BRANCH';
    public static final String COUNTRY_OF_REGISTRATION='COUNTRY OF REGISTRATION';
    public static final String CELLPHONE='CELLPHONE';
    public static final String EMAIL_ADDRESS='EMAIL ADDRESS';
    public static final String TELEPHONE_NUMBER_OPTIONAL='TELEPHONE  NUMBER (OPTIONAL)';
    public static final String COMPLEX='Complex';
    public static final String UNIT_NUMBER='UnitNumber';
    public static final String STREET_NAME='StreetName';
    public static final String SUBURB='SUBURB';
    public static final String CITY='city';
    public static final String PROVINCE='province';
    public static final String COMPANY_PROVINCE='PROVINCE';
    public static final String POSTAL_CODE='PostalCode';
    public static final String ENTITY_CLASSIFICATION='ENTITY CLASSIFICATION';
    public static final String FIRST_TAX_NUMBER='firstTaxNumber';
    public static final String FIRST_REASON='firstReason';
    public static final String TAX_TYPE='taxType';
    public static final String SECOND_TAX_NUMBER='secondTaxNumber';
    public static final String SECOND_REASON='secondReason';
    public static final String MARKET_PERMISSION='consentForMarketing';
    public static final String RESEARCH_CONTACT='consentForSharing';
    public static final String OTHER_COMPANIES_COM='consentForCrossBorderSharing';
    public static final String WFR_STATUS='wfrStatus';
    public static final String WFR_RETRY_ALLOWED='wfrRetryAllowed';
    public static final String WFR_FAILURE_REASON='wfrFailureReason';
    public static final String Step_Await_IDV_Callback='Step: Await IDV Callback';
    public static final String CLIENT_CREDENTIALSOTP='client_credentials';
    public static final String PROD_WRITER_CUSTOMER='prod write customer';
    public static final String SCOPEOTP='&scope=';
    //SET DIGITAL API
    public static final String MYMOBIZPRODUCTCODE='4648';
    public static final String TNXDETAILS='tnxDetails';
    public static final String MYUPDATES='myUpdates';
    public static final String RECIEPIENT='recipientName';
    public static final String CELLPHONESET='cellphone';
    public static final String MSGTYPE='msgType';
    public static final String ZBCH='ZBCH';
    public static final String CHEQUECARDDETAILS='chequeCardDetails';
    public static final String DELIVERYDETAILS='deliveryDetail';
    public static final String CARDOPTION='cardOption';
    public static final String DELIVERYMETHOD='deliveryMethod';
    public static final String STREETNAME='streetName';
    public static final String PROVINCESETAPI='province';
    public static final String POSTALCODE='postalCode';
    public static final String ZAF='ZAF';
    public static final String DELIVERYBRANCHNAME='deliveryBranchName';
    public static final String CARDHOLDERUUID='cardHolderUUID';
    public static final String ZPOB='ZPOB';
    public static final String MERCHANTDEVICEDETAILS='merchantDeviceDetails';
    public static final String PRODDETAILS='prodDetails';
    public static final String NUBEROFDEVICES='numberOfDevices';
    public static final String SERVICEDESCRIPTION='serviceDescription';
    public static final String MERCHANTCATEGORYCODE='merchantCategoryCode';
    public static final String BUSINESSEMAILADDR='businessEmailAddr';
    public static final String BUSINESSTELEPHONEN='businessTelephoneNbr';
    public static final String BUSINESSREGISTRAIONADDRE='registrationEmailAddr';
    public static final String ZPSS='ZPSS';
    public static final String SNAPSCANDETAILS='snapScanDetails';
    public static final String SNAPSCANDETAILS1='snapscanDetails';
    public static final String AUTHPERSONIDNUM='authPersonIdNum';
    public static final String AUTHPERSONNAME='authPersonName';
    public static final String BUSINESSEMAIL='businessEmail';
    public static final String AUTHPERSONCELL='authPersonCell';
    public static final String MERCHANTCATEGORYDESC='merchantCategoryDesc';
    public static final String STORETYPE='storeType';
    public static final String TRANSACTIONAL='TRANSACTIONAL';
    public static final String WEB='WEB';
    public static final String ACCOUNTLEADEXTERNAL='MYMOBIZ CURRENT ACCOUNT';
    public static final String NO='No';
    public static final String YES='Yes';
    public static final String NULLVALUE='null';
    public static final String PREAPPLICATION='PreApplication';
    /*Get digital offer api*/
    public static final String SCREENAME_ADDRESS ='New Address';
    public static final String POCKETBIZ = 'PocketBiz';
    public static final String SNAPSCAN = 'SnapScan'; 
    public static final String CHEQUECCARDDETAILS = 'Cheque Card';
    public static final String  EMAILFIELD= 'Email';
    public static final String CONTACTNAME = 'Name';
    public static final String CONTACTID = 'ContactID';
    public static final String CROSSBORDERTYPE = 'Cross_Border_CoE_Record_Type';
    public static final String CONTACTMAPHIGH = 'High';
    public static final String AOBSOUTHAFRICADFCT = 'AOB_SouthAfricaDFCTechnical';
    public static final String CONTACTNEWMAP = 'New';
    public static final String ONLINEOFFERCREATION = 'Online Offer Creation Failed';
    public static final String OOBJECTCASE= 'Case';
    public static final String DATEFORM = 'yyyy/MM/dd hh:mm:ss';
    public static final String SAMEERROR = 'Same error happened again on';
    public static final String CSORIGIN = 'Web';
    public static final String SALESFORCEBCCAO_PRODUCTION = 'Salesforce BCC AO Production Support ';
    public static final String DONOTREPLY = 'DONOT REPLY-BCC AO : Online Offer Creation Failed';
    public static final String CASECREATED = 'Your Case:  has been created.';
    public static final String HELLOHTMLTAG = 'Hello,<p> This is an automatic email to inform you that Application ';
    public static final String HASFAILEDONLINE = ' has Failed the online offer creation.<p><p> Online offer Message: { ';
    public static final String GENERATEDEMAIL = ' <p><p><b> ****{}{}This is a system generated email. PLEASE DONOT REPLY{}{}**** </b><p><p> <p>Regards.<p> Account Onboarding Team';
    public static final String AVALIBLE_BUNDLES =  'Available Bundles';
    public static final String CARDSELECTION =  'Card Selection';
    public static final String  HTTPGETMETHOD ='GET';
    public static final String BEARER =  'Bearer ';
    public static final String NOTEXT =  'No'; 
    public static final String YESNORDIO =  'YESNORADIONotif';
    public static final String FALESTEXT =  'false';
    public static final String CONTRACTDOUCUMENT = 'ContractDoucument';
    public static final String DOCUMENTNAME = 'documentName';
    public static final String DOCUMENTID = 'documentId';
    public static final String GETPHONENUMBER = '832656123';
    public static final String Stringaccess_token= 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOltdLCJjbGllbnRfaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwianRpIjoiMjhOMWM1R3p2bzhJQW1aSzZhREFuSyIsInN1YiI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsIm5iZiI6MTY3NTA3NTYyMiwiaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpYXQiOjE2NzUwNzU2MjIsImV4cCI6MTY3NTA3NTkyMn0.U5OMtytkp0GtRX6ztko32t7PazUNt_Ka3xLrKOZ0SjdQbgn7-eu9EDweGxGy-59eh3zI-1w4MZhVA8Ed3JEPiewqm8zTWY9BdKYxC1lkGBhrpU-zXPxxDN8LfPyTIAcqATgowWqgEIzeuu58tt_nci-VHeG7_d4t_ezCQsclHqsZfLFs8gIqP2JON5xtwngu3HJ3MGgbujCMO0XE0SBQA-9oSf4IqfeYV_EY_TXLeA7p7Jyvq2NWZ3bxML0L-WQ84ze37DBLWybWZyz_dqiEpkFj7cMZ05djz2OcnnwEps2ywqhFMwIWqDR4Ggy9e_Exeiik6cI4j7dYGAfn9_n';
    public static final String qname= 'MAPPOTP000043008'; 
    public static final String getotpnum = '57024';
    public static final String OTP_QNAAME = 'otp_qname';
    public static final String OTP_QNAAME1 = 'vers_v_response_code';
    public static final String CONTENTID='2e891199ef9e406eb39f96dbd70535b7';
    public static final String CONTRACTS='contracts';
    public static final String CONTRACT_DOCUMENT='ContractDoucument';
    public static final String sentReplyTo = 'testing@rf.com';
    public static final String test1 =  'TEST_1';
    public static final String testorg = '%@test.org';
    public static final String searchapiendpoint = 'https://www.standardbank.co.za/commerce/suggestions?q=';
    public static final String jsonstr = '{"applicationID": "0045375115","appStatus": [{"mainStatus": true,"statusCode": "E0041","statusDesc": "Draft"}],"initiatorUUID": "A142403","channel": "Z009","maintOfferId": "0600045723","productItems": [{"expiryDate": "2022-11-08","itemID": 100,"productID": "4648","mainProduct": "R","itemStatus": [{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}],"tnxDetails": {"priceOption": "ZMMB","myUpdates": { "recipientName": "KARABO MODISE","cellphone": null,"email": "karabo.modise@standardbank.co.za","msgType": "E"}}},{"expiryDate": "2022-11-08","itemID": 400,"productID": "ZBCH","mainProduct": "X","itemStatus": [{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}], "chequeCardDetails": {"cardOption": "4108","deliveryDetail": {"deliveryMethod": "F","deliveryBranch": null,"deliveryBranchName": null,"city": "JOHANNESBURG","streetNumber": null,"streetName": null,"province": "GP","postalCode": "2001"},"cardHolderUUID": null}},{"expiryDate": "2022-11-08","itemID": 500,"productID": "4488","mainProduct": "X","itemStatus": [{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}]},{"expiryDate": "2022-11-08","itemID": 600, "productID": "ZPOB","mainProduct": "X","itemStatus": [{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}],"merchantDeviceDetails": {"pricingOption": "ZPBP","prodDetails": {"merchantCategoryCode": "7996","businessEmailAddr": "tktrading@webmail.com","businessMobileNbr": "0839876543","businessTelephoneNbr": "0784585896","registrationEmailAddr": "karabo.modise@standardbank.co.za","consents": null,"numberOfDevices": 1,"serviceDescription": "TRADING IN ENTERTAINMENT COMMODITIES","acceptAmExpressNum": null, "acceptDinersNum": null,"acceptRCSNum": null}}},{"expiryDate": "2022-11-08","itemID": 700,"productID": "ZPSS","mainProduct": "X","itemStatus": [{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}],"snapScanDetails": {"pricingOption": "ZPSP","snapscanDetails": {"authPartner": null,"businessName": "MAFIA INC","storeType": "O","accountNbr": "0000010006844276","authPersonIdNum": "6711205246099","authPersonName": "GAMBINO LUCCHESE","authPersonEmail": "gambino@standardbank.co.za","authPersonCell": "0834167890","businessEmail": "mafia@testemail.com", "businessServiceDesc": "ANTIQUES","merchantCategoryCode": "5937","merchantCategoryDesc": "ANTIQUE REPRODUCTION STORES"}}}]}}}';
    public static final String testlineitem = 'testLineItem';
    public static final String XSBGCHANNEL='x-sbg-channel';
    public static final String Error409='Error409';
    public static final String FACIALRECOGNITIONURL='https://facialrecognitiontest.standardbank.co.za?token=';
    public static final String Error='Error';
    public static final String RetryCounter='RetryCounter';
    public static final String CANCELLED='Not completed by customer';   
    public static final String Started='Started';
    public static final String SUCCESS='Completed by customer';
    public static final String TAXRESIDENT='TaxResident';
    public static final String FIRSTCOUNTRY='firstCountry';
    public static final String ZSOLEP='ZSOLEP';
    public static final String ZDIREC='ZDIREC';
    public static final String TAXCOUNTRIES='taxCountries';
    public static final String SECONDCOUNTRY='secondCountry';
    public static final String ZA1='ZA1';  
    
     public static final String RESPONSESTATUSDESC='responseStatusDesc'; 
     
     
}