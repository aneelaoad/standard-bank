/**
* Service class that retrieves data from Gateway API.
* US-1463
*
* @author Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
* @ModifiedBy Emmanuel Mulea(Nocks)
* @date July 2022
* @Description : adding pmt service getPMTFinacials
*/
public with sharing class PBB_SRV_GatewayAPI_GetTransactions implements IService {
    
    private static final SRV_Logger loggerService = (SRV_Logger) SRV_Logger.newInstance();
    private static final SRV_HttpRequestSender.IService httpService = SRV_HttpRequestSender.newInstance();
    private static final PBB_SRV_GatewayRequestProvider.IService requestProviderService = PBB_SRV_GatewayRequestProvider.newInstance();
    
    private static final String URL_GET_PROACT_ROLLUP_TRANSACTIONS = '/proact-rollup-transaction-details/rollup-transactions';
    private static final String URL_GET_PROACT_NARRATIVE_TRANSACTIONS = '/proact-narrative-transaction-details/narrative-transactions';
    private static final String URL_GET_PMT_FINACIALS = '/pmt/pmt-financials?customerNumber={0}';
    
    public interface IService {
        List<RollUpTransactionData> fetchRollUpTransactionsData(Id clientId);
        List<NarrativeTransactionData> fetchNarrativeTransactionsData(Id clientId);
        List<PMTFinacials> getPMTFinacials(Id clientId);
    }
    
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }
    /**
     * @description returns BPID or CIF Number
     * @param client client record
     * @return string of cif or bpid
     */
    private static String getBpIdOrCif(Account client){
        if(String.isBlank(client.BPID__c)){
            return client.CIF__c;
        }
        else{
            return client.BPID__c;
        }
    }

    /**
     * @description makes API call to get PMT data 
     * @param clientId id
     * @return list of PMTFinacials
     */    
    public List<PMTFinacials> getPMTFinacials(Id clientId) {
        
        try{
            Account client = getClientRecord(clientId,true);
            HttpRequest request = buildCallRequest();
            request.setEndpoint('callout:gatewaynp'+String.format(URL_GET_PMT_FINACIALS, new List<String>{getBpIdOrCif(client)}));
            request.setMethod('GET');
            request.setTimeout(120000);
            List<PMTFinacials> pmtFinance = new List<PMTFinacials>();
            HttpResponse response = httpService.send(request, 5);
            if (response.getStatusCode() == 200 && !String.isBlank(response.getBody())) {
                pmtFinance = (List<PMTFinacials>) JSON.deserialize(response.getBody(), List<PMTFinacials>.class);
                return pmtFinance;
            } else if (response.getStatusCode() == 204 || String.isBlank(response.getBody())) {
                return null;
            } else {
                throw new ApiException(String.format('Error! For client {0} Got {1} with {2}, body {3}', new List<String>{
                    clientId, String.valueOf(response.getStatusCode()), response.getStatus(), response.getBody()
                        }));
            } 
        }
        catch(Exception ex){
            throw new ApiException(ex.getMessage());
        }
    }
    
   /**
    * Method retrieves rollup transactions from the Gateway Proact API.
    * US-1463
    *
    * @param clientId: Client id for which the data will be retrieved.     *
    * @return list of raw rollup transactions data for the given client.
    */
    public List<RollUpTransactionData> fetchRollUpTransactionsData(Id clientId) {
        
        
        try{
            Account client = getClientRecord(clientId,false);
            HttpRequest request = buildCallRequest();
            request.setEndpoint('callout:gatewaynp' + URL_GET_PROACT_ROLLUP_TRANSACTIONS);
            request.setMethod('POST');
            request.setTimeout(120000);
            request.setBody(JSON.serialize(new ProactRequestBody(Uuid.formatValue(client.GUID__c))));
            List<RollUpTransactionData> rollUpTransactions = new List<RollUpTransactionData>();
            HttpResponse response = httpService.send(request, 5);
            if (response.getStatusCode() == 200 && !String.isBlank(response.getBody())) {
                rollUpTransactions = (List<RollUpTransactionData>) JSON.deserialize(response.getBody(), List<RollUpTransactionData>.class);
                return rollUpTransactions;
            } else if (response.getStatusCode() == 204 || String.isBlank(response.getBody())) {
                return null;
            } else {
                throw new ApiException(String.format('Error! For client {0} Got {1} with {2}, body {3}', new List<String>{
                    clientId, String.valueOf(response.getStatusCode()), response.getStatus(), response.getBody()
                        }));
            }
        }
        catch(Exception ex){
            throw new ApiException(ex.getMessage());
        }
    }
    
   /**
    * Method retrieves narrative transaction from the proact api.
    * US-1463
    *
    * @param clientId: Client id for which the data will be retrieved.
    * @return list of raw narrative transactions data for the given client.
    */
    public List<NarrativeTransactionData> fetchNarrativeTransactionsData(Id clientId) {
        
        Account client = getClientRecord(clientId,false);
        
        HttpRequest request = buildCallRequest();
        request.setEndpoint('callout:gatewaynp' + URL_GET_PROACT_NARRATIVE_TRANSACTIONS);
        request.setMethod('POST');
        request.setBody(JSON.serialize(new ProactRequestBody(Uuid.formatValue(client.GUID__c))));
        
        List<NarrativeTransactionData> narrativeTransactions = new List<NarrativeTransactionData>();
        HttpResponse response = httpService.send(request, 5);
        
        if (response.getStatusCode() == 200 && !String.isBlank(response.getBody())) {
            narrativeTransactions = (List<NarrativeTransactionData>) JSON.deserialize(response.getBody(), List<NarrativeTransactionData>.class);
            return narrativeTransactions;
        } else if (response.getStatusCode() == 204 || String.isBlank(response.getBody())) {
            return null;
        } else {
            throw new ApiException(String.format('Error! For client {0} Got {1} with {2}, body {3}', new List<String>{
                clientId, String.valueOf(response.getStatusCode()), response.getStatus(), response.getBody()
                    }));
        }
    }
    /**
     * @description returns account record and checking if it got GUID or BPID/CIF depanding on isPMT param
     * @param clientId id
     * @param isPMT check if is PMT data being requested
     * @return Account record
     */      
    private Account getClientRecord(Id clientId,Boolean isPMT) {
        
        List<Account> clients = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{
            clientId
                });
        if(!isPMT){
            if (clients.isEmpty() || clients[0].GUID__c == null) {
                ApiException ex = new ApiException('Error, client ' + clientId + ' does not exist or client does not have GUID number specified');
                throw ex;
            }
        }
        else{
            if (clients.isEmpty() || (clients[0].BPID__c == null && clients[0].CIF__c == null)) {
                ApiException ex = new ApiException('Error, client ' + clientId + ' does not exist or client does not have BPID/CIF number specified');
                throw ex;
            }   
        }
        
        return clients[0];
    }
    /**
     * @description HTTP builder and request for token
     * @return HttpRequest
     */     
    private HttpRequest buildCallRequest() {
        
        HttpRequest request = requestProviderService.getRequestWithToken();
        request.setHeader('Accept', 'application/json');
        request.setTimeout(20000);
        
        return request;
    }
    
    public class RollUpTransactionData {
        
        public String Period;
        public Integer Transaction_Count;
        public Decimal Account_OD_Limit;
        public Integer Flag_Pos_Trans_Amt;
        public Decimal Account_Balance;
        public String Acc_Type;
        public Decimal Transaction_Amount;
    }
    
    public class NarrativeTransactionData {
        
        public Integer Debtor_Creditor_Count;
        public String Debtor_Creditor;
        public Decimal Debtor_Creditor_Amount;
    }
    
    public class ApiException extends Exception {
    }
    
    public class ProactRequestBody {
        String PartnerGUID;
        public ProactRequestBody(String GUID) {
            this.PartnerGUID = GUID;
        }
    }
    public class PMTFinacials {
        
        public String AE_Number;
        public Integer Customer_Num;
        public String Business_name;
        public Double OI;
        public Double NII;
        public Double NIR;
        public Integer Year_Month;
        public Double YTD_Average_Credit_Balance;
        public Double YTD_Average_Debit_Balance;
        public Double Impairments;
        public Double Performing_Average_Credit_Balance;
        public Double Performing_Average_Debit_Balance;
        public Double YTD_Impairments;
        public Double YTD_OI;
        public Double YTD_NII;
        public Double YTD_NIR;
    }
}