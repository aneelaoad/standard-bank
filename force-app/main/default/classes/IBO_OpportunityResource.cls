/**
 * IB Online Opportunity api
 * US-4660
 *
 * @author Wayne Solomon
 * @date 28 Apr 2020
 */
@RestResource(urlMapping='/ibo/v1/opportunities')
global without sharing class IBO_OpportunityResource {
    final static String MESSAGE = 'An error has occurred. Please forward to your Salesforce Support Centre';
    final static String CONTACT_US = 'Email crmsalesforce.com@standardbank.co.za - Call +27 11 721 8444.';

    @HttpGet global static void doGet() {
        RestResponse res = RestContext.response;
        final String cif = RestContext.request.params.get('cif');
        IBO_OpportunityServiceAbstract iboi = new IBO_OpportunityService();

        if(String.isNotBlank(cif)){
            try{
                res.responseBody = Blob.valueOf(JSON.serializePretty(iboi.getOpportunities(cif)));
                res.statusCode = 200;
                res.addHeader('Content-Type','application/json');
            } catch (Exception e) { res = genJsonErr(String.valueOf(e),500); }
        } else { res = genJsonErr('No CIF number was found in your query parameter for this request.',400); }
    }

    static RestResponse genJsonErr(String error, Integer code) {
        RestResponse res = RestContext.response;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('errors');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('message', MESSAGE);
            gen.writeStringField('contact_us', CONTACT_US);
            gen.writeStringField('error', String.valueOf(error));
            gen.writeEndObject();
            gen.writeEndArray();
        gen.writeEndObject();
        res.responseBody = Blob.valueOf(gen.getAsString());
        res.statusCode = code;
        res.addHeader('Content-Type', 'application/json');
        return res;
    }
}