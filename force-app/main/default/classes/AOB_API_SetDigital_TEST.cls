/**
* @description Test class to test the Outbound set digital API call
* @author Dayakar
*/
@IsTest
private class AOB_API_SetDigital_TEST {

   /**
    * @description test method for AOB_SRV_SetDigital.callSetDigitalAPI
    * author dayakar
    */
    @isTest
    public static void setDigitalAPITest(){
       String jsonString='{"ContractDoucument":[{"documentId":"00EB1186-0000-C117-99FA-762353A112EE", "documentName":"Card application","documentCode":"CARAP","itemId":"400"}],"PreApplication": { "Name": "SampleName", "Surname": "Ram", "IdNum": "9801120672097","businessRegistrationNumber":"2020/679442/07","pricingOption":"ZMMB", "PhoneNumber": "0612345678", "EmailAddress": "force@ggmail.com","soleOwner": "true","businessType": "SOLE PROPRIETOR", "soleShareholder": "true","businessName": "Business Name","businessTurnover": "200000","businessProvince": "ZAF.EC", "consent": true },"PreApplicationResponse":{"businessBPGUID":"d671c60e-fe03-1ed7-a9eb-4cf2ef6d1dec","businessBPID":"0531113757","businessRegisteredName":"MONSTER DOORS","digitalOfferId":"0045379680","inflightCustomerDataId":"0045379680","initiatorBPGUID":"45551ed4-38a9-0164-0000-00000ab6f567","initiatorBPID":"0530845443","initiatorDigitalID":null,"processId":"0045379680"},"Summary":{"itemId":"100","documentCode":"Test Code","documentName":"Contract","documentId":"idd_D0273485-0000-C316-A1CC-C389514C5256"},"Available Bundles":{"ZPOB":false,"ZPSS":false,"4488":false},"Company Financial Details":{"taxInputs":{"firstTaxNumber":"1234567890","firstCountry":"AX"},"taxCountries":true,"undefined":"","FOREIGN TAX RESIDENCY":"false","ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true"},"Employment Details":{"taxInputs":{"firstCountry":"AL","firstReason":"1","secondCountry":"AX","secondReason":"3"},"jobTitle":"14","INDUSTRY":"1","Employed":"true","TaxResident":"true","taxCountries":true,"undefined":"1234567890"},"Personal Details":{"Nationality":"AL","citizenship":"AF","PublicOfficial":"false","Related":"true","RelationType":"5","RelationName":"Sample"},"PreApplication":{"consent":true,"businessProvince":"ZAF.EC","businessTurnover":"800000","businessName":"Random Company Name","soleShareholder":"true","businessType":"SOLE PROPRIETOR","soleOwner":"true","EmailAddress":"force@gmail.com","PhoneNumber":"765878260","IdNum":"5601120672097","Surname":"Ram","Name":"SampleName"},"Residential Address":{"Street":"dsfjks","UnitNumber":"hj","Complexe":"jh","suburb":"42ND HILL","city":"ABERDEEN","province":"ZAF.EC","PostalCode":"4567"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0612345678","EMAIL ADDRESS":"sample@gmail.com","CELLPHONE":"0612345678","PREFERRED BRANCH":"2750","COUNTRY OF REGISTRATION":"AX","INDUSTRY CLASSIFICATION":"27","NATURE OF THE BUSINESS":"18"},"Company Trading Address":{"PostalCode":"4567","PROVINCE":"ZAF.EC","city":"ABERDEEN","SUBURB":"486 SCHEME","Complex":"df","UnitNumber":"hj","StreetName":"sjhdj","AddressType":"Same"},"Marketing Consent":{"marketPermission":"true","researchContact":"true","otherCompaniesCom":"true"},"Card Selection":{},"Notifications":{"NotifiedMean":"EMAIL","depositInfo":"true"},"ProcessData":[{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704451","taskName":"Capture Application Data"},{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704452","taskName":"Step: Await IDV Callback"}]}';
       String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
      
       AOB_ReferencedData__c refernce= new AOB_ReferencedData__c();
       refernce.AOB_Code__c='3064';
       refernce.Name='sudhakar';
       refernce.AOB_SapField__c='MRCHT_CAT';
       insert  refernce;
       Test.startTest();
       Integer responseCode=AOB_SRV_SetDigital.callSetDigitalAPI(applicationId); 
       Test.stopTest();
       Assert.areNotEqual(null, responseCode); 
    }
        
    @isTest
    public static void setDigitalAPIWithNewAddressTest(){
        
       String applicationId=AOB_DAL_TestFactory.createApplicationWithNewAddress();
      
       AOB_ReferencedData__c refernce= new AOB_ReferencedData__c();
       refernce.AOB_Code__c='3065';
       refernce.Name='sudhakar23';
       refernce.AOB_SapField__c='MRCHT_CAT23';
       insert  refernce;
       Test.startTest();
       Integer responseCode=AOB_SRV_SetDigital.callSetDigitalAPI(applicationId); 
       Test.stopTest();
       Assert.areNotEqual(null, responseCode); 
    }
    
    /**
    * @description test method for AOB_SRV_SetDigital.callSetDigitalAPI
    * author dayakar
    */
    @isTest
    public static void callsetDigitalAPINegTest(){
            try{
                String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
                Test.startTest();
                AOB_SRV_SetDigital.callSetDigitalAPI(null); 
                Test.stopTest();
            }Catch(Exception e){
                Assert.areNotEqual(null, e);
                
            }
    }
}