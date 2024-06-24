/**
 * RAS DCP Business Assessment service
 * <br/>SGPRT-1201
 *
 * @author Wayne Solomon
 * @date Aug 2020
 */
public inherited sharing class RAS_DCP_BusinessAssessmentService {

    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String APPLICATION_JSON = 'application/json';
    public static final String BUSINESS_ASSESSMENT_ID = 'businessAssessmentId';
    public static final Integer WITH_BA_ID = 0;
    public static final Integer WITHOUT_BA_ID = 1;
    public static final Integer ALL_BA_ID = 2;
    public static final String ERROR = 'ERROR';
    public static final String EMPTY_STRING = '';
    public static final String CIF_NUMBER = 'cifNumber';
    public static final String ERROR_IN_PAYLOAD = 'There is problem in the payload.';
    public static final String ERROR_IN_CIF = 'Missing / invalid cifNumber or no \'Submitted\' business assessments found for cifNumber.';
    public static final Integer BAD_REQUEST = 400;

    private static final Integer LATEST_BA_RECORD = 0;
    private static final String SUCCESS = 'SUCCESS';
    private static final String SUCCESS_ON_PATCH = 'Business Assessment has been successfully patched';
    private static final String ERROR_IN_ID = 'Missing / invalid Id for businessAssessmentId.';
    private static final String ERROR_IN_DATE = 'Missing / invalid date or time found. Enter format as \'yyyy-MM-dd HH:mm\'.';
    private static final String GENERAL_ERROR_MSG = 'An error has occurred. Please forward to your Salesforce Support Centre.';
    private static final String GENERAL_CONTACT_EMAIL = 'Email crmsalesforce.com@standardbank.co.za';
    private static final String GENERAL_CONTACT_CALL = 'Call +27 11 721 8444.';
    private static final String GENERAL_CONTACT_US = String.format('{0} - {1}', new List<Object>{
            GENERAL_CONTACT_EMAIL, GENERAL_CONTACT_CALL
    });

    /**
     * Retrieve latest business assessment
     * @param segregatedReqBodyObjsInput list for object organising
     * @return JSONGenerator
     */
    public static List<Map<String, Map<String, Object>>> constructListOfLatestBusinessAssessments(List<Map<String, Map<String, Object>>> segregatedReqBodyObjsInput) {
        List<Map<String, Map<String, Object>>> segregatedReqBodyObjs = new List<Map<String, Map<String, Object>>>(segregatedReqBodyObjsInput);
        for (Account a : AccountService.getAccountsWithBusinessAssessments(segregatedReqBodyObjs[WITHOUT_BA_ID].keySet())) {
            segregatedReqBodyObjs[WITHOUT_BA_ID].get(a.CIF__c).put(BUSINESS_ASSESSMENT_ID, a.Business_Assessments__r[LATEST_BA_RECORD].Id);
            segregatedReqBodyObjs[WITH_BA_ID].put(a.Business_Assessments__r[LATEST_BA_RECORD].Id, segregatedReqBodyObjs[WITHOUT_BA_ID].get(a.CIF__c));
            segregatedReqBodyObjs[ALL_BA_ID].put(a.Business_Assessments__r[LATEST_BA_RECORD].Id, segregatedReqBodyObjs[WITHOUT_BA_ID].get(a.CIF__c));
            segregatedReqBodyObjs[WITHOUT_BA_ID].remove(a.CIF__c);
            segregatedReqBodyObjs[ALL_BA_ID].remove(a.CIF__c);
        }
        return segregatedReqBodyObjs;
    }

    /**
     * Error handling
     * @param businessAssessments list of businessAssessments
     * @return dcpResWrappers
     */
    public static List<DcpResWrapper> constructDmlResponse(List<Business_Assessment__c> businessAssessments) {
        List<DcpResWrapper> dcpResWrappers = new List<DcpResWrapper>();
        List<Database.SaveResult> saveResults = BusinessAssessmentService.updateBusinessAssessments(businessAssessments);
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
                dcpResWrappers.add(new DcpResWrapper(saveResults[i].getId(), SUCCESS, SUCCESS_ON_PATCH, EMPTY_STRING));
            } else {
                dcpResWrappers.add(new DcpResWrapper(businessAssessments[i].Id, ERROR, String.valueOf(saveResults[i].getErrors()[0].getMessage()), EMPTY_STRING));
            }
        }
        return dcpResWrappers;
    }

    /**
     * Clear up workspace
     * @param segregatedReqBodyObjs list for object organising
     * @return segregatedReqBodyObjs
     */
    public static List<Map<String, Map<String, Object>>> cleanupLists(List<Map<String, Map<String, Object>>> segregatedReqBodyObjs) {
        segregatedReqBodyObjs[WITHOUT_BA_ID] = null;
        segregatedReqBodyObjs[ALL_BA_ID] = null;
        return segregatedReqBodyObjs;
    }

    /**
     * Generate a unique json error repsonse
     * @param error text
     * @param code restful code
     * @return RestResponse
     */
    public static RestResponse genJsonErr(String error, Integer code) {
        RestResponse res = RestContext.response;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('errors');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('message', GENERAL_ERROR_MSG);
        gen.writeStringField('contact_us', GENERAL_CONTACT_US);
        gen.writeStringField('error', String.valueOf(error));
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        res.responseBody = Blob.valueOf(gen.getAsString());
        res.statusCode = code;
        res.addHeader(CONTENT_TYPE, APPLICATION_JSON);
        return res;
    }

    /**
     * Validate a business assessment id
     * @param businessAssessmentId id to validate
     * @return Boolean
     */
    public static Boolean isValidId(String businessAssessmentId) {
        if (String.isNotBlank(businessAssessmentId) && Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(businessAssessmentId).matches()) {
            try {
                ((Business_Assessment__c) Business_Assessment__c.class.newInstance()).Id = businessAssessmentId;
            } catch (Exception e) {
                throw new IdException(ERROR_IN_ID);
            }
        } else {
            throw new IdException(ERROR_IN_ID);
        }
        return true;
    }

    /**
     * Parse a date string
     * @param dateTimeInput string for parsing
     * @return Datetime
     */
    public static Datetime parseDateTime(String dateTimeInput) {
        try {
            List<String> dt = dateTimeInput.split(' ');
            List<String> myDate = dt[0].split('-');
            List<String> myTime = dt[1].split(':');
            return Datetime.newInstance(Integer.valueOf(myDate[0]), Integer.valueOf(myDate[1]), Integer.valueOf(myDate[2]), Integer.valueOf(myTime[0]), Integer.valueOf(myTime[1]), 0);
        } catch (Exception e) {
            throw new DateException(ERROR_IN_DATE);
        }
    }

    /**
     * Process a response exception
     * @param dcpResWrappers string for parsing
     * @param dcpResWrappersParams string for parsing
     * @param e Exception
     * @param o Response object
     */
    public static void processResponseException(List<RAS_DCP_BusinessAssessmentService.DcpResWrapper> dcpResWrappers, Map<String, String> dcpResWrappersParams, Exception e, Object o) {
        dcpResWrappers.add(new DcpResWrapper(dcpResWrappersParams.get('businessAssessmentId'), ERROR, dcpResWrappersParams.get('msg'), String.valueOf(o)));
        if (Limits.getDmlStatements() > 0) {
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_IB_DCP, RAS_DCP_BusinessAssessmentResource.class.getName());
        }
    }

    /**
     * Process a payload exception
     * @param res RestResponse
     * @param msg Message string
     * @param e Exception
     */
    public static void processPayloadException(RestResponse res, String msg, Exception e) {
        res = genJsonErr(msg, BAD_REQUEST);
        if (Limits.getDmlStatements() > 0) {
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_IB_DCP, RAS_DCP_BusinessAssessmentResource.class.getName());
        }
    }

    /**
     * DcpMainResWrapper inner class
     */
    public class DcpMainResWrapper {
        Integer count;
        List<DcpResWrapper> responses;
        /**
         * DcpMainResWrapper constructor
         * @param count count
         * @param responses responses
         */
        public DcpMainResWrapper(Integer count, List<DcpResWrapper> responses) {
            this.count = count;
            this.responses = responses;
        }
    }
    /**
     * DcpResWrapper inner class
     */
    public class DcpResWrapper {
        String businessAssessmentId;
        String result;
        String responseMessage;
        String errorPayload;
        /**
         * DcpMainResWrapper constructor
         * @param businessAssessmentId businessAssessmentId
         * @param result result
         * @param responseMessage responseMessage
         * @param errorPayload errorPayload
         */
        public DcpResWrapper(String businessAssessmentId, String result, String responseMessage, String errorPayload) {
            this.businessAssessmentId = businessAssessmentId;
            this.result = result;
            this.responseMessage = responseMessage;
            this.errorPayload = errorPayload;
        }
    }

    public class CifException extends Exception {
    }
    public class IdException extends Exception {
    }
    public class DateException extends Exception {
    }
}