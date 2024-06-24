/**
 * Rest Resource for Marketing Pocket RSVP integration
 * <br/>
 *
 * @author Mykhailo Reznyk (mreznyk@deloittece.com)
 * @date October 2019
 * 
 * @ Last Modified By       : Maksim Dzianisik
 * @ Last Modified On       : July 2021
 * @ last Modified Reason   : SFP-5893
 * @description             : Fixed logic with sending Email notification
 *
 * @Last Modified By        : Maksim Dzianisik
 * @Last Modified On        : Nov 2021
 * @last Modified Reason    : SFP-8467
 * @description             : Tha logic has to send Email notification also to the CampaignMember's Account Client Coordinator
 * 
 * @Last Modified By        : Nikita Haruk
 * @Last Modified On        : Dec 2022
 * @last Modified Reason    : SFP-19908
 * @description             : Updated the logic to prevent the Assistant Name field update on Contact records.
*/
@RestResource(UrlMapping='/Events/*')
global without sharing class PocketRSVP_REST_API {

    private static final List<String> CONTACT_DETAILS_FIELDS = new List<String> {
        DMN_Contact.FN_FIRST_NAME,
        DMN_Contact.FN_LAST_NAME,
        DMN_Contact.FN_EMAIL,
        DMN_Contact.FN_PHONE,
        DMN_Contact.FN_MOBILE_PHONE,
        DMN_Contact.FN_BIRTHDATE,
        DMN_Contact.FN_DEPARTMENT
    };
        
    private static final Set<String> CONTACT_DETAILS_FIELDS_TO_AVOID = new Set<String> {
        DMN_Contact.FN_ASSISTANT_NAME
    };

    private static final Map<String, String> STATUS_TRANSLATION = new Map<String, String> {
        'PENDING'   => DMN_CampaignMember.STATUS_SENT,
        'INVSENT'   => DMN_CampaignMember.STATUS_SENT,
        'DUPLICATE' => DMN_CampaignMember.STATUS_SENT,
        'DELETED'   => DMN_CampaignMember.STATUS_SENT,
        'WAITLIST'  => DMN_CampaignMember.STATUS_RESPONDED,
        'ACCEPT'    => DMN_CampaignMember.STATUS_ACCEPTED,
        'DECLINE'   => DMN_CampaignMember.STATUS_DECLINED
    };

    private static final Map<String, String> ATTENDANCE_STATUS_TRANSLATION = new Map<String, String> {
        'REGISTER'  => DMN_CampaignMember.ATT_STATUS_ATTENDED,
        'WALKIN'    => DMN_CampaignMember.ATT_STATUS_WALK_IN,
        'WALKDE'    => DMN_CampaignMember.ATT_STATUS_WALK_IN,
        'WALKNOINV' => DMN_CampaignMember.ATT_STATUS_WALK_IN,
        'CHECKIN'   => DMN_CampaignMember.ATT_STATUS_ATTENDED,
        'CHECKOUT'  => DMN_CampaignMember.ATT_STATUS_ATTENDED,
        'NOSHOW'    => DMN_CampaignMember.ATT_STATUS_NO_SHOW
    };

    private static final String MFIELD_START = '#!';
    private static final String MFIELD_END   = '!#';

    private static final String MFIELD_CAMPAIGN_NAME = 'CAMPAIGN_NAME';
    private static final String MFIELD_CONTACT_NAME  = 'CONTACT_NAME';
    private static final String MFIELD_FIELDS_LIST   = 'FIELDS_LIST';
    private static final String MFIELD_HOSTS_LIST    = 'HOSTS_LIST';

    private static Contact contactOld;
    private static String ownerName;
    private static String ownerEmail;
    private static Map<String, Object> contactDetailField2NewValue = new Map<String, Object>();

    /**
     * Updates Campaign, its members or Contacts related based on /Events/CAMPAIGN_ID.
     * Sends email to Campaign Hosts if any contact details were changed.
     *
     * @return Transaction status and list of updated fields
     */
    @HttpPatch
    global static ResponseWrapper updateCampaign(){

        RestRequest request = RestContext.request;
        String campaignMemberId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);

        CampaignMember[] campaignMembers = [
            SELECT ContactId, CampaignId,  Status, Attendance_Status__c, Date_Responded__c,
                Campaign_Dietary_Requirements__c, Campaign_Salutation__c, Campaign_Shirt_Size__c
            FROM CampaignMember
            WHERE Id = :campaignMemberId
        ];

        if(campaignMembers.size() == 0){
            ResponseWrapper response = new ResponseWrapper();
            response.message = 'Didn\'t find Campaign Member with such Id';
            return response;
        }

        CampaignMember campMemberRec = campaignMembers[0];

        Contact conRec = [
            SELECT Allergies__c, AssistantName, Birthdate, AccountId, Department, Email, Fax, Birth_Day_Month__c,
                MailingAddress, MobilePhone, Phone, FirstName, LastName, Name,
                SA_Preferred_Language__c, Salutation, Shirt_Size__c, Dietary_Requirements__c, Account.Owner.Name, Account.Owner.Email
            FROM Contact
            WHERE Id= :campMemberRec.ContactId
        ];
        contactOld = conRec.clone();
        ownerName = conRec.Account.Owner.Name;
        ownerEmail = conRec.Account.Owner.Email;

        Campaign campRec = [
            SELECT Name,
                EndDate,
                StartDate,
                Status
            FROM Campaign
            WHERE Id =: campMemberRec.CampaignId
        ];

        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());

        return getResponse(params, conRec, campRec, campMemberRec);
    }

    /**
     * @param params Map<String, Object>
     * @param conRec Contact
     * @param campRec Campaign
     * @param campMemberRec CampaignMember
     * @description getResponse
     * @return ResponseWrapper
     */
    private static ResponseWrapper getResponse(Map<String, Object> params, Contact conRec, Campaign campRec, CampaignMember campMemberRec) {
        ResponseWrapper response = new ResponseWrapper();

        Map<String, SObject> records = new Map<String, SObject> {
            DMN_Contact.OBJ_NAME => conRec,
            DMN_Campaign.OBJ_NAME => campRec,
            DMN_CampaignMember.OBJ_NAME => campMemberRec
        };

        List<SObject> recordsToUpdate = new List<SObject>();
        String originalContactName = conRec.Name;
        for (String objectName : params.keySet()) {
            SObject recordToUpdate = records.get(objectName);
            recordsToUpdate.add(recordToUpdate);

            Map<String, Object> objParams = (Map<String, Object>) params.get(objectName);
            for (String fieldName : objParams.keySet()) {

                if (fieldName == 'Dates') {
                    Map<String, Object> dateParams = (Map<String, Object>) objParams.get(fieldName);
                    //Iterate date fields of current object
                    for (String dateFieldName : dateParams.keySet()) {
                        if (!UTL_Schema.hasField(recordToUpdate.getSObjectType(), dateFieldName)) {
                            response.message = getFieldNotExistingMessage(dateFieldName, objectName);
                            return response;
                        }
                        Date dateFieldValue;
                        try {
                            String dateString = dateParams.get(dateFieldName).toString();
                            String[] dateParts = dateString.split('/');
                            dateFieldValue = Date.newInstance(
                                Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
                        }
                        catch (Exception e) {
                            response.message = 'Error during String to Date conversion; ' + e.getMessage();
                            return response;
                        }
                        response.addUpdatedField(
                            updateMappedFields(dateFieldName, dateFieldValue, recordToUpdate));
                    }
                }
                else if (new Set<String> {DMN_CampaignMember.FN_ATTENDANCE_STATUS, DMN_CampaignMember.FN_STATUS}.contains(fieldName)) {
                    response.addUpdatedField(
                        mapAttendanceStatus(String.valueOf(objParams.get(fieldName)), fieldName, campMemberRec));
                }
                else {
                    if (!UTL_Schema.hasField(recordToUpdate.getSObjectType(), fieldName)) {
                        response.message = getFieldNotExistingMessage(fieldName, objectName);
                        return response;
                    }
                    response.addUpdatedField(
                        updateMappedFields(fieldName, objParams.get(fieldName), recordToUpdate));
                }
            }
        }

        if (response.updatedFields.size() == 0) {
            response.message = 'No field was updated';
        }
        else {
            update recordsToUpdate;
            response.message = 'Successfully updated';
            sendEmailToHostsIfNeeded(campMemberRec, campRec, originalContactName);
        }
        response.status = 'Success';
        return response;
    }

    /**
     * @param fieldName String
     * @param fieldValue Object
     * @param objectToUpdate SObject
     * @description updateMappedFields
     * @return String
     */
    private static String updateMappedFields(String fieldName, Object fieldValue, SObject objectToUpdate) {
        String result = '';
        Set<String> skippedFields = new Set<String> {
            DMN_Contact.FN_ALLERGIES,
            DMN_Contact.FN_DIETARY_REQUIREMENTS,
            DMN_Contact.FN_SHIRT_SIZE,
            DMN_CampaignMember.FN_ATTENDANCE_STATUS,
            DMN_Contact.FN_STATUS
        };
        if ((objectToUpdate.get(fieldName) == null
            || CONTACT_DETAILS_FIELDS.contains(fieldName)
            || skippedFields.contains(fieldName))
        	&& !CONTACT_DETAILS_FIELDS_TO_AVOID.contains(fieldName)){
            objectToUpdate.put(fieldName, fieldValue);
            result += fieldName+ ' field is updated with value: ' + fieldValue;
            if (CONTACT_DETAILS_FIELDS.contains(fieldName)) {
                String oldValue = String.valueOf(contactOld.get(fieldName));
                String newValue = String.valueOf(fieldValue);
                if ((newValue.length() > 0 || oldValue != null) && newValue != oldValue) {
                    contactDetailField2NewValue.put(fieldName, fieldValue);
                }
            }
            if (fieldName == DMN_Contact.FN_BIRTHDATE && objectToUpdate.getSObjectType() == Contact.SObjectType) {
                objectToUpdate.put(Contact.Birth_Day_Month__c, getBirthDayMonth(fieldValue));
            }
        }
        return result;
    }

    /**
     * @param statusCode String
     * @param fieldName String
     * @param campaignMember CampaignMember
     * @description mapAttendanceStatus
     * @return String
     */
    private static String mapAttendanceStatus(String statusCode, String fieldName, CampaignMember campaignMember) {
        String statusString;
        if (fieldName == DMN_CampaignMember.FN_STATUS) {
            statusString = STATUS_TRANSLATION.get(statusCode);
        } else if (fieldName == DMN_CampaignMember.FN_ATTENDANCE_STATUS) {
            statusString = ATTENDANCE_STATUS_TRANSLATION.get(statusCode);
        } else {
            return '';
        }
        return updateMappedFields(fieldName, statusString, campaignMember);
    }

    /**
     * @param fieldValue Object
     * @description getBirthDayMonth
     * @return String
     */
    private static String getBirthDayMonth(Object fieldValue) {
        Date birthdate = Date.valueOf(fieldValue);
        return getStandardizedDayOrMonth(birthdate.day()) + '/' + getStandardizedDayOrMonth(birthdate.month());
    }

    /**
     * @param dayOrMonth Integer
     * @description getStandardizedDayOrMonth
     * @return String
     */
    private static String getStandardizedDayOrMonth(Integer dayOrMonth) {
        return dayOrMonth < 10 ? '0' + dayOrMonth : String.valueOf(dayOrMonth);
    }

    /**
     * @param campMemberRec CampaignMember
     * @param campRec Campaign
     * @param originalContactName String
     * @description sendEmailToHostsIfNeeded
     */
    private static void sendEmailToHostsIfNeeded(CampaignMember campMemberRec, Campaign campRec, String originalContactName) {
        if (!contactDetailField2NewValue.isEmpty()) {
            List<Campaign_Hosts__c> hosts = [
                SELECT Bank_Contact__r.Name,
                    Bank_Contact__r.Email
                FROM Campaign_Hosts__c
                WHERE Campaign_Member_Host__r.Member_Id__c = :campMemberRec.Id
                    AND Bank_Contact__r.Email != NULL
            ];
            if (!hosts.isEmpty() || (ownerName != null && ownerEmail != null)) {
                sendEmailToHosts(campRec, hosts, originalContactName);
            }
        }
    }

    /**
     * @param campaign Campaign
     * @param hosts List<Campaign_Hosts__c>
     * @param originalContactName String
     * @description sendEmailToHosts
     */
    private static void sendEmailToHosts(Campaign campaign, List<Campaign_Hosts__c> hosts, String originalContactName) {
        EmailTemplate template = UTL_EmailTemplate.getTemplate(DCN_EmailTemplate.POCKET_RSVP_CONTACT_UPDATED);

        List<String> hostsNames = new List<String>();
        List<String> toAddresses = new List<String>();
        if(!hosts.isEmpty()) {
            for (Integer i = 0, j = hosts.size(); i < j; i++) {
                Campaign_Hosts__c host = hosts[i];
                hostsNames.add(host.Bank_Contact__r.Name);
                toAddresses.add(host.Bank_Contact__r.Email);
            }
        }
        if(ownerName != null && ownerEmail != null) {
            hostsNames.add(ownerName);
            toAddresses.add(ownerEmail);
        }

        List<String> updatedConDetailFields = new List<String>();
        for (Integer i = 0, j = CONTACT_DETAILS_FIELDS.size(); i < j; i++) {
            String fieldName = CONTACT_DETAILS_FIELDS[i];
            if (contactDetailField2NewValue.containsKey(fieldName)) {
                updatedConDetailFields.add(' - ' + UTL_Schema.getFieldLabel(Contact.SObjectType, fieldName) + ': '
                    + contactDetailField2NewValue.get(fieldName) + '; Old Value: ' + String.valueOf(contactOld.get(fieldName)));
            }
        }

        String body = template.HtmlValue;
        body = body.replace(getMergeField(MFIELD_HOSTS_LIST), String.join(hostsNames, ', '));
        body = body.replace(getMergeField(MFIELD_CONTACT_NAME), originalContactName);
        body = body.replace(getMergeField(MFIELD_CAMPAIGN_NAME), campaign.Name);
        body = body.replace(getMergeField(MFIELD_FIELDS_LIST), String.join(updatedConDetailFields, '<br/>'));

        String subject = template.Subject;
        subject = subject.replace(getMergeField(MFIELD_CONTACT_NAME), originalContactName);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setOrgWideEmailAddressId(UTL_OrgWideEmailAddress.getAddressId(
            EmailAddress__c.getInstance('CRM Data Mailbox').Email__c.removeEnd('.fake')));
        email.setSubject(subject);
        email.setHtmlBody(body);
        email.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {email}, false);
    }

    /**
     * @param mergeFieldText String
     * @description getMergeField
     * @return String
     */
    private static String getMergeField(String mergeFieldText) {
        return MFIELD_START + mergeFieldText + MFIELD_END;
    }

    /**
     * @param fieldName String
     * @param sObjectName String
     * @description getFieldNotExistingMessage
     * @return String
     */
    private static String getFieldNotExistingMessage(String fieldName, String sObjectName) {
        return String.format('Invalid field {0} for {1}',
            new List<String> {
                fieldName,
                sObjectName
            }
        );
    }

    /**
     * Stores transaction status, message and list of updated fields.
     */
    global class ResponseWrapper {
        global String status {get;set;}
        global String message {get;set;}
        global String[] updatedFields {get;set;}

        private ResponseWrapper() {
            this.status = 'Error';
            this.message = '';
            this.updatedFields = new String[]{};
        }

        private void addUpdatedField(String field) {
            if (String.isNotBlank(field)) {
                updatedFields.add(field);
            }
        }
    }
}