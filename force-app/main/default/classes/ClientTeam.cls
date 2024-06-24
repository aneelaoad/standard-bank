/**
 * Created by Caro on 2019-02-06.
 */

global class ClientTeam {

    public class Attributes {
        public String type_Z {get;set;} // in json: type
        public String url {get;set;}

        public Attributes(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'url') {
                            url = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class TeamMember {
        public Attributes attributes {get;set;}
        public String client {get;set;}
        public String Id {get;set;}
        public String businessUnit {get;set;}
        public Boolean isClientCoordinator {get;set;}
        public Boolean isClientCoordinatorBusinessManager {get;set;}
        public String role {get;set;}
        public String currencyIsoCode {get;set;}
        public Boolean isGlobalTransactionalBanker {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String teamMemberId {get;set;}
        public String contactNumber {get;set;}
        public String emailAddress {get;set;}
        public String addressCountry {get;set;}
        public String addressCity {get;set;}
        public String addressPostalCode {get;set;}
        public String addressStreet {get;set;}

        public TeamMember(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'attributes') {
                            attributes = new Attributes(parser);
                        } else if (text == 'Account__c') {
                            client = parser.getText();
                        } else if (text == 'Id') {
                            Id = parser.getText();
                        } else if (text == 'Business_Unit__c') {
                            businessUnit = parser.getText();
                        } else if (text == 'Client_Coordinator_BM__c') {
                            isClientCoordinator = parser.getBooleanValue();
                        } else if (text == 'Client_Coordinator__c') {
                            isClientCoordinatorBusinessManager = parser.getBooleanValue();
                        } else if (text == 'Client_Role__c') {
                            role = parser.getText();
                        } else if (text == 'CurrencyIsoCode') {
                            currencyIsoCode = parser.getText();
                        } else if (text == 'GTB__c') {
                            isGlobalTransactionalBanker = parser.getBooleanValue();
                        } else if (text == 'Team_Member_First_Name__c') {
                            firstName = parser.getText();
                        } else if (text == 'Team_Member_Last_Name__c') {
                            lastName = parser.getText();
                        } else if (text == 'Team_Member__c') {
                            teamMemberId = parser.getText();
                        } else if (text == 'contactNumber') {
                            contactNumber = parser.getText();
                        } else if (text == 'emailAddress') {
                            emailAddress = parser.getText();
                        } else if (text == 'AddressCountry') {
                            addressCountry = parser.getText();
                        } else if (text == 'AddressCity') {
                            addressCity = parser.getText();
                        } else if (text == 'AddressPostalCode') {
                            addressPostalCode = parser.getText();
                        } else if (text == 'AddressStreet') {
                            addressStreet = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Records consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class ClientTeamMembers {
        public Integer totalSize {get;set;}
        public Boolean done {get;set;}
        public List<TeamMember> records {get;set;}

        public ClientTeamMembers(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'totalSize') {
                            totalSize = parser.getIntegerValue();
                        } else if (text == 'done') {
                            done = parser.getBooleanValue();
                        } else if (text == 'records') {
                            records = arrayOfRecords(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Custom_Client_Teams__r consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public Attributes attributes {get;set;}
    public String billingCountry {get;set;}
    public String billingPostalCode {get;set;}
    public String billingStreet {get;set;}
    public String cif {get;set;}
    public String clientRecordType {get;set;}
    public String clientSector {get;set;}
    public String clientSubSector {get;set;}
    public String registeredAddrStreet {get;set;}
    public String registeredAddrCity {get;set;}
    public String registeredAddrCountry {get;set;}
    public String registeredAddrPostalCode {get;set;}
    public String currencyIsoCode {get;set;}
    public String id {get;set;}
    public String industryCode {get;set;}
    public String name {get;set;}
    public String ownerId {get;set;}
    public String parentId {get;set;}
    public String phone {get;set;}
    public String primaryRelationshipHolder {get;set;}
    public String recordTypeId {get;set;}
    public String registrationNumber {get;set;}
    public String relationshipRoles {get;set;}
    public ClientTeamMembers customClientTeamMembers {get;set;}

    public ClientTeam(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'attributes') {
                        attributes = new Attributes(parser);
                    } else if (text == 'BillingCountry') {
                        billingCountry = parser.getText();
                    } else if (text == 'BillingPostalCode') {
                        billingPostalCode = parser.getText();
                    } else if (text == 'BillingStreet') {
                        billingStreet = parser.getText();
                    } else if (text == 'CIF__c') {
                        cif = parser.getText();
                    } else if (text == 'Client_Record_Type__c') {
                        clientRecordType = parser.getText();
                    } else if (text == 'Client_Sector__c') {
                        clientSector = parser.getText();
                    } else if (text == 'Client_Sub_Sector__c') {
                        clientSubSector = parser.getText();
                    } else if (text == 'Correspondence_Addr_Line1__c') {
                        registeredAddrStreet = parser.getText();
                    } else if (text == 'Correspondence_City__c') {
                        registeredAddrCity = parser.getText();
                    } else if (text == 'Correspondence_Country__c') {
                        registeredAddrCountry = parser.getText();
                    } else if (text == 'Correspondence_Postal_Code__c') {
                        registeredAddrPostalCode = parser.getText();
                    } else if (text == 'CurrencyIsoCode') {
                        currencyIsoCode = parser.getText();
                    } else if (text == 'Id') {
                        id = parser.getText();
                    } else if (text == 'Industry_Code__c') {
                        industryCode = parser.getText();
                    } else if (text == 'Name') {
                        name = parser.getText();
                    } else if (text == 'OwnerId') {
                        ownerId = parser.getText();
                    } else if (text == 'ParentId') {
                        parentId = parser.getText();
                    } else if (text == 'Phone') {
                        phone = parser.getText();
                    } else if (text == 'Primary_Relationship_Holder__c') {
                        primaryRelationshipHolder = parser.getText();
                    } else if (text == 'RecordTypeId') {
                        recordTypeId = parser.getText();
                    } else if (text == 'Registration_Number__c') {
                        registrationNumber = parser.getText();
                    } else if (text == 'Relationship_Roles__c') {
                        relationshipRoles = parser.getText();
                    } else if (text == 'Custom_Client_Teams__r') {
                        customClientTeamMembers = new ClientTeamMembers(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'ClientTeam consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }


    public static ClientTeam parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ClientTeam(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                    curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    private static List<TeamMember> arrayOfRecords(System.JSONParser p) {
        List<TeamMember> res = new List<TeamMember>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new TeamMember(p));
        }
        return res;
    }

}