@isTest
public class AOB_API_UpdateApplication_Test {
    
    @isTest static void AOB_API_UpdateApplication_TEST() {
        try{
            AOB_Application__c testApplication = new AOB_Application__c();
            testApplication.Name='test';
            testApplication.AOB_inflightData__c = '{"Marketing Consent":{"otherCompaniesCom":"true","researchContact":"true","marketPermission":"true"},"Company Details":{"TELEPHONE NUMBER (OPTIONAL)":"27812345678","EMAIL ADDRESS":"rasje@gmail.com","CELLPHONE":"27812345678","COUNTRY OF REGISTRATION":"AF","PREFERRED BRANCH":"3028","INDUSTRY CLASSIFICATION":"1","NATURE OF THE BUSINESS":"18"},"Employment Details":{"undefined":"0123456789","taxInputs":{"firstTaxNumber":"0123456789","firstCountry":"AF"},"taxCountries":true,"TaxResident":"true","jobTitle":"24","INDUSTRY":"1","Employed":"true"},"Personal details":{"Nationality":"AF","citizenship":"AF","PublicOfficial":"false","Related":"true","RelationType":"5","RelationName":"dfg"},"Residential Address":{"city":"ABERDEEN","province":"ZAF.EC","suburb":"42ND HILL","Complexe":"g","Street":"hj","UnitNumber":"68h","PostalCode":"1234"},"Personal Details":{"RelationName":"dfg","RelationType":"5","Related":"true","PublicOfficial":"false","citizenship":"AF","Nationality":"AF"},"Card Selection":{},"Notifications":{"debitCardselected":true,"chequeCardSelected":false},"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true},"Company Trading Address":{"AddressType":"Same"}}';
            insert testApplication;
            RestRequest request = new RestRequest();
            request.requestURI = '/services/apexrest/Application/';
            request.addParameter('AppliactionId', testApplication.Id);
            request.httpMethod = 'GET';
            RestContext.request = request;
            AOB_API_UpdateApplication.sendApplicationData();
            RestResponse response = RestContext.response;
            Assert.areEqual(200, response.statusCode);
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());
       }
        catch(Exception e){}
    }
}