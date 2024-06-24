/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 10-04-2023
@ Name of the Class : SEL_CIBApplication
@ Description       : Selector class for Application__c
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 10-04-2023
@ Modification Description : SFP-23639, SFP-23580
***************************************************************************************/
public with sharing class SEL_CIBApplication extends fflib_SObjectSelector {
  private static Set<String> fields = new Set<String>{
    'Id',
    'Name',
    'Status__c',
    'ExpiryDate__c',
    'CompletionPercentage__c',
    'Client__c',
    'CIB_TC_AcceptedTermsConditionsDateTime__c',
    'CIB_TC_AcceptedTermsConditions__c',
    'CIB_SOS_VotingRightsPercentage__c',
    'CIB_SOS_StateGovName__c',
    'CIB_SOS_OwnershipPercentage__c',
    'CIB_SOF_OtherWealthDetails__c',
    'CIB_SOF_OtherFundsDetails__c',
    'CIB_SOF_InitialFundsSourceCountry__c',
    'CIB_SOF_ExpectedInitialWealthSource__c',
    'CIB_SOF_ExpectedInitialFundsSource__c',
    'CIB_RPD_StandardBankEntitiesSeniorOffice__c',
    'CIB_RPD_StandardBankEntitiesDirectorName__c',
    'CIB_RPD_StandardBankEntitiesCloseRelativ__c',
    'CIB_RPD_IsStandardBankEntitiesSenior__c',
    'CIB_RPD_IsStandardBankEntitiesDirector__c',
    'CIB_RPD_HasStandardBankEntitiesRelative__c',
    'CIB_RPD_DeclarationFullName__c',
    'CIB_RPD_DeclarationDate__c',
    'CIB_RiskRating__c',
    'CIB_PR_RegistrationNumber__c',
    'CIB_PR_RegistrationDate__c',
    'CIB_PR_Name__c',
    'CIB_PR_IssuingAuthorityName__c',
    'CIB_PR_IncorporationNumber__c',
    'CIB_PR_IncorporationDate__c',
    'CIB_PR_HasPreviousRegistration__c',
    'CIB_LI_ManagementCompanyName__c',
    'CIB_LI_LicenceType__c',
    'CIB_LI_LicenceNumber__c',
    'CIB_LI_IsMauManagementCompany__c',
    'CIB_GII_SupplierInvolvementDetails__c',
    'CIB_GII_HasSupplerInvolvement__c',
    'CIB_GII_HasCustomerInvolvement__c',
    'CIB_GII_HasBusinessInvolvement__c',
    'CIB_GII_CustomerInvolvementDetails__c',
    'CIB_GII_BusinessInvolvementDetails__c',
    'CIB_GCFI_IndependentAuditorName__c',
    'CIB_GCFI_HasIndependentAuditor__c',
    'CIB_GBI_NatureProductServices__c',
    'CIB_GBI_AccountPurpose__c',
    'CIB_FIS_RegulatoryLicenceNumber__c',
    'CIB_FIS_Name__c',
    'CIB_FIS_IsRegulatedFinancialInstitution__c',
    'CIB_FIS_Country__c',
    'CIB_EII_DulySignedAsPerBoardResolution__c',
    'CIB_DFI_TotalExpectedAnnual__c',
    'CIB_DFI_PaymentOriginCountry__c',
    'CIB_DFI_PaymentDestinationCountry__c',
    'CIB_DFI_ExpectedIncomeType__c',
    'CIB_DFI_ExpectedDebitsType__c',
    'CIB_DFI_DebitMonthlyExpectedTransfersVol__c',
    'CIB_DFI_DebitMonthlyExpectedTransfersVal__c',
    'CIB_DFI_CreditMonthlyExpectedTransfersVo__c',
    'CIB_DFI_CreditMonthlyExpectedTransfers__c',
    'CIB_CPDU_NonControllingPersonCapacity__c',
    'CIB_CPDU_IsControllingPerson__c',
    'CIB_CPDU_AuthorizedSignatoryTitle__c',
    'CIB_CPDU_AuthorizedSignatoryName__c',
    'CIB_CPDU_AuthorizedSignatoryDate__c',
    'CIB_CDeclaration_OfficeFullName__c',
    'CIB_CDeclaration_OfficeDate__c',
    'CIB_CDeclaration_IntroductionSource__c',
    'CIB_CDeclaration_FullName__c',
    'CIB_CDeclaration_DulySignedDate__c',
    'CIB_CDeclaration_Designation__c',
    'CIB_CDeclaration_Date__c',
    'CIB_CD_URL_link__c',
    'CIB_CD_TradingAddressProvince__c',
    'CIB_CD_TradingAddressPostalCode__c',
    'CIB_CD_TradingAddressCountry__c',
    'CIB_CD_TradingAddressCity__c',
    'CIB_CD_SameTradingAddressAsRegistered__c',
    'CIB_CD_RegistrationAddressProvince__c',
    'CIB_CD_RegistrationAddressPostalCode__c',
    'CIB_CD_RegistrationAddressCountry__c',
    'CIB_CD_RegistrationAddressCity__c',
    'CIB_CD_OfficeNumbersTelephoneNumber__c',
    'CIB_CD_OfficeNumbersFaxNumber__c',
    'CIB_CD_HasSameCorrespondAsRegistered__c',
    'CIB_CD_EmailAddressesMain__c',
    'CIB_CD_EmailAddressesElectroAdvices__c',
    'CIB_CD_CorrespondAddressProvince__c',
    'CIB_CD_CorrespondAddressPostalCode__c',
    'CIB_CD_CorrespondAddressCountry__c',
    'CIB_CD_CorrespondAddressCity__c',
    'CIB_BAI_NameOfIssuingAuthority__c',
    'CIB_BAI_IncorporationNumber__c',
    'CIB_BAI_IncorporationDate__c',
    'CIB_BAI_EntityType__c',
    'CIB_BAI_CompanyRegisteredName__c',
    'CIB_BAI_BusinessRegistrationNumber__c',
    'CIB_BAI_BusinessRegistrationDate__c',
    'CIB_AT_IsCurrentAccountPlus__c',
    'CIB_AT_IsCurrentAccount__c',
    'CIB_AT_CurrentAccountPlusCurrencies__c',
    'CIB_AT_CurrentAccountCurrencies__c',
    'CIB_AD_IsNewSubscription__c',
    'CIB_AD_CustomPassword__c',
    'CIB_AD_CustomerSignatureName__c',
    'CIB_AD_CustomerSignatureDate__c',
    'CIB_AD_CustomerSignatureAutority__c',
    'CIB_AD_CustomerName__c',
    'CIB_AD_AccountNumber__c',
    'CIB_ACI_TradingName__c',
    'CIB_ACI_StockExchangeName__c',
    'CIB_ACI_RegistrationCountry__c',
    'CIB_ACI_IsTradingWithRegisteredName__c',
    'CIB_ACI_IncorporationCountry__c',
    'CIB_ACI_HasStockExchangeListing__c',
    'CIB_AC_GeneralDateSigned__c',
    'CIB_AB_US_USPersonsEntitiesDetails__c',
    'CIB_AB_US_IsUSPersonEntities__c',
    'CIB_AB_US_IsFATCAClassification__c',
    'CIB_AB_NUS_TrustName__c',
    'CIB_AB_NUS_TrustGIIN__c',
    'CIB_AB_NUS_RegisteredFIType__c',
    'CIB_AB_NUS_RegisteredFIGIIN__c',
    'CIB_AB_NUS_NonGIINType__c',
    'CIB_AB_NUS_FATCAStatusType__c',
    'CIB_AB_NUS_FATCAStatus__c',
    'CIB_AB_CRS_NonFinancialEntityType__c',
    'CIB_AB_CRS_GIINNoProvidedType__c',
    'CIB_AB_CP_TaxNumber__c',
    'CIB_AB_CP_TaxJuristiction__c',
    'CIB_AB_CP_ResidentialAddress__c',
    'CIB_AB_CP_FullName__c',
    'CIB_AB_CP_DateOfBirth__c',
    'CIB_AB_CP_CountryOfBirth__c',
    'CIB_AB_CP_ControllingPersonType__c',
    'CIB_AB_AI_RecievesIncome_US_OECD__c',
    'CIB_AB_AI_HasStandingOrderInstructions__c',
    'CIB_AB_AI_AuthorizedSignatoryTitle__c',
    'CIB_AB_AI_AuthorizedSignatoryName__c',
    'CIB_AB_AI_AuthorizedSignatoryDate__c',
    'CIB_AA_D_IdNumber__c',
    'CIB_AA_D_FullName__c',
    'CIB_AA_BI_RegistrationNumber__c',
    'CIB_AA_BI_OwnershipsStructure__c',
    'CIB_AA_BI_NaturalPersonIdentification__c',
    'CIB_AA_BI_IsMajorOwnedSubsidiary__c',
    'CIB_AA_BI_IsListedEntity__c',
    'CIB_AA_BI_ApplicantCompanyName__c',
    'CIB_AA_BI_ApplicantAddress__c',
    'AssignedTo__c',
    'ApplicationSectionPercentTotal__c',
    'ApplicationSectionCount__c',
    'CIB_TC_AcceptedTermsConditions__c',
    'CIB_RPD_IsStandardBankEntitiesDirector__c',
    'CIB_RPD_StandardBankEntitiesDirectorName__c',
    'CIB_RPD_IsStandardBankEntitiesSenior__c',
    'CIB_RPD_StandardBankEntitiesSeniorOffice__c',
    'CIB_RPD_HasStandardBankEntitiesRelative__c',
    'CIB_RPD_DeclarationDate__c',
    'CIB_RPD_StandardBankEntitiesCloseRelativ__c',
    'CIB_RPD_DeclarationFullName__c',
    'CIB_AB_US_Fatcha_Type__c',
    'CreatedDate',
    'LastModifiedDate',
    'CIB_IsCertOfficialRelatedParty__c',
    'CIB_RelatedCertOfficer__c',
    'CIB_CertOfficerName__c',
    'CIB_CertOfficerPosition__c',
    'CIB_CertOfficerAddress__c',
    'CIB_CertOfficerTelephone__c',
    'CIB_CertOfficerEmail__c',
    'Client__r.Name'
  };

  /**
   * @description getSObjectFieldList
   * @return List<Schema.SObjectField>
   */
  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      Application__c.Id,
      Application__c.Name,
      Application__c.Status__c,
      Application__c.ExpiryDate__c,
      Application__c.CompletionPercentage__c,
      Application__c.Client__c,
      Application__c.CIB_TC_AcceptedTermsConditionsDateTime__c,
      Application__c.CIB_TC_AcceptedTermsConditions__c,
      Application__c.CIB_SOS_VotingRightsPercentage__c,
      Application__c.CIB_SOS_StateGovName__c,
      Application__c.CIB_SOS_OwnershipPercentage__c,
      Application__c.CIB_SOF_OtherWealthDetails__c,
      Application__c.CIB_SOF_OtherFundsDetails__c,
      Application__c.CIB_SOF_InitialFundsSourceCountry__c,
      Application__c.CIB_SOF_ExpectedInitialWealthSource__c,
      Application__c.CIB_SOF_ExpectedInitialFundsSource__c,
      Application__c.CIB_RPD_StandardBankEntitiesSeniorOffice__c,
      Application__c.CIB_RPD_StandardBankEntitiesDirectorName__c,
      Application__c.CIB_RPD_StandardBankEntitiesCloseRelativ__c,
      Application__c.CIB_RPD_IsStandardBankEntitiesSenior__c,
      Application__c.CIB_RPD_IsStandardBankEntitiesDirector__c,
      Application__c.CIB_RPD_HasStandardBankEntitiesRelative__c,
      Application__c.CIB_RPD_DeclarationFullName__c,
      Application__c.CIB_RPD_DeclarationDate__c,
      Application__c.CIB_RiskRating__c,
      Application__c.CIB_PR_RegistrationNumber__c,
      Application__c.CIB_PR_RegistrationDate__c,
      Application__c.CIB_PR_Name__c,
      Application__c.CIB_PR_IssuingAuthorityName__c,
      Application__c.CIB_PR_IncorporationNumber__c,
      Application__c.CIB_PR_IncorporationDate__c,
      Application__c.CIB_PR_HasPreviousRegistration__c,
      Application__c.CIB_LI_ManagementCompanyName__c,
      Application__c.CIB_LI_LicenceType__c,
      Application__c.CIB_LI_LicenceNumber__c,
      Application__c.CIB_LI_IsMauManagementCompany__c,
      Application__c.CIB_GII_SupplierInvolvementDetails__c,
      Application__c.CIB_GII_HasSupplerInvolvement__c,
      Application__c.CIB_GII_HasCustomerInvolvement__c,
      Application__c.CIB_GII_HasBusinessInvolvement__c,
      Application__c.CIB_GII_CustomerInvolvementDetails__c,
      Application__c.CIB_GII_BusinessInvolvementDetails__c,
      Application__c.CIB_GCFI_IndependentAuditorName__c,
      Application__c.CIB_GCFI_HasIndependentAuditor__c,
      Application__c.CIB_GBI_NatureProductServices__c,
      Application__c.CIB_GBI_AccountPurpose__c,
      Application__c.CIB_FIS_RegulatoryLicenceNumber__c,
      Application__c.CIB_FIS_Name__c,
      Application__c.CIB_FIS_IsRegulatedFinancialInstitution__c,
      Application__c.CIB_FIS_Country__c,
      Application__c.CIB_EII_DulySignedAsPerBoardResolution__c,
      Application__c.CIB_DFI_TotalExpectedAnnual__c,
      Application__c.CIB_DFI_PaymentOriginCountry__c,
      Application__c.CIB_DFI_PaymentDestinationCountry__c,
      Application__c.CIB_DFI_ExpectedIncomeType__c,
      Application__c.CIB_DFI_ExpectedDebitsType__c,
      Application__c.CIB_DFI_DebitMonthlyExpectedTransfersVol__c,
      Application__c.CIB_DFI_DebitMonthlyExpectedTransfersVal__c,
      Application__c.CIB_DFI_CreditMonthlyExpectedTransfersVo__c,
      Application__c.CIB_DFI_CreditMonthlyExpectedTransfers__c,
      Application__c.CIB_CPDU_NonControllingPersonCapacity__c,
      Application__c.CIB_CPDU_IsControllingPerson__c,
      Application__c.CIB_CPDU_AuthorizedSignatoryTitle__c,
      Application__c.CIB_CPDU_AuthorizedSignatoryName__c,
      Application__c.CIB_CPDU_AuthorizedSignatoryDate__c,
      Application__c.CIB_CDeclaration_OfficeFullName__c,
      Application__c.CIB_CDeclaration_OfficeDate__c,
      Application__c.CIB_CDeclaration_IntroductionSource__c,
      Application__c.CIB_CDeclaration_FullName__c,
      Application__c.CIB_CDeclaration_DulySignedDate__c,
      Application__c.CIB_CDeclaration_Designation__c,
      Application__c.CIB_CDeclaration_Date__c,
      Application__c.CIB_CD_URL_link__c,
      Application__c.CIB_CD_TradingAddressProvince__c,
      Application__c.CIB_CD_TradingAddressPostalCode__c,
      Application__c.CIB_CD_TradingAddressCountry__c,
      Application__c.CIB_CD_TradingAddressCity__c,
      Application__c.CIB_CD_SameTradingAddressAsRegistered__c,
      Application__c.CIB_CD_RegistrationAddressProvince__c,
      Application__c.CIB_CD_RegistrationAddressPostalCode__c,
      Application__c.CIB_CD_RegistrationAddressCountry__c,
      Application__c.CIB_CD_RegistrationAddressCity__c,
      Application__c.CIB_CD_OfficeNumbersTelephoneNumber__c,
      Application__c.CIB_CD_OfficeNumbersFaxNumber__c,
      Application__c.CIB_CD_HasSameCorrespondAsRegistered__c,
      Application__c.CIB_CD_EmailAddressesMain__c,
      Application__c.CIB_CD_EmailAddressesElectroAdvices__c,
      Application__c.CIB_CD_CorrespondAddressProvince__c,
      Application__c.CIB_CD_CorrespondAddressPostalCode__c,
      Application__c.CIB_CD_CorrespondAddressCountry__c,
      Application__c.CIB_CD_CorrespondAddressCity__c,
      Application__c.CIB_BAI_NameOfIssuingAuthority__c,
      Application__c.CIB_BAI_IncorporationNumber__c,
      Application__c.CIB_BAI_IncorporationDate__c,
      Application__c.CIB_BAI_EntityType__c,
      Application__c.CIB_BAI_CompanyRegisteredName__c,
      Application__c.CIB_BAI_BusinessRegistrationNumber__c,
      Application__c.CIB_BAI_BusinessRegistrationDate__c,
      Application__c.CIB_AT_IsCurrentAccountPlus__c,
      Application__c.CIB_AT_IsCurrentAccount__c,
      Application__c.CIB_AT_CurrentAccountPlusCurrencies__c,
      Application__c.CIB_AT_CurrentAccountCurrencies__c,
      Application__c.CIB_AD_IsNewSubscription__c,
      Application__c.CIB_AD_CustomPassword__c,
      Application__c.CIB_AD_CustomerSignatureName__c,
      Application__c.CIB_AD_CustomerSignatureDate__c,
      Application__c.CIB_AD_CustomerSignatureAutority__c,
      Application__c.CIB_AD_CustomerName__c,
      Application__c.CIB_AD_AccountNumber__c,
      Application__c.CIB_ACI_TradingName__c,
      Application__c.CIB_ACI_StockExchangeName__c,
      Application__c.CIB_ACI_RegistrationCountry__c,
      Application__c.CIB_ACI_IsTradingWithRegisteredName__c,
      Application__c.CIB_ACI_IncorporationCountry__c,
      Application__c.CIB_ACI_HasStockExchangeListing__c,
      Application__c.CIB_AC_GeneralDateSigned__c,
      Application__c.CIB_AB_US_USPersonsEntitiesDetails__c,
      Application__c.CIB_AB_US_IsUSPersonEntities__c,
      Application__c.CIB_AB_US_IsFATCAClassification__c,
      Application__c.CIB_AB_NUS_TrustName__c,
      Application__c.CIB_AB_NUS_TrustGIIN__c,
      Application__c.CIB_AB_NUS_RegisteredFIType__c,
      Application__c.CIB_AB_NUS_RegisteredFIGIIN__c,
      Application__c.CIB_AB_NUS_NonGIINType__c,
      Application__c.CIB_AB_NUS_FATCAStatusType__c,
      Application__c.CIB_AB_NUS_FATCAStatus__c,
      Application__c.CIB_AB_CRS_NonFinancialEntityType__c,
      Application__c.CIB_AB_CRS_GIINNoProvidedType__c,
      Application__c.CIB_AB_CP_TaxNumber__c,
      Application__c.CIB_AB_CP_TaxJuristiction__c,
      Application__c.CIB_AB_CP_ResidentialAddress__c,
      Application__c.CIB_AB_CP_FullName__c,
      Application__c.CIB_AB_CP_DateOfBirth__c,
      Application__c.CIB_AB_CP_CountryOfBirth__c,
      Application__c.CIB_AB_CP_ControllingPersonType__c,
      Application__c.CIB_AB_AI_RecievesIncome_US_OECD__c,
      Application__c.CIB_AB_AI_HasStandingOrderInstructions__c,
      Application__c.CIB_AB_AI_AuthorizedSignatoryTitle__c,
      Application__c.CIB_AB_AI_AuthorizedSignatoryName__c,
      Application__c.CIB_AB_AI_AuthorizedSignatoryDate__c,
      Application__c.CIB_AA_D_IdNumber__c,
      Application__c.CIB_AA_D_FullName__c,
      Application__c.CIB_AA_BI_RegistrationNumber__c,
      Application__c.CIB_AA_BI_OwnershipsStructure__c,
      Application__c.CIB_AA_BI_NaturalPersonIdentification__c,
      Application__c.CIB_AA_BI_IsMajorOwnedSubsidiary__c,
      Application__c.CIB_AA_BI_IsListedEntity__c,
      Application__c.CIB_AA_BI_ApplicantCompanyName__c,
      Application__c.CIB_AA_BI_ApplicantAddress__c,
      Application__c.AssignedTo__c,
      Application__c.ApplicationSectionPercentTotal__c,
      Application__c.ApplicationSectionCount__c,
      Application__c.CIB_TC_AcceptedTermsConditions__c,
      Application__c.CIB_RPD_IsStandardBankEntitiesDirector__c,
      Application__c.CIB_RPD_StandardBankEntitiesDirectorName__c,
      Application__c.CIB_RPD_IsStandardBankEntitiesSenior__c,
      Application__c.CIB_RPD_StandardBankEntitiesSeniorOffice__c,
      Application__c.CIB_RPD_HasStandardBankEntitiesRelative__c,
      Application__c.CIB_RPD_DeclarationDate__c,
      Application__c.CIB_RPD_StandardBankEntitiesCloseRelativ__c,
      Application__c.CIB_RPD_DeclarationFullName__c,
      Application__c.CIB_AB_US_Fatcha_Type__c,
      Application__c.CreatedDate,
      Application__c.LastModifiedDate
    };
  }

  /**
   * @description Creates a new instance of the selector via the class selectById
   * @return Schema.SObjectType
   */
  public Schema.SObjectType getSObjectType() {
    return Application__c.sObjectType;
  }

  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
   * and inject a mock instead of this class or to switch out this class for a new version.
   * @return SEL_Accounts
   */
  public static SEL_CIBApplication newInstance() {
    return (SEL_CIBApplication) ORG_Application.selector.newInstance(
      Application__c.SObjectType
    );
  }
  /**
   * @description Select without conditions
   *
   * @return List<Account>
   */
  public List<Application__c> selectWithoutCondition() {
    return (List<Application__c>) Database.query(newQueryFactory().toSOQL());
  }

  /**
   * @description Select by section
   *  @param appId
   * @return List<Application__c>
   */
  public List<Application__c> selectAppsById(String appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('id = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by client
   * @param clientId
   * @return List<Application__c>
   */
  public List<Application__c> selectAppsByClient(String clientId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Client__c = :clientId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(FieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by client & status
   * @param clientId
   * @param stat
   * @return List<Application__c>
   */
  public List<Application__c> selectAppsByClientStatus(
    String clientId,
    String stat
  ) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition(
      'Client__c = :clientId AND Status__c  = :stat'
    );
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }
  /**
   * @description  Select by status
   * @param stat
   * @return List<Application__c>
   */
  public List<Application__c> selectAppsByStatus(String stat) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Status__c  = :stat');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by section
   *  @param appId
   * @return Application__c
   */
  public Application__c selectApplicationById(String appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Id = :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by section
   *  @param appId
   * @return List<Application__c>
   */
  public List<Application__c> selectByIds(List<Id> appId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Id in :appId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Select by section
   *  @param contactId
   * @return List<Application__c>
   */
  public List<Application__c> selectDashboardApplications(Id contactId) {
    fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.selectFields(fields);
    fieldQueryFactory.subselectQuery('Application_Sections__r')
      .selectFields(new List<String>{ 'Id' })
      .setCondition('Status__c = \'Revision Requested\'');
    fieldQueryFactory.setCondition(
      'Status__c != \'Closed\' AND Client__c IN (SELECT AccountId FROM AccountContactRelation WHERE ContactId = :contactId)'
    );
    return Database.query(fieldQueryFactory.toSOQL());
  }
}