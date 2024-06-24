/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Digitization Client Onboarding - Account Opening US-2668
*
* Apex REST class designed to expose multiple client hierarchies
*
* URL Mapping: services/apexrest/LegalEntities .
*
* HTTP Verbs Handled:
*
*   POST    -   given an array of CIF numbers in string format this class will return the full hierarchy for those clients
*               including the KYC Status associated to those clients from an SBSA perspective. e.g.
*               [
                    {
                        "ID": "0010E00000DxnYdQAJ",
                        "ParentID": "",
                        "Country": "MAURITIUS",
                        "TradingAs": "Econet Global Limited",
                        "RegNum": "C088185 C1/GBL",
                        "CIFNumber": "509103820",
                        "Authorised": false,
                        "KYCStatus": "Requested",
                        "Children": [
                                    {
                                        "ID": "0010E00000DxnXvQAJ",
                                        "ParentID": "0010E00000DxnYdQAJ",
                                        "Country": "VIRGIN ISLANDS BRITISH",
                                        "TradingAs": "Austin Eco Holdings Ltd",
                                        "RegNum": "1427454",
                                        "CIFNumber": "522370615",
                                        "Authorised": false,
                                        "KYCStatus": "N/A",
                                        "Children": []
                                    }
                                    ]
                    }
                ]
*   GET     -   [Insert Functional Description Here]
*   PUT     -   [Insert Functional Description Here]
*   DELETE  -   [Insert Functional Description Here]
*   PATCH   -   [Insert Functional Description Here]
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Caro Reinecke   <caro@khonology.com>
* @version        1.0
* @created        2018-01-D8
* @systemLayer    Invocation ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            your name here
* YYYY-MM-DD      Explanation of the change.  Multiople lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/LegalEntities/*')
global with sharing class AOB_LegalEntityHierarchyResource {

    @HttpPost
    global static void doPost(){
        RestResponse res = RestContext.response;
        String jsonRequestBody = RestContext.request.requestBody.toString();
        // Validate payload provided
        if (jsonRequestBody == null || jsonRequestBody == ''){
            res.responseBody = Blob.valueOf('No authorised client numbers supplied');
            res.statusCode = 200;
        } else {
            try {
                Set<String> CIFNumbers = (Set<String>)System.JSON.deserialize(jsonRequestBody, Set<String>.class);
                // Validate request body
                if (CIFNumbers == null || CIFNumbers.size() == 0){
                    res.responseBody = Blob.valueOf('No authorised client numbers supplied');
                    res.statusCode = 200;
                } else {
                    String responseString = AccountService.getClientHierarchyAsJSON(CIFNumbers);
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = Blob.valueOf(responseString);
                    res.statusCode = 200;
                }
            } catch (AccountService.AccountServiceException ase) {
                res.responseBody = Blob.valueOf(String.valueOf(ase));
                res.statusCode = 200;
            } catch (Exception e) {
                res.responseBody = Blob.valueOf(String.valueOf(e) + '\n\n' + e.getStackTraceString());
                res.statusCode = 500;
            }
        }
    }
}