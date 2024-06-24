/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description This class map data of DigitalSignatureRequest class
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class DigiSignRequestData {
    private static final String ID_TYPE_NAME = 'NATIONAL IDENTITY DOCUMENT';
    private static final String TYPE_OF_APPROVAL = 'PRE';
    private static final String STATUS_PENDING = DMN_ApplicationDocuments.STATUS_PENDING;
    private static final String VALID_DAYS = '7';
    private static final String SIGNATORY_TYPE = 'Director';
    private static final String COMPANY_ATTR = 'company';
    private static final Set<String> CONFIRM_TYPE = new Set<String>{'Question','Agreement'};
    private static final String PAGE_HEADING = 'Give Consent';
    public static final String ESB_CALL_BACK = SB_Parameters__c.getValues('ESB_CALL_BACK').Value__c;

    /**
    * populate signatory contact into an object that will be serialized into json
    *
    * @param conList list of SignatoryContact
    *
    * @return SignInfoList
    */
    @TestVisible
    private static List<DigitalSignatureRequest.SignatoryInformation> getSignatoryInfoList(List<SignatoryContact> conList) {

        List<DigitalSignatureRequest.SignatoryInformation> signInfoList = new List<DigitalSignatureRequest.SignatoryInformation>();

        for (SignatoryContact con : conList) {

            DigitalSignatureRequest.SignatoryInformation signInfo = new DigitalSignatureRequest.SignatoryInformation();
            signInfo.signatoryFirstName = con.firstName;
            signInfo.signatoryLastName = con.lastName;
            signInfo.signatoryIdentificationDocumentType = ID_TYPE_NAME;
            signInfo.signatoryIdentificationDocumentNumber = con.id_number;
            signInfo.signatoryGuid = con.signatoryGuid;
            signInfo.originatorIndicator = con.initiatingDirector;
            signInfo.typeOfApproval = TYPE_OF_APPROVAL;
            signInfo.isDigitalSignatureRequired = true;
            signInfo.notifySignatory = true;
            signInfo.signatoryApprovalStatus = STATUS_PENDING;
            signInfo.signatoryContactInformation = getContactInfo(con);
            signInfoList.add(signInfo);
        }
        return signInfoList;
    }

    /**
    * Assigns address
    *
    * @return postalAddress
    */
    @TestVisible
    private static DigitalSignatureRequest.PostalAddress getAddress() {

        DigitalSignatureRequest.PostalAddress postalAddress = new DigitalSignatureRequest.PostalAddress();
        postalAddress.address = new DigitalSignatureRequest.Address();
        postalAddress.address.streetName = '';
        postalAddress.address.city = '';
        postalAddress.address.suburb = '';
        postalAddress.address.province = '';
        postalAddress.address.country = '';
        postalAddress.address.postalCode = '';

        return postalAddress;
    }

    /**
    * Assings contact details
    *
    * @param con SignatoryContact
    *
    * @return conInfo
    */
    @TestVisible
    private static DigitalSignatureRequest.SignatoryContactInformation getContactInfo(SignatoryContact con) {

        DigitalSignatureRequest.SignatoryContactInformation conInfo = new DigitalSignatureRequest.SignatoryContactInformation();
        conInfo.mobile = con.mobileNumber;
        conInfo.email = con.Email;
        conInfo.postalAddress = getAddress();

        return conInfo;
    }

    /**
    * Assigns client data into EntityInformation
    *
    * @param acc  Account
    * @param onboardingAppId  String
    *
    * @return signed token
    */
    @TestVisible
    private static DigitalSignatureRequest.EntityInformation getEntityInformation(Account acc, String onboardingAppId) {

        DigitalSignatureRequest.EntityInformation entityInformation = new DigitalSignatureRequest.EntityInformation();
        entityInformation.entityGuid = onboardingAppId;
        entityInformation.entityType = acc.Client_Type__c;
        entityInformation.entityRegistrationNumber = acc.Registration_Number__c;
        entityInformation.entityName = acc.Name;
        return entityInformation;
    }

    /**
    * Generate an object that has to be sent to BPM as a JSON
    * @param signList SignatoryContact
    * @param clientId String which is an Account ID
    * @return signed token
    */
    public static DigitalSignatureRequest.DigitalSignatureRequest_Z digiSignInformation(List<SignatoryContact> signList, String clientId) {
        Account acc = SEL_Accounts.newInstance().selectById(new Set<Id>{
                clientId
        })[0];
        DigitalSignatureRequest.DigitalSignatureRequest_Z digiSignObject = new DigitalSignatureRequest.DigitalSignatureRequest_Z();
        digiSignObject.digitalSignatureRequest = new DigitalSignatureRequest();
        digiSignObject.digitalSignatureRequest.requestCorrelationIdentifier = signList[0].onboardingAppId;
        digiSignObject.digitalSignatureRequest.callbackURL = ESB_CALL_BACK;
        digiSignObject.digitalSignatureRequest.digiSignInformation = new DigitalSignatureRequest.DigiSignInformation();
        digiSignObject.digitalSignatureRequest.digiSignInformation.signatoryAccountInformation = new DigitalSignatureRequest.SignatoryAccountInformation();
        digiSignObject.digitalSignatureRequest.digiSignInformation.signatoryAccountInformation.signatoryAccountNumber = '';
        digiSignObject.digitalSignatureRequest.digiSignInformation.signatoryAccountInformation.signatoryAccountType = '';
        digiSignObject.digitalSignatureRequest.digiSignInformation.timeToExpire = VALID_DAYS;
        digiSignObject.digitalSignatureRequest.digiSignInformation.businessDataAsJSON = getPipQuestions(acc);
        digiSignObject.digitalSignatureRequest.digiSignInformation.signatoryType = SIGNATORY_TYPE;
        digiSignObject.digitalSignatureRequest.digiSignInformation.digiSignRules = new DigitalSignatureRequest.DigiSignRules();
        digiSignObject.digitalSignatureRequest.digiSignInformation.digiSignRules.generateSignedDocumentIndicator = false;
        digiSignObject.digitalSignatureRequest.digiSignInformation.digiSignRules.consentRequiredIndicator = true;

        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation = new DigitalSignatureRequest.SignatoryAndEmailInvitationInformation();
        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation.emailInvitationDetails = new DigitalSignatureRequest.EmailInvitationDetails();
        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation.emailInvitationDetails.emailInvitationContent = new List<DigitalSignatureRequest.EmailInvitationContent>();
        DigitalSignatureRequest.EmailInvitationContent emailcontent = new DigitalSignatureRequest.EmailInvitationContent();
        emailcontent.name = COMPANY_ATTR;
        emailcontent.value = acc.Name;
        emailcontent.key = '';
        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation.emailInvitationDetails.emailInvitationContent.add(emailcontent);
        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation.emailInvitationDetails.emailTemplateInformation
                = new DigitalSignatureRequest.EmailTemplateInformation();
        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation.emailInvitationDetails.emailTemplateInformation.emailTemplateName = DMN_EmailTemplates.DIGISIGN_EMAIL_TEMPLATE;
        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation.signatoryInformation = new List<DigitalSignatureRequest.SignatoryInformation>();


        List<DigitalSignatureRequest.SignatoryInformation> signInfoList = getSignatoryInfoList(signList);
        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation.signatoryInformation.addAll(signInfoList);

        digiSignObject.digitalSignatureRequest.signatoryAndEmailInvitationInformation.entityInformation = DigiSignRequestData.getEntityInformation(acc, signList[0].onboardingAppId);

        digiSignObject.digitalSignatureRequest.documentInformation = new DigitalSignatureRequest.DocumentInformation();
        digiSignObject.digitalSignatureRequest.documentInformation.documents = new List<DigitalSignatureRequest.Documents>();
        DigitalSignatureRequest.Documents doc = new DigitalSignatureRequest.Documents();
        doc.documentDataBase64 = '';
        doc.documentGUID = '';
        doc.documentLink = '';
        doc.preText = '';
        doc.postText = '';
        doc.documentName = '';
        doc.documentType = '';
        doc.xmlPayloadIndicator = false;
        doc.xmlTemplatePayload = '';
        doc.templateInformation = new DigitalSignatureRequest.TemplateInformation();
        doc.templateInformation.messageContentIndicator = false;
        doc.templateInformation.hasTemplateIndicator = false;
        doc.templateInformation.templateLanguage = '';
        doc.templateInformation.templateName = '';
        doc.templateInformation.templateSystem = '';
        doc.templateInformation.templateVersion = '';
        doc.templateInformation.messageContent = new List<DigitalSignatureRequest.EmailInvitationContent>();
        DigitalSignatureRequest.EmailInvitationContent emailInvite = new DigitalSignatureRequest.EmailInvitationContent();
        emailInvite.key = '';
        emailInvite.name = '';
        emailInvite.value = '';
        doc.templateInformation.messageContent.add(emailInvite);
        digiSignObject.digitalSignatureRequest.documentInformation.documents.add(doc);
        digiSignObject.digitalSignatureRequest.documentInformation.reminderInformation = new DigitalSignatureRequest.ReminderInformation();
        digiSignObject.digitalSignatureRequest.documentInformation.reminderInformation.notifyAfter = '';
        digiSignObject.digitalSignatureRequest.documentInformation.reminderInformation.templateData = '';
        digiSignObject.digitalSignatureRequest.documentInformation.reminderInformation.templateId = '';
        digiSignObject.digitalSignatureRequest.documentInformation.reminderInformation.templateVersion = '';
        return digiSignObject;
    }

    /**
    * create a map of strings and object in order to generate a Json
    *
    * @param config Consent_Configuration__c
    *
    * @return map of object
    */
    @TestVisible
    private static Map<String,Object> generateJSONContent(Consent_Configuration__c config) {

        Map<String,Object> att = new Map<String,Object>();
        att.put('type',config.Type__c);
        if(config.Order__c!=5) {
            att.put('description', config.Description__c);
        }
        else {
            att.put('description', '');
        }
        att.put('order',config.Order__c);
        if(config.Type__c=='text-box' || config.Type__c=='drop-down'){
            att.put('dependsOn',config.DependsOn__c);
        }
        if(config.Type__c!='point') {
            if (String.isBlank(config.Value__c) || config.Value__c == 'null') {
                att.put('value', null);
            } else {
                if (config.Value__c == 'false') {
                    att.put('value', false);
                } else {
                    att.put('value', config.Value__c);
                }
            }
            if(config.Order__c!=2) {
                att.put('toolTip', config.ToolTip__c);
            }
            att.put('label', config.Label__c);
        }

        return att;
    }

    /**
    * create PIP questions from Consent_Configuration__c
    *
    * @param acc Account
    *
    * @return JSON.serialize(pipQ)
    */
    @TestVisible
    private static String getPipQuestions(Account acc){
        String expDate = String.valueOf(Date.today().addDays(Integer.valueOf(VALID_DAYS)));
        PipQuestion pipQ = new PipQuestion();
        pipQ.pageHeading = PAGE_HEADING;
        pipQ.labelDecline = 'DECLINE';
        pipQ.labelApprove = 'SIGN';
        pipQ.confirmation = buildConfirmation(acc);
        pipQ.decline = buildDecline();
        pipQ.validateToDate = 'This application is valid until '+expDate;
        List<Section> secList = new List<Section>();
        Section sec  = new Section();
        sec.infoList = new List<Map<String,Object>>();
        Agreement agree = new Agreement();
        agree.infoList = new List<Map<String,Object>>();
        agree.headingLines = null;
        List<Consent_Configuration__c> configList = SEL_ConsentConfiguration.newInstance().selectByConfirmationType(CONFIRM_TYPE);

        for(Consent_Configuration__c config : configList){

            if(String.isBlank(sec.heading)){
                sec.heading = String.isNotBlank(config.Heading__c) ? acc.Name +' '+config.Heading__c:null;
            }

            if(config.Confirmation_Type__c=='Agreement') {
                agree.infoList.add(generateJSONContent(config));
            }
            else {
                sec.infoList.add(generateJSONContent(config));
                if((config.Type__c=='radio-button' || config.Type__c=='drop-down')){
                    if(config.Order__c==0) {
                        Map<String, Object> att = new Map<String, Object>();
                        att.put('order', 1);
                        sec.infoList.add(att);
                    }
                    else if(config.Order__c==2) {
                        Map<String, Object> att = new Map<String, Object>();
                        att.put('order', 3);
                        sec.infoList.add(att);
                    }
                    else if(config.Order__c==8) {
                        Map<String, Object> att = new Map<String, Object>();
                        att.put('order', 9);
                        sec.infoList.add(att);
                    }
                }

                if(config.Label__c=='surname'){
                    Map<String, Object> att = new Map<String, Object>();
                    att.put('order', 5);
                    sec.infoList.add(att);
                }

                if(config.Label__c=='relationship'){
                Map<String, Object> att = new Map<String, Object>();
                att.put('order', 7);
                sec.infoList.add(att);
            }

            }
        }

        secList.add(sec);
        pipQ.sections = secList;
        pipQ.agreement = agree;
        return JSON.serialize(pipQ);
    }

    /**
    * Build the confirm content for IBR
    *
    * @param acc Account
    *
    * @return confir
    */
    @TestVisible
    private static Confirmation buildConfirmation(Account acc){

        Confirmation confir = new Confirmation();
        confir.pageHeader = 'Application Status';
        confir.header = 'Business Current Account for account '+acc.Name;
        confir.subHeader = 'You\'ve agreed to credit and compliance checks for this application.';
        confir.cellPhone = 'Your Relationship Manager.';
        confir.email = null;
        confir.message = 'The offer has been accepted by you. We will keep you informed of the applications progress.';
        confir.declineReasons = null;
        return confir;
    }

    /**
    * Build the decline content for IBR
    *
    * @return declin
    */
    @TestVisible
    private static Decline buildDecline(){

        Decline declin = new Decline();
        declin.pageHeader = 'Declined offer';
        declin.header = 'Sorry to see that this offer was not accepted. If you change your mind please contact us with the detail below.';
        declin.subHeader = null;
        declin.cellPhone = 'Your Relationship Manager.';
        declin.email = null;
        declin.message = 'The offer has been declined and correspondence sent to all signatories.';
        declin.declineReasons = new List<String>{'The account is no longer required.','We went with another bank.',
                                                'I do not feel comfortable with the request.','We have a better offer.','Other'};
        return declin;
    }

    /**
    * @description Inner class to wrap SignatoryContact Object
    */
    public class SignatoryContact {

        public String Id;
        public String signatoryGuid;
        public String onboardingAppId;
        public String Email;
        public String id_number;
        public String firstName;
        public String lastName;
        public string phone;
        public String mobileNumber;
        public String contactRoleClient;
        public string isIdValid;
        public string checked;
        public Boolean initiatingDirector;
    }

    /**
    * @description Inner class to wrap PipQuestion Object
    */
    public class PipQuestion {

        public String pageHeading;
        public List<Section> sections;
        public Agreement agreement;
        public String validateToDate;
        public String labelDecline;
        public String labelApprove;
        public Confirmation confirmation;
        public Decline decline;


    }

    /**
    * @description Inner class to wrap Section Object
    */
    public class Section {
        public String heading;
        public List<Map<String,Object>> infoList;
    }

    /**
    * @description Inner class to wrap Agreement Object
    */
    public class Agreement {
        public String headingLines;
        public List<Map<String,Object>> infoList;
    }

    /**
    * @description Inner class to wrap Confirmation Object
    */
    public class Confirmation {
        public String pageHeader;
        public String header;
        public String subHeader;
        public String cellPhone;
        public String email;
        public String message;
        public String declineReasons;
    }

    /**
    * @description Inner class to wrap Decline Object
    */
    public class Decline {
        public String pageHeader;
        public String header;
        public String subHeader;
        public String cellPhone;
        public String email;
        public String message;
        public List<String> declineReasons;
    }

}