/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10/03/2023
@ Name of the Class : CIB_CTRL_BaseSectionScreen
@ Description       : This class provides common functionality for CIB section screens. It includes methods for retrieving application and application section records, updating application and application section records, retrieving session ID, and retrieving picklist values for a given object and field name.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10/03/2023
@ Modification Description : SFP-24725, SFP-24620, SFP-24656, SFP-24657, SFP-24662, SFP-24664, SFP-24666, SFP-24667, 
                             SFP-24669, SFP-24671, SFP-24673, SFP-24681, SFP-24685, SFP-24691, SFP-24694, SFP-24698, 
                             SFP-24701, SFP-24877, SFP-24890, SFP-24891, SFP-24892, SFP-24897, SFP-24909, SFP-24911, 
                             SFP-24914, SFP-24916, SFP-24941, SFP-25176, SFP-24668
***************************************************************************************/
public without sharing class CIB_CTRL_BaseSectionScreen {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CIB_CTRL_BaseSectionScreen');
  private static final String PREFIX_TERMS_AND_CONDITIONS = 'Terms and Conditions - Standard Bank (Mauritius) Limited - ';
  private static final String PREFIX_MARKETING = 'Email Marketing - Standard Bank (Mauritius) Limited - ';
  /**
   * @description This method used getApplicationRecord
   * @param applicationId
   * @return Application
   */
  @AuraEnabled
  public static Application__c getApplicationRecord(String applicationId) {
    try {
      return (Application__c) new SEL_CIBApplication()
        .selectApplicationById(applicationId);
    } catch (Exception e) {
      LOGGER.error('Error in getApplicationRecord: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This method used getApplicationSectionRecord
   * @param sectionId
   * @return Application_Section__c
   */
  @AuraEnabled
  public static Application_Section__c getApplicationSectionRecord(
    String sectionId
  ) {
    try {
      List<Application_Section__c> sections = new SEL_CIBApplicationSection()
        .selectSectionsById(sectionId);

      if (sections.size() > 0) {
        return sections.get(0);
      }

      return null;
    } catch (Exception e) {
      LOGGER.error('Error in getApplicationSectionRecord: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This method used getApplicatinSections
   * @param recordId
   * @return List<Application_Section__c>
   */
  @AuraEnabled(cacheable=true)
  public static List<Application_Section__c> getApplicatinSections(
    String recordId
  ) {
    try {
      return (List<Application_Section__c>) new SEL_CIBApplicationSection()
        .selectHubScreenSections(recordId);
    } catch (Exception e) {
      LOGGER.error('Error in getApplicatinSections: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }
  /**
   * @description This method used updateApplication
   * @param applicationRecord - Application__c
   */
  @AuraEnabled
  public static void updateApplication(Application__c applicationRecord) {
    try {
      CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
        new List<SObjectType>{ Application__c.SObjectType },
        new List<Application__c>{ applicationRecord }
      );
    } catch (Exception e) {
      LOGGER.error('Error in updateApplication: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This method used updateApplicationSection
   * @param sectionRecord - Application_Section__c
   */
  @AuraEnabled
  public static void updateApplicationSection(
    Application_Section__c sectionRecord
  ) {
    try {
      CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
        new List<SObjectType>{ Application_Section__c.SObjectType },
        new List<Application_Section__c>{ sectionRecord }
      );
    } catch (Exception e) {
      LOGGER.error('Error in updateApplicationSection: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This method used getSessionId
   * @return String
   */
  @AuraEnabled(cacheable=true)
  public static String getSessionId() {
    return UserInfo.getSessionId();
  }

  /**
   * @description : Method to retrieve picklist values for a given object and field name.
   * @param objectName The API name of the object.
   * @param fieldName The API name of the field.
   * @return A list of PicklistValueWrapper objects containing the label and value of each picklist value.
   * @throws AuraHandledException if an error occurs while retrieving the picklist values.
   */
  @AuraEnabled
  public static List<PicklistValueWrapper> getPicklistValues(
    String objectName,
    String fieldName
  ) {
    try {
      List<PicklistValueWrapper> picklistValues = new List<PicklistValueWrapper>();

      Schema.SObjectType objectType = Schema.getGlobalDescribe()
        .get(objectName);
      if (objectType == null) {
        return picklistValues;
      }

      Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();

      Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
      Schema.SObjectField field = fieldMap.get(fieldName);
      if (field == null) {
        return picklistValues;
      }

      Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

      List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();

      for (Schema.PicklistEntry entry : picklistEntries) {
        if (entry.isActive()) {
          picklistValues.add(
            new PicklistValueWrapper(entry.getLabel(), entry.getValue())
          );
        }
      }

      return picklistValues;
    } catch (Exception e) {
      LOGGER.error('Error in getPicklistValues: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description : Wrapper class for picklist values.
   */
  public class PicklistValueWrapper {
    /**
     * @description : Represents a label-value pair that can be used in an Aura component.
     */
    @AuraEnabled
    public String label { get; set; }

    /**
     * @description : Represents the value of a label-value pair that can be used in an Aura component.
     */
    @AuraEnabled
    public String value { get; set; }

    /**
     * @description : Constructor for PicklistValueWrapper.
     * @param label The label of the picklist value.
     * @param value The value of the picklist value.
     */
    public PicklistValueWrapper(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

  /**
   * @description : Method to retrieve marketing consent details.
   * @return ContactPointConsent
   */
  @AuraEnabled
  public static List<ContactPointConsent> getMarketingConsentDetails() {
    List<Contact> contactRecords = new SEL_Contacts()
      .selectByUserId(new Set<Id>{ UserInfo.getUserId() });

    if (contactRecords == null || contactRecords.size() == 0) {
      return null;
    }

    Contact contactRecord = contactRecords.get(0);

    List<Individual> individuals = new SEL_Individuals()
      .selectByIndividualIdOrFirstNameLastNameEmail(
        contactRecord.IndividualId,
        contactRecord.FirstName,
        contactRecord.LastName,
        contactRecord.Email
      );

    Individual individual;

    if (individuals == null || individuals.size() == 0) {
      individual = createIndividual(contactRecord);
      updateContact(contactRecord, individual);
    } else {
      individual = individuals.get(0);
    }

    List<ContactPointEmail> contactPointEmails = new SEL_ContactPointEmails()
      .selectByParentId(new Set<Id>{ individual.Id });

    ContactPointEmail contactPointEmail;

    if (contactPointEmails == null || contactPointEmails.size() == 0) {
      contactPointEmail = createContactPointEmail(individual);
    } else {
      contactPointEmail = contactPointEmails.get(0);
    }

    List<ContactPointConsent> contactPointConsents = new SEL_ContactPointConsents()
      .selectByContactPointId(new Set<Id>{ contactPointEmail.Id });

    if (contactPointConsents == null || contactPointConsents.size() <= 1) {
      Boolean isMarketingConsent = false;
      Boolean isTermsAndConditionsConsent = false;
      for (ContactPointConsent cPointConsent : contactPointConsents) {
        if (cPointConsent.Name.startsWith(PREFIX_MARKETING)) {
          isMarketingConsent = true;
        } else if (cPointConsent.Name.startsWith(PREFIX_TERMS_AND_CONDITIONS)) {
          isTermsAndConditionsConsent = true;
        }
      }
      if (!isMarketingConsent) {
        contactPointConsents.add(
          createContactPointConsent(
            PREFIX_MARKETING,
            contactPointEmail,
            individual
          )
        );
      }
      if (!isTermsAndConditionsConsent) {
        contactPointConsents.add(
          createContactPointConsent(
            PREFIX_TERMS_AND_CONDITIONS,
            contactPointEmail,
            individual
          )
        );
      }
    }

    return contactPointConsents;
  }

  /**
   * @description : Method to create individual record.
   * @param contact The contact record.
   * @return Individual
   */
  private static Individual createIndividual(Contact contact) {
    Individual individual = new Individual();
    individual.FirstName = contact.FirstName;
    individual.LastName = contact.LastName;
    individual.Email_Address__c = contact.Email;
    individual.Id = contact.IndividualId;

    CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
      new List<SObjectType>{ Schema.Individual.SObjectType },
      new List<Individual>{ individual }
    );

    return individual;
  }

  /**
   * @description : Method to create contact point consent record.
   * @param individual The individual record.
   * @return ContactPointEmail
   */
  private static ContactPointEmail createContactPointEmail(
    Individual individual
  ) {
    ContactPointEmail contactPointEmail = new ContactPointEmail();
    contactPointEmail.ParentId = individual.Id;
    contactPointEmail.EmailAddress = individual.Email_Address__c;
    contactPointEmail.EmailDomain = individual.Email_Address__c.split('@')[1];
    contactPointEmail.EmailMailBox = individual.Email_Address__c.split('@')[0];

    CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
      new List<SObjectType>{ Schema.ContactPointEmail.SObjectType },
      new List<ContactPointEmail>{ contactPointEmail }
    );

    return contactPointEmail;
  }

  /**
   * @description : Method to create contact point consent record.
   * @param prefix The prefix for the contact point consent name.
   * @param contactPointEmail The contact point email record.
   * @param individual The individual record.
   * @return ContactPointConsent
   */
  private static ContactPointConsent createContactPointConsent(
    String prefix,
    ContactPointEmail contactPointEmail,
    Individual individual
  ) {
    ContactPointConsent contactPointConsent = new ContactPointConsent();
    contactPointConsent.ContactPointId = contactPointEmail.Id;
    contactPointConsent.PrivacyConsentStatus = 'NotSeen';
    contactPointConsent.CaptureContactPointType = 'Email';
    contactPointConsent.Name =
      PREFIX_MARKETING +
      individual.FirstName +
      ' ' +
      individual.LastName;

    CIB_SEL_Fflib_FrameWork.insertfflibFrameWorkList(
      new List<SObjectType>{ Schema.ContactPointConsent.SObjectType },
      new List<ContactPointConsent>{ contactPointConsent }
    );

    return contactPointConsent;
  }

  /**
   * @description : Method to update marketing consent details.
   * @param contactPointConsent The contact point consent record.
   */
  @AuraEnabled
  public static void saveMarketingConsentDetails(
    ContactPointConsent contactPointConsent
  ) {
    if (contactPointConsent.PrivacyConsentStatus == 'OptedIn') {
      contactPointConsent.EffectiveFrom = Date.today();
      contactPointConsent.EffectiveTo = Date.today().addYears(2);
    }
    contactPointConsent.CaptureDate = Date.today();

    CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
      new List<SObjectType>{ Schema.ContactPointConsent.SObjectType },
      new List<ContactPointConsent>{ contactPointConsent }
    );

    List<ContactPointEmail> contactPointEmail = new SEL_ContactPointEmails()
      .selectById(new Set<Id>{ contactPointConsent.ContactPointId });

    if (ContactPointEmail.size() > 0) {
      List<Individual> individual = new SEL_Individuals()
        .selectById(new Set<Id>{ contactPointEmail.get(0).ParentId });
      if (individual.size() > 0) {
        individual.get(0)
          .HasOptedOutSolicit = contactPointConsent.PrivacyConsentStatus ==
          'OptedIn'
          ? false
          : true;

        CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
          new List<SObjectType>{ Schema.Individual.SObjectType },
          new List<Individual>{ individual.get(0) }
        );
      }
    }
  }

  /**
   * @description : Method to update contact record.
   * @param contact The contact record.
   * @param individual The individual record.
   */
  private static void updateContact(Contact contact, Individual individual) {
    contact.IndividualId = individual.Id;

    CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
      new List<SObjectType>{ Schema.Contact.SObjectType },
      new List<Contact>{ contact }
    );
  }

  /**
   * @description : Method to retrieve all Application Documents.
   * @param applicationId The application ID.
   * @return List<Application_Document__c>
   */
  @AuraEnabled(cacheable=true)
  public static List<Application_Document__c> getApplicationDocuments(
    Id applicationId
  ) {
    try {
      return (List<Application_Document__c>) new SEL_ApplicationDocuments()
        .selectByApplicationIdWithSection(applicationId);
    } catch (Exception e) {
      LOGGER.error('Error in getApplicationDocuments: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description : Method to store all Application Documents.
   * @param applicationDocuments The list of application documents.   
   * @return void
   */
  @AuraEnabled
  public static void saveApplicationDocuments(
    List<Application_Document__c> applicationDocuments
  ) {
    try {
      CIB_SEL_Fflib_FrameWork.updatefflibFrameWorkList(
        new List<SObjectType>{ Application_Document__c.SObjectType },
        applicationDocuments
      );
    } catch (Exception e) {
      LOGGER.error('Error in saveApplicationDocuments: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }
}