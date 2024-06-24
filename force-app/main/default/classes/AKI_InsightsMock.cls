/**
*  @description Mock class for AKILI Insights
*
* @author Vipeen Sarode
* @date October 2021
*
* @LastModified Oct 2023
* @author Mokkala Chandrasekhar (chandrasekhar.mokkala@standardbank.co.za)
* @UserStory SFP-28741
* @LastModifiedReason Included persona and isclientdealer in the response
*/

@isTest
public class AKI_InsightsMock implements HttpCalloutMock {
    
    /**
    * @description  create mock data to test get insight api
    * *
    * @param req dummy req to the mock class method
    * 
    * @return HttpResponse
    */
    public HttpResponse respond(HttpRequest req){
        HttpResponse res = New HttpResponse();
        string resBody = '{ "leads": [{ "leadid": 101,"full_count": 1024,"persona":"Client", "isclientdealer":false, "customercif": "100063021", "clientcoordinatorid": "00520000001h0GlAAI", "productspecialistid": null, "salesforceopportunityid": "0067Z00000NL9j7QAD", "salesforceleadid": null, "eventdate": "2021-10-04", "leaddate": "2021-09-29", "expirydate": "2021-10-06", "opportunitycreatedtimestamp": "2021-10-04 09:36:42", "visibility": "Private", "category": "FX Tips", "subcategory": "FX Client Affinity", "insights": "Similar clients took up a USD SPOT in a buy direction", "nextbestaction": "Sell USD SPOT or USD FORWARD", "insightstatus": "null", "insightquality": "null", "insightcreatedbyid": "0057Z000008IBALQA4", "insightcreatedtimestamp": "2021-10-04 12:37:55.144923", "issnoozed": false, "isexpired": false, "lastupdatedtimestamp": "2021-10-04 12:37:55.144923" },{ "leadid": 102,"persona":"Client","full_count": 1024, "isclientdealer":true, "customercif": "100063021", "clientcoordinatorid": "00520000001h0GlAAI", "productspecialistid": null, "salesforceopportunityid": "0067Z00000NL9j7QAD", "salesforceleadid": null, "eventdate": "2021-10-04", "leaddate": "2021-09-29", "expirydate": "2021-10-06", "opportunitycreatedtimestamp": "2021-10-04 09:36:42", "visibility": "Private", "category": "FX Tips", "subcategory": "FX Client Affinity", "insights": "Similar clients took up a USD SPOT in a buy direction", "nextbestaction": "Sell USD SPOT or USD FORWARD", "insightstatus": "null", "insightquality": "null", "insightcreatedbyid": "0057Z000008IBALQA4", "insightcreatedtimestamp": "2021-10-04 12:37:55.144923", "issnoozed": false, "isexpired": false, "lastupdatedtimestamp": "2021-10-04 12:37:55.144923" },{ "leadid": 111532,"full_count": 1024, "customercif": "100063021", "clientcoordinatorid": "00520000001h0GlAAI", "productspecialistid": null, "salesforceopportunityid": "0067Z00000NL9j7QAD", "salesforceleadid": null, "eventdate": "2021-10-04", "leaddate": "2021-09-29", "expirydate": "2021-10-06", "opportunitycreatedtimestamp": "2021-10-04 09:36:42", "visibility": "Private", "category": "FX Tips", "subcategory": "FX Client Affinity", "insights": "Similar clients took up a USD SPOT in a buy direction", "nextbestaction": "Sell USD SPOT or USD FORWARD", "insightstatus": "null", "insightquality": "null", "insightcreatedbyid": "0057Z000008IBALQA4", "insightcreatedtimestamp": "2021-10-04 12:37:55.144923", "issnoozed": false, "isexpired": false, "lastupdatedtimestamp": "2021-10-04 12:37:55.144923" },{ "leadid": 111532, "full_count": 1024,"customercif": "100063021", "clientcoordinatorid": "00520000001h0GlAAI", "productspecialistid": "0057R00000Bp4IUQAZ", "salesforceopportunityid": "0067Z00000NL9j7QAD", "salesforceleadid": null, "eventdate": "2021-10-04", "leaddate": "2021-09-29", "expirydate": "2021-10-06", "opportunitycreatedtimestamp": "2021-10-04 09:36:42", "visibility": "Private", "category": "FX Tips", "subcategory": "FX Client Affinity", "insights": "Similar clients took up a USD SPOT in a buy direction", "nextbestaction": "Sell USD SPOT or USD FORWARD", "insightstatus": "null", "insightquality": "null", "insightcreatedbyid": "0057Z000008IBALQA4", "insightcreatedtimestamp": "2021-10-04 12:37:55.144923", "issnoozed": false, "isexpired": false, "lastupdatedtimestamp": "2021-10-04 12:37:55.144923" }, { "leadid": 111536,"full_count": 1024, "customercif": "100104569", "clientcoordinatorid": "005w0000005m58WAAQ", "productspecialistid": null, "salesforceopportunityid":null, "salesforceleadid": "a0q7Z000005MR92QAG", "eventdate": "2021-09-28", "leaddate": "2021-09-29", "expirydate": "2021-10-06", "opportunitycreatedtimestamp": null, "visibility": "Private", "category": "FX Tips", "subcategory": "FX Client Execution Type", "insights": "Client usually comes to the FX desk to request/buy forward on a weekly basis on Tuesdays", "nextbestaction": "Currenct Derivative", "insightstatus": "null", "insightquality": "null", "insightcreatedbyid": "0057Z000008IBALQA4", "insightcreatedtimestamp": "2021-10-04 13:42:03.427431", "issnoozed": false, "isexpired": false, "lastupdatedtimestamp": "2021-10-04 13:42:03.427431" },{ "leadid": 111532,"full_count": 1024, "customercif": "100063021", "clientcoordinatorid": "00520000001h0GlAAI", "productspecialistid": "00520000001h0GlAAI", "salesforceopportunityid": "0067Z00000NL9j7QAD", "salesforceleadid": null, "eventdate": "2021-10-04", "leaddate": "2021-09-29", "expirydate": "2021-10-06", "opportunitycreatedtimestamp": "2021-10-04 09:36:42", "visibility": "Private", "category": "FX Tips", "subcategory": "FX Client Affinity", "insights": "Similar clients took up a USD SPOT in a buy direction", "nextbestaction": "Sell USD SPOT or USD FORWARD", "insightstatus": "null", "insightquality": "null", "insightcreatedbyid": "0057Z000008IBALQA4", "insightcreatedtimestamp": "2021-10-04 12:37:55.144923", "issnoozed": false, "isexpired": false, "lastupdatedtimestamp": "2021-10-04 12:37:55.144923" } ] }';       
        res.setHeader('Content-Type', 'application/json'); 
        res.setBody(resBody);
        res.setStatusCode(200);
        return res;
    }     
}