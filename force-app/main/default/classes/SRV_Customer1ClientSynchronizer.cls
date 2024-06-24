/**
* Service class that asynchronously upserts and updates Account record based on Gateway API responses
* US-SGPRT-1010
*
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
public without sharing class SRV_Customer1ClientSynchronizer implements SRV_ExternalDataSynchronizer.ISyncStrategy {
    private static final SRV_Logger LOGGER_SERVICE = (SRV_Logger) SRV_Logger.newInstance();
    class SRV_Customer1ClientSynchronizerException extends Exception {
    }
    
    /**
* IService interface to call the data sync request
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
    public interface IService {
        /**
* Execute to call the data sync request
* @param dataSyncRequest
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        void execute(Change_Request__e dataSyncRequest);
    }
    
    /**
* Execute to call the data sync request
* @param dataSyncRequest
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
    public void execute(Change_Request__e dataSyncRequest) {
        try {
            Log_Event__e log = new Log_Event__e();
            log.Area__c = 'Message';
            log.Type__c = DMN_Log.TYPE_INFO;
            log.Message__c = 'Message : ' + JSON.serializePretty(dataSyncRequest);
            log.Source__c = 'ChangeRequest__c';
            
            EventBus.publish(log);
            System.enqueueJob(new BaseInfoUpdater(Uuid.formatValue(dataSyncRequest.EntityId__c)));
        } catch (Exception e) {
            LOGGER_SERVICE.log(e, SRV_Customer1ClientSynchronizer.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
        }
    }
    
    /**
* IService instance to call the  sync request
* @return IService
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
    public static IService newInstance() {
        return(IService) ORG_Application.service.newInstance(IService.class);
    }
    
    /**
* Class that asynchronously upserts Account with basic information based on Gateway API response
* US-SGPRT-1010
*
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
    public class BaseInfoUpdater implements Queueable, Database.AllowsCallouts {
        private String clientUuid;
           /**
* Custom constructor for BaseInfoUpdater class
* @param uuidValue
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public BaseInfoUpdater(String uuidValue) {
            clientUuid = uuidValue;
        }
        
        /**
* Execute method of the queueable class
* @param context
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public void execute(QueueableContext context) {
            processClient();
        }
        
        /**
* Executes bussine logic from the execute method
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public void processClient(){
            try {
                PBB_SRV_GatewayApi_GetCustomers.CustomerBase customer = PBB_SRV_GatewayApi_GetCustomers.newInstance().getBase(clientUuid).customer;
                Account newAccount = new Account();
                if (customer.orgDetails == null) {
                    throw new SRV_Customer1ClientSynchronizerException('For customer: ' + clientUuid + ' orgDetails field not specified, cannot set client name');
                }
                newAccount.Name = UTL_String.capitalizeWords(String.isNotBlank(customer.orgDetails.companyName) ? customer.orgDetails.companyName : customer.orgDetails.legalName);
                newAccount.GUID__c = clientUuid;
                newAccount.BPID__c = customer.BPID;
                newAccount.Market_Segments__c = getMarketSegmentByCode(customer.mktgSegment);
                newAccount.Relationship_Commenced__c = getLatestRelationshipCommence(customer.customerRole);
                User customerOwner;
                User pbbClient = UTL_User.getPbbClientsUser();
                if (String.isBlank(customer.relManagerLink)) {     
                    customerOwner = pbbClient;
                }
                else{
                    customerOwner = [SELECT Id, Name FROM User WHERE AE_Number__c = :customer.relManagerLink];
                    if(customerOwner == null){
                        customerOwner = pbbClient;
                    }
                }
                
                newAccount.OwnerId = customerOwner.Id;
                
                DMN_Account.populateDefaultPBBCLientFields(new List<Account>{
                    newAccount
                        });
                Database.upsert(newAccount, Account.GUID__c);
                if (newAccount.Id != null) {
                    System.enqueueJob(new AddressUpdater(newAccount.Id));
                }
            } catch (Exception e) {
                LOGGER_SERVICE.log(e, BaseInfoUpdater.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            }
        }
        /**
* Get the market segment by code
* @param marketSegmentCode
* @return Market segment String
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        private String getMarketSegmentByCode(Integer marketSegmentCode) {
            Schema.DescribeFieldResult fieldResult = Account.Market_Segments__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                if (pickListVal.getValue().contains(String.valueOf(marketSegmentCode))) {
                    return pickListVal.getValue();
                }
            }
            return null;
        }
        
        /**
* Get the relationship commence date
* @param customerRoles
* @return MRelationship commence date
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        private Date getLatestRelationshipCommence(List<PBB_SRV_GatewayApi_GetCustomers.CustomerRole> customerRoles) {
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
    }
    
    /**
* Class that asynchronously updates Account address information based on Gateway API response
* US-SGPRT-1010
*
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
    public class AddressUpdater implements Queueable, Database.AllowsCallouts {
        private String clientId;
        /**
* Custom constructor for AddressUpdater class
* @param clientId
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public AddressUpdater(Id clientId) {
            this.clientId = clientId;
        }
                /**
* Execute method of the queueable class
* @param context
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public void execute(QueueableContext context) {
            try {
                List<PBB_SRV_GatewayApi_GetCustomers.Address> addresses = PBB_SRV_GatewayApi_GetCustomers.newInstance().getAddresses(clientId);
                PBB_SRV_GatewayApi_GetCustomers.Address address = getLatestAddress(addresses);
                Account clientToUpdate = [SELECT BillingPostalCode, BillingCity, BillingState, BillingStreet FROM Account WHERE Id = :clientId FOR UPDATE];
                clientToUpdate.BillingStreet = address.line1;
                clientToUpdate.BillingState = address.province;
                clientToUpdate.BillingCity = address.city;
                clientToUpdate.BillingPostalCode = address.postalCode;
                clientToUpdate.BillingCountry = address.countryCode;
                update clientToUpdate;
                
                System.enqueueJob(new RegistrationNumberUpdater(clientId));
            } catch (Exception e) {
                LOGGER_SERVICE.log(e, AddressUpdater.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            }
        }
        
        private PBB_SRV_GatewayApi_GetCustomers.Address getLatestAddress(List<PBB_SRV_GatewayApi_GetCustomers.Address> addresses) {
            if (addresses == null || addresses.isEmpty()) {
                return null;
            }
            addresses.sort();
            return addresses[0];
        }
    }
    
    /**
* Class that asynchronously updates Account registration number information based on Gateway API response
* US-SGPRT-1010
*
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
    public class RegistrationNumberUpdater implements Queueable, Database.AllowsCallouts {
        private String clientId;
        /**
* Custom constructor for AddressUpdater class
* @param clientId
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public RegistrationNumberUpdater(Id clientId) {
            this.clientId = clientId;
        }
                        /**
* Execute method of the queueable class
* @param context
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public void execute(QueueableContext context) {
            try {
                List<PBB_SRV_GatewayApi_GetCustomers.Identification> response = PBB_SRV_GatewayApi_GetCustomers.newInstance().getCustomerIdentifications(clientId);
                if (!response.isEmpty()) {
                    for (PBB_SRV_GatewayApi_GetCustomers.Identification identification : response) {
                        if (identification.type == PBB_SRV_GatewayApi_GetCustomers.IDENTIFICATION_TYPE_REGISTRATION) {
                            if (identification.IDnumber != null) {
                                Account clientToUpdate = [SELECT Registration_Number__c FROM Account WHERE Id = :clientId FOR UPDATE];
                                clientToUpdate.Registration_Number__c = identification.IDnumber;
                                update clientToUpdate;
                            }
                        }
                    }
                }
                
                System.enqueueJob(new AccountInfoUpdate(clientId));
            } catch (Exception e) {
                LOGGER_SERVICE.log(e, RegistrationNumberUpdater.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            }
        }
    }
    
    /**
* Class that asynchronously updates Account_Information__c records related to specified Account with information based on Gateway API response
* US-SGPRT-1010
*
* @author Michal Lipinski (milipinski@deloittece.com)
* @date August 2020
*/
    public class AccountInfoUpdate implements Queueable, Database.AllowsCallouts {
        private String clientId;
                /**
* Custom constructor for AddressUpdater class
* @param clientId
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public AccountInfoUpdate(Id clientId) {
            this.clientId = clientId;
        }
                                /**
* Execute method of the queueable class
* @param context
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
        public void execute(QueueableContext context) {
            try {
                PBB_SRV_RefreshAccountInfo.upsertAccountInfo(clientId);
            } catch (Exception e) {
                LOGGER_SERVICE.log(e, AccountInfoUpdate.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            }
        }
    }
}