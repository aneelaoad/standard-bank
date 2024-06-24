/**
 * Created by Caro on 2018/08/15.
 */
@RestResource(urlMapping='/LegalEntity/*')
global class AOB_ClientResource {

    @HttpGet
    global static list<Account> doGet() {

        String registrationNumber = RestContext.request.params.get('registrationNumber');
        String registeredName = RestContext.request.params.get('registeredName');

        return AccountService.getClients(registrationNumber,registeredName);
    }

    @HttpPost
    global static void doPost(){
        RestResponse res = RestContext.response;
        String jsonRequestBody = RestContext.request.requestBody.toString();
        Blob responseBody;
        Integer statusCode;
        if (jsonRequestBody == null || jsonRequestBody == ''){
            res.responseBody = Blob.valueOf('Unable to process request. No Onboarding Application supplied.');
            res.statusCode = 400;
        } else {
            List<Account> newClientList;
            try {
                OnboardingApplication objResponseBody = (OnboardingApplication) JSON.deserialize(jsonRequestBody, OnboardingApplication.class);
                String requestType = OnboardingApplicationService.determineOnboardingRequestType(objResponseBody);
                newClientList = OnboardingApplicationService.processOnboardingRequest(objResponseBody, requestType);
                if (requestType ==  OnboardingApplicationService.REQUEST_TYPE_NEW_CLIENT ) {
                    if (newClientList.size() == 1) {
                        String onboardingCountry = objResponseBody.legalEntity.registeredCountry == 'ZA' ? 'SA' : 'AR';
                        AOB_OnboardingService.sendClientsData(newClientList[0].Id, onboardingCountry);
                        responseBody = Blob.valueOf(JSON.serialize(newClientList[0]));
                        statusCode = 200;
                    } else {
                        responseBody = Blob.valueOf('Onboarding request failed. Requested Entity was successfully processed but not stored.');
                        statusCode = 500;
                    }
                } else if (requestType <> OnboardingApplicationService.REQUEST_TYPE_NEW_CLIENT) {
                    OnboardingApplicationService.sendRequestNotificationEmail(newClientList[0].Id, objResponseBody.legalEntity.parentEntityCIF, objResponseBody.requester.requestedBy, requestType);
                    responseBody = Blob.valueOf(JSON.serialize(newClientList[0]));
                    statusCode = 200;
                    res.addHeader('Content-Type', 'application/json');
                } else {
                    responseBody = Blob.valueOf('Unable to process request. Unable to determine the request type. Onboarding, Migration or Hierarchy Change.');
                    statusCode = 400;
                }
            } catch (Exception e) {
                responseBody = Blob.valueOf('Onboarding request failed. ' + String.valueOf(e) + '\n\n' + e.getStackTraceString());
                statusCode = 500;
            } finally {

                res.statusCode = statusCode;
                res.responseBody = responseBody;
            }
        }
    }
}