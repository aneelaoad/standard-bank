/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Digitization Client Onboarding - Account Opening US-2668
*
* Apex REST class designed to sync the Account Application in Salesforce from the Onboarding App.
*
* URL Mapping: services/apexrest/AccountApplication.
*
* HTTP Verbs Handled:
*
*   POST    -   given an Account Application document check in salesforce if this application exists and update it or create it if it does not. e.g.
*
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

@RestResource(urlMapping='/AccountApplication/*')
global with sharing class AOB_AccountApplicationResource {

    @HttpPost
    global static void doPost() {

        RestResponse res = RestContext.response;
        String jsonRequestBody = RestContext.request.requestBody.toString();
        if (jsonRequestBody == null || jsonRequestBody == '') {
            res.responseBody = Blob.valueOf('No application submitted');
            res.statusCode = 200;
        } else {
            try {
                AccountApplication.AOBApplication objResponseBody = (AccountApplication.AOBApplication) JSON.deserialize(jsonRequestBody, AccountApplication.AOBApplication.class);
                AccountApplicationService.syncAccountApplication(objResponseBody);
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = RestContext.request.requestBody;
                res.statusCode = 200;
            } catch (Exception e) {
                res.responseBody = Blob.valueOf(String.valueOf(e) + '\n\n' + e.getStackTraceString());
                res.statusCode = 500;
            }
        }
    }
}