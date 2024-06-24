/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-03-2023
@ Name of the Class : CIB_Constants
@ Description       : This class contains all the constants used in the CIB Onboarding process
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-03-2023
@ Modification Description : SFP-24620, SFP-24656, SFP-24657, SFP-24662, SFP-24664, SFP-24666, SFP-24667, SFP-24668, 
                             SFP-24669, SFP-24671, SFP-24673, SFP-24681, SFP-24685, SFP-24691, SFP-24694, SFP-24698, 
                             SFP-24701, SFP-24877, SFP-24890, SFP-24891, SFP-24892, SFP-24897, SFP-24909, SFP-24911, 
                             SFP-24914, SFP-24916, SFP-24941, SFP-25176
***************************************************************************************/
public class CIB_Constants {
  public static final String IS_YOUR_COMPANY_REGISTERED_COUNTRY = 'Is your company registered in another country';
  public static final String COMPANY_REGISTERED_NAME = 'Company registered name';
  public static final String NAME_OF_ISSUING_AUTHORITY = 'Name of issuing authority';
  public static final String INCORPORATION_NUMBER = 'Incorporation number';
  public static final String INCORPORATION_DATE = 'Incorporation date';
  public static final String BUSINESS_REGISTRATION_NUMBER = 'Business registration number';
  public static final String BUSINESS_REGISTRATION_DATE = 'Business registration date';
  public static final String NAME_OF_STATE_OR_GOVERNMENT = 'Name of state or government';

  public static final string ENTITY_TYPE = 'EntityType';

  //  general business information
  public static final String NATURE_OF_PRODUCT_SERVICE_TRADED = 'Nature of product service traded';
  public static final String PURPOSE_OF_ACCOUNT = 'Purpose of account';

  public static final String ATTACHMENT = 'Attachment';
  public static final String FILENAME = 'filename';
  public static final String FORMAT = 'format';
  public static final String DATA = 'data';
  public static final String IS_THIS_REGULATED_FINANCIAL_INSTITUTION = 'Is this Regulated Financial Institution?';
  public static final String COUNTRY = 'Country';
  public static final String REGULATORY_LICENSE_NUMBER = 'Regulatory License Number';
  public static final String NAME = 'Name';
  //Gaming Industry Status --Start
  public static final String BUSINESS = 'Business';
  public static final String CUSTOMERS = 'Customers';
  public static final String SUPPIER = 'Suppier';
  public static final String DETAILS_OF_THEIR_INVOLVEMENT_BUSINESS = 'Details of their involvement - Business';
  public static final String DETAILS_OF_THEIR_INVOLVEMENT_SUPPLIERS = 'Details of their involvement -Suppliers';
  public static final String DETAILS_OF_THEIR_INVOLVEMENT_CUSTOMERS = 'Details of their involvement - Customers';

  //--end gaming
  //Annexure A Basic Info
  public static final String NAME_OF_APPLICANT = 'Name Of Applicant';
  public static final String APPLICANT_ADDRESS = 'Applicant Address';
  public static final String REGISTRATION_NUMBER = 'Registration Number';
  public static final String NATURAL_PERSON_IDENTIFIED = 'Natural Person Identified';
  public static final String LISTED_ENTITY = 'Listed Entity';
  public static final String MAJOR_OWNED_SUBSIDIARY = 'Major Owned Subsidiary';
  public static final String PROVIDE_PERCENTAGE_OWNERSHIP = 'Provide Percentage ownership';

  //Authorized signatory details
  public static final String APPLICATION_NAME = 'Application Participant Name';
  public static final String PERMANENT_RESIDENTIAL_ADDRESS = 'Permanent Residential Address';
  public static final String MOBILE_NUMBER = 'Mobile Number';
  public static final String TELEPHONE_NUMBER = 'Telephone Number';

  //end

  //Related Party Disclosure
  public static final String DIRECTOR_OF_ANY_STANDARD_BANK_ENTITIES = 'Director of Any of Standard Bank Entity';
  public static final String SENIOR_OFFICER_OF_ANY_STANDARD_BANK_ENTITIES = 'Senior Officer of Any of Standard Bank';
  public static final String CLOSE_RELATIVE_OF_ANY_DIRECTOR_OF_SENIOR_OFFICER_OF_THE_STANDARD_BANK_ENTITIES = 'Has Standard Bank Relative';
  public static final String FULL_NAME = 'Full Name';
  public static final String SIGNATURE = 'Signature';
  public static final String NAME_OF_THE_PARTY_TO_BE_DISCLOSED = 'Name of Related Party to be Disclosed';
  public static final String NAME_OF_THE_PARTY_TO_BE_CLOSERELATIV = 'Name of Relative Party to be Relative';
  public static final String NAME_OF_THE_PARTY_TO_BE_SENIOR = 'Name of Related Party to be senior';

  public static final String RP_DATE = 'Date';

  // Annexure A Benifial Ownership
  public static final String NAME_OF_ANNEXURE_A = 'Name of Annexure A';
  public static final String VOTING_RIGHTS = 'Voting Rights';
  public static final String PASSPORT_ID_NUMBER = 'Passport Id Number';

  //Controlling Person Declaration and Undertakings
  public static final String ARE_YOU_NOT_THE_CONTROLLING_PERSON = 'Are you not the Controlling Person';
  public static final String INDICATE_THE_CAPACITY = 'Indicate the Capacity';
  public static final String NAME_OF_AUTHORISED_SIGNATORY = 'Name of Authorised Signatory';
  public static final String POSITION_TITLE = 'Position/Title';
  public static final String CPDU_DATE = 'Date';

  public static final String SURVEY_DEVELOPER_NAME = 'mauritius_cib_account_onboarding_experience';  
  public static final String SURVEY_INVITATION_RESPONSE_STATUS_COMPLETED = 'Completed';

  public static final String APPLICATION_LINE_ITEM_RECORD_TYPE_BANK_ACCOUNT = 'Bank_Account';
  public static final String APPLICATION_LINE_ITEM_RECORD_TYPE_TAX_RESIDENCE = 'Tax_Residence';
  public static final String APPLICATION_PARTICIPANT_RECORD_TYPE_DIRECTOR = 'Director';

  public static final String APPLICATION_DOCUMENT_TYPE_PARTICIPANT = 'Participant Document';
  public static final String APPLICATION_DOCUMENT_TYPE_ENTITY = 'Entity Document';

  public static final String APPLICATION_SECTION_STATUS_SUBMITTED = 'Submitted';
  public static final String APPLICATION_SECTION_STATUS_REVISION_REQUESTED = 'Revision Requested';

  // component api names
  public static final String CIB_COMP_HUB_SCREEN = 'cib_comp_hubScreen';
  public static final String CIB_COMP_THANK_YOU = 'cib_comp_thankYou';

  public CIB_Constants() {}
}