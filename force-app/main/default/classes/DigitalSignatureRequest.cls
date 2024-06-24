/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description  This class is used to Deserialize json into Apex object and also serialize apex object into Json
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class DigitalSignatureRequest {
	public string requestCorrelationIdentifier;
	public String callbackURL;
	public DigiSignInformation digiSignInformation;
	public SignatoryAndEmailInvitationInformation signatoryAndEmailInvitationInformation;
	public DocumentInformation documentInformation;
	/**
    * @description Inner class to wrap SignatoryAccountInformation Object
    */
	public class SignatoryAccountInformation {
		public String signatoryAccountNumber;
		public String signatoryAccountType;
	}

	/**
    * @description Inner class to wrap SignatoryAndEmailInvitationInformation Object
    */
	public class SignatoryAndEmailInvitationInformation {
		public EmailInvitationDetails emailInvitationDetails;
		public List<SignatoryInformation> signatoryInformation;
		public EntityInformation entityInformation;
	}

	/**
    * @description Inner class to wrap DigiSignInformation Object
    */
	public class DigiSignInformation {
		public SignatoryAccountInformation signatoryAccountInformation;
		public String timeToExpire;
		public String businessDataAsJSON;
		public String signatoryType;
		public DigiSignRules digiSignRules;
	}

	/**
    * @description Inner class to wrap Address Object
    */
	public class Address {
		public String streetName;
		public String city;
		public String suburb;
		public String province;
		public String country;
		public String postalCode;
	}

	/**
    * @description Inner class to wrap DocumentInformation Object
    */
	public class DocumentInformation {
		public List<Documents> documents;
		public ReminderInformation reminderInformation;
	}

	/**
    * @description Inner class to wrap SignatoryContactInformation Object
    */
	public class SignatoryContactInformation {
		public String email;
		public String mobile;
		public PostalAddress postalAddress;
	}

	/**
    * @description Inner class to wrap PostalAddress Object
    */
	public class PostalAddress {
		public Address address;
	}

	/**
    * @description Inner class to wrap SignatoryInformation Object
    */
	public class SignatoryInformation {
		public String signatoryFirstName;
		public String signatoryLastName;
		public String signatoryIdentificationDocumentType;
		public String signatoryIdentificationDocumentNumber;
		public String signatoryGuid;
		public Boolean originatorIndicator;
		public String typeOfApproval;
		public Boolean isDigitalSignatureRequired;
		public SignatoryContactInformation signatoryContactInformation;
		public Boolean notifySignatory;
		public String signatoryApprovalStatus;
	}

	/**
    * @description Inner class to wrap EmailInvitationContent Object
    */
	public class EmailInvitationContent {
		public String name;
		public String value;
		public String key;
	}

	/**
    * @description Inner class to wrap EmailTemplateInformation Object
    */
	public class EmailTemplateInformation {
		public String emailTemplateName;
	}

	/**
    * @description Inner class to wrap Documents Object
    */
	public class Documents {
		public String documentDataBase64;
		public String documentGUID;
		public String documentLink;
		public String preText;
		public String postText;
		public String documentName;
		public String documentType;
		public Boolean xmlPayloadIndicator;
		public String xmlTemplatePayload;
		public TemplateInformation templateInformation;
	}

	/**
    * @description Inner class to wrap TemplateInformation Object
    */
	public class TemplateInformation {
		public Boolean messageContentIndicator;
		public Boolean hasTemplateIndicator;
		public List<EmailInvitationContent> messageContent;
		public String templateLanguage;
		public String templateName;
		public String templateSystem;
		public String templateVersion;
	}

	/**
    * @description Inner class to wrap DigitalSignatureRequest_Z Object
    */
	public class DigitalSignatureRequest_Z {
		public DigitalSignatureRequest digitalSignatureRequest;
	}

	/**
    * @description Inner class to wrap DigiSignRules Object
    */
	public class DigiSignRules {
		public Boolean generateSignedDocumentIndicator;
		public Boolean consentRequiredIndicator;
	}

	/**
    * @description Inner class to wrap EntityInformation Object
    */
	public class EntityInformation {
		public String entityGuid;
		public String entityType;
		public String entityRegistrationNumber;
		public String entityName;
	}

	/**
    * @description Inner class to wrap ReminderInformation Object
    */
	public class ReminderInformation {
		public String notifyAfter;
		public String templateData;
		public String templateId;
		public String templateVersion;
	}

	/**
    * @description Inner class to wrap EmailInvitationDetails Object
    */
	public class EmailInvitationDetails {
		public List<EmailInvitationContent> emailInvitationContent;
		public EmailTemplateInformation emailTemplateInformation;
	}

	/**
    * @description Inner class to wrap ResendInviteRequest Object
    */
    public class ResendInviteRequest{
        public  ResendInvite resendInviteRequest;
    }
	/**
    * @description Inner class to wrap ResendInvite Object
    */
    public class ResendInvite{
        public string signatoryIdentificationDocumentNumber;
        public string signatoryGuid;
    }
	/**
	*
    * @description converts JSON to DigitalSignatureRequest class
    * @param json String
    * @return DigitalSignatureRequest
    */
	public static DigitalSignatureRequest parse(String json) {
		return (DigitalSignatureRequest) System.JSON.deserialize(json, DigitalSignatureRequest.class);
	}
}