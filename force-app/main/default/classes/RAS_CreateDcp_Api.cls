/**
* Salesforce NBAC - DCP Integration
* As a NBAC Secretary I want to approve the NBAC In order to automatically trigger a
* DCP (Digital Credit Paper).  This code gets triggered from the
* "On Business Assessment Update" process builder
* US-4434
*
* @author Wayne Solomon
* @date 2020-01-08
*
* Minor bug fixing
* Improved error handling
* Refactored to use service class and increase in dcpwrapper class size
*
* @modified Wayne Solomon
* @date 2020-06-17
*/
public without sharing class RAS_CreateDcp_Api {

    /**
     * Create digital credit paper on risk app store.
     *
     * @param nbacIds
     */
    @InvocableMethod(label='Create DCP on RAS' description='Create digital credit paper on risk app store.')
    public static void executeDcpCreation(List<Id> nbacIds) {
        if (!nbacIds.isEmpty()) {
            List<DcpWrapper> dcpWrappers = new List<DcpWrapper>();
            dcpWrappers = RAS_CreateDcp_Api.getDCPData(nbacIds);
            if (!dcpWrappers.isEmpty()) {
                System.enqueueJob(new RAS_CreateDcp_ApiGetTokenQ(dcpWrappers, nbacIds));
            } else {
                RAS_CreateDcp_Api.writeResponseStatus('A data access error occurred.  Records could not be sent.', nbacIds);
            }
        }
    }

    @TestVisible static List<DcpWrapper> getDCPData(List<Id> nbacIds) {
        Map<Id, Business_Assessment__c> mapBusinessAssessments = BusinessAssessmentService.getBusinessAssessmentsWithAssessmentOpps(new Set<Id>(nbacIds));
        List<DcpWrapper> dcpWrappers = new List<DcpWrapper>();
        if (!mapBusinessAssessments.values().isEmpty()) {
            for (Business_Assessment__c ba : mapBusinessAssessments.values()) {
                for (Assessment_Opportunity__c ao : ba.Assessment_Opportunities__r) {
                    dcpWrappers.add(new DcpWrapper(ba, ao));
                }
            }
        }
        return dcpWrappers;
    }

    /**
     * Obtain access token for DCP API
     *
     * @param nbacIds
     *
     * @return
     */
    public static String getAccessToken(List<Id> nbacIds) {
        RasDcpApiSettings__c rasDcpApiSettings = RasDcpApiSettings__c.getOrgDefaults();
        HttpResponse res;
        Map<String, Object> resBody;
        String accessToken;
        try {
            res = RAS_CreateDcp_Api.retryAndHandleEndpointResponses(
                    String.valueOf(rasDcpApiSettings.AuthUrl__c),
                    'application/x-www-form-urlencoded',
                    null,
                    'client_id=' + EncodingUtil.urlEncode(String.valueOf(rasDcpApiSettings.client_id__c), 'UTF-8')
                            + '&client_secret=' + EncodingUtil.urlEncode(String.valueOf(rasDcpApiSettings.client_secret__c), 'UTF-8')
                            + '&grant_type=' + String.valueOf(rasDcpApiSettings.grant_type__c)
                            + '&resource=' + String.valueOf(rasDcpApiSettings.resource__c),
                    'POST'
            );
            resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            accessToken = String.valueOf(resBody.get('access_token'));
        } catch (Exception e) {
            System.debug(e); RAS_CreateDcp_Api.writeResponseStatus(String.valueOf(e), nbacIds); return null;
        }
        return accessToken;
    }

    /**
     * Send NBAC data to DCP system
     *
     * @param accessToken
     * @param dcpWrappers
     * @param nbacIds
     *
     * @return
     */
    public static List<Object> postNbac(String accessToken, List<DcpWrapper> dcpWrappers, List<Id> nbacIds) {
        RasDcpApiSettings__c rasDcpApiSettings = RasDcpApiSettings__c.getOrgDefaults();
        String jsonString = JSON.serialize(dcpWrappers);
        HttpResponse res;
        List<Object> result;
        try {
            res = RAS_CreateDcp_Api.retryAndHandleEndpointResponses(
                    String.valueOf(rasDcpApiSettings.DcpPostingUrl__c),
                    'application/json',
                    accessToken,
                    jsonString,
                    'POST'
            );
            result = (List<Object>) JSON.deserializeUntyped(res.getBody());
        } catch (Exception e) {
            System.debug(e); RAS_CreateDcp_Api.writeResponseStatus(String.valueOf(e), nbacIds); return null;
        }
        return result;
    }

    /**
     * Update Nbac_API_Posting_Status__c field on Business_Assessment__c records
     *
     * @param resBody
     */
    public static void writeResponseStatus(List<Object> resBody) {
        Set<Business_Assessment__c> businessAssessments = new Set<Business_Assessment__c>();
        for (Object o : resBody) {
            Map<String, Object> rec = (Map<String, Object>) o;
            businessAssessments.add(new Business_Assessment__c(
                    Id = String.valueOf(rec.get('businessAssessmentId')),
                    Nbac_API_Posting_Status__c = String.valueOf(rec.get('result')),
                    Nbac_API_Posting_Description__c = String.valueOf(rec.get('responseMessage'))));
        }
        List<Database.SaveResult> srList = Database.update(new List<Business_Assessment__c>(businessAssessments), false);
    }

    /**
     * Update Nbac_API_Posting_Status__c field on Business_Assessment__c records in case of error
     *
     * @param result
     * @param nbacIds
     */
    public static void writeResponseStatus(String result, List<Id> nbacIds) {
        Set<Business_Assessment__c> businessAssessments = new Set<Business_Assessment__c>();
        for (Id i : nbacIds) {
            businessAssessments.add(new Business_Assessment__c(Id = i, Nbac_API_Posting_Status__c = result));
        }
        List<Database.SaveResult> srList = Database.update(new List<Business_Assessment__c>(businessAssessments), false);
    }

    static HttpResponse retryAndHandleEndpointResponses(String endpoint, String contentType, String accessToken, String body, String method) {
        HttpResponse res;
        Boolean retry = false;
        Integer retries = 5;
        do {
            res = RAS_CreateDcp_Api.makeCallout(
                    endpoint,
                    contentType,
                    accessToken,
                    body,
                    method
            );
            if (String.valueOf(res.getStatusCode()).startsWith('5')) {
                retry = true; retries--;
            } else if (retry) {
                retry = false;
            }
        } while (retry && retries > 0 && (Limits.getCallouts() < Limits.getLimitCallouts() - 1) && (Limits.getCpuTime() < (Limits.getLimitCpuTime() - 3000)));
        return res;
    }

    static HttpResponse makeCallout(String endpoint, String contentType, String accessToken, String body, String method) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Content-Type', contentType);
        if (accessToken != null) {
            req.setHeader('Authorization', 'Bearer ' + accessToken);
        }
        req.setTimeout(120000);
        if (method != 'GET') {
            req.setBody(body);
        }
        return new Http().send(req);
    }

    /**
     * @description Wrapper class for DCP message created out of Business_Assessment__c record
     */
    public class DcpWrapper {
        String cifNumber;
        String referenceId;
        String userReferenceID;
        String approvalDate;
        String opportunityCurrency;
        String limitAmount;
        String messageType = 'Salesforce';
        String businessAssessmentId;
        String businessAssessmentName;
        String economicGroupClientSector;
        String economicGroupClientCountryofRisk;
        String economicGroupSectorRiskAppetite;
        String riskClassification;
        String complexity;
        String decisionEmphasis;
        String clientLGD;
        String groupParentClientName;
        String guarantorName;
        String natureofBusiness;
        String transactionProfile;
        String transactionType;
        String strategicRationale;
        String underwriteAmount;
        String sbGrossParticipation;
        String amountHeld;
        String sbHold;
        String sbsaRole;
        String bankRole;
        String creditRequirement;
        String sbSellDown;
        String marketDealSize;
        String listedInstruments;
        String riskCommentary;
        String gccrStatus;
        String kycStatus;
        String eddPep;
        String sanctions;
        String transactionRisk;
        String clientRisk;
        String referenceNumber;
        String transactionontheExceptionsList;
        String environmentalSocialRisksTool;
        String businessSponsor;
        String transactionDescription;

        /**
         * Constructor for DcpWrapper class
         *
         * @param businessAssessment
         * @param assessmentOpportunity
         */
        public DcpWrapper(Business_Assessment__c businessAssessment, Assessment_Opportunity__c assessmentOpportunity) {
            this.cifNumber = String.isBlank(String.valueOf(businessAssessment.Account__r.CIF__c)) ? String.valueOf('0') : businessAssessment.Account__r.CIF__c;
            this.referenceId = assessmentOpportunity.Opportunity__c;
            this.userReferenceID = assessmentOpportunity.Opportunity__r.Opportunity_ID__c;
            this.approvalDate = String.isBlank(String.valueOf(businessAssessment.Approval_Milestone_Date__c)) ? String.valueOf(System.now()) : String.valueOf(businessAssessment.Approval_Milestone_Date__c);
            this.opportunityCurrency = assessmentOpportunity.Opportunity__r.CurrencyIsoCode;
            this.limitAmount = String.valueOf(assessmentOpportunity.Total_SB_Gross_Participation__c);
            this.businessAssessmentId = businessAssessment.Id;
            this.businessAssessmentName = businessAssessment.Name;
            this.economicGroupClientSector = businessAssessment.Economic_Group_Client_Sector__c;
            this.economicGroupClientCountryofRisk = businessAssessment.Economic_Group_Client_Country_of_Risk__c;
            this.economicGroupSectorRiskAppetite = businessAssessment.Economic_Group_Sector_Risk_Appetite__c;
            this.riskClassification = businessAssessment.Risk_Classification__c;
            this.complexity = businessAssessment.Complexity__c;
            this.decisionEmphasis = businessAssessment.Decision_Emphasis__c;
            this.clientLGD = String.valueOf(businessAssessment.Client_LGD__c);
            this.groupParentClientName = businessAssessment.Group_Parent_Client_Name__c;
            this.guarantorName = businessAssessment.Guarantor_Name__c;
            this.natureofBusiness = businessAssessment.Nature_of_Business__c;
            this.transactionProfile = businessAssessment.Transaction_Profile__c;
            this.transactionType = businessAssessment.Transaction_Type__c;
            this.strategicRationale = businessAssessment.Strategic_Rationale__c;
            this.underwriteAmount = String.valueOf(businessAssessment.Underwrite_Amount__c);
            this.sbGrossParticipation = String.valueOf(businessAssessment.SB_Gross_Participation__c);
            this.amountHeld = String.valueOf(businessAssessment.Amount_Held__c);
            this.sbHold = String.valueOf(businessAssessment.SB_Hold__c);
            this.sbsaRole = businessAssessment.SBSA_Role__c;
            this.bankRole = businessAssessment.Bank_Role__c;
            this.creditRequirement = String.valueOf(businessAssessment.Credit_Requirement__c);
            this.sbSellDown = String.valueOf(businessAssessment.SB_Sell_Down__c);
            this.marketDealSize = String.valueOf(businessAssessment.Market_Deal_Size__c);
            this.listedInstruments = businessAssessment.Listed_Instruments__c;
            this.riskCommentary = businessAssessment.Risk_Commentary__c;
            this.gccrStatus = businessAssessment.GCCR_Status__c;
            this.kycStatus = businessAssessment.KYC_Status__c;
            this.eddPep = businessAssessment.EDD_PEP__c;
            this.sanctions = businessAssessment.Sanctions__c;
            this.transactionRisk = businessAssessment.Transaction_Risk__c;
            this.clientRisk = businessAssessment.Client_Risk__c;
            this.referenceNumber = businessAssessment.Reference_Number__c;
            this.transactionontheExceptionsList = String.valueOf(businessAssessment.Transaction_on_the_Exceptions_List__c);
            this.environmentalSocialRisksTool = businessAssessment.Link_to_ENS__c;
            this.businessSponsor = businessAssessment.Business_Sponsor__c;
            this.transactionDescription = businessAssessment.Transaction_Description__c;
        }
    }
}