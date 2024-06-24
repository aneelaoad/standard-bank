/**
 * Web service class that serves as POST HTTP method for the external API system to merge
 * duplicated Account from SAP
 *
 * US-SGPRT-1627
 * @author Agnieszka Adrianowska (aadrianowska@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
 * @date August 2020
 */
@RestResource(UrlMapping='/partner-sync/*')
global without sharing class PBB_WS_PartnerSyncMerge {

    @TestVisible
    private static final String RESPONSE_ERROR_MESSAGE_TOO_MANY_RECORDS_TO_MERGE = 'Merge data list is too big, the list may contain up to 20 records';
    @TestVisible
    private static final String RESPONSE_ERROR_MESSAGE_MERGE_LIST_IS_EMPTY = 'Merge data list is empty';
    @TestVisible
    private static final String RESPONSE_ERROR_MESSAGE_INVALID_SYNTAX = 'Invalid syntax';
    @TestVisible
    private static final String RESPONSE_ERROR_MESSAGE_NO_AE_NUMBER = 'Master customer record can not be inserted. Get API returned no client coordinator (relManagerLink) for this client.';
    @TestVisible
    private static final String RESPONSE_ERROR_MESSAGE_NO_CLIENT_OWNER_IN_SF = 'Master customer record can not be inserted. Client coordinator (relManagerLink) not found in Salesforce.';
    @TestVisible
    private static final String RESPONSE_ERROR_MESSAGE_INTERNAL_SERVER_ERROR = 'Internal server error';
    @TestVisible
    private static final String LOG_ERROR_MESSAGE_NO_AE_NUMBER = 'Error! Master customer record with GUID: {0} can not be inserted. Gateway API returned no client coordinator (relManagerLink) for this client.';
    @TestVisible
    private static final String LOG_ERROR_MESSAGE_NO_CLIENT_OWNER_IN_SF = 'Error! Master customer record with GUID: {0} can not be inserted. Client coordinator not found in Salesforce. Client coordinator AE number: {1}';
    @TestVisible
    private static final String LOG_ERROR_MESSAGE_NOT_PBB_MARKET_SEGMENT = 'Error! Master customer record does not belong to Lifestyle segment';
    @TestVisible
    private static final List<String> PBB_SEGMENT = new List<String>{'400 - Lifestyle', '419 - Agric Small (Lifestyle)'};
    @TestVisible
    private static final Integer MERGE_LIMIT = 20;

   

    private enum ExceptionType {
        INVALID_SYNTAX, TOO_MANY_RECORDS_TO_MERGE, MERGE_LIST_EMPTY, NO_AE_NUMBER, NO_OWNER_IN_SF,DATA_ISSUE
    }

    public class PBB_WS_PartnerSyncMergeException extends Exception {
        private ExceptionType exType { get; set; }
        /**
        * The Exception Method
        * @param message error dessciption
        * @param exceptionType the type of the exception
        */
        public PBB_WS_PartnerSyncMergeException(String message, ExceptionType exceptionType) {
            this(message);
            exType = exceptionType;
        }
    }
	/**
    * The Service Logger
    */
    private static final SRV_Logger LOGGERSERVICE = (SRV_Logger) SRV_Logger.newInstance();

    /**
     * A method that serves as POST HTTP method for the external API system to merge
     * duplicated Account from SAP
     *
     * US-SGPRT-1627
     */
    @HttpPost
    global static void mergeAccounts() {
        try {
            RequestWrapper requestWrapper = (RequestWrapper) JSON.deserialize(RestContext.request.requestBody.toString(), RequestWrapper.class);
            validateRequest(requestWrapper);
            Account masterAccount = getMasterAccount(requestWrapper);
            List<Account> accountsToArchive = getAccountsToArchive(requestWrapper);
            Boolean wasMasterAccountCreated = false;
            if (masterAccount == null) {
                createNewMasterAccount(requestWrapper.newEntityId);
                masterAccount = getMasterAccount(requestWrapper);
                wasMasterAccountCreated = true;
            }
            deleteRelated(accountsToArchive);
            doMerge(masterAccount, accountsToArchive);
            if (wasMasterAccountCreated) {
                fetchOtherCustomerInformation(masterAccount.Id);
            }
        } catch (Exception e) {
            if (e instanceof System.JSONException) {
                setInvalidSyntaxResponse();
            } else if (e instanceof PBB_WS_PartnerSyncMerge.PBB_WS_PartnerSyncMergeException) {
                PBB_WS_PartnerSyncMergeException serviceException = (PBB_WS_PartnerSyncMergeException) e;
                switch on serviceException.exType {
                    when NO_AE_NUMBER {
                        setAPIReturnedNoClientCoordinatorResponse();
                    }
                    when NO_OWNER_IN_SF {
                        setClientCoordinatorNotFoundInSalesforceResponse();
                    }
                    when INVALID_SYNTAX {
                        setInvalidSyntaxResponse();
                    }
                    when TOO_MANY_RECORDS_TO_MERGE {
                        setTooManyRecordsResponse();
                    }
                    when MERGE_LIST_EMPTY {
                        setNoRecordsToMergeResponse();
                    }
                    When DATA_ISSUE {
                        setDataIssueErrorResponse(serviceException.getMessage());
                    }
                    when else {
                        setInternalServerErrorResponse();
                    }
                }
            } else {
                setInternalServerErrorResponse();
            }
            LOGGERSERVICE.log(e, PBB_WS_PartnerSyncMerge.class.getName(), DMN_Log.AREA_PBB_PARTNER_SYNC);
        }
    }

    private static void validateRequest(RequestWrapper requestWrapper) {
        if (requestWrapper == null || requestWrapper.mergeData == null || requestWrapper.newEntityId == null) {
            throw new PBB_WS_PartnerSyncMergeException(RESPONSE_ERROR_MESSAGE_INVALID_SYNTAX, ExceptionType.INVALID_SYNTAX);
        }
        if (requestWrapper.mergeData.isEmpty()) {
            throw new PBB_WS_PartnerSyncMergeException(RESPONSE_ERROR_MESSAGE_MERGE_LIST_IS_EMPTY, ExceptionType.MERGE_LIST_EMPTY);
        }
        if (requestWrapper.mergeData.size() > MERGE_LIMIT) {
            throw new PBB_WS_PartnerSyncMergeException(RESPONSE_ERROR_MESSAGE_TOO_MANY_RECORDS_TO_MERGE, ExceptionType.TOO_MANY_RECORDS_TO_MERGE);
        }
    }

    private static void fetchOtherCustomerInformation(Id id) {
        System.enqueueJob(new SRV_Customer1ClientSynchronizer.AddressUpdater(id));
    }

    private static Account getMasterAccount(RequestWrapper requestWrapper) {
        List<Account> masterAccount = [SELECT Id, GUID__c FROM Account WHERE GUID__c = :Uuid.formatValue(requestWrapper.newEntityId)];
        if (masterAccount.isEmpty()) {
            return null;
        }
        return masterAccount[0];
    }

    private static List<String> getAccountsGUIDs(RequestWrapper requestWrapper) {
        List<String> accountsGUIDS = new List<String>();
        for (ResponseMergeData archivedId : requestWrapper.mergeData) {
            accountsGUIDS.add(Uuid.formatValue(archivedId.archivedEntityId));
        }
        return accountsGUIDS;
    }

    private static List<Account> getAccountsToArchive(RequestWrapper requestWrapper) {
        List<String> accountsGUIDs = getAccountsGUIDs(requestWrapper);

        if (accountsGUIDs.contains(requestWrapper.newEntityId)) {
            accountsGUIDs.remove(accountsGUIDs.indexOf(requestWrapper.newEntityId));
        }
        return [SELECT Id, Name, GUID__c FROM Account WHERE GUID__c IN :accountsGUIDs ORDER BY CreatedDate DESC];
    }
	/**
    * This method for Master account creation
    * @param	accountGUID guid id of the client
    **/
    private static void createNewMasterAccount(String accountGUID) {
        Account createdAccount = new Account();
        PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse customerInfo = PBB_SRV_GatewayApi_GetCustomers.newInstance().getBase(accountGUID);
            if(customerInfo.customer.mktgSegment==400 || customerInfo.customer.mktgSegment==419) {
                createdAccount.Market_Segments__c = getMarketSegmentByCode(customerInfo.customer.mktgSegment);
                if (createdAccount.Market_Segments__c.toLowerCase() == PBB_SEGMENT[0].toLowerCase() || createdAccount.Market_Segments__c.toLowerCase() == PBB_SEGMENT[1].toLowerCase()) {
                    if (customerInfo.customer.orgDetails == null) {
                        throw new PBB_WS_PartnerSyncMergeException('For customer: ' + accountGUID + ' orgDetails field not specified, cannot set client name',ExceptionType.DATA_ISSUE);
                    }
                    createdAccount.Name = UTL_String.capitalizeWords(String.isNotBlank(customerInfo.customer.orgDetails.companyName) ? customerInfo.customer.orgDetails.companyName : customerInfo.customer.orgDetails.legalName);
                    createdAccount.GUID__c = Uuid.formatValue(accountGUID);
                    createdAccount.BPID__c = customerInfo.customer.BPID;
                    createdAccount.Relationship_Commenced__c = getLatestRelationshipCommence(customerInfo.customer.customerRole);
                    List<User> customerOwner = new List<User>([SELECT Id, Name FROM User WHERE AE_Number__c = :customerInfo.customer.relManagerLink]);
                    if (String.isBlank(customerInfo.customer.relManagerLink)) {
                        customerOwner = new List<User>{
                                UTL_User.getPbbClientsUser()
                        };
                    }


                    if (customerOwner.isEmpty()) {
                        customerOwner = new List<User>{
                                UTL_User.getPbbClientsUser()
                        };
                    }
                    createdAccount.OwnerId = customerOwner[0].Id;

                    DMN_Account.populateDefaultPBBCLientFields(new List<Account>{
                            createdAccount
                    });
                    Database.upsert(createdAccount, Account.GUID__c);
                }
            }
            else {

                throw new PBB_WS_PartnerSyncMergeException(LOG_ERROR_MESSAGE_NOT_PBB_MARKET_SEGMENT, ExceptionType.DATA_ISSUE);
            }

    }

    private static String getMarketSegmentByCode(Integer marketSegmentCode) {
        Schema.DescribeFieldResult fieldResult = Account.Market_Segments__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            if (pickListVal.getValue().contains(String.valueOf(marketSegmentCode))) {
                return pickListVal.getValue();
            }
        }
        return null;
    }

    private static Date getLatestRelationshipCommence(List<PBB_SRV_GatewayApi_GetCustomers.CustomerRole> customerRoles) {
        if (customerRoles == null || customerRoles.isEmpty()) {
            return null;
        }
        customerRoles.sort();
        //The earliest valid date accepted by Salesforce is 1700-01-01T00:00:00Z GMT
        if (Date.valueOf(customerRoles[0].startDate) < Date.valueOf('1700-01-01T00:00:00Z GMT')) {
            return null;
        }
        return Date.valueOf(customerRoles[0].startDate);
    }

    /**
     * A method that delete records related to Account duplicated records which are fetched from
     * external systems. We don't wanted them to be reparented to the master record since
     * we could have duplicated related records in case external systems changed external ids
     *
     * @param archivedRecords - duplicated Records that will be merged and deleted
     *
     */
    private static void deleteRelated(List<Account> archivedRecords) {
        List<SObject> lstDeleteRecords = new List<SObject>();
        Set<Id> contactIds = new Set<Id>();
        List<SObject> lstDeleteContactRelRecords = new List<SObject>();
        Set<Id> archivedRecIds = new Map<Id, Account>(archivedRecords).keySet();
        List<String> lstsObjectName = new List<String>{
                'Account_Information__c', 'Transaction__c', 'Conversation__c'
        };
        for (String strObjectName : lstsObjectName) {
            List<SObject> objects = Database.query('Select Id from ' + strObjectName + ' where Client__c IN :archivedRecIds');
            lstDeleteRecords.addAll(objects);
        }
        List<Revenue_and_Profitability__c> revenueAndProfitabilities = [SELECT Id FROM Revenue_and_Profitability__c WHERE Client_Name__c IN :archivedRecIds];
        lstDeleteRecords.addAll(revenueAndProfitabilities);

        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId IN :archivedRecIds];
        lstDeleteRecords.addAll(contacts);
        contactIds.addAll(new Map<Id, Contact>(contacts).keySet());

        if (!contactIds.isEmpty()) {
            lstDeleteContactRelRecords = fetchRelatedContactRecords(contactIds);
            if (!lstDeleteContactRelRecords.isEmpty()) {
                delete lstDeleteContactRelRecords;
            }
        }
        if (!lstDeleteRecords.isEmpty()) {
            lstDeleteRecords.sort();
            delete lstDeleteRecords;
        }
    }
    /**
     * A method that collect all records related to contact records that could prevent us
     * from delete operation on contact records
     * Documentation: https://help.salesforce.com/articleView?id=contacts_del.htm&type=5
     *
     * @param contactIds - a set of ids of contact records related to accounts we want to delete
     *
     * @return a list of sObjects that contains all related contact records that could prevent delete
     * operation according to the documentation and actual SF configuration
     */
    private static List<SObject> fetchRelatedContactRecords(Set<Id> contactIds) {
        List<SObject> lstDeleteContactRelRecords = new List<SObject>();
        List<String> lstsContactRelObjectName = new List<String>{
                'Asset', 'Case', 'ServiceContract'
        };

        for (String strObjectName : lstsContactRelObjectName) {
            List<SObject> objsObject = Database.query('Select Id from ' + strObjectName + ' where ContactId IN :contactIds');
            lstDeleteContactRelRecords.addAll(objsObject);
        }
        List<Contract> contracts = new List<Contract>([SELECT Id FROM Contract WHERE CustomerSignedId IN :contactIds]);
        lstDeleteContactRelRecords.addAll(contracts);

        return lstDeleteContactRelRecords;
    }
    /**
     * In this method the actual merge is happening. We are using standard merge method which
     * has the limitation - it can merge up to 3 records, so we are calling it in loop.
     * It counts to DML operations, but we are not allowing more then 11 records for one merge.
     * According to the documentation it is reparenting all related records and then delete duplicated
     * records.
     * Documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_dml_examples_merge.htm
     *
     * @param masterRecord - master Account to which other duplicates will be merged
     * @param archivedRecords - duplicated Records that will be merged and deleted
     *
     */
    private static void doMerge(Account masterRecord, List<Account> archivedRecords) {
        List<Account> accDuplicates = new List<Account>();
        for (Integer i = 0; i < archivedRecords.size(); i = i + 2) {
            accDuplicates.add(archivedRecords[i]);
            if ((archivedRecords.size() - i) == 1) {
                try {
                    Database.merge(masterRecord, accDuplicates);
                } catch (Exception e) {
                    LOGGERSERVICE.log(e, PBB_WS_PartnerSyncMerge.class.getName(), DMN_Log.AREA_PBB_PARTNER_SYNC);
                }
            } else {
                accDuplicates.add(archivedRecords[i + 1]);
                try {
                    Database.merge(masterRecord, accDuplicates);
                } catch (Exception e) {
                    LOGGERSERVICE.log(e, PBB_WS_PartnerSyncMerge.class.getName(), DMN_Log.AREA_PBB_PARTNER_SYNC);
                }
            }
            accDuplicates.clear();
        }
    }

    private static void setInvalidSyntaxResponse() {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(RESPONSE_ERROR_MESSAGE_INVALID_SYNTAX);
    }

    private static void setTooManyRecordsResponse() {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(RESPONSE_ERROR_MESSAGE_TOO_MANY_RECORDS_TO_MERGE);
    }

    private static void setNoRecordsToMergeResponse() {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(RESPONSE_ERROR_MESSAGE_MERGE_LIST_IS_EMPTY);
    }

    private static void setAPIReturnedNoClientCoordinatorResponse() {
        RestContext.response.statusCode = 409;
        RestContext.response.responseBody = Blob.valueOf(RESPONSE_ERROR_MESSAGE_NO_AE_NUMBER);
    }

    private static void setClientCoordinatorNotFoundInSalesforceResponse() {
        RestContext.response.statusCode = 409;
        RestContext.response.responseBody = Blob.valueOf(RESPONSE_ERROR_MESSAGE_NO_CLIENT_OWNER_IN_SF);
    }

    private static void setInternalServerErrorResponse() {
        RestContext.response.statusCode = 500;
        RestContext.response.responseBody = Blob.valueOf(RESPONSE_ERROR_MESSAGE_INTERNAL_SERVER_ERROR);
    }
    private static void setDataIssueErrorResponse(String msg) {
        RestContext.response.statusCode = 409;
        RestContext.response.responseBody = Blob.valueOf(msg);
    }

    private class RequestWrapper {
        private String newEntityId;
        private ResponseMergeData[] mergeData;
    }

    private class ResponseMergeData {
        private String archivedEntityId;
    }

}