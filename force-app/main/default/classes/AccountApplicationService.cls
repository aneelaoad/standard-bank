/**.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* Account Application Service Layer
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Caro Reinecke
* @version        1.0
* @created        2018-01-08
* @systemLayer    Service ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ApexDoc,PMD.LocalVariableNamingConventions')
public with sharing class AccountApplicationService {

    public static void syncAccountApplication(AccountApplication.AOBApplication objResponseBody) {

        try {
            Id appId = null;
            Boolean newApp = false;

            if (objResponseBody.id != null) {

                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[]{
                                Account_Application__c.SObjectType,
                                Authorised_Signatory__c.SObjectType,
                                KYC_Maintenance_Request__c.SObjectType,
                                Related_Party__c.SObjectType,
                                Product_Terms_Accepted__c.SObjectType,
                                Application_Document__c.SObjectType
                        }
                );

                List<Account_Application__c> aa = new SEL_AccountApplications().selectByApplicationId(new Set<Decimal>{
                        objResponseBody.id
                });

                Account_Application__c app;

                //If application exists delete children records and update application object
                if (aa.size() == 1) {

                    //Get Account Application Salesforce ID
                    appId = aa[0].id;


                    //KYC_Maintenance_Request__c
                    List<KYC_Maintenance_Request__c> kycRequest = new SEL_KYCMaintenanceRequests().selectByAccountApplicationId(new Set<Id>{
                            appId
                    });
                    if (kycRequest.size() > 0) {
                        uow.registerDeleted(kycRequest[0]);
                    }

                    //Related_Party__c
                    List<Related_Party__c> relParties = new SEL_RelatedParties().selectByAccountApplicationId(new Set<Id>{
                            appId
                    });
                    for (Related_Party__c relatedParty : relParties) {
                        uow.registerDeleted(relatedParty);
                    }

                    //Authorised_Signatory__c
                    List<Authorised_Signatory__c> authorizedSignatories = new SEL_AuthorisedSignatories().selectByAccountApplicationId(new Set<Id>{
                            appId
                    });
                    for (Authorised_Signatory__c authorizedSignatory : authorizedSignatories) {
                        uow.registerDeleted(authorizedSignatory);
                    }

                    //Product_Terms_Accepted__c
                    List<Product_Terms_Accepted__c> productTerms = new SEL_ProductTermsAccepted().selectByAccountApplicationId(new Set<Id>{
                            appId
                    });
                    for (Product_Terms_Accepted__c productTermAccepted : productTerms) {
                        uow.registerDeleted(productTermAccepted);
                    }

                    //Application_Document__c
                    List<Application_Document__c> appDocuments = new SEL_ApplicationDocuments().selectByAccountApplicationId(new Set<Id>{
                            appId
                    });

                    for (Application_Document__c appDocument : appDocuments) {
                        uow.registerDeleted(appDocument);
                    }
                }

                //New Application or Update existing Application
                if (appId == null) {
                    // New Application
                    app = new Account_Application__c();
                    newApp = true;
                } else {
                    // Existing Application
                    app = aa[0];
                }

                //APPLICATION
                app.OnboardingApplicationID__c = objResponseBody.id;
                app.Requested_By__c = objResponseBody.requester.requestedBy;
                app.Requester_Number__c = objResponseBody.requester.requesterNumber;

                //LEGAL ENTITY
                if ((objResponseBody.legalEntity.salesforceId == null) || (objResponseBody.legalEntity.salesforceId == '')) {
                    if ((objResponseBody.legalEntity.cif == null) || (objResponseBody.legalEntity.cif == '')) {
                        throw new AccountApplicationServiceException('Unable to sync account application. No CIF Number provided!');
                    } else {
                        List<Account> client = new SEL_Accounts().selectByCIFNumber(new Set<String>{objResponseBody.legalEntity.cif });
                        if (client.size() == 0) {
                            throw new AccountApplicationServiceException('Unable to sync account application. Client with CIF: ' + objResponseBody.legalEntity.cif + 'not found in Salesforce!');
                        } else {
                            app.Client__c = client[0].Id;
                        }
                    }

                } else {
                    app.Client__c = objResponseBody.legalEntity.salesforceId;
                }


                //BANK ACCOUNT
                app.Bank_Account_Type__c = objResponseBody.bankAccount.accountType;
                app.Bank_Account_Number__c = objResponseBody.bankAccount.accountNumber;
                app.Branch_Code__c = objResponseBody.bankAccount.branchCode;
                app.Bank_Account_Active__c = objResponseBody.bankAccount.active;

                //PREFERENCES
                app.Bank_Account_Name__c = objResponseBody.bankAccount.preferences.accountName;
                app.Statement_Delivery_Frequency__c = objResponseBody.bankAccount.preferences.statementDeliveryFrequency;
                app.Statement_Delivery_Method__c = objResponseBody.bankAccount.preferences.statementDeliveryMethod;
                app.Statement_Delivery_Destination__c = objResponseBody.bankAccount.preferences.deliveryDestination;

                //TODO: This part of the application still needs to be defined - Ignoring it for MVP
                //ADDITIONAL PRODUCTS REQUIRED
                for (Integer i = 0; i < objResponseBody.AdditionalProductsRequired.size(); i++) {
                    if (objResponseBody.AdditionalProductsRequired.get(i).id == 'Cash Management') {
                        app.Cash_Management__c = true;
                        app.CashMan_Group_No__c = objResponseBody.additionalProductsRequired.get(i).cashManGroupNumber;
                    }
                    if (objResponseBody.AdditionalProductsRequired.get(i).id == 'Business Online') {
                        app.Business_Online__c = true;
                        app.BOL_Profile_Id__c = objResponseBody.additionalProductsRequired.get(i).bolProfileId;
                    }
                }

                //PRODUCT
                app.Product_Name__c = objResponseBody.product.name;

                //CONFIRMED ENTITY DETAILS
                app.Entity_Details_Confirmed__c = objResponseBody.confirmedEntityDetails;

                //CONFIRMED ACCOUNT DETAILS
                app.Account_Details_Confirmed__c = objResponseBody.confirmedAccountDetails;

                if (newApp) {
                    uow.registerNew(app);
                } else {
                    uow.registerDirty(app);
                }

                KYC_Maintenance_Request__c rr = new KYC_Maintenance_Request__c(
                        TradingAs__c = objResponseBody.legalEntity.tradingAs,
                        Entity_Registration_Number__c = objResponseBody.legalEntity.registrationNumber,
                        Registered_Name__c = objResponseBody.legalEntity.registeredName,
                        VAT_Number__c = objResponseBody.legalEntity.vatNumber,
                        Telephone_Number__c = objResponseBody.legalEntity.telephoneNumber,
                        Registered_Address_Line_1__c = objResponseBody.legalEntity.address.registeredAddress,
                        Registered_Address_Line_2__c = objResponseBody.legalEntity.address.line2,
                        Registered_Province__c = objResponseBody.legalEntity.address.province,
                        Registered_City__c = objResponseBody.legalEntity.address.registeredCity,
                        Registered_Postal_Code__c = objResponseBody.legalEntity.address.postalCode,
                        Registered_Country__c = objResponseBody.legalEntity.address.country,
                        Annual_Turnover__c = objResponseBody.legalEntity.annualTurnover,
                        Changes_Made__c = objResponseBody.fieldChanges,
                        Status__c = objResponseBody.fieldChanges == null ? null : 'New'
                );
                uow.registerNew(rr, KYC_Maintenance_Request__c.Account_Application__c, app);

                // SUPPORTING DOCUMENTS
                if (objResponseBody.legalEntity.supportingDocuments != null) {
                    for (Integer i = 0; i < objResponseBody.legalEntity.supportingDocuments.size(); i++) {
                        if (objResponseBody.legalEntity.SupportingDocuments.get(i).documentId != null) {
                            Application_Document__c ad = new Application_Document__c(
                                    Document_Status__c = objResponseBody.legalEntity.SupportingDocuments.get(i).verified == true ? 'Verified' : 'Unverified',
                                    Document_Type__c = objResponseBody.legalEntity.SupportingDocuments.get(i).documentType,
                                    FileNet_Id__c = objResponseBody.legalEntity.SupportingDocuments.get(i).documentId
                            );
                            uow.registerNew(ad, Application_Document__c.Account_Application__c, app);
                        }
                    }
                }

                //RELATED PARTIES
                for (Integer i = 0; i < objResponseBody.legalEntity.relatedParties.size(); i++) {
                    if (objResponseBody.legalEntity.relatedParties.get(i).actionType <> 'NONE') {
                        Related_Party__c rp = new Related_Party__c(
                                Type__c = objResponseBody.legalEntity.relatedParties.get(i).businessType,
                                Last_Name__c = objResponseBody.legalEntity.relatedParties.get(i).lastName,
                                Contact_Number__c = objResponseBody.legalEntity.relatedParties.get(i).contactNumber,
                                Email_Address__c = objResponseBody.legalEntity.relatedParties.get(i).emailAddress,
                                Shareholding_Percentage__c = objResponseBody.legalEntity.relatedParties.get(i).sharePercentage,
                                Capacity__c = objResponseBody.legalEntity.relatedParties.get(i).capacity,
                                Registration_Number__c = objResponseBody.legalEntity.relatedParties.get(i).registrationNumber,
                                Registered_Name__c = objResponseBody.legalEntity.relatedParties.get(i).registeredName,
                                Registered_Address__c = objResponseBody.legalEntity.relatedParties.get(i).registeredAddress,
                                Head_Office_Address__c = objResponseBody.legalEntity.relatedParties.get(i).headOfficeAddress,
                                Physical_Address__c = objResponseBody.legalEntity.relatedParties.get(i).physicalAddress,
                                GoldTier_Id__c = objResponseBody.legalEntity.relatedParties.get(i).goldTierId == null ? '' : objResponseBody.legalEntity.relatedParties.get(i).goldTierId.format(),
                                Action_Type__c = objResponseBody.legalEntity.relatedParties.get(i).actionType
                        );
                        if (rp.Last_Name__c == null) {
                            rp.Type__c = 'Juristic Entity';
                        } else {
                            // Natural Person - First Name is passed as registeredName and IdentityNumber as RegistrationNumber for individuals
                            rp.First_Name__c = objResponseBody.legalEntity.relatedParties.get(i).registeredName;
                            rp.Identity_Number__c = objResponseBody.legalEntity.relatedParties.get(i).registrationNumber;
                            rp.Type__c = 'Natural Person';
                        }
                        uow.registerNew(rp, Related_Party__c.Account_Application__c, app);

                        // SUPPORTING DOCUMENTS
                        if (objResponseBody.legalEntity.relatedParties.get(i).SupportingDocuments != null) {
                            //Application_Document__c
                            for (Integer j = 0; j < objResponseBody.legalEntity.relatedParties.get(i).SupportingDocuments.size(); j++) {
                                if (objResponseBody.legalEntity.relatedParties.get(i).SupportingDocuments.get(j).documentId != null) {
                                    Application_Document__c ad = new Application_Document__c(
                                            Document_Status__c = objResponseBody.legalEntity.relatedParties.get(i).SupportingDocuments.get(j).verified == true ? 'Verified' : 'Unverified',
                                            Document_Type__c = objResponseBody.legalEntity.relatedParties.get(i).SupportingDocuments.get(j).documentType,
                                            FileNet_Id__c = objResponseBody.legalEntity.relatedParties.get(i).SupportingDocuments.get(j).documentId
                                    );
                                    uow.registerNew(ad, Application_Document__c.Account_Application__c, app);
                                    uow.registerRelationship(ad, Application_Document__c.Related_Party__c, rp);
                                }
                            }
                        }
                    }
                }

                //SIGNATORIES
                for (Integer i = 0; i < objResponseBody.bankAccount.signatories.size(); i++) {

                    Authorised_Signatory__c authS = new Authorised_Signatory__c(
                            First_Name__c = objResponseBody.bankAccount.signatories.get(i).firstName,
                            Last_Name__c = objResponseBody.bankAccount.signatories.get(i).lastName,
                            Identity_Number__c = objResponseBody.bankAccount.signatories.get(i).idNumber,
                            Contact_Number__c = objResponseBody.bankAccount.signatories.get(i).contactNumber,
                            Email_Address__c = objResponseBody.bankAccount.signatories.get(i).emailAddress,
                            Signing_Limits__c = objResponseBody.bankAccount.signatories.get(i).signingLimits,
                            Signing_Arrangements__c = objResponseBody.bankAccount.signatories.get(i).signingArrangements
                    );
                    uow.registerNew(authS, Authorised_Signatory__c.Account_Application__c, app);

                    // SUPPORTING DOCUMENTS
                    if (objResponseBody.bankAccount.signatories.get(i).SupportingDocuments != null) {
                        //Application_Document__c
                        for (Integer j = 0; j < objResponseBody.bankAccount.signatories.get(i).SupportingDocuments.size(); j++) {
                            if (objResponseBody.bankAccount.signatories.get(i).SupportingDocuments.get(j).documentId != null) {
                                Application_Document__c ad = new Application_Document__c(
                                        Document_Status__c = objResponseBody.bankAccount.signatories.get(i).SupportingDocuments.get(j).verified == true ? 'Verified' : 'Unverified',
                                        Document_Type__c = objResponseBody.bankAccount.signatories.get(i).SupportingDocuments.get(j).documentType,
                                        FileNet_Id__c = objResponseBody.bankAccount.signatories.get(i).SupportingDocuments.get(j).documentId
                                );
                                uow.registerNew(ad, Application_Document__c.Account_Application__c, app);
                                uow.registerRelationship(ad, Application_Document__c.Authorised_Signatory__c, authS);
                            }
                        }
                    }
                }

                //ACCEPTED TERMS
                for (Integer i = 0; i < objResponseBody.acceptedTerms.size(); i++) {

                    Product_Terms_Accepted__c pta = new Product_Terms_Accepted__c(
                            Term_Name__c = objResponseBody.acceptedTerms.get(i).term.name,
                            Term_Title__c = objResponseBody.acceptedTerms.get(i).term.title,
                            Term_URL__c = objResponseBody.acceptedTerms.get(i).term.url
                    );
                    uow.registerNew(pta, Product_Terms_Accepted__c.Account_Application__c, app);
                }

                //Commit Application
                uow.commitWork();
            }

        } catch (exception e) {
            throw new AccountApplicationServiceException('Unable to sync account application. ' + e.getMessage() +e.getStackTraceString());
        }

    }
    public class AccountApplicationServiceException extends Exception {
    }
}