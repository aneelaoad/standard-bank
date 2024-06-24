/**
 * @description Data Factory class for Custom Settings and similar records generation.
 *
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Additions to OSB_URLS for shortcuts
 */
@SuppressWarnings(
    'PMD.CyclomaticComplexity, PMD.AvoidHardcodingId, PMD.ExcessivePublicCount'
)
@IsTest
public without sharing class TEST_DataFactory {
    public static Id myId;
    public static Account stdBankEmpAcc {
        get {
            if (stdBankEmpAcc == null) {
                stdBankEmpAcc = (Account) new BLD_Account()
                    .useGroupParent()
                    .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
                    .primaryRelationshipHolder('Commercial Banking')
                    .commitWork()
                    .getRecord();
            }
            return stdBankEmpAcc;
        }
        private set;
    }

    public static Account stdBankEmpAccProspect {
        get {
            if (stdBankEmpAccProspect == null) {
                stdBankEmpAccProspect = (Account) new BLD_Account()
                    .useGroupParent()
                    .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
                    .CIF('5647883')
                    .recordTypeId(
                        UTL_RecordType.getRecordTypeId(
                            DMN_Account.OBJ_NAME,
                            DMN_Account.RT_PROSPECT
                        )
                    )
                    .primaryRelationshipHolder('Commercial Banking')
                    .commitWork()
                    .getRecord();
            }
            return stdBankEmpAccProspect;
        }
        private set;
    }

    private static Contact cdgRefCon {
        get {
            if (cdgRefCon == null) {
                cdgRefCon = new Contact(
                    FirstName = DMN_Contact.CDG_REF_FIRSTNAME,
                    LastName = DMN_Contact.CDG_REF_LASTNAME,
                    Email = DMN_Contact.CDG_REF_EMAIL,
                    AccountId = stdBankEmpAcc.Id,
                    RecordTypeId = UTL_RecordType.getRecordTypeId(
                        DMN_Contact.OBJ_NAME,
                        DMN_Contact.RTD_BANK
                    )
                );
                insert cdgRefCon;
            }
            return cdgRefCon;
        }
        private set;
    }

    public static User sysAdmin {
        get {
            if (sysAdmin == null) {
                fetchUsers();
            }
            return sysAdmin;
        }
        private set;
    }

    private static User pbbUsr {
        get {
            if (pbbUsr == null) {
                fetchUsers();
            }
            return pbbUsr;
        }
        private set;
    }
    private static Integer shareSettingCounter = 0;

    private static void fetchUsers() {
        for (User usr : [
            SELECT ProfileId, Name, UserName
            FROM User
            WHERE
                (Name = 'Salesforce Administration'
                OR Name = 'PBB Clients')
                AND (UserName LIKE 'integration@standardbank.com%'
                OR UserName LIKE 'pbb.clients@standardbank.co.za%')
            LIMIT 2
        ]) {
            if (usr.Name == 'Salesforce Administration') {
                sysAdmin = usr;
            }
            if (usr.Name == 'PBB Clients') {
                pbbUsr = usr;
            }
        }
    }

    /**
     * Inserts all defined Custom Settings.<br/>
     * <b>Use only when full config is needed.</b>
     */
    public static void generateConfiguration() {
        insertSettings(
            new List<Object>{
                getEmailAddress(),
                getEnvironmentVariable(),
                getCaseConfiguration(),
                getCcSettings(),
                getCountrySettings(),
                getUserProfileIds(),
                getErrorMessages(),
                getCsiProjectCountries(),
                getSharingSettings(),
                getDALendingLimits(),
                getCommitteeRegGlobMap(),
                getCommitteeLocalMap(),
                getKycLocations(),
                getSystemAdminBAprofileIDtaskDeletion(),
                getSbParameters(),
                getCstCoreRoles(),
                getCstTeamRankings()
            }
        );
    }

    /**
     * Inserts specified Custom Settings. Accepts single and/or listed settings.<br/>
     * Usage:<br/>
     * <code>
     *     TEST_DataFactory.insertSettings(new List<Object> {
     *         TEST_DataFactory.getEmailAddress(),
     *         TEST_DataFactory.getEnvironmentVariable()
     *     });
     * </code>
     *
     * @param settings List consisting of settings list or single setting records
     */
    @SuppressWarnings('PMD.AvoidDmlStatementsInLoops')
    public static void insertSettings(List<Object> settings) {
        // Number of types per insert cannot exceed this number due to Apex DML limitations
        Integer typesPerList = 9;
        Map<SObjectType, List<SObject>> settingsToInsert = new Map<SObjectType, List<SObject>>();

        for (Integer i = 0, j = settings.size(); i < j; i++) {
            Object setting = settings[i];

            SObjectType settingsSType;
            List<SObject> settingsToAdd;
            if (setting instanceof List<SObject>) {
                List<SObject> records = (List<SObject>) setting;
                settingsSType = records.getSObjectType();
                settingsToAdd = records;
            } else if (setting instanceof SObject) {
                SObject record = (SObject) setting;
                settingsSType = record.getSObjectType();
                settingsToAdd = new List<SObject>{ record };
            }

            if (settingsSType == null) {
                throw new DataFactoryException(
                    'Only single SObject or list of same SObject types is permitted'
                );
            }
            if (!settingsSType.getDescribe().isCustomSetting()) {
                throw new DataFactoryException(
                    'Only Custom settings can be inserted using insertSettings method'
                );
            }

            if (!settingsToInsert.containsKey(settingsSType)) {
                settingsToInsert.put(settingsSType, new List<SObject>());
            }
            settingsToInsert.get(settingsSType).addAll(settingsToAdd);
        }

        List<SObject> settingsBatch = new List<SObject>();
        for (Integer i = 0, j = settingsToInsert.values().size(); i < j; i++) {
            settingsBatch.addAll(settingsToInsert.values()[i]);
            if (Math.mod(i, typesPerList) == 0 || i + 1 == j) {
                insert settingsBatch;
                settingsBatch.clear();
            }
        }
    }

    public static Environment_Variable__c getEnvironmentVariable() {
        Environment_Variable__c env = new Environment_Variable__c();

        env.Admin_Profile_IDs__c =
            UTL_Profile.getProfileId(DCN_Profile.SYS_ADMIN) +
            ';' +
            UTL_Profile.getProfileId(DCN_Profile.SYS_ADMIN_SUPPORT) +
            ';' +
            UTL_Profile.getProfileId(DCN_Profile.BUSINESS_ADMIN);
        if (
            stdBankEmpAccProspect.RecordTypeId ==
            UTL_RecordType.getRecordTypeId(
                DMN_Account.OBJ_NAME,
                DMN_Account.RT_PROSPECT
            )
        ) {
            env.Bank_Contact_Account_Id__c = stdBankEmpAccProspect.Id;
        } else {
            env.Bank_Contact_Account_Id__c = stdBankEmpAcc.Id;
        }
        env.Bank_Contact_Record_Id__c = UTL_RecordType.getRecordTypeId(
            DMN_Contact.OBJ_NAME,
            DMN_Contact.RTD_BANK
        );
        env.BatchErrorEmails__c = 'CIBSACRMITProductionSuppo@standardbank.co.za';
        env.ConfirmationEmailHandlerAddress__c = 'acctconfirm@1hunxa46atciwcg46tn5swewd.in.salesforce.com';
        env.CRM_Production_Support__c = 'cibsacrmitproductionsuppo@standardbank.co.za';
        env.CCRejectionPBBUserID__c = pbbUsr.Id;
        env.CCRejectionProfileID__c = UTL_Profile.getProfileId(
            DCN_Profile.API_USER
        );
        env.Draw_Down_Grand_Parent_Products__c = 'Advisory Fees';
        env.Draw_Down_Product_Record_Types__c = 'Advisory';
        env.GainMarginChangeEMailAddress__c = 'support@forex.com';
        env.Gain_Partner_Services_email_address__c = 'partnerservices@gaincapital.com';
        env.Ignore_Validation_Rule__c = false;
        env.MarketingWebServerURL__c = 'http://corporateandinvestment.standardbank.co.za';
        env.onErrorAddress__c = 'standardfxtrader@standardbank.co.za';
        env.Salesforce_Administration_Id__c = sysAdmin.Id;
        env.serverURL__c = '';
        env.urlTrainingSnippets__c = 'http://bluematter.scmb.co.za';
        return env;
    }

    public static CaseConfiguration__c getCaseConfiguration() {
        String contactId = (String) cdgRefCon.Id;
        String rtId = (String) UTL_RecordType.getRecordTypeId(
            DMN_Case.OBJ_NAME,
            DMN_Case.RT_USER_CASE
        );
        return new CaseConfiguration__c(
            Name = 'CaseConfiguration',
            RecordTypeId__c = rtId.substring(0, 15),
            MainCategory__c = 'Client On boarding',
            SubCategory__c = 'CIF Rejection',
            OwnerId__c = '00Gw0000001C2pd',
            CaseOrigin__c = 'Email',
            CasePriority__c = 'Medium',
            ContactId__c = contactId.substring(0, 15)
        );
    }

    public static EmailAddress__c[] getEmailAddress() {
        return new List<EmailAddress__c>{
            new EmailAddress__c(
                Name = 'CIB SA Prod Support',
                Email__c = 'cibsacrmitproductionsuppo@standardbank.co.za.fake'
            ),
            new EmailAddress__c(
                Name = 'CDG Data Mailbox',
                Email__c = 'clientinformationfile@standardbank.co.za.fake'
            ),
            new EmailAddress__c(
                Name = 'CRM Data Mailbox',
                Email__c = 'cibsacrmitproductionsuppo@standardbank.co.za.fake'
            )
        };
    }

    public static ClientCoordinatorSettings__c[] getCcSettings() {
        return new List<ClientCoordinatorSettings__c>{
            createNewCcSetting('AccountAccessLevel', 'Edit'),
            createNewCcSetting('CaseAccessLevel', 'Read'),
            createNewCcSetting('CC_AsOwner_AccountaccessLevel', 'Full Access'),
            createNewCcSetting('CC_ClientAccessLevel', 'Read/Write'),
            createNewCcSetting('CC_OpportunityAccessLevel', 'Read/Write'),
            createNewCcSetting('ContactAccessLevel', 'Edit'),
            createNewCcSetting('OpportunityAccessLevel', 'Edit'),
            createNewCcSetting('CC_CaseAccessLevel', 'Read Only'),
            createNewCcSetting('CC_ContactAccessLevel', 'Read/Write'),
            createNewCcSetting(
                'CC_Client_Coverage_OppAccessLevel',
                'Read Only'
            ),
            createNewCcSetting('OpportunityAccessLevelClientCoverage', 'Read')
        };
    }

    private static ClientCoordinatorSettings__c createNewCcSetting(
        String name,
        String accessLvl
    ) {
        return new ClientCoordinatorSettings__c(
            Name = name,
            AccessLevel__c = accessLvl
        );
    }

    public static CountrySettings__c[] getCountrySettings() {
        return new List<CountrySettings__c>{
            new CountrySettings__c(Name = 'INDIA', Country_ISO_Code__c = 'IN'),
            new CountrySettings__c(
                Name = 'AFGHANISTAN',
                Country_ISO_Code__c = 'AF'
            ),
            new CountrySettings__c(
                Name = 'AUSTRALIA',
                Country_ISO_Code__c = 'AU'
            )
        };
    }

    public static ProfitCentreMatrix__c[] getProfitCentersSettings() {
        return new List<ProfitCentreMatrix__c>{
            new ProfitCentreMatrix__c(
                Name = '1',
                Company_Code__c = 7005,
                Legal_Entity_of_Booking__c = 'Angola - Standard Bank de Angola S.A.'
            ),
            new ProfitCentreMatrix__c(
                Name = '2',
                Company_Code__c = 7021,
                Legal_Entity_of_Booking__c = 'Malawi - Standard Bank Limited'
            ),
            new ProfitCentreMatrix__c(
                Name = '3',
                Company_Code__c = 7022,
                Legal_Entity_of_Booking__c = 'Mauritius - Standard Bank (Mauritius) Limited'
            ),
            new ProfitCentreMatrix__c(
                Name = '4',
                Company_Code__c = 4015,
                Legal_Entity_of_Booking__c = 'Namibia - Standard Bank Namibia Limited'
            )
        };
    }

    public static UserProfileId__c[] getUserProfileIds() {
        return new List<UserProfileId__c>{
            new UserProfileId__c(
                Name = 'UserProfileId',
                UserProfileId__c = UTL_Profile.getProfileId(
                    DCN_Profile.SYS_ADMIN
                )
            ),
            new UserProfileId__c(
                Name = DCN_Profile.BUSINESS_ADMIN,
                UserProfileId__c = UTL_Profile.getProfileId(
                    DCN_Profile.BUSINESS_ADMIN
                )
            )
        };
    }

    public static ErrorMessages__c[] getErrorMessages() {
        return new List<ErrorMessages__c>{
            new ErrorMessages__c(
                Name = 'Add_Attendee_to_list',
                Error_String__c = 'Please select the check box next to the Attendee you want to add.',
                Where_is_this_used__c = 'SA_EventReportContactSearchController Class'
            ),
            new ErrorMessages__c(
                Name = 'Attendee_Added',
                Error_String__c = 'Attendee(s) added successfully',
                Where_is_this_used__c = 'SA_EventReportContactSearchController Class'
            ),
            new ErrorMessages__c(
                Name = 'Blank_Search',
                Error_String__c = 'Please enter some search criteria before clicking on Search Button',
                Where_is_this_used__c = 'Apex Class : CampaignHostsController'
            ),
            new ErrorMessages__c(
                Name = 'Blank_Search_Client',
                Error_String__c = 'You cannot search for a blank value, please insert a value and search again',
                Where_is_this_used__c = 'Apex Class: ClientandContactsearch'
            ),
            new ErrorMessages__c(
                Name = 'Campaign Locked',
                Error_String__c = 'The campaign is currently locked by the campaign owner. You cannot add new members, update or remove existing members, OR edit campaign member detail at this stage.',
                Where_is_this_used__c = 'Apex Class : CampaignMemberTriggerFunctions'
            ),
            new ErrorMessages__c(
                Name = 'Campaign_AddLeadValidation',
                Error_String__c = 'You cannot add Leads to Campaigns. Please change your selection to only include Contacts',
                Where_is_this_used__c = 'Apex Trigger : CampaignMemberTrigger'
            ),
            new ErrorMessages__c(
                Name = 'CCBM_Validation',
                Error_String__c = 'You currently have a Client Coordinator - Business Manager, If you would like to update the Client Coordinator - Business Manager please deselect the current Client Coordinator - Business Manager and try again.',
                Where_is_this_used__c = 'CustomClientTeamUtility Class'
            ),
            new ErrorMessages__c(
                Name = 'CC_And_CCBM_SameUserNotAllowed',
                Error_String__c = 'The Client Coordinator and Client Coordinator - Business Manager cannot be the the same user in the Client Team.',
                Where_is_this_used__c = 'CustomClientTeamUtility Class'
            ),
            new ErrorMessages__c(
                Name = 'ClientCoordinatorBM_Exists',
                Error_String__c = 'You currently have a Client Coordinator - Business Manager, If you would like to update the Client Coordinator - Business Manager please deselect the current Client Coordinator - Business Manager and try again.',
                Where_is_this_used__c = 'CustomClientTeamUtility Class'
            ),
            new ErrorMessages__c(
                Name = 'Client_CordinatorExists',
                Error_String__c = 'You currently have a Client Coordinator, If you would like to update the Client Coordinator please deselect the current Client Coordinator and try again.',
                Where_is_this_used__c = 'CustomClientTeamUtility Class'
            ),
            new ErrorMessages__c(
                Name = 'Event_Attendee_Exists',
                Error_String__c = 'The Contact is already added as an Attendee to this Event',
                Where_is_this_used__c = 'SA_EventReportContactSearchController'
            ),
            new ErrorMessages__c(
                Name = 'Inactive_Contact',
                Error_String__c = 'One or more of the contacts selected are inactive',
                Where_is_this_used__c = 'SA_EventReportContactSearchController'
            ),
            new ErrorMessages__c(
                Name = 'Insufficient_Access',
                Error_String__c = 'Insufficient Access',
                Where_is_this_used__c = 'CustomClientTeamUtility Class'
            ),
            new ErrorMessages__c(
                Name = 'No_Contact_Selected',
                Error_String__c = 'NO Contact was selected from the Contact list. Please click the above link and then select Contacts to add to the Campaign',
                Where_is_this_used__c = 'Apex Class: CampaignMemberHostAssignerController'
            ),
            new ErrorMessages__c(
                Name = 'No_Host_Selected_ToRemove',
                Error_String__c = 'In order to remove hosts, please select the checkbox next to the hosts you want to remove.',
                Where_is_this_used__c = 'Apex Class : CampaignHostsController'
            ),
            new ErrorMessages__c(
                Name = 'OppSharingundefined',
                Error_String__c = 'Sharing is not defined for this opportunity',
                Where_is_this_used__c = 'Apex Class: OpportunityVisibilityController'
            ),
            new ErrorMessages__c(
                Name = 'OppTeamMemberEmptyMessage',
                Error_String__c = 'This opportunity does not have any team member(s)',
                Where_is_this_used__c = 'Apex Class: OpportunityVisibilityController'
            ),
            new ErrorMessages__c(
                Name = 'Less_than_three_character_search',
                Error_String__c = 'Please use three or more characters in the search',
                Where_is_this_used__c = 'Apex Class: ClientandContactsearch'
            ),
            new ErrorMessages__c(
                Name = 'SameTeamRoleValidation',
                Error_String__c = 'Same Team Role exist for Client Team Member. Please select a different Team Role.',
                Where_is_this_used__c = 'CustomClientTeamUtility Class'
            ),
            new ErrorMessages__c(
                Name = 'SameUserExists',
                Error_String__c = 'Same User already exists in the Client Team',
                Where_is_this_used__c = 'CustomClientTeamUtility Class'
            ),
            new ErrorMessages__c(
                Name = 'Search_Results_Not_Found',
                Error_String__c = 'No search results could be found based on your searh criteria.',
                Where_is_this_used__c = 'Apex Class : CampaignHostsController'
            ),
            new ErrorMessages__c(
                Name = 'Select_Host',
                Error_String__c = 'In order to add hosts, please select the checkbox next to the hosts you want to add.',
                Where_is_this_used__c = 'Apex Class : CampaignHostsController'
            ),
            new ErrorMessages__c(
                Name = 'TeamMember_Validation',
                Error_String__c = 'There is already a Team Member with the same Team Role on the Client Team. Please select an alternative Team Role to Add the Team Member to the Client Team.',
                Where_is_this_used__c = 'CustomClientTeamUtility Class'
            )
        };
    }

    public static CsiProjectCountry__c[] getCsiProjectCountries() {
        return new List<CsiProjectCountry__c>{
            new CsiProjectCountry__c(Name = 'South Africa'),
            new CsiProjectCountry__c(Name = 'Swaziland'),
            new CsiProjectCountry__c(Name = 'Tanzania'),
            new CsiProjectCountry__c(Name = 'Uganda')
        };
    }

    public static Sharing_Settings__c[] getSharingSettings() {
        return new List<Sharing_Settings__c>{
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'CST_Member_Can_Access_Accounts_Info__c',
                Sharing_Sobject_Type__c = 'Account_Information__share',
                Sobject_Type__c = 'Account_Information__c',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'CST_Member_Can_Access_Accounts_Info__c',
                Sharing_Sobject_Type__c = 'Account_Information__share',
                Sobject_Type__c = 'Account_Information__c',
                Key_Value__c = DCN_CustomSetting.CCT_CC
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'Manual',
                Sharing_Sobject_Type__c = 'AccountShare',
                Sobject_Type__c = 'Account',
                Key_Value__c = DCN_CustomSetting.CCT_CC
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'Manual',
                Sharing_Sobject_Type__c = 'AccountShare',
                Sobject_Type__c = 'Opportunity',
                Key_Value__c = DCN_CustomSetting.CCT_CC
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'Manual',
                Sharing_Sobject_Type__c = 'AccountShare',
                Sobject_Type__c = 'Contact',
                Key_Value__c = DCN_CustomSetting.CCT_CC
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'Manual',
                Sharing_Sobject_Type__c = 'AccountShare',
                Sobject_Type__c = 'Case',
                Key_Value__c = DCN_CustomSetting.CCT_CC
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'Manual',
                Sharing_Sobject_Type__c = 'AccountShare',
                Sobject_Type__c = 'Account',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'Manual',
                Sharing_Sobject_Type__c = 'AccountShare',
                Sobject_Type__c = 'Opportunity',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'Manual',
                Sharing_Sobject_Type__c = 'AccountShare',
                Sobject_Type__c = 'Contact',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'Manual',
                Sharing_Sobject_Type__c = 'AccountShare',
                Sobject_Type__c = 'Case',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'CST_Member_Can_Read_CSI_Records__c',
                Sharing_Sobject_Type__c = 'Client_Satisfaction_Index__Share',
                Sobject_Type__c = 'Client_Satisfaction_Index__c',
                Key_Value__c = DCN_CustomSetting.CCT_CC
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'CST_Member_Can_Read_CSI_Records__c',
                Sharing_Sobject_Type__c = 'Client_Satisfaction_Index__Share',
                Sobject_Type__c = 'Client_Satisfaction_Index__c',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'CCT_Member_Can_Read_Records',
                Sharing_Sobject_Type__c = 'Global_Client_Revenue__share',
                Sobject_Type__c = 'Global_Client_Revenue__c',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = 'CCT_Member_Can_Read_Records',
                Sharing_Sobject_Type__c = 'Global_Client_Revenue__share',
                Sobject_Type__c = 'Global_Client_Revenue__c',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = SHR_CreditLine.DEF_SHARING,
                Sharing_Sobject_Type__c = 'Credit_Line__share',
                Sobject_Type__c = 'Credit_Line__c',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = SHR_CreditLine.DEF_SHARING,
                Sharing_Sobject_Type__c = 'Credit_Line__share',
                Sobject_Type__c = 'Credit_Line__c',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = SHR_BusinessAssessment.CLIENT_COORDINATOR,
                Sharing_Sobject_Type__c = 'Business_Assessment__share',
                Sobject_Type__c = 'Business_Assessment__c',
                Key_Value__c = DCN_CustomSetting.CCT_CC
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = SHR_BusinessAssessment.CLIENT_COORDINATOR,
                Sharing_Sobject_Type__c = 'Business_Assessment__share',
                Sobject_Type__c = 'Business_Assessment__c',
                Key_Value__c = DCN_CustomSetting.CCT_CCBM
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = SHR_BusinessAssessment.CREDIT_OFFICER,
                Sharing_Sobject_Type__c = 'Business_Assessment__share',
                Sobject_Type__c = 'Business_Assessment__c',
                Key_Value__c = DMN_ClientTeam.ROLE_CREDIT_OFFICER
            ),
            new Sharing_Settings__c(
                Name = String.valueOf(shareSettingCounter++),
                Access_Level__c = 'Edit',
                Sharing_Reason__c = SHR_BusinessAssessment.CREDIT_OFFICER,
                Sharing_Sobject_Type__c = 'Business_Assessment__share',
                Sobject_Type__c = 'Business_Assessment__c',
                Key_Value__c = DMN_ClientTeam.ROLE_CREDIT_RISK
            )
        };
    }

    public static DA_Lending_Limits__c[] getDALendingLimits() {
        return new List<DA_Lending_Limits__c>{
            new DA_Lending_Limits__c(
                Name = DMN_Account.RISK_RATING_D1,
                Approval_Min_DA3__c = 0.00,
                Approval_Max_DA3__c = 200000000.00,
                Approval_Min_DA2__c = 200000001.00,
                Approval_Max_DA2__c = 676000000.00,
                Approval_Min_DA1__c = 676000001.00
            ),
            new DA_Lending_Limits__c(
                Name = DMN_Account.RISK_RATING_D2,
                Approval_Min_DA3__c = 0.00,
                Approval_Max_DA3__c = 200000000.00,
                Approval_Min_DA2__c = 200000001.00,
                Approval_Max_DA2__c = 644000000.00,
                Approval_Min_DA1__c = 644000001.00
            )
        };
    }

    public static NBAC_Committee_RegGlob_Map__c[] getCommitteeRegGlobMap() {
        return new List<NBAC_Committee_RegGlob_Map__c>{
            new NBAC_Committee_RegGlob_Map__c(
                Name = DMN_BusinessAssessment.DELEGATED_AUTHORITY_DA1,
                Committee__c = DMN_BusinessAssessment.COMMITTEE_GLOBAL,
                Committee_Level__c = DMN_BusinessAssessment.COMMITTEE_LEVEL_GLOBAL
            )
        };
    }

    public static NBAC_Committee_Local_Map__c[] getCommitteeLocalMap() {
        return new List<NBAC_Committee_Local_Map__c>{
            new NBAC_Committee_Local_Map__c(
                Name = (DMN_BusinessAssessment.DELEGATED_AUTHORITY_DA2 +
                DMN_Account.FRANCO_ANGOLA),
                Committee__c = DMN_BusinessAssessment.COMMITTEE_ANGOLA,
                Committee_Level__c = DMN_BusinessAssessment.COMMITTEE_LEVEL_LOCAL
            )
        };
    }

    public static KYC_Locations__c[] getKycLocations() {
        return new List<KYC_Locations__c>{
            new KYC_Locations__c(
                Name = 'SBSA',
                Value__c = 'SBSA - Standard Bank of South Africa Ltd'
            ),
            new KYC_Locations__c(
                Name = 'SBAO',
                Value__c = 'SBAO - Standard Bank de Angola SA'
            ),
            new KYC_Locations__c(
                Name = 'SBMU',
                Value__c = 'SBMU - Standard Bank (Mauritius) Ltd'
            ),
            new KYC_Locations__c(
                Name = 'Cote dIvoire',
                Value__c = 'SBCI - Standard Bank Cote D\'Ivoire SA'
            )
        };
    }

    public static SystemAdmin_BA_profileID_task_Deletion__c[] getSystemAdminBAprofileIDtaskDeletion() {
        return new List<SystemAdmin_BA_profileID_task_Deletion__c>{
            new SystemAdmin_BA_profileID_task_Deletion__c(
                Name = 'System Admin Profile ID',
                Profile_ID__c = UTL_Profile.getProfileId('System Administrator')
                    .substring(0, 15)
            ),
            new SystemAdmin_BA_profileID_task_Deletion__c(
                Name = 'Business Admin Profile ID',
                Profile_ID__c = UTL_Profile.getProfileId(
                        'Business Administrator'
                    )
                    .substring(0, 15)
            )
        };
    }

    public static SB_Parameters__c[] getSbParameters() {
        return new List<SB_Parameters__c>{
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBCD', Value__c = 'AR'),
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBCI', Value__c = 'AR'),
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBMU', Value__c = 'AR'),
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBSA', Value__c = 'SA'),
            new SB_Parameters__c(
                Name = 'CRMHelpdeskEmail',
                Value__c = UserInfo.getUserEmail()
            ),
            new SB_Parameters__c(
                Name = 'KYC Team Email',
                Value__c = 'SA@t.com'
            ),
            new SB_Parameters__c(
                Name = 'Not_Restricted_Divisions',
                Value__c = 'Commercial Banking;Client Coverage;Global Markets;Investment Banking;Transactional Products and Services;General Management;Real Estate;'
            ),
            new SB_Parameters__c(
                Name = 'TPS_Core_Roles',
                Value__c = 'Investor Services Manager;Trade Finance Manager'
            ),
            new SB_Parameters__c(Name = 'MC_Client_Id', Value__c = '123'),
            new SB_Parameters__c(Name = 'MC_Client_Secret', Value__c = '123'),
            new SB_Parameters__c(Name = 'MC_Acc_Id_Test', Value__c = '1234'),
            new SB_Parameters__c(
                Name = 'MC_Event_Definition_Key',
                Value__c = 'TestEventDefinitionKey'
            ),
            new SB_Parameters__c(
                Name = 'API_Request_Consent_Errors',
                Value__c = 'API_Request_Consent_Errors_JyU'
            ),
            new SB_Parameters__c(
                Name = 'DIGISIGN_CONSENT_INVITATION',
                Value__c = 'DIGISIGN_CONSENT_INVITATION'
            ),
            new SB_Parameters__c(
                Name = 'ESB_CALL_BACK',
                Value__c = 'https://esbdpd01.standardbank.co.za:5120/services/apexrest/bpm/v1/digisignfeedback'
            )
        };
    }

    public static CI_Parameters__c[] getCIParameters() {
        return new List<CI_Parameters__c>{
            new CI_Parameters__c(
                Name = 'CYPipelDiv',
                Value__c = 'Investment Banking;Transactional Products and Services'
            ),
            new CI_Parameters__c(
                Name = 'RevenueBudgetDiv',
                Value__c = 'Investment Banking;Transactional Products and Services'
            ),
            new CI_Parameters__c(
                Name = 'RevenueSecondLevelNavDisable',
                Value__c = 'Transactional Products and Services;Investment Banking;'
            )
        };
    }

    public static List<CST_Core_Roles__c> getCstCoreRoles() {
        return new List<CST_Core_Roles__c>{
            new CST_Core_Roles__c(
                Name = 'CommB Relationship Manager',
                Value__c = 'CommB Relationship Manager'
            ),
            new CST_Core_Roles__c(
                Name = 'Credit Risk',
                Value__c = 'Credit Risk'
            ),
            new CST_Core_Roles__c(
                Name = 'Executive Sponsor',
                Value__c = 'Executive Sponsor'
            ),
            new CST_Core_Roles__c(
                Name = 'GM Champion',
                Value__c = 'GM Champion'
            ),
            new CST_Core_Roles__c(
                Name = 'Advisory Banker',
                Value__c = 'Advisory Banker'
            ),
            new CST_Core_Roles__c(
                Name = 'Finance Banker',
                Value__c = 'Finance Banker'
            ),
            new CST_Core_Roles__c(
                Name = 'Manager Client Coverage',
                Value__c = 'Manager Client Coverage'
            ),
            new CST_Core_Roles__c(
                Name = 'Sector/Client Coverage Head',
                Value__c = 'Sector/Client Coverage Head'
            ),
            new CST_Core_Roles__c(
                Name = 'TPS Champion',
                Value__c = 'TPS Champion'
            )
        };
    }

    public static List<Reporting_Franco_to_Public_Group__c> getReportingFrancos() {
        return new List<Reporting_Franco_to_Public_Group__c>{
            new Reporting_Franco_to_Public_Group__c(
                Name = 'Non Presence West Africa',
                Client_Reporting_Franco__c = 'Non Presence West Africa',
                Public_Group_Name__c = 'CIBROA Core Markets'
            ),
            new Reporting_Franco_to_Public_Group__c(
                Name = 'Presence West Africa',
                Client_Reporting_Franco__c = 'Presence West Africa',
                Public_Group_Name__c = 'CIBROA Core Markets'
            ),
            new Reporting_Franco_to_Public_Group__c(
                Name = 'South and Central Africa',
                Client_Reporting_Franco__c = 'South and Central Africa',
                Public_Group_Name__c = 'CIBROA Core Markets'
            ),
            new Reporting_Franco_to_Public_Group__c(
                Name = 'West Africa',
                Client_Reporting_Franco__c = 'West Africa',
                Public_Group_Name__c = 'CIBROA Core Markets'
            )
        };
    }

    public static List<CSTTeamRoleRanking__c> getCstTeamRankings() {
        return new List<CSTTeamRoleRanking__c>{
            new CSTTeamRoleRanking__c(
                Name = DMN_ClientTeam.ROLE_CREDIT_RISK,
                AccountFieldName__c = 'Credit_Risk__c',
                CSTTeamRoleRanking__c = '7'
            ),
            new CSTTeamRoleRanking__c(
                Name = DMN_ClientTeam.ROLE_GM_CHAMPION,
                AccountFieldName__c = 'GM_Champion__c',
                CSTTeamRoleRanking__c = '5'
            ),
            new CSTTeamRoleRanking__c(
                Name = DMN_ClientTeam.ROLE_EXEC_SPONSOR,
                AccountFieldName__c = 'Executive_Sponsor__c',
                CSTTeamRoleRanking__c = '1'
            ),
            new CSTTeamRoleRanking__c(
                Name = DMN_ClientTeam.ROLE_ADVISORY_BANKER,
                AccountFieldName__c = 'IB_Champion__c',
                CSTTeamRoleRanking__c = '4'
            ),
            new CSTTeamRoleRanking__c(
                Name = DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE,
                AccountFieldName__c = 'Manager_Client_Coverage__c',
                CSTTeamRoleRanking__c = '3'
            ),
            new CSTTeamRoleRanking__c(
                Name = DMN_ClientTeam.ROLE_SECTORCLIENT_COVERAGE_HEAD,
                AccountFieldName__c = 'Sector_Client_Coverage_Head__c',
                CSTTeamRoleRanking__c = '2'
            ),
            new CSTTeamRoleRanking__c(
                Name = DMN_ClientTeam.ROLE_TPS_CHAMPION,
                AccountFieldName__c = 'TPS_Champion__c',
                CSTTeamRoleRanking__c = '6'
            )
        };
    }

    public static List<ProductSearch__c> getProductSearchSettings() {
        return new List<ProductSearch__c>{
            new ProductSearch__c(
                Name = '1',
                Grand_Parent_Product__c = 'Advisory Fees',
                Parent_Product__c = '',
                Product__c = '',
                Product_Record_Type__c = 'Advisory',
                Product_Division__c = 'Transactional Products and Services'
            ),
            new ProductSearch__c(
                Name = '10',
                Grand_Parent_Product__c = 'Bank Sector Services',
                Parent_Product__c = 'Retail Clearing',
                Product__c = 'SWIFT Remit',
                Product_Record_Type__c = 'Transactional 2014',
                Product_Division__c = 'Global Markets'
            ),
            new ProductSearch__c(
                Name = '142',
                Grand_Parent_Product__c = 'Equity Capital Markets',
                Parent_Product__c = 'Block Trade',
                Product__c = '',
                Product_Record_Type__c = 'Capital Markets',
                Product_Division__c = 'Business and Commercial Banking'
            ),
            new ProductSearch__c(
                Name = '5',
                Grand_Parent_Product__c = 'Bank Sector Services',
                Parent_Product__c = 'Bank Notes',
                Product__c = '',
                Product_Record_Type__c = 'Transactional 2014',
                Product_Division__c = 'Investment Banking'
            )
        };
    }

    public static List<ProductSearch__c> getProductSearchSettingsCIB() {
        return new List<ProductSearch__c>{
            new ProductSearch__c(
                Name = '124',
                Grand_Parent_Product__c = 'Loans',
                Parent_Product__c = 'Working Capital',
                Product__c = 'Overdraft (Business Current Account)',
                Product_Record_Type__c = 'CommB Lending',
                Product_Division__c = 'Business and Commercial Banking'
            ),
            new ProductSearch__c(
                Name = '122',
                Grand_Parent_Product__c = 'Cash Management',
                Parent_Product__c = 'Deposits',
                Product_Record_Type__c = 'TPS 2022',
                Product__c = 'Current Account',
                Product_Division__c = 'Transactional Products and Services'
            ),
            new ProductSearch__c(
                Name = '123',
                Grand_Parent_Product__c = 'Property (lending)',
                Parent_Product__c = 'VAF Other Assets',
                Product_Record_Type__c = 'Insurance',
                Product__c = 'Aviation hull',
                Product_Division__c = 'Insurance'
            )
        };
    }
    public static List<Product2> getProduct2CIB() {
        return new List<Product2>{
            new Product2(
                Name = 'Overdraft (Business Current Account)',
                Grand_Parent_Product__c = 'Loans',
                Parent_Product__c = 'Working Capital',
                Product_Division__c = 'Business and Commercial Banking',
                isActive = true
            ),
            new Product2(
                Name = 'Current Account',
                Grand_Parent_Product__c = 'Cash Management',
                Parent_Product__c = 'Deposits',
                Product_Division__c = 'Transactional Products and Services',
                isActive = true
            ),
            new Product2(
                Name = 'Aviation hull',
                Grand_Parent_Product__c = 'Property (lending)',
                Parent_Product__c = 'VAF Other Assets',
                Product_Division__c = 'Insurance',
                isActive = true
            )
        };
    }
    public static List<Product_Fields__c> getProductFieldsSettings() {
        return new List<Product_Fields__c>{
            new Product_Fields__c(
                Name = 'productIds',
                Account_Id__c = 'CF00N20000001bfK9',
                Grand_Parent_Product_Id__c = '00N20000001bfKd',
                Opportunity_Id__c = 'CF00N20000001bfJa',
                Parent_Product_Id__c = '00N20000001bfKs',
                Product_Id__c = '00N20000001qqtG',
                Product_Division_Id__c = '00Nw0000008f4A9'
            )
        };
    }

    public static Gift_Expense_Log_Variables__c getGiftExpenseLogVariable() {
        return new Gift_Expense_Log_Variables__c(
            Bank_Contact_Field_Id__c = 'CF00N20000003HmHU',
            Client_Contact_Field_Id__c = 'CF00N20000003HmHZ'
        );
    }

    public static List<CSTManyperRegionTeamRoles__c> getCSTManyPerRegionTeamRoles() {
        return new List<CSTManyperRegionTeamRoles__c>{
            new CSTManyperRegionTeamRoles__c(Name = 'Trader'),
            new CSTManyperRegionTeamRoles__c(
                Name = 'Trade Service Advisory Manager'
            ),
            new CSTManyperRegionTeamRoles__c(Name = 'Structurer'),
            new CSTManyperRegionTeamRoles__c(Name = 'Service Manager'),
            new CSTManyperRegionTeamRoles__c(Name = 'Service Advisor'),
            new CSTManyperRegionTeamRoles__c(Name = 'Sales Manager'),
            new CSTManyperRegionTeamRoles__c(Name = 'Sales / Cell Head'),
            new CSTManyperRegionTeamRoles__c(Name = 'Product Specialist'),
            new CSTManyperRegionTeamRoles__c(Name = 'In Country RM'),
            new CSTManyperRegionTeamRoles__c(Name = 'GM Execution Manager'),
            new CSTManyperRegionTeamRoles__c(Name = 'GM Client Manager'),
            new CSTManyperRegionTeamRoles__c(Name = 'Credit Officer'),
            new CSTManyperRegionTeamRoles__c(Name = 'Client Analyst')
        };
    }

    public static List<Open_KYC_Review_Status__c> getOpenKycReviewStatuses() {
        return new List<Open_KYC_Review_Status__c>{
            new Open_KYC_Review_Status__c(
                Name = 'Potential Closure',
                Value__c = 'Potential Closure'
            ),
            new Open_KYC_Review_Status__c(
                Name = 'KYC Reviewer Approval Outstanding',
                Value__c = 'KYC Reviewer Approval Outstanding'
            ),
            new Open_KYC_Review_Status__c(
                Name = 'KYC Processing Documents',
                Value__c = 'KYC Processing Documents'
            ),
            new Open_KYC_Review_Status__c(
                Name = 'In progress',
                Value__c = 'In progress'
            ),
            new Open_KYC_Review_Status__c(
                Name = 'Entities Still to Contact',
                Value__c = 'Entities Still to Contact'
            ),
            new Open_KYC_Review_Status__c(
                Name = 'Compliance Approval Outstanding',
                Value__c = 'Compliance Approval Outstanding'
            ),
            new Open_KYC_Review_Status__c(
                Name = 'Approval Outstanding',
                Value__c = 'Client Risk Committee Approval Outstanding'
            )
        };
    }

    public static List<StandardBank_Email_Domains__c> getStandardBankEmailDomains() {
        return new List<StandardBank_Email_Domains__c>{
            new StandardBank_Email_Domains__c(
                Name = 'SBG',
                Domain_Value__c = 'sbg'
            ),
            new StandardBank_Email_Domains__c(
                Name = 'Stanbic',
                Domain_Value__c = 'stanbic'
            ),
            new StandardBank_Email_Domains__c(
                Name = 'StandardBank',
                Domain_Value__c = 'standardbank'
            ),
            new StandardBank_Email_Domains__c(
                Name = 'Stanlib',
                Domain_Value__c = 'stanlib'
            )
        };
    }

    public static List<SubClassification_Mapping__c> getSubClassificationMappings() {
        return new List<SubClassification_Mapping__c>{
            new SubClassification_Mapping__c(
                Name = 'Broker Dealer - Corporation - 10',
                Client_Type__c = 'Broker Dealer',
                Business_Classification__c = 'Corporation',
                SubClassification__c = 'Corporation'
            ),
            new SubClassification_Mapping__c(
                Name = 'Broker Dealer - Corporation - 20',
                Client_Type__c = 'Broker Dealer',
                Business_Classification__c = 'Corporation',
                SubClassification__c = 'Close Corporation'
            )
        };
    }

    public static void insertClientOperatingCountriesSettings() {
        Test.loadData(
            CS_Client_Operating_Countries__c.SObjectType,
            'ClientOperatingCountriesCustomSetting'
        );
    }

    public static List<System_Parameter__c> getSystemParameters() {
        return new List<System_Parameter__c>{
            new System_Parameter__c(
                Name = 'Environment',
                Environment__c = 'Live',
                Value__c = 'Live'
            ),
            new System_Parameter__c(
                Name = 'Multiple Cashflow Creation - Number of Rows',
                Environment__c = 'Same for All',
                Value__c = '5'
            ),
            new System_Parameter__c(
                Name = 'Multiple Distribution Client Creation - Number of Rows',
                Environment__c = 'Same for All',
                Value__c = '5'
            )
        };
    }
    public static List<OSB_URLs__c> getOsbUrls() {
        List<OSB_URLs__c> osbUrls = new List<OSB_URLs__c>();
        String testUrl = 'https:/test.force.com';

        OSB_URLs__c osbUrl = new OSB_URLs__c();
        osbUrl.Name = 'OSB_Url';
        osbUrl.Value__c = testUrl;
        osbUrls.add(osbUrl);

        OSB_URLs__c osbUrlSite = new OSB_URLs__c();
        osbUrlSite.Name = 'OSB_SiteName';
        osbUrlSite.Value__c = 'One Hub';
        osbUrls.add(osbUrlSite);

        OSB_URLs__c userAccessKey = new OSB_URLs__c();
        userAccessKey.Name = 'UserAccess';
        userAccessKey.Value__c = 'CIB-APDPJSON';
        osbUrls.add(userAccessKey);

        OSB_URLs__c adapterId = new OSB_URLs__c();
        adapterId.Name = 'AdapterId';
        adapterId.Value__c = '/ext/pwdchange/Identify?AdapterId=HTMLFormAdapterCIBAMTSALESFORCE&pf.username=';
        osbUrls.add(adapterId);

        OSB_URLs__c inviteUrl = new OSB_URLs__c();
        inviteUrl.Name = 'OSB_OneSpace_Invite_Url';
        inviteUrl.Value__c = testUrl;
        osbUrls.add(inviteUrl);

        OSB_URLs__c emailAddress = new OSB_URLs__c();
        emailAddress.Name = 'OSB_Email_Address';
        emailAddress.Value__c = 'onehub@standardbank.co.za';
        osbUrls.add(emailAddress);

        OSB_URLs__c congratulationUrl = new OSB_URLs__c();
        congratulationUrl.Name = 'OSB_Congratulations_Url';
        congratulationUrl.Value__c = testUrl;
        osbUrls.add(congratulationUrl);

        OSB_URLs__c baseUrl = new OSB_URLs__c();
        baseUrl.Name = 'OSB_Base_URL';
        baseUrl.Value__c = testUrl;
        osbUrls.add(baseUrl);

        OSB_URLs__c pingAccessTokenUrl = new OSB_URLs__c();
        pingAccessTokenUrl.Name = 'Ping_Token_Endpoint';
        pingAccessTokenUrl.Value__c = 'callout:Ping_directory/as/token.oauth2';
        osbUrls.add(pingAccessTokenUrl);

        OSB_URLs__c pingCreateUserUrl = new OSB_URLs__c();
        pingCreateUserUrl.Name = 'Ping_Directory_Endpoint';
        pingCreateUserUrl.Value__c = 'callout:Ping_SCIM/directory/v1';
        osbUrls.add(pingCreateUserUrl);

        OSB_URLs__c pingGetUserUrl = new OSB_URLs__c();
        pingGetUserUrl.Name = 'Ping_Get_User';
        pingGetUserUrl.Value__c = 'callout:Ping_SCIM/directory/v1/ou=People,dc=sbsa,dc=com/subtree?searchScope=wholeSubtree&filter=uid%20eq%20%22@#username#@%22';
        osbUrls.add(pingGetUserUrl);

        OSB_URLs__c pingUpdateUserUrl = new OSB_URLs__c();
        pingUpdateUserUrl.Name = 'Ping_Update_User';
        pingUpdateUserUrl.Value__c = 'callout:Ping_SCIM/directory/v1/@#pingId#@';
        osbUrls.add(pingUpdateUserUrl);

        OSB_URLs__c pingGetUserDetailsUrl = new OSB_URLs__c();
        pingGetUserDetailsUrl.Name = 'Ping_Get_User_Details';
        pingGetUserDetailsUrl.Value__c = 'callout:Ping_SCIM/directory/v1/me';
        osbUrls.add(pingGetUserDetailsUrl);

        OSB_URLs__c pingGetAccessToken = new OSB_URLs__c();
        pingGetAccessToken.Name = 'Ping_Get_Access_Token_URL';
        pingGetAccessToken.Value__c = 'client_id=@#consumerKey#@&client_secret=##consumerSecret##&scope=Salesforce urn:pingidentity:directory-api&grant_type=client_credentials';
        osbUrls.add(pingGetAccessToken);

        OSB_URLs__c pingTargetResource = new OSB_URLs__c();
        pingTargetResource.Name = 'OSB_Ping_TargetResource';
        pingTargetResource.Value__c = testUrl;
        osbUrls.add(pingTargetResource);

        OSB_URLs__c insightsURL = new OSB_URLs__c();
        insightsURL.Name = 'Insights_website';
        insightsURL.Value__c = 'https://corporateandinvestment.standardbank.com/cib/global/insights/african-platform-business-economies';
        osbUrls.add(insightsURL);

        OSB_URLs__c noknokRegistrationEndpoint = new OSB_URLs__c();
        noknokRegistrationEndpoint.Name = 'Noknok_Registration_Endpoint';
        noknokRegistrationEndpoint.Value__c = 'https://gateway.standardbank.co.za:5543/sbsa/ext-prod/noknok/reg/nbol';
        osbUrls.add(noknokRegistrationEndpoint);

        OSB_URLs__c termsUrl = new OSB_URLs__c();
        termsUrl.Name = 'OSB_T&C';
        termsUrl.Value__c = 'https://termsandconditions.test';
        osbUrls.add(termsUrl);

        OSB_URLs__c emailToCaseEmail = new OSB_URLs__c();
        emailToCaseEmail.Name = 'OSB_OD_EmailToCase';
        emailToCaseEmail.Value__c = 'onehub@standardbank.co.za';
        osbUrls.add(emailToCaseEmail);

        OSB_URLs__c shortcutAccessTokenEndpoint = new OSB_URLs__c();
        shortcutAccessTokenEndpoint.Name = 'Shortcuts_Access_Token_Endpoint';
        shortcutAccessTokenEndpoint.Value__c = '/npextorg/extnonprod/sysauth/oauth2/token';
        osbUrls.add(shortcutAccessTokenEndpoint);

        OSB_URLs__c shortcutAccessTokenURL = new OSB_URLs__c();
        shortcutAccessTokenURL.Name = 'Shortcuts_Access_Token_URL';
        shortcutAccessTokenURL.Value__c = 'client_id=@#clientId#@&client_secret=##clientSecret##&scope=corporate&grant_type=client_credentials';
        osbUrls.add(shortcutAccessTokenURL);

        OSB_URLs__c shortcutSolutionPath = new OSB_URLs__c();
        shortcutSolutionPath.Name = 'Shortcuts_For_Solution_User';
        shortcutSolutionPath.Value__c = '/npextorg/extnonprod/short-cuts-api/user/@#pingUUID#@/service-task?email=##email##&shopname=shp#shopName#shp';
        osbUrls.add(shortcutSolutionPath);

        return osbUrls;
    }

    public static List<OSB_Ping_Integration__c> getOsbPingIntegrationKeys() {
        List<OSB_Ping_Integration__c> osbPingKeys = new List<OSB_Ping_Integration__c>();

        OSB_Ping_Integration__c osbPingKeyLastName = new OSB_Ping_Integration__c();
        osbPingKeyLastName.Name = 'SB-LastName';
        osbPingKeyLastName.Value__c = '"@#Contact.LastName#@"';
        osbPingKeyLastName.UsedIn__c = 'createUser,updateUser';
        osbPingKeys.add(osbPingKeyLastName);

        OSB_Ping_Integration__c osbPingKeyPassword = new OSB_Ping_Integration__c();
        osbPingKeyPassword.Name = 'userPassword';
        osbPingKeyPassword.Value__c = '["@#userPassword#@"]';
        osbPingKeyPassword.UsedIn__c = 'createUser';
        osbPingKeys.add(osbPingKeyPassword);

        return osbPingKeys;
    }

    public static List<OSB_Ping_Integration_Response__c> getOsbPingIntegrationResponseKeys() {
        List<OSB_Ping_Integration_Response__c> osbPingResponseKeys = new List<OSB_Ping_Integration_Response__c>();

        OSB_Ping_Integration_Response__c osbPingKeyFirstName = new OSB_Ping_Integration_Response__c();
        osbPingKeyFirstName.Name = 'givenName';
        osbPingKeyFirstName.Value__c = 'SB-FirstName';
        osbPingResponseKeys.add(osbPingKeyFirstName);

        OSB_Ping_Integration_Response__c osbPingKeyLastName = new OSB_Ping_Integration_Response__c();
        osbPingKeyLastName.Name = 'familyName';
        osbPingKeyLastName.Value__c = 'SB-SurName';
        osbPingResponseKeys.add(osbPingKeyLastName);

        OSB_Ping_Integration_Response__c osbPingKeyIndustry = new OSB_Ping_Integration_Response__c();
        osbPingKeyIndustry.Name = 'industry';
        osbPingKeyIndustry.Value__c = 'Industry';
        osbPingResponseKeys.add(osbPingKeyIndustry);

        OSB_Ping_Integration_Response__c osbPingKeyPhoneNumber = new OSB_Ping_Integration_Response__c();
        osbPingKeyPhoneNumber.Name = 'phoneNumber';
        osbPingKeyPhoneNumber.Value__c = 'SB-CellPhone';
        osbPingResponseKeys.add(osbPingKeyPhoneNumber);

        OSB_Ping_Integration_Response__c osbPingKeyEmailVerificationStatus = new OSB_Ping_Integration_Response__c();
        osbPingKeyEmailVerificationStatus.Name = 'emailVerificationStatus';
        osbPingKeyEmailVerificationStatus.Value__c = 'SB-EmailVerificationStatus';
        osbPingResponseKeys.add(osbPingKeyEmailVerificationStatus);

        OSB_Ping_Integration_Response__c osbPingKeyOrganization = new OSB_Ping_Integration_Response__c();
        osbPingKeyOrganization.Name = 'organization';
        osbPingKeyOrganization.Value__c = 'o';
        osbPingKeyOrganization.Is_Array__c = true;
        osbPingResponseKeys.add(osbPingKeyOrganization);

        OSB_Ping_Integration_Response__c osbPingKeyCountryCode = new OSB_Ping_Integration_Response__c();
        osbPingKeyCountryCode.Name = 'countryCode';
        osbPingKeyCountryCode.Value__c = 'CountryCode';
        osbPingResponseKeys.add(osbPingKeyCountryCode);

        OSB_Ping_Integration_Response__c osbPingKeyTitle = new OSB_Ping_Integration_Response__c();
        osbPingKeyTitle.Name = 'title';
        osbPingKeyTitle.Value__c = 'title';
        osbPingKeyTitle.Is_Array__c = true;
        osbPingResponseKeys.add(osbPingKeyTitle);

        OSB_Ping_Integration_Response__c osbPingKeyEmail = new OSB_Ping_Integration_Response__c();
        osbPingKeyEmail.Name = 'email';
        osbPingKeyEmail.Value__c = 'uid';
        osbPingKeyEmail.Is_Array__c = true;
        osbPingResponseKeys.add(osbPingKeyEmail);

        OSB_Ping_Integration_Response__c osbPingKeyPingId = new OSB_Ping_Integration_Response__c();
        osbPingKeyPingId.Name = 'pingId';
        osbPingKeyPingId.Value__c = '_dn';
        osbPingResponseKeys.add(osbPingKeyPingId);

        return osbPingResponseKeys;
    }

    public static List<OSB_PingRegistrationResponse__c> getOsbPingRegistrationResponseKeys() {
        List<OSB_PingRegistrationResponse__c> osbPingResponseKeys = new List<OSB_PingRegistrationResponse__c>();

        OSB_PingRegistrationResponse__c osbPingKeyFirstName = new OSB_PingRegistrationResponse__c();
        osbPingKeyFirstName.Name = 'First_name';
        osbPingKeyFirstName.Value__c = 'First_name';
        osbPingResponseKeys.add(osbPingKeyFirstName);

        OSB_PingRegistrationResponse__c osbPingKeyLastName = new OSB_PingRegistrationResponse__c();
        osbPingKeyLastName.Name = 'Last_name';
        osbPingKeyLastName.Value__c = 'Last_name';
        osbPingResponseKeys.add(osbPingKeyLastName);

        OSB_PingRegistrationResponse__c osbPingKeyId = new OSB_PingRegistrationResponse__c();
        osbPingKeyId.Name = 'id';
        osbPingKeyId.Value__c = 'id';
        osbPingResponseKeys.add(osbPingKeyId);

        OSB_PingRegistrationResponse__c osbPingKeySub = new OSB_PingRegistrationResponse__c();
        osbPingKeySub.Name = 'sub';
        osbPingKeySub.Value__c = 'sub';
        osbPingResponseKeys.add(osbPingKeySub);

        OSB_PingRegistrationResponse__c osbPingKeyCell = new OSB_PingRegistrationResponse__c();
        osbPingKeyCell.Name = 'Cellphone';
        osbPingKeyCell.Value__c = 'cellphonenumber';
        osbPingResponseKeys.add(osbPingKeyCell);

        OSB_PingRegistrationResponse__c osbPingKeyDOB = new OSB_PingRegistrationResponse__c();
        osbPingKeyDOB.Name = 'DateOfBirth';
        osbPingKeyDOB.Value__c = 'DateOfBirth';
        osbPingResponseKeys.add(osbPingKeyDOB);

        return osbPingResponseKeys;
    }

    public static List<Product_Fee_Rec_Client_Sector_Map__c> getProductFeeRecClientSectorMap() {
        return new List<Product_Fee_Rec_Client_Sector_Map__c>{
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'Consumer30%',
                Client_Sector__c = 'Consumer',
                Product_Total_Revenue_Percentage__c = 30
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'FInstitutions30%',
                Client_Sector__c = 'Financial Institutions',
                Product_Total_Revenue_Percentage__c = 30
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'Industrials30%',
                Client_Sector__c = 'Industrials',
                Product_Total_Revenue_Percentage__c = 30
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'MMetals30%',
                Client_Sector__c = 'Mining and Metals',
                Product_Total_Revenue_Percentage__c = 30
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'OGas50%',
                Client_Sector__c = 'Oil and Gas',
                Product_Total_Revenue_Percentage__c = 50
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'PInfrastructure50%',
                Client_Sector__c = 'Power and Infrastructure',
                Product_Total_Revenue_Percentage__c = 50
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'SPublicSector30%',
                Client_Sector__c = 'Sovereign / Public Sector',
                Product_Total_Revenue_Percentage__c = 30
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'TMedia30%',
                Client_Sector__c = 'Telecoms and Media',
                Product_Total_Revenue_Percentage__c = 30
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'REstate30%',
                Client_Sector__c = 'Real Estate',
                Product_Total_Revenue_Percentage__c = 30
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'USector30%',
                Client_Sector__c = 'Unknown Sector',
                Product_Total_Revenue_Percentage__c = 30
            ),
            new Product_Fee_Rec_Client_Sector_Map__c(
                Name = 'IGrouped30%',
                Client_Sector__c = 'Internal / Grouped',
                Product_Total_Revenue_Percentage__c = 30
            )
        };
    }

    public class DataFactoryException extends Exception {
    }
}