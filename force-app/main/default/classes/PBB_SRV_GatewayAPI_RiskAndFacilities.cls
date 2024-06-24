/**
 * Service class for Proact risk and facilities API.
 * <br/>US-1008
 *
 *
 * @author Maria Pszonka (mpszonka@deloittece.com)
 * @date July 2020
 */
public with sharing class PBB_SRV_GatewayAPI_RiskAndFacilities implements IService {
    private static final SRV_HttpRequestSender.IService httpService = SRV_HttpRequestSender.newInstance();
    private static final PBB_SRV_GatewayRequestProvider.IService requestProviderService = PBB_SRV_GatewayRequestProvider.newInstance();

    private static final String CALLOUT = 'callout:gatewaynp';
    private static final String URL_GET_DATA = '/proact-risk-profile/profiles';

    public interface IService {
        List<RiskAndFacilities> getData(String GUID);
    }
    public static IService newInstance() {
        return(IService) ORG_Application.service.newInstance(IService.class);
    }

    public class ApiException extends Exception {
    }

    /**
    * Method fetches data for a specific client from API
    * <br/>US-1008
    *
    * @param GUID client's GUID
    * @return wrapped response
    */
    public List<RiskAndFacilities> getData(String GUID) {
        HttpRequest req = buildCallRequest();
        req.setEndpoint(CALLOUT + URL_GET_DATA);
        req.setMethod('POST');
        RiskAndFacilitiesRequest body = new RiskAndFacilitiesRequest();
        body.PartnerGUID = GUID;
        req.setBody(JSON.serialize(body));
        HttpResponse res = httpService.send(req, 2);
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            List<RiskAndFacilities> response = (List<RiskAndFacilities>) JSON.deserialize(res.getBody(), List<RiskAndFacilities>.class);
            return response;
        } else if (res.getStatusCode() == 204 || (res.getStatusCode() == 200 && String.isBlank(res.getBody()))) {
            return null;
        } else {
            throw new ApiException(String.format('Error! For client {0} Got {1} with {2}, body {3}', new List<String>{
                    GUID, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
    }

    private HttpRequest buildCallRequest() {
        HttpRequest req = requestProviderService.getRequestWithToken();
        req.setHeader('accept', 'application/json');
        req.setTimeout(45000);
        req.setHeader('content-type', 'application/json');
        return req;
    }

    @TestVisible
    private class RiskAndFacilitiesRequest {
        public String PartnerGUID;
    }

    public class RiskAndFacilities {
        @AuraEnabled
        public Integer ERI1;
        @AuraEnabled
        public Integer ERL1;
        @AuraEnabled
        public Decimal DAYS_DISHONOURS_L6M;
        @AuraEnabled
        public Decimal DAYS_IN_EXCESS_L6M;
        @AuraEnabled
        public String HEADROOM;
        @AuraEnabled
        public Decimal CURRENT_LIMIT;
        @AuraEnabled
        public String EXP_MONTHLY_CR_TURN;
        @AuraEnabled
        public Boolean JUDGEMENT_FLAG;
        @AuraEnabled
        public Boolean DIRECTOR_JUDGEMENT_FLAG;
        @AuraEnabled
        public String RISK_MONITORING_TYPE;
    }
}