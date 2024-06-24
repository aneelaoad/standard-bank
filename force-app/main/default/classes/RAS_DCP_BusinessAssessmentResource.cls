/**
 * RAS DCP Business Assessment api
 * <br/>SGPRT-1201
 *
 * @author Wayne Solomon
 * @date Aug 2020
 */
@RestResource(UrlMapping='/dcp/v1/business_assessments') @SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.StdCyclomaticComplexity,PMD.NcssMethodCount')
global without sharing class RAS_DCP_BusinessAssessmentResource {

    /**
     * Patch rest resource for dcp
     * <br/>SGPRT-1201
     */
    @HttpPatch global static void doPatch() {
        RestResponse res = RestContext.response;
        List<RAS_DCP_BusinessAssessmentService.DcpResWrapper> dcpResWrappers = new List<RAS_DCP_BusinessAssessmentService.DcpResWrapper>();
        List<Business_Assessment__c> businessAssessments = new List<Business_Assessment__c>();
        List<Map<String, Map<String, Object>>> segregatedReqBodyObjs = new List<Map<String, Map<String, Object>>>{
                new Map<String, Map<String, Object>>(), new Map<String, Map<String, Object>>(), new Map<String, Map<String, Object>>()
        };
        try {
            List<Object> reqBody = (List<Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString().normalizeSpace());
            for (Object o : reqBody) {
                Map<String, Object> rec = (Map<String, Object>) o;
                final String businessAssessmentId = String.valueOf(rec.get(RAS_DCP_BusinessAssessmentService.BUSINESS_ASSESSMENT_ID));
                final String cifNumber = String.valueOf(rec.get(RAS_DCP_BusinessAssessmentService.CIF_NUMBER));
                Boolean businessAssessmentIdNotBlank = String.isNotBlank(businessAssessmentId);
                Boolean cifNumberNotBlank = String.isNotBlank(cifNumber);

                if (businessAssessmentIdNotBlank) {
                    segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.WITH_BA_ID].put(businessAssessmentId, rec);
                    segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.ALL_BA_ID].put(businessAssessmentId, rec);
                } else if (!businessAssessmentIdNotBlank && cifNumberNotBlank) {
                    segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.WITHOUT_BA_ID].put(cifNumber, rec);
                    segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.ALL_BA_ID].put(cifNumber, rec);
                } else {
                    Map<String, String> dcpResWrappersParams = new Map<String, String>{
                            'businessAssessmentId' => null,
                            'msg' => RAS_DCP_BusinessAssessmentService.ERROR_IN_CIF
                    };
                    RAS_DCP_BusinessAssessmentService.processResponseException(dcpResWrappers, dcpResWrappersParams, new RAS_DCP_BusinessAssessmentService.CifException(RAS_DCP_BusinessAssessmentService.ERROR_IN_CIF), rec);
                }
            }
            segregatedReqBodyObjs = new List<Map<String, Map<String, Object>>>((RAS_DCP_BusinessAssessmentService.constructListOfLatestBusinessAssessments(segregatedReqBodyObjs)));

            if (segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.WITH_BA_ID].values().size() != segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.ALL_BA_ID].values().size()) {
                for (String s : segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.ALL_BA_ID].keySet()) {
                    if (!segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.WITH_BA_ID].containsKey(s)) {
                        Map<String, String> dcpResWrappersParams = new Map<String, String>{
                                'businessAssessmentId' => null,
                                'msg' => RAS_DCP_BusinessAssessmentService.ERROR_IN_CIF
                        };
                        RAS_DCP_BusinessAssessmentService.processResponseException(dcpResWrappers, dcpResWrappersParams, new RAS_DCP_BusinessAssessmentService.CifException(RAS_DCP_BusinessAssessmentService.ERROR_IN_CIF), segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.ALL_BA_ID].get(s));
                    }
                }
            }
            segregatedReqBodyObjs = RAS_DCP_BusinessAssessmentService.cleanupLists(segregatedReqBodyObjs);

            for (Object o : segregatedReqBodyObjs[RAS_DCP_BusinessAssessmentService.WITH_BA_ID].values()) {
                Map<String, Object> rec = (Map<String, Object>) o;
                final String businessAssessmentId = String.valueOf(rec.get(RAS_DCP_BusinessAssessmentService.BUSINESS_ASSESSMENT_ID));
                final String creditpaperId = String.valueOf(rec.get('creditpaperId'));
                final String creditpaperUrl = String.valueOf(rec.get('creditpaperUrl'));
                final String creditpaperCreatedDate = String.valueOf(rec.get('creditpaperCreatedDate'));
                final String creditpaperCreatedBy = String.valueOf(rec.get('creditpaperCreatedBy'));
                final String creditpaperDeclined = String.valueOf(rec.get('creditpaperDeclined'));
                final String creditpaperDeclinedReason = String.valueOf(rec.get('creditpaperDeclinedReason'));
                final String creditpaperDeclinedDate = String.valueOf(rec.get('creditpaperDeclinedDate'));
                final String creditpaperDeclinedBy = String.valueOf(rec.get('creditpaperDeclinedBy'));
                final String creditpaperApprovalSentDate = String.valueOf(rec.get('creditpaperApprovalSentDate'));
                final String creditpaperApprovalSentBy = String.valueOf(rec.get('creditpaperApprovalSentBy'));
                final String creditpaperApprovedDate = String.valueOf(rec.get('creditpaperApprovedDate'));
                final String creditpaperApprovedBy = String.valueOf(rec.get('creditpaperApprovedBy'));
                try {
                    businessAssessments.add(new Business_Assessment__c(
                            Id = (RAS_DCP_BusinessAssessmentService.isValidId(businessAssessmentId)) ? businessAssessmentId : null,
                            Credit_Paper_ID__c = String.isNotBlank(creditpaperId) ? creditpaperId : RAS_DCP_BusinessAssessmentService.EMPTY_STRING,
                            Credit_Paper_URL__c = String.isNotBlank(creditpaperUrl) ? creditpaperUrl : RAS_DCP_BusinessAssessmentService.EMPTY_STRING,
                            Credit_Paper_Application_Created__c = String.isNotBlank(creditpaperCreatedDate) ? RAS_DCP_BusinessAssessmentService.parseDateTime(creditpaperCreatedDate) : null,
                            Credit_Paper_Application_Created_By__c = String.isNotBlank(creditpaperCreatedBy) ? creditpaperCreatedBy : RAS_DCP_BusinessAssessmentService.EMPTY_STRING,
                            Credit_Paper_Declined__c = Boolean.valueOf(creditpaperDeclined),
                            Credit_Paper_Decline_Reason__c = String.isNotBlank(creditpaperDeclinedReason) ? creditpaperDeclinedReason : RAS_DCP_BusinessAssessmentService.EMPTY_STRING,
                            Credit_Paper_Decline_Date__c = String.isNotBlank(creditpaperDeclinedDate) ? RAS_DCP_BusinessAssessmentService.parseDateTime(creditpaperDeclinedDate) : null,
                            Credit_Paper_Decline_By__c = String.isNotBlank(creditpaperDeclinedBy) ? creditpaperDeclinedBy : RAS_DCP_BusinessAssessmentService.EMPTY_STRING,
                            Credit_Paper_Sent_for_Approval__c = String.isNotBlank(creditpaperApprovalSentDate) ? RAS_DCP_BusinessAssessmentService.parseDateTime(creditpaperApprovalSentDate) : null,
                            Credit_Paper_Sent_for_Approval_By__c = String.isNotBlank(creditpaperApprovalSentBy) ? creditpaperApprovalSentBy : RAS_DCP_BusinessAssessmentService.EMPTY_STRING,
                            Credit_Paper_Approval__c = String.isNotBlank(creditpaperApprovedDate) ? RAS_DCP_BusinessAssessmentService.parseDateTime(creditpaperApprovedDate) : null,
                            Credit_Paper_Approved_By__c = String.isNotBlank(creditpaperApprovedBy) ? creditpaperApprovedBy : RAS_DCP_BusinessAssessmentService.EMPTY_STRING
                    ));
                } catch (RAS_DCP_BusinessAssessmentService.IdException ie) {
                    Map<String, String> dcpResWrappersParams = new Map<String, String>{
                            'businessAssessmentId' => null,
                            'msg' => ie.getMessage()
                    };
                    RAS_DCP_BusinessAssessmentService.processResponseException(dcpResWrappers, dcpResWrappersParams, ie, rec);
                } catch (RAS_DCP_BusinessAssessmentService.DateException de) {
                    Map<String, String> dcpResWrappersParams = new Map<String, String>{
                            'businessAssessmentId' => businessAssessmentId,
                            'msg' => de.getMessage()
                    };
                    RAS_DCP_BusinessAssessmentService.processResponseException(dcpResWrappers, dcpResWrappersParams, de, rec);
                } catch (Exception e) {
                    Map<String, String> dcpResWrappersParams = new Map<String, String>{
                            'businessAssessmentId' => null,
                            'msg' => String.valueOf(e)
                    };
                    RAS_DCP_BusinessAssessmentService.processResponseException(dcpResWrappers, dcpResWrappersParams, e, rec);
                }
            }

            dcpResWrappers.addAll(RAS_DCP_BusinessAssessmentService.constructDmlResponse(businessAssessments));
            res.addHeader(RAS_DCP_BusinessAssessmentService.CONTENT_TYPE, RAS_DCP_BusinessAssessmentService.APPLICATION_JSON);
            res.responseBody = Blob.valueOf(JSON.serializePretty(new RAS_DCP_BusinessAssessmentService.DcpMainResWrapper(dcpResWrappers.size(), dcpResWrappers)));
            res.statusCode = 200;

        } catch (TypeException te) {
            String msg = String.format('{0} Ensure structure is an array of objects and that dates are in the correct format and retransmit.',
                    new List<Object>{
                            RAS_DCP_BusinessAssessmentService.ERROR_IN_PAYLOAD
                    });
            RAS_DCP_BusinessAssessmentService.processPayloadException(res, msg, te);
        } catch (JSONException je) {
            String msg = String.format('{0} Please review payload object/s, colons, commas, double quotes, opening and closing braces and retransmit.',
                    new List<Object>{
                            RAS_DCP_BusinessAssessmentService.ERROR_IN_PAYLOAD
                    });
            RAS_DCP_BusinessAssessmentService.processPayloadException(res, msg, je);
        } catch (ListException le) {
            String msg = String.format('{0} {1}.',
                    new List<Object>{
                            RAS_DCP_BusinessAssessmentService.ERROR_IN_PAYLOAD, le.getMessage()
                    });
            RAS_DCP_BusinessAssessmentService.processPayloadException(res, msg, le);
        } catch (Exception e) {
            RAS_DCP_BusinessAssessmentService.processPayloadException(res, String.valueOf(e), e);
        }
    }
}