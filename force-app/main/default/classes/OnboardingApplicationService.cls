/**
 * Created by Caro on 2018/08/24.
 */

public with sharing class OnboardingApplicationService {

    public static final String CRM_HELPDESK_PARAMETER_NAME = 'CRMHelpdeskEmail';

    public static final String REQUEST_TYPE_NEW_CLIENT = 'Onboarding';
    public static final String REQUEST_TYPE_MIGRATION = 'Migration';
    public static final String REQUEST_TYPE_HIERARCHY_CHANGE = 'Hierarchy';

    public static final String REQUEST_TEMPLATE_MIGRATION = 'On_boarding_Migration_Request';
    public static final String REQUEST_TEMPLATE_HIERARCHY_CHANGE = 'On_boarding_Hierarchy_Change_Request';
    public static final String REQUEST_TEMPLATE_NEW_CLIENT  = 'Onboarding_Submitted_to_Goldtier';

    public static String determineOnboardingRequestType(OnboardingApplication application) {
        String requestType = '';
        try {
            if (application.legalEntity.salesforceId <> null) {
                List<Account> parentEntities = new SEL_Accounts().selectByCIFNumber(new Set<String> {application.legalEntity.parentEntityCIF} );
                Account parentEntity = parentEntities.size() > 0 ? parentEntities[0] : null;
                List<Account> newEntities = new SEL_Accounts().selectById(new Set<Id> {application.legalEntity.salesforceId} );
                Account newEntity = newEntities.size() > 0 ? newEntities[0] : null;
                if (parentEntity.Primary_Relationship_Holder__c <> newEntity.Primary_Relationship_Holder__c) {
                    requestType = OnboardingApplicationService.REQUEST_TYPE_MIGRATION;
                } else if (parentEntity.Group_Parent_CIF_Number__c <> newEntity.Group_Parent_CIF_Number__c) {
                    requestType = OnboardingApplicationService.REQUEST_TYPE_HIERARCHY_CHANGE;
                }
            } else {
                requestType = OnboardingApplicationService.REQUEST_TYPE_NEW_CLIENT;
            }
        } catch (exception e) {
            throw new OnboardingApplicationServiceException('Unable to process request. ' + e.getMessage() +e.getStackTraceString());
        }
        return requestType;
    }
 
    public static void sendRequestNotificationEmail(Id clientId, String newParentCIF, String submittedBy, String requestType) {
        SB_Parameters__c crmHelpdeskEmail = SB_Parameters__c.getValues(CRM_HELPDESK_PARAMETER_NAME);
        List<String> toAddress = new List<String>();
        if (crmHelpdeskEmail != null) toAddress.add(crmHelpdeskEmail.Value__c);

        Messaging.SingleEmailMessage email;

        List<Account> topParent = new SEL_Accounts().selectByCIFNumber(new Set<String>{ newParentCIF });
        Set<Id> notificationUserIdSet = new Set<Id>();
        notificationUserIdSet.add(topParent[0].OwnerId);
        for (AccountTeamMember notificationMember : new SEL_AccountTeams().selectByAccountIdAndTeamMemberRole(new Set<Id>{ topParent[0].Id ,clientId } , new Set<string>{'Transaction Solutions Manager',''
        }) ){
            notificationUserIdSet.add(notificationMember.UserId);
        }
        for (User notificationUser : new SEL_Users().selectById(notificationUserIdSet)){
            toAddress.add(notificationUser.Email);
        }
        List<Account> relevantClient = new SEL_Accounts().selectById(new Set<Id>{ clientId });
        // TODO: Remember to define workflow on case closed

        if (toAddress.size() > 0) {
            String requestTemplate;
            switch on requestType {
                when 'Onboarding' {
                    requestTemplate = OnboardingApplicationService.REQUEST_TEMPLATE_MIGRATION;
                }
                when 'Hierarchy' {
                    requestTemplate = OnboardingApplicationService.REQUEST_TEMPLATE_NEW_CLIENT;
                }
                when 'Migration' {
                        requestTemplate = OnboardingApplicationService.REQUEST_TEMPLATE_HIERARCHY_CHANGE;
                }
                when else {
                    throw new OnboardingApplicationServiceException('Unable to process request. No valid request type defined');
                }
            }
            List<EmailTemplate> emailTemplates = [SELECT Subject, Body FROM EmailTemplate  WHERE DeveloperName = :requestTemplate];
            if (!emailTemplates.isEmpty()) {

                email = new Messaging.SingleEmailMessage();

                EmailTemplate emailTemplate = emailTemplates[0];

                List<String> bodyMergeFields = new List<String>();
                switch on requestType {
                    when 'Onboarding' {
                        bodyMergeFields.add(relevantClient[0].Name);
                        bodyMergeFields.add(relevantClient[0].Professional_or_Non_Professional_Client__c);
                        bodyMergeFields.add(relevantClient[0].Client_Sector__c);
                        bodyMergeFields.add(relevantClient[0].Client_Sub_Sector__c);
                        bodyMergeFields.add(relevantClient[0].Industry_Code__c);
                        bodyMergeFields.add(topParent[0].Name);
                        bodyMergeFields.add(topParent[0].CIF__c);
                        bodyMergeFields.add(topParent[0].Id);
                        bodyMergeFields.add(submittedBy);
                    }
                    when 'Hierarchy', 'Migration' {
                        bodyMergeFields.add(relevantClient[0].Name);
                        bodyMergeFields.add(relevantClient[0].CIF__c);
                        bodyMergeFields.add(relevantClient[0].Id);
                        bodyMergeFields.add(topParent[0].Name);
                        bodyMergeFields.add(topParent[0].CIF__c);
                        bodyMergeFields.add(topParent[0].Id);
                        bodyMergeFields.add(submittedBy);
                    }
                    when else {
                        throw new OnboardingApplicationServiceException('Unable to process request. No valid request type defined');
                    }
                }

                String emailBody = String.format(emailTemplate.Body, bodyMergeFields);

                String subject = String.format(emailTemplate.Subject, new List<String>{ relevantClient[0].Name });

                email.setSubject(subject);
                email.setPlainTextBody(emailBody);
                email.setToAddresses(toAddress);

                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        email
                });
            }
        } else {
            throw new OnboardingApplicationServiceException('Unable to process request. No defined recipients at CRM Helpdesk, CC or TB: ');
        }
    }

    public static List<Account> processOnboardingRequest(OnboardingApplication application, String requestType) {

        try {
            Account topParent;
            Account submittedClient;
            Onboarding_Application__c app = new Onboarding_Application__c();

            if (application.id != null) {

                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[]{
                                Account.SObjectType,
                                Onboarding_Application__c.SObjectType,
                                Contact.SObjectType,
                                Related_Party__c.SObjectType,
                                Application_Document__c.SObjectType
                        },  new  fflib_SObjectUnitOfWork.BypassDuplicateRulesDML()
                );

                //Cyclic related record support for KYC Contact related to Account
                fflib_SObjectUnitOfWork uowKYCContact = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[]{
                                Account.SObjectType,
                                Contact.SObjectType
                        }
                );

                //APPLICATION
                app.Application_Id__c = application.id;
                app.Requested_By__c = application.requester.requestedBy;
                app.Requester_Number__c = application.requester.requesterNumber;
                app.Primary_Data_Source__c = application.legalEntity.primaryDataSource;
                app.Request_Type__c = requestType;

                List<Account> parent = new SEL_Accounts().selectByCIFNumber(new Set<String> {application.legalEntity.parentEntityCIF});
                //hotfix C-00002609  - if parent is child in sf select its parent as parent for new entity
                if (parent[0].RecordTypeId == AccountService.RECORD_TYPE_CHILD){
                    parent = new SEL_Accounts().selectById(new Set<Id> {parent[0].ParentId});
                }
                Set<Id> topParentIds = new SEL_Accounts().selectTopParentIdByChildId(new Set<Id> {parent[0].Id});
                List<Account> topParents = new SEL_Accounts().selectById(topParentIds);

                if (topParents.size() > 0){
                    topParent = topParents[0];
                }

                List<Account> existingClients = new SEL_Accounts().selectByRegistrationNumber( new Set<String> { application.legalEntity.registrationNumber });

                if ( existingClients.size() > 0 && requestType == OnboardingApplicationService.REQUEST_TYPE_NEW_CLIENT) {
                    throw new OnboardingApplicationServiceException('Unable to process request. Client / Prospect already exists with reg number: '+application.legalEntity.registrationNumber);
                }
                if (requestType == OnboardingApplicationService.REQUEST_TYPE_NEW_CLIENT) {

                    submittedClient = new Account(
                            Registration_Number__c = application.legalEntity.registrationNumber,
                            Name = application.legalEntity.registeredName,
                            VAT_Number__c = application.legalEntity.vatNumber,
                            Phone_Number__c = application.legalEntity.telephoneNumber,
                            Industry_Code__c = application.legalEntity.sic == null ? topParent.Industry_Code__c : application.legalEntity.sic,
                            AnnualRevenue = application.legalEntity.annualTurnover,
                            High_Risk_Business__c = application.legalEntity.natureOfBusiness.toUpperCase() == 'OTHER' ? 'No' : application.legalEntity.natureOfBusiness,
                            Business_Classification__c = application.legalEntity.businessClassification,
                            Client_Type_OnBoard__c = application.legalEntity.clientType,
                            Country_of_Revenue__c = application.legalEntity.countryOfRevenue,
                            Entity_Actively_Trade__c = application.legalEntity.entityActive ? 'Yes' : 'No',
                            ParentId = parent[0].Id,
                            Immediate_Parent__c = parent[0].Id,
                            Relationship_Roles__c = application.legalEntity.relationshipRole,
                            Country_of_Operation__c = application.legalEntity.countryOfOperation,
                            KYC_Location__c = application.legalEntity.kycLocation,
                            BillingStreet = application.legalEntity.registeredAddress.street,
                            Registered_Suburb__c = application.legalEntity.registeredAddress.suburb,
                            BillingState = application.legalEntity.registeredAddress.province,
                            BillingCity = application.legalEntity.registeredAddress.city,
                            BillingPostalCode = application.legalEntity.registeredAddress.postalCode,
                            BillingCountry = application.legalEntity.registeredAddress.country,
                            Correspondence_Addr_Line1__c = application.legalEntity.physicalAddress.street,
                            Correspondence_Addr_Line2__c = application.legalEntity.physicalAddress.suburb,
                            Correspondence_Province_Region__c = application.legalEntity.physicalAddress.province,
                            Correspondence_City__c = application.legalEntity.physicalAddress.city,
                            Correspondence_Postal_Code__c = application.legalEntity.physicalAddress.postalCode,
                            Correspondence_Country__c = application.legalEntity.physicalAddress.country,
                            Client_contacted_in_person__c = 'No',
                            Professional_or_Non_Professional_Client__c = topParent.Professional_or_Non_Professional_Client__c == null ? 'Professional' : topParent.Professional_or_Non_Professional_Client__c,
                            Client_Sector__c = topParent.Client_Sector__c,
                            Client_Sub_Sector__c = topParent.Client_Sub_Sector__c,
                            Proposed_Group_Parent__c = topParent.Id,
                            Client_Relationship_Hierarchy__c = AccountService.RECORD_TYPE_NAME_CHILD, // Rules dictates that the client will always be added as child to the parent.
                            Primary_Relationship_Holder__c = topParent.Primary_Relationship_Holder__c,
                            OwnerId = topParent.OwnerId,
                            Client_Co_ordinator__c = topParent.OwnerId,
                            Services_Products_Expected_or_currently__c = 'Business Current Account',
                            Source_of_Funds_Type__c = 'Profit from Business Activity',
                            RecordTypeId = AccountService.RECORD_TYPE_POTENTIAL_GT
                    );

                    uow.registerNew(submittedClient);

                } else { //Migration or Hierarchy change
                    //Link app to existing Client
                    Set<Id> existingClientIds = new Set<Id>();
                    existingClientIds.add((Id)application.legalEntity.salesforceId);
                    List<Account> existingClientRecords = new SEL_Accounts().selectById(existingClientIds);
                    if (existingClientRecords.size() == 1) {
                        submittedClient = existingClientRecords[0];
                    } else {
                        throw new OnboardingApplicationServiceException('Unable to process request. Failed to find client with salesforceId: '+application.legalEntity.salesforceId);
                    }
                }
                uow.registerNew(app, Onboarding_Application__c.Client__c, submittedClient);
                uow.registerRelationship(app, Onboarding_Application__c.Client__c, submittedClient);


                // SUPPORTING DOCUMENTS - Entity
                if (application.legalEntity.entityDocuments != null) {
                    for (Integer i = 0; i < application.legalEntity.entityDocuments.size(); i++) {
                        if (application.legalEntity.entityDocuments.get(i).documentId != null) {
                            Application_Document__c ad = new Application_Document__c(
                                    Document_Status__c = application.legalEntity.entityDocuments.get(i).verified == true ? 'Verified' : 'Unverified',
                                    Document_Type__c = application.legalEntity.entityDocuments.get(i).documentType,
                                    FileNet_Id__c = application.legalEntity.entityDocuments.get(i).documentId
                            );
                            uow.registerNew(ad, Application_Document__c.Onboarding_Application__c, app);
                        }
                    }
                }

                //RELATED PARTIES
                for (Integer i = 0; i < application.legalEntity.relatedParties.size(); i++) {
                    if (application.legalEntity.relatedParties.get(i).actionType <> 'NONE') {
                        Related_Party__c rp = new Related_Party__c(
                                Type__c = application.legalEntity.relatedParties.get(i).businessType,
                                Last_Name__c = application.legalEntity.relatedParties.get(i).lastName,
                                Contact_Number__c = application.legalEntity.relatedParties.get(i).contactNumber,
                                Email_Address__c = application.legalEntity.relatedParties.get(i).emailAddress,
                                Shareholding_Percentage__c = application.legalEntity.relatedParties.get(i).sharePercentage,
                                Capacity__c = application.legalEntity.relatedParties.get(i).capacity,
                                Registration_Number__c = application.legalEntity.relatedParties.get(i).registrationNumber,
                                Registered_Name__c = application.legalEntity.relatedParties.get(i).registeredName,
                                Registered_Address__c = application.legalEntity.relatedParties.get(i).registeredAddress,
                                Head_Office_Address__c = application.legalEntity.relatedParties.get(i).headOfficeAddress,
                                Physical_Address__c = application.legalEntity.relatedParties.get(i).physicalAddress,
                                Action_Type__c = application.legalEntity.relatedParties.get(i).actionType
                        );
                        if (rp.Last_Name__c == null) {
                            rp.Type__c = 'Juristic Entity';
                        } else {
                            // Natural Person - First Name is passed as registeredName and IdentityNumber as RegistrationNumber for individuals
                            rp.First_Name__c = application.legalEntity.relatedParties.get(i).registeredName;
                            rp.Identity_Number__c = application.legalEntity.relatedParties.get(i).registrationNumber;
                            rp.Type__c = 'Natural Person';
                        }
                        uow.registerNew(rp, Related_Party__c.Onboarding_Application__c, app);

                        // SUPPORTING DOCUMENTS
                        if (application.legalEntity.relatedParties.get(i).supportingDocuments != null) {
                            //Application_Document__c
                            for (Integer j = 0; j < application.legalEntity.relatedParties.get(i).supportingDocuments.size(); j++) {
                                if (application.legalEntity.relatedParties.get(i).supportingDocuments.get(j).documentId != null) {
                                    Application_Document__c ad = new Application_Document__c(
                                            Document_Status__c = application.legalEntity.relatedParties.get(i).supportingDocuments.get(j).verified == true ? 'Verified' : 'Unverified',
                                            Document_Type__c = application.legalEntity.relatedParties.get(i).supportingDocuments.get(j).documentType,
                                            FileNet_Id__c = application.legalEntity.relatedParties.get(i).supportingDocuments.get(j).documentId
                                    );
                                    uow.registerNew(ad, Application_Document__c.Onboarding_Application__c, app);
                                    uow.registerRelationship(ad, Application_Document__c.Related_Party__c, rp);
                                }
                            }
                        }
                    }
                }

                for (Integer i = 0; i < application.legalEntity.authorisers.size(); i++) {

                    Contact authP = new Contact(
                            RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_CLIENT),
                            Contact_Role_s_at_Client__c = DMN_Contact.CONTACT_ROLE_AUTHORISED_PERSON,
                            FirstName = application.legalEntity.authorisers.get(i).firstName,
                            LastName = application.legalEntity.authorisers.get(i).lastName,
                            Identity_Number__c = application.legalEntity.authorisers.get(i).idNumber,
                            Phone = application.legalEntity.authorisers.get(i).contactNumber,
                            Email = application.legalEntity.authorisers.get(i).emailAddress,
                            MailingStreet = application.legalEntity.authorisers.get(i).address.street,
                            MailingCity = application.legalEntity.authorisers.get(i).address.city,
                            MailingState = application.legalEntity.authorisers.get(i).address.province,
                            MailingCountry = application.legalEntity.authorisers.get(i).address.country,
                            MailingPostalCode = application.legalEntity.authorisers.get(i).address.postalCode,
                            Phone_Country__c = 'South Africa',
                            Contact_Category__c = DMN_Contact.CONTACT_ROLE_AUTHORISED_PERSON
                    );
                    uow.registerNew(authP, Contact.AccountId, submittedClient);

                    // SUPPORTING DOCUMENTS
                    if (application.legalEntity.authorisers.get(i).authoriserDocuments != null) {
                        //Application_Document__c
                        for (Integer j = 0; j < application.legalEntity.authorisers.get(i).authoriserDocuments.size(); j++) {
                            if (application.legalEntity.authorisers.get(i).authoriserDocuments.get(j).documentId != null) {
                                Application_Document__c ad = new Application_Document__c(
                                        Document_Status__c = application.legalEntity.authorisers.get(i).authoriserDocuments.get(j).verified == true ? 'Verified' : 'Unverified',
                                        Document_Type__c = application.legalEntity.authorisers.get(i).authoriserDocuments.get(j).documentType,
                                        FileNet_Id__c = application.legalEntity.authorisers.get(i).authoriserDocuments.get(j).documentId
                                );
                                uow.registerNew(ad, Application_Document__c.Onboarding_Application__c, app);
                                uow.registerRelationship(ad, Application_Document__c.Authorised_Person__c, authP);
                            }
                        }
                    }
                }

                //KYC Contact - Only for new Clients or if not existing on client
                Contact kycContact;
                List<Contact> kycContacts = new List<Contact>();

                if (requestType <> OnboardingApplicationService.REQUEST_TYPE_NEW_CLIENT) {
                    kycContacts = new SEL_Contacts().selectKYCContactByAccountId(new Set<Id> {submittedClient.Id});
                }

                if (kycContacts.size() == 0) {

                    kycContact = new Contact(
                            RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_CLIENT),
                            Contact_Role_s_at_Client__c = DMN_Contact.CONTACT_ROLE_KYC_CONTACT,
                            FirstName = application.legalEntity.kycContact.firstName,
                            LastName = application.legalEntity.kycContact.lastName,
                            Phone = application.legalEntity.kycContact.contactNumber,
                            Email = application.legalEntity.kycContact.email,
                            Phone_Country__c = 'South Africa',
                            Contact_Category__c = DMN_Contact.CONTACT_ROLE_KYC_CONTACT,
                            OwnerId = topParent.OwnerId
                    );
                    uow.registerNew(kycContact, Contact.AccountId, submittedClient);
                }

                //Commit Application
                uow.commitWork();

                //Link Client to KYC Contact
                List<Account> committedProspectRecords = new SEL_Accounts().selectByRegistrationNumber(new Set<String>{ application.legalEntity.registrationNumber });
                if (committedProspectRecords.size() == 0) {
                    throw new OnboardingApplicationServiceException('Unable to  process request. Failed to create Prospect record.');
                }
                kycContacts = new SEL_Contacts().selectKYCContactByAccountId(new Set<Id>{committedProspectRecords[0].Id});
                if (kycContacts.size() > 0) {
                    committedProspectRecords[0].KYC_Contact__c = kycContacts[0].Id;
                    uowKYCContact.registerDirty(committedProspectRecords[0]);
                    uowKYCContact.commitWork();
                } else {
                    throw new OnboardingApplicationServiceException('Unable to process request. KYC Contact could not be added');
                }
            }

    } catch (exception e) {
        throw new OnboardingApplicationServiceException('Unable to  process request. ' + e.getMessage() +e.getStackTraceString());
    }
        return new SEL_Accounts().selectByRegistrationNumber(new Set<String> {application.legalEntity.registrationNumber});
    }

    public class OnboardingApplicationServiceException extends Exception {
    }

}