/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* JSON Parser class for the Account Application payload.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Caro Reinecke
* @version        1.0
* @created        2018-01-08
* @systemLayer    Utility ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class AccountApplication {

    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT ||
                    curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT ||
                    curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    global class AOBApplication {
        public String createdAt {get;set;}
        public String modifiedAt {get;set;}
        public Integer id {get;set;}
        public LegalEntity legalEntity {get;set;}
        public BankAccount bankAccount {get;set;}
        public List<AdditionalProductsRequired> additionalProductsRequired {get;set;}
        public List<AcceptedTerms> acceptedTerms {get;set;}
        public Product product {get;set;}
        public Boolean confirmedEntityDetails {get;set;}
        public Boolean confirmedAccountDetails {get;set;}
        public String fieldChanges {get;set;}
        public ContactPerson requester {get;set;}

        public AOBApplication(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'modifiedAt') {
                            modifiedAt = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'legalEntity') {
                            legalEntity = new LegalEntity(parser);
                        } else if (text == 'bankAccount') {
                            bankAccount = new BankAccount(parser);
                        } else if (text == 'additionalProductsRequired') {
                            additionalProductsRequired = new List<AdditionalProductsRequired>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                additionalProductsRequired.add(new AdditionalProductsRequired(parser));
                            }
                        } else if (text == 'acceptedTerms') {
                            acceptedTerms = new List<AcceptedTerms>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                acceptedTerms.add(new AcceptedTerms(parser));
                            }
                        } else if (text == 'product') {
                            product = new Product(parser);
                        } else if (text == 'confirmedEntityDetails') {
                            confirmedEntityDetails = parser.getBooleanValue();
                        } else if (text == 'confirmedAccountDetails') {
                            confirmedAccountDetails = parser.getBooleanValue();
                        } else if (text == 'fieldChanges') {
                            fieldChanges = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class LegalEntity {
        public String salesforceId {get;set;}
        public String cif {get;set;}
        public String tradingAs {get;set;}
        public String registrationNumber {get;set;}
        public String vatNumber {get;set;}
        public String registeredName {get;set;}
        public String telephoneNumber {get;set;}
        public Address address {get;set;}
        public List<RelatedParties> relatedParties {get;set;}
        public List<SupportingDocuments> supportingDocuments {get;set;}
        public Decimal annualTurnover {get;set;}

        public LegalEntity(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'salesforceId') {
                            salesforceId = parser.getText();
                        } else if (text == 'cif') {
                            cif = parser.getText();
                        } else if (text == 'annualTurnover') {
                            annualTurnover = parser.getDecimalValue();
                        } else if (text == 'tradingAs') {
                            tradingAs = parser.getText();
                        } else if (text == 'registrationNumber') {
                            registrationNumber = parser.getText();
                        } else if (text == 'vatNumber') {
                            vatNumber = parser.getText();
                        } else if (text == 'registeredName') {
                            registeredName = parser.getText();
                        } else if (text == 'address') {
                            address = new Address(parser);
                        } else if (text == 'telephoneNumber') {
                            telephoneNumber = parser.getText();
                        } else if (text == 'relatedParties') {
                            relatedParties = new List<RelatedParties>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                relatedParties.add(new RelatedParties(parser));
                            }
                        } else if (text == 'supportingDocuments') {
                            supportingDocuments = new List<SupportingDocuments>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                supportingDocuments.add(new SupportingDocuments(parser));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'LegalEntity consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Address {
        public String registeredAddress {get;set;}
        public String line2 {get;set;}
        public String province {get;set;}
        public String registeredCity {get;set;}
        public String postalCode {get;set;}
        public String country {get;set;}

        public Address(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'registeredAddress') {
                            registeredAddress = parser.getText();
                        } else if (text == 'line2') {
                            line2 = parser.getText();
                        } else if (text == 'province') {
                            province = parser.getText();
                        } else if (text == 'registeredCity') {
                            registeredCity = parser.getText();
                        } else if (text == 'postalCode') {
                            postalCode = parser.getText();
                        } else if (text == 'country') {
                            country = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Address consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class AcceptedTerms {
        public String createdAt {get;set;}
        public String modifiedAt {get;set;}
        public Term term {get;set;}

        public AcceptedTerms(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'modifiedAt') {
                            modifiedAt = parser.getText();
                        } else if (text == 'term') {
                            term = new Term(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'AcceptedTerms consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Product {
        public String createdAt {get;set;}
        public String modifiedAt {get;set;}
        public String id {get;set;}
        public String name {get;set;}
        public String description {get;set;}
        public Integer openingDepositCents {get;set;}
        public Integer monthlyFeeCents {get;set;}
        public String access {get;set;}
        public List<Term> terms {get;set;}

        public Product(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'modifiedAt') {
                            modifiedAt = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'description') {
                            description = parser.getText();
                        } else if (text == 'openingDepositCents') {
                            openingDepositCents = parser.getIntegerValue();
                        } else if (text == 'monthlyFeeCents') {
                            monthlyFeeCents = parser.getIntegerValue();
                        } else if (text == 'access') {
                            access = parser.getText();
                        } else if (text == 'terms') {
                            terms = new List<Term>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                terms.add(new Term(parser));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'Product consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class SupportingDocuments {
        public String documentType {get;set;} // in json: type
        public String name {get;set;}
        public Boolean verified {get;set;}
        public String documentId {get;set;}

        public SupportingDocuments(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'documentType') {
                            documentType = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'verified') {
                            verified = parser.getBooleanValue();
                        } else if (text == 'documentId') {
                            documentId = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'SupportingDocuments consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class BankAccount {
        public String createdAt {get;set;}
        public String modifiedAt {get;set;}
        public String accountType {get;set;} // in json: type
        public String accountNumber {get;set;} // in json: number
        public String branchCode {get;set;}
        public Boolean active {get;set;}
        public List<Signatories> signatories {get;set;}
        public Preferences preferences {get;set;}

        public BankAccount(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'modifiedAt') {
                            modifiedAt = parser.getText();
                        } else if (text == 'accountType') {
                            accountType = parser.getText();
                        } else if (text == 'accountNumber') {
                            accountNumber = parser.getText();
                        } else if (text == 'branchCode') {
                            branchCode = parser.getText();
                        } else if (text == 'active') {
                            active = parser.getBooleanValue();
                        } else if (text == 'signatories') {
                            signatories = new List<Signatories>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                signatories.add(new Signatories(parser));
                            }
                        } else if (text == 'preferences') {
                            preferences = new Preferences(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'BankAccount consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Signatories {
        public String createdAt {get;set;}
        public String modifiedAt {get;set;}
        public String idNumber {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String contactNumber {get;set;}
        public String emailAddress {get;set;}
        public Integer signingLimits {get;set;}
        public String signingArrangements {get;set;}
        public String addressRv {get;set;}
        public List<SupportingDocuments> supportingDocuments {get;set;}

        public Signatories(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'modifiedAt') {
                            modifiedAt = parser.getText();
                        } else if (text == 'idNumber') {
                            idNumber = parser.getText();
                        } else if (text == 'firstName') {
                            firstName = parser.getText();
                        } else if (text == 'lastName') {
                            lastName = parser.getText();
                        } else if (text == 'contactNumber') {
                            contactNumber = parser.getText();
                        } else if (text == 'emailAddress') {
                            emailAddress = parser.getText();
                        } else if (text == 'signingLimits') {
                            signingLimits = parser.getIntegerValue();
                        } else if (text == 'signingArrangements') {
                            signingArrangements = parser.getText();
                        } else if (text == 'addressRv') {
                            addressRv = parser.getText();
                        } else if (text == 'supportingDocuments') {
                            supportingDocuments = new List<SupportingDocuments>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                supportingDocuments.add(new SupportingDocuments(parser));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'Signatories consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Term {
        public String createdAt {get;set;}
        public String modifiedAt {get;set;}
        public String name {get;set;}
        public String title {get;set;}
        public String url {get;set;}

        public Term(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'modifiedAt') {
                            modifiedAt = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'title') {
                            title = parser.getText();
                        } else if (text == 'url') {
                            url = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Term consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class AdditionalProductsRequired {
        public String id {get;set;}
        public String bolProfileId {get;set;}
        public String cashManGroupNumber {get;set;}

        public AdditionalProductsRequired(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'bolProfileId') {
                            bolProfileId = parser.getText();
                        } else if (text == 'cashManGroupNumber') {
                            cashManGroupNumber = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'AdditionalProductsRequired consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Preferences {
        public String accountName {get;set;}
        public String statementDeliveryFrequency {get;set;}
        public String statementDeliveryMethod {get;set;}
        public String deliveryDestination {get;set;}

        public Preferences(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'accountName') {
                            accountName = parser.getText();
                        } else if (text == 'statementDeliveryFrequency') {
                            statementDeliveryFrequency = parser.getText();
                        } else if (text == 'statementDeliveryMethod') {
                            statementDeliveryMethod = parser.getText();
                        } else if (text == 'deliveryDestination') {
                            deliveryDestination = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Preferences consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class RelatedParties {
        public String createdAt {get;set;}
        public String modifiedAt {get;set;}
        public Integer goldTierId {get;set;} // this is not the id/passport number
        public String businessType {get;set;} // populate with 'Juristic Entity' or 'Natural Person'
        public Integer sharePercentage {get;set;}
        public String lastName {get;set;}
        public String registrationNumber {get;set;}
        public String registeredName {get;set;}
        public String contactNumber {get;set;}
        public String capacity {get;set;}
        public String emailAddress {get;set;}
        public String registeredAddress {get;set;}
        public String headOfficeAddress {get;set;}
        public String physicalAddress {get;set;}
        public String actionType {get;set;} // {NONE; REMOVE; ADD; MODIFY; COPY;
        public List<SupportingDocuments> supportingDocuments {get;set;}

        public RelatedParties(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'createdAt') {
                            createdAt = parser.getText();
                        } else if (text == 'modifiedAt') {
                            modifiedAt = parser.getText();
                        } else if (text == 'goldTierId') {
                            goldTierId = parser.getIntegerValue();
                        } else if (text == 'businessType') {
                            businessType = parser.getText();
                        } else if (text == 'sharePercentage') {
                            sharePercentage = parser.getIntegerValue()/1000;
                        } else if (text == 'lastName') {
                            lastName = parser.getText();
                        } else if (text == 'registrationNumber') {
                            registrationNumber = parser.getText();
                        } else if (text == 'registeredName') {
                            registeredName = parser.getText();
                        } else if (text == 'contactNumber') {
                            contactNumber = parser.getText();
                        } else if (text == 'capacity') {
                            capacity = parser.getText();
                        } else if (text == 'emailAddress') {
                            emailAddress = parser.getText();
                        } else if (text == 'registeredAddress') {
                            registeredAddress = parser.getText();
                        } else if (text == 'headOfficeAddress') {
                            headOfficeAddress = parser.getText();
                        } else if (text == 'physicalAddress') {
                            physicalAddress = parser.getText();
                        } else if (text == 'supportingDocuments') {
                            supportingDocuments = new List<SupportingDocuments>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                supportingDocuments.add(new SupportingDocuments(parser));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'RelatedParties consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class ContactPerson {
        public String requestedBy {get;set;}
        public String requesterNumber {get;set;}

        public ContactPerson(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'requestedBy') {
                            requestedBy = parser.getText();
                        } else if (text == 'requesterNumber') {
                            requesterNumber = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ContactPerson consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public static AOBApplication parse(String json) {
        return new AOBApplication(System.JSON.createParser(json));
    }
}