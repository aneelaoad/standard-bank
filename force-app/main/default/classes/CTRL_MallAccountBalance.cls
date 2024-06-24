/**
 * 
 * @description CTRL_MallAccountBalance
 * @author Ankit Kumar
 * @since 
 */
public with sharing class CTRL_MallAccountBalance {
    private static final String DEFAULT_CIF_COUNTRY = 'ZA';
    @TestVisible
    private static final String CUSTOMER_BPGUID_TEXT = 'customer_bpguid';
    @TestVisible
    private static final String CUSTOMER_BPID_TEXT = 'customer_bpid';


    /**
     * 
     * @description getCustomerAccountBalances
     * @return ResponseWrapper
     */
    @AuraEnabled
    public static ResponseWrapper getCustomerAccountBalances() {
        try {
            Map <String, String>  customerIdentificationInfo = getCustomerIdentificationInfo();
            String accountNumber;
            if(String.IsnotBlank(customerIdentificationInfo.get(CUSTOMER_BPGUID_TEXT))) {
                accountNumber = getAccountNumber(customerIdentificationInfo.get(CUSTOMER_BPGUID_TEXT));
            }
            ResponseWrapper wrapperResponse = new ResponseWrapper();
            if (String.isNotBlank(accountNumber) && String.IsnotBlank(customerIdentificationInfo.get(CUSTOMER_BPID_TEXT))) {
                MallAccountBalanceInfo mallAccountBalanceInfo = new mallAccountBalanceInfo();
                MallAccountBalanceInfo.Request request = new MallAccountBalanceInfo.Request();
                request.uniqueTransactionIdentificationNumber = MALL_OAuth_Util.generateGUID();
                request.cifCountry = DEFAULT_CIF_COUNTRY;
                request.cifSystemIdentificationNumber = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 1000));
                request.routingInformation = new List <MallAccountBalanceInfo.RoutingInformation> ();
                MallAccountBalanceInfo.RoutingInformation routeInfo = new MallAccountBalanceInfo.RoutingInformation();
                routeInfo.systemIdentificationNumber = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 1000));
                routeInfo.applicationIdentificationNumber = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 1000));
                request.routingInformation.add(routeInfo);
                request.customerUUID = customerIdentificationInfo.get(CUSTOMER_BPID_TEXT);
                request.customerIdNumber = CMN_UTIL_String.EMPTY;
                request.customerRegNumber = CMN_UTIL_String.EMPTY;
                request.accountNo = accountNumber;
                mallAccountBalanceInfo.request = request;
                HttpResponse responseHttp = new API_MallCustomerAccountBalance().getCustomerAccountBalance(System.JSON.serialize(mallAccountBalanceInfo));
                Map <String, Object> response = (Map <String, Object> ) JSON.deserializeUntyped(responseHttp.getBody());
                wrapperResponse.statusCode = responseHttp.getStatusCode();
                wrapperResponse.message = response;
            }
            return wrapperResponse;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallAccountBalance.getCustomerAccountBalances', e);
        }
    }

    public static String getAccountNumber(String customerBPGUID) {
        MallCustomerAccountListResponse response = getCustomerAccountList(customerBPGUID);
        String accountNumber;
        if (response != NULL && response.customerAccountListDetails != NULL && !response.customerAccountListDetails.isEmpty()) {
            accountNumber = response.customerAccountListDetails.get(0).accountNumber;
        }
        return accountNumber;
    }

    /**
     * 
     * @description getCustomerAccountList
     * @param customerBPGUID String
     * @return  `MallCustomerAccountListResponse`
     */
    @AuraEnabled
    public static MallCustomerAccountListResponse getCustomerAccountList(String customerBPGUID) {
        try {
            MallCustomerAccountListResponse accountListResponse;
            if(String.isNotBlank(customerBPGUID)) {
                if (String.isBlank(customerBPGUID)) {
                    throw MallExceptionUtil.throwAuraException('CTRL_MallAccountBalance.getCustomerAccountList', new AuraHandledException('Customer BPGUID should not be empty'));
                }
                if (String.isNotBlank(customerBPGUID)) {
                    accountListResponse = API_MallCustomerAccountList.getCustomerAccountList(customerBPGUID);
                }
            }
            return accountListResponse;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallAccountBalance.getCustomerAccountList', e);
        }
    }

    /**
     * 
     * @description getCustomerIdentificationInfo
     * @return Map<String, String>
     */
    public static Map <String, String> getCustomerIdentificationInfo() {
        Map <String, String> customerIdentificationMap = new Map <String, String> ();
        String customerBPGUID;
        String customerBPID;

        List <User> users = SEL_Users.newInstance().selectById(new Set <Id> {
            (Id) UserInfo.getUserId()
        });
        customerBPGUID = (users.size()> 0) ? users.get(0).Ping_BPGUID__c : NULL;
        customerIdentificationMap.put(CUSTOMER_BPGUID_TEXT, customerBPGUID);
        if (String.isNotBlank(users.get(0).ContactId)) {
            List <Contact> contacts = SEL_Contacts.newInstance().selectById(new Set <Id> {
                (Id) users.get(0).ContactId
            });
            customerBPID = (contacts.size()> 0) ? contacts.get(0).BPID__c : NULL;
            customerIdentificationMap.put(CUSTOMER_BPID_TEXT, customerBPID);
        }
        return customerIdentificationMap;
    }


    /**
     * 
     * @description ResponseWrapper 
     */
    public class ResponseWrapper {
        /**
         * 
         * @description http response code 
         */
        @AuraEnabled
        public integer statusCode {
            get;
            set;
        }
        /**
         * 
         * @description http response body 
         */
        @AuraEnabled
        public Map <string, Object> message {
            get;
            set;
        }
    }
}