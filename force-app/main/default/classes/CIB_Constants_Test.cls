/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-04-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class CIB_Constants_Test {
  @isTest
  static void testConstants() {
    Test.startTest();
    CIB_Constants constants = new CIB_Constants();
    Map<String, Object> expectedValues = new Map<String, Object>{
      CIB_Constants.NATURAL_PERSON_IDENTIFIED => 'Natural Person Identified',
      CIB_Constants.LISTED_ENTITY => 'Listed Entity',
      CIB_Constants.MAJOR_OWNED_SUBSIDIARY => 'Major Owned Subsidiary',
      CIB_Constants.PROVIDE_PERCENTAGE_OWNERSHIP => 'Provide Percentage ownership',
      CIB_Constants.APPLICATION_NAME => 'Application Participant Name',
      CIB_Constants.PERMANENT_RESIDENTIAL_ADDRESS => 'Permanent Residential Address',
      CIB_Constants.MOBILE_NUMBER => 'Mobile Number',
      CIB_Constants.TELEPHONE_NUMBER => 'Telephone Number',
      CIB_Constants.DIRECTOR_OF_ANY_STANDARD_BANK_ENTITIES => 'Director of Any of Standard Bank Entity',
      CIB_Constants.SENIOR_OFFICER_OF_ANY_STANDARD_BANK_ENTITIES => 'Senior Officer of Any of Standard Bank',
      CIB_Constants.CLOSE_RELATIVE_OF_ANY_DIRECTOR_OF_SENIOR_OFFICER_OF_THE_STANDARD_BANK_ENTITIES => 'Has Standard Bank Relative',
      CIB_Constants.FULL_NAME => 'Full Name',
      CIB_Constants.SIGNATURE => 'Signature',
      CIB_Constants.NAME_OF_THE_PARTY_TO_BE_DISCLOSED => 'Name of Related Party to be Disclosed',
      CIB_Constants.NAME_OF_THE_PARTY_TO_BE_CLOSERELATIV => 'Name of Relative Party to be Relative',
      CIB_Constants.NAME_OF_THE_PARTY_TO_BE_SENIOR => 'Name of Related Party to be senior',
      CIB_Constants.RP_DATE => 'Date',
      CIB_Constants.NAME_OF_ANNEXURE_A => 'Name of Annexure A',
      CIB_Constants.VOTING_RIGHTS => 'Voting Rights',
      CIB_Constants.PASSPORT_ID_NUMBER => 'Passport Id Number',
      CIB_Constants.ARE_YOU_NOT_THE_CONTROLLING_PERSON => 'Are you not the Controlling Person',
      CIB_Constants.INDICATE_THE_CAPACITY => 'Indicate the Capacity',
      CIB_Constants.NAME_OF_AUTHORISED_SIGNATORY => 'Name of Authorised Signatory',
      CIB_Constants.POSITION_TITLE => 'Position/Title',
      CIB_Constants.CPDU_DATE => 'Date',
      CIB_Constants.SURVEY_DEVELOPER_NAME => 'mauritius_cib_account_onboarding_experience',
      CIB_Constants.SURVEY_INVITATION_RESPONSE_STATUS_COMPLETED => 'Completed',
      CIB_Constants.APPLICATION_LINE_ITEM_RECORD_TYPE_BANK_ACCOUNT => 'Bank_Account',
      CIB_Constants.APPLICATION_LINE_ITEM_RECORD_TYPE_TAX_RESIDENCE => 'Tax_Residence',
      CIB_Constants.APPLICATION_PARTICIPANT_RECORD_TYPE_DIRECTOR => 'Director',
      CIB_Constants.APPLICATION_DOCUMENT_TYPE_PARTICIPANT => 'Participant Document',
      CIB_Constants.APPLICATION_DOCUMENT_TYPE_ENTITY => 'Entity Document',
      CIB_Constants.APPLICATION_SECTION_STATUS_SUBMITTED => 'Submitted',
      CIB_Constants.APPLICATION_SECTION_STATUS_REVISION_REQUESTED => 'Revision Requested',
      CIB_Constants.CIB_COMP_HUB_SCREEN => 'cib_comp_hubScreen',
      CIB_Constants.CIB_COMP_THANK_YOU => 'cib_comp_thankYou'
    };
    Test.stopTest();
    System.assertNotEquals(null, constants, 'Constants should not be null');
    for (String key : expectedValues.keySet()) {
      System.assertEquals(
        expectedValues.get(key),
        key,
        'Constant should be equal to value'
      );
    }
  }
}