/**
 * @description Account Service Layer - Service ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
 * @author Unknown
 * @date Unknown
 *
 * Digitization Client Onboarding - Account Opening US-2668 - Added client hierarchy JSON generator
 * @author Caro Reinecke
 * @date Jan 2018
 *
 * Modified hierarchy generator to exclude inactive clients and clients with no CIF Number
 * @author Caro Reinecke
 * @date Feb 2019
*/
public with sharing class AccountService {
	public static final String STATUS_REJECTED_IN_GT = 'Rejected by KYC Team(GoldTier)';
	public static final String STATUS_CIF_ALLOCATED = 'CIF Allocated';
	public static final String STATUS_SUBMITTED_FOR_ONBOARDING = 'Submitted for Onboarding';

	public static final String REL_HIERARCHY_GROUP_PARENT = 'Group Parent';
	public static final String REL_HIERARCHY_IMMEDIATE_PARENT = 'Immediate Parent';
	public static final String REL_HIERARCHY_CHILD = 'Child';

	public static final Map<String,Schema.RecordTypeInfo> MAP_RT_BY_NAME = Account.SObjectType.getDescribe().getRecordTypeInfosByName();

	public static final String RECORD_TYPE_NAME_GROUP_PARENT = 'Ultimate Group Parent';
	public static final String RECORD_TYPE_NAME_IMMEDIATE_PARENT = 'Immediate Parent';
	public static final String RECORD_TYPE_NAME_CHILD = 'Child';
	public static final String RECORD_TYPE_NAME_LOCKED_POTENTIAL_GT = 'Locked Potential (Goldtier)';
	public static final String RECORD_TYPE_NAME_POTENTIAL_GT = 'Potential (Goldtier)';
	public static final String RECORD_TYPE_NAME_LOCKED_POTENTIAL_CIF = 'Locked Potential (CIF)';


	public static final Id RECORD_TYPE_GROUP_PARENT = MAP_RT_BY_NAME.get(RECORD_TYPE_NAME_GROUP_PARENT).getRecordTypeId();
	public static final Id RECORD_TYPE_IMMEDIATE_PARENT = MAP_RT_BY_NAME.get(RECORD_TYPE_NAME_IMMEDIATE_PARENT).getRecordTypeId();
	public static final Id RECORD_TYPE_CHILD = MAP_RT_BY_NAME.get(RECORD_TYPE_NAME_CHILD).getRecordTypeId();
	public static final Id RECORD_TYPE_LOCKED_POTENTIAL_GT = MAP_RT_BY_NAME.get(RECORD_TYPE_NAME_LOCKED_POTENTIAL_GT).getRecordTypeId();
	public static final Id RECORD_TYPE_POTENTIAL_GT = MAP_RT_BY_NAME.get(RECORD_TYPE_NAME_POTENTIAL_GT).getRecordTypeId();
	public static final Id RECORD_TYPE_LOCKED_POTENTIAL_CIF = MAP_RT_BY_NAME.get(RECORD_TYPE_NAME_LOCKED_POTENTIAL_CIF).getRecordTypeId();

    public class AccountServiceException extends Exception {
    }

    /**
     * getClientHierarchyAsJSON
     * @param cifNumbers set of string cif numbers
     * @return String
     */
    public static String getClientHierarchyAsJSON(Set<String> cifNumbers) {
        try {
            List<Account> authorisedClients = new SEL_Accounts().selectByCIFNumber(cifNumbers);
            Set<Id> authorisedClientIds = new Set<Id>();
            for (Account authorisedClient : authorisedClients) {
                authorisedClientIds.add(authorisedClient.Id);
            }
            // Given a list of client Id's fetch the Top Parent record Ids.
            Set<Id> topParentIds = new SEL_Accounts().selectTopParentIdByChildId(authorisedClientIds);
            // Given a list of top parent id's fetch the clients related to those Top parents with their KYC Status records

            List<Account> clients = new SEL_Accounts().selectHierarchyByTopParentIdWithKYCStatus(topParentIds);
            List<SObject> hierarchyRecords = (List<SObject>) clients;

            UTL_Hierarchy.Hierarchy clientHierarchies = new UTL_Hierarchy.Hierarchy(hierarchyRecords, 'ParentId');
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartArray();
            for (SObject topParent : clientHierarchies.getTopRecord()) {
                gen = AccountService.generateJSONHierarchy(gen, clientHierarchies, topParent, authorisedClientIds);
            }
            return gen.getAsString();
        } catch (exception e) {
            throw new AccountServiceException('Unable to generate client hierarchy! ' + e.getMessage());
        }
    }

    /**
     * generateJSONHierarchy
     * @param gen JSONGenerator
     * @param hierarchy UTL_Hierarchy.Hierarchy
     * @param parent SObject
     * @param authorisedClients set of ids
     * @return JSONGenerator
     */
    public static JSONGenerator generateJSONHierarchy(JSONGenerator gen, UTL_Hierarchy.Hierarchy hierarchy, SObject parent, Set<Id> authorisedClients) {
        try {
            Account acct = (Account) parent;
            // Exclude Inactive clients and clients without a CIF number
            if (acct.CIF__c == null || acct.Client_Record_Type__c == 'Inactive') {
                return gen;
            }
            gen.writeStartObject();
            gen.writeStringField('ID', acct.Id);
            gen.writeStringField('ParentID', acct.ParentId == null ? '' : acct.ParentId);
            gen.writeStringField('Country', acct.BillingCountry == null ? '' : acct.BillingCountry);
            gen.writeStringField('TradingAs', acct.Name);
            gen.writeStringField('RegNum', acct.REGISTRATION_NUMBER__C == null ? '' : acct.REGISTRATION_NUMBER__C);
            gen.writeStringField('CIFNumber', acct.CIF__c == null ? '' : acct.CIF__c);
            gen.writeBooleanField('Authorised', authorisedClients.contains(acct.Id));
            String kycStatus = '';
            for (KYC_Status__c kycS : acct.R00N20000001EiOhEAK) {
                if (kycS.Entity_Code__c == 'SBSA') { kycStatus = kycS.KYC_Status__c; }
            }
            if (kycStatus == '') { kycStatus = 'N/A'; }
            gen.writeStringField('KYCStatus', kycStatus);
            gen.writeFieldName('Children');
            gen.writeStartArray();
            for (SObject child : hierarchy.getImmediateChildRecords(acct.Id)) {
                gen = AccountService.generateJSONHierarchy(gen, hierarchy, child, authorisedClients);
            }
            gen.writeEndArray();
            gen.writeEndObject();
            return gen;
        } catch (exception e) {
            throw new AccountServiceException('Unable to generate client hierarchy ' + e.getMessage());
        }
    }

    /**
     * getClients
     * @param registrationNumber registration number
     * @param registeredName registered name
     * @return list of account
     */
    public static List<Account> getClients(String registrationNumber, String registeredName) {
        List<Account> clients = new List<Account>();
        if (registrationNumber <> null) {
            clients = new SEL_Accounts().selectByRegistrationNumber(new Set<String>{
                    registrationNumber
            });
            if (clients.size() == 0) {
                clients = new SEL_Accounts().selectByRegisteredName(new Set<String>{
                        registeredName
                });
            }
        } else if (registeredName <> null) {
            clients = new SEL_Accounts().selectByRegisteredName(new Set<String>{
                    registeredName
            });
        }
        return clients;
    }

    /**
     * getClientTeam
     * @param cifNUmber cif number
     * @param teamMemberRole string
     * @return ClientTeam record
     */
    public static ClientTeam getClientTeam(String cifNUmber,String teamMemberRole) {


        List<Account> accountWithClientTeam = new List<Account>();
        ClientTeam theTeam;

        if ((cifNUmber <> null) && (teamMemberRole <> null)) {
            System.debug('cif: ' + cifNUmber);
            accountWithClientTeam = new SEL_Accounts().selectByCIFNumberWithClientTeamAndRole(new Set<String>{
                    cifNUmber
            }, teamMemberRole);
        } else if (cifNUmber <> null) {
            System.debug('cif: ' + cifNUmber);
            accountWithClientTeam = new SEL_Accounts().selectByCIFNumberWithClientTeam(new Set<String>{
                    cifNUmber
            });
        }
        if (accountWithClientTeam.size() > 0 && accountWithClientTeam[0].Custom_Client_Teams__r.size() > 0) {
            String clientTeamJSONString = JSON.serialize(accountWithClientTeam[0]);

            theTeam = ClientTeam.parse(clientTeamJSONString);

            Set<Id> teamMemberIds = new Set<Id>();
            for (Integer i = 0; i < theTeam.customClientTeamMembers.totalSize; i++) {
                teamMemberIds.add((id) theTeam.customClientTeamMembers.records[i].teamMemberId);
            }

            List<User> teamMembers = new SEL_Users().selectById(teamMemberIds);

            Map<Id, User> teamMemberMap = new Map<Id, User>(teamMembers);

            for (Integer i = 0; i < theTeam.customClientTeamMembers.totalSize; i++) {
                theTeam.customClientTeamMembers.records[i].addressCity = teamMemberMap.get(theTeam.customClientTeamMembers.records[i].teamMemberId).City;
                theTeam.customClientTeamMembers.records[i].addressCountry = teamMemberMap.get(theTeam.customClientTeamMembers.records[i].teamMemberId).Country;
                theTeam.customClientTeamMembers.records[i].addressPostalCode = teamMemberMap.get(theTeam.customClientTeamMembers.records[i].teamMemberId).PostalCode;
                theTeam.customClientTeamMembers.records[i].addressStreet = teamMemberMap.get(theTeam.customClientTeamMembers.records[i].teamMemberId).Street;
                theTeam.customClientTeamMembers.records[i].contactNumber = teamMemberMap.get(theTeam.customClientTeamMembers.records[i].teamMemberId).Phone;
                theTeam.customClientTeamMembers.records[i].emailAddress = teamMemberMap.get(theTeam.customClientTeamMembers.records[i].teamMemberId).Email;
            }
        }

        return theTeam;
    }

    /**
     * Get accounts latest submitted business assessment
     * <br/>SGPRT-1201
     *
     * @param cifs account cif numbers
     * @return list of account
     */
    public static List<Account> getAccountsWithBusinessAssessments(Set<String> cifs) {
        if (!cifs.isEmpty()){
            return new List<Account>(SEL_Accounts.newInstance().selectByCifWithSubmittedBusinessAssessments(cifs, 1));
        }
        return new List<Account>();
    }
}