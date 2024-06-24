/**
 * @FuncArea PBB_Lifestyle
 * @Author Michał Lipiński, Maria Pszonka mpszonka@deloittece.com
 * @Date
 * @UserStory
 * @Description A class that implements HTTP service to integrate SF data with the API.
 */
public without sharing class PBB_SRV_GatewayApi_GetCustomers implements IService {
    public static final String IDENTIFICATION_TYPE_REGISTRATION = 'ENTERPRISE REGISTRATION NUMBER';
    public static final String DEBT_REVIEW_STATUS_CODE = '94';

    private static final SRV_HttpRequestSender.IService httpService = SRV_HttpRequestSender.newInstance();
    private static final PBB_SRV_GatewayRequestProvider.IService requestProviderService = PBB_SRV_GatewayRequestProvider.newInstance();

    @TestVisible
    private static final String URL_ACCOUNT = '/external-partner/customers/{0}';
    @TestVisible
    private static final String URL_ACCOUNT_CONTACTS = '/external-partner/customers/{0}/contacts';
    @TestVisible
    private static final String URL_ACCOUNT_COMPLIANCE_CHECKS = '/external-partner/customers/{0}/compliancechecks';
    @TestVisible
    private static final String URL_ACCOUNT_STATUSES = '/external-partner/customers/{0}/statuses';
    @TestVisible
    private static final String URL_ACCOUNT_IDENTIFICATIONS = '/external-partner/customers/{0}/identifications';
    @TestVisible
    private static final String URL_ACCOUNT_ADDRESSES = '/external-partner/customers/{0}/addresses';

    public interface IService {
        GetCustomerValidityInfoResponseWrapper getCustomerCompliance(Id clientId);
        ContactObject[] getCustomerContacts(Id clientId);
        Identification[] getCustomerIdentifications(Id clientId);
        Status[] getCustomerStatuses(Id clientId);
        CustomerBaseResponse getBase(String guid);
        List<Address> getAddresses(String id);
    }

    public static IService newInstance() {
        return(IService) ORG_Application.service.newInstance(IService.class);
    }

    public class ServiceException extends Exception {
    }

    public class ApiException extends Exception {
    }

    /**
     * A method that initiates GET HTTP callout to the external API system using gateway to get a list of
     * client's contact information.
     *
     * @param clientId - SF idea of the client that the API will call for.
     *
     * @return a list of wrapper class called ContactObject which consists of list of all contact information
     * in regards to the client.
     */
    public ContactObject[] getCustomerContacts(Id clientId) {
        Account record = [SELECT id, GUID__c from Account where id = :clientId];
        if (String.isEmpty(record.GUID__c)) {
            return null;
        }
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + String.format(URL_ACCOUNT_CONTACTS, new List<String>{
                Uuid.formatValue(record.GUID__C)
        }));
        req.setMethod('GET');
        HttpResponse res = httpService.send(req, 5);
        ContactObject[] wrappedResponse = new List<ContactObject> ();
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            wrappedResponse = (ContactObject[]) JSON.deserialize(res.getBody(), ContactObject[].class);
        } else if (res.getStatusCode() == 204) {
            throw new ApiException(String.format('Data not found for client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    clientId, URL_ACCOUNT_CONTACTS, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        } else {
            throw new ApiException(String.format('Error! For client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    clientId, URL_ACCOUNT_CONTACTS, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
        return wrappedResponse;
    }

    /**
     * A method that initiates GET HTTP callout to the external API system using gateway to get a list of
     * client's compliance information.
     *
     * @param clientId - SF idea of the client that the API will call for.
     *
     * @return an instance of wrapper class called GetCustomerValidityInfoResponseWrapper which consists of list of all compliance information
     * in regards to the client, especially the KYC Status.
     */
    public GetCustomerValidityInfoResponseWrapper getCustomerCompliance(Id clientId) {
        Account record = [SELECT id, GUID__c from Account where id = :clientId];
        if (String.isEmpty(record.GUID__c)) {
            return null;
        }
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + String.format(URL_ACCOUNT_COMPLIANCE_CHECKS, new List<String>{
                Uuid.formatValue(record.GUID__C)
        }));
        req.setMethod('GET');
        HttpResponse res = httpService.send(req, 5);
        GetCustomerValidityInfoResponseWrapper wrappedResponse;
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            String response = res.getBody().replace('"Desc":', '"description":');
            wrappedResponse = (GetCustomerValidityInfoResponseWrapper) JSON.deserialize(response, GetCustomerValidityInfoResponseWrapper.class);
        } else if (res.getStatusCode() == 204) {
            throw new ApiException(String.format('Data not found for client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    clientId, URL_ACCOUNT_COMPLIANCE_CHECKS, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        } else {
            throw new ApiException(String.format('Error! For client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    clientId, URL_ACCOUNT_COMPLIANCE_CHECKS, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
        return wrappedResponse;
    }

    /**
     * A method that initiates GET HTTP callout to the external API system using gateway to get a list of
     * client's statuses information.
     *
     * @param clientId - SF idea of the client that the API will call for.
     *
     * @return a list of wrapper class called Status which consists of list of all compliance information
     * in regards to the client, especially the KYC Status.
     */
    public Status[] getCustomerStatuses(Id clientId) {
        Account record = [SELECT id, GUID__c from Account where id = :clientId];
        if (String.isEmpty(record.GUID__c)) {
            return null;
        }
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + String.format(URL_ACCOUNT_STATUSES, new List<String>{
                Uuid.formatValue(record.GUID__C)
        }));
        req.setMethod('GET');
        req.setTimeout(20000);
        HttpResponse res = httpService.send(req, 5);
        Status[] wrappedResponse;
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            String response = res.getBody().replace('"desc":', '"description":');
            wrappedResponse = (Status[]) JSON.deserialize(response, Status[].class);
        } else if (res.getStatusCode() == 204) {
            throw new ApiException(String.format('Data not found for client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    clientId, URL_ACCOUNT_STATUSES, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        } else {
            throw new ApiException(String.format('Error! For client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    clientId, URL_ACCOUNT_STATUSES, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
        return wrappedResponse;
    }

    /**
     * A method that initiates GET HTTP callout to the external API system using gateway to get a list of
     * client's indentification information.
     * US-SGPRT-1010
     *
     * @param clientId - SF idea of the client that the API will call for.
     *
     * @return a list of wrapper class called Address which consists of list of all indentification information
     * in regards to the client.
     */
    public List<Identification> getCustomerIdentifications(Id clientId) {
        Account record = [SELECT Id, GUID__c FROM Account WHERE Id = :clientId];
        if (String.isBlank(record.GUID__c)) {
            throw new ServiceException('Client\'s GUID__c not specified');
        }
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + String.format(URL_ACCOUNT_IDENTIFICATIONS, new List<String>{
                Uuid.formatValue(record.GUID__c)
        }));
        req.setMethod('GET');
        HttpResponse res = httpService.send(req, 5);
        List<Identification> wrappedResponse;
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            String response = res.getBody().replace('"number":', '"IDnumber":');
            wrappedResponse = (List<Identification>) JSON.deserialize(response, List<Identification>.class);
        } else if (res.getStatusCode() == 204 || (res.getStatusCode() == 200 && String.isBlank(res.getBody()))) {
            throw new ApiException(String.format('Data not found for the client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    clientId, URL_ACCOUNT_IDENTIFICATIONS, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        } else {
            throw new ApiException(String.format('Error! For client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    clientId, URL_ACCOUNT_IDENTIFICATIONS, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
        return wrappedResponse;
    }

    /**
     * A method that initiates GET HTTP callout to the external API system using gateway to get basic client's information.
     * US-SGPRT-1010
     *
     * @param guid - client's GUID that the API will call for.
     * @return client's basic information.
     */
    public CustomerBaseResponse getBase(String guid) {
        if (String.isBlank(guid)) {
            throw new ServiceException('Client\'s GUID__c not specified');
        }
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + String.format(URL_ACCOUNT, new List<String>{
                Uuid.formatValue(guid)
        }));
        req.setMethod('GET');
        HttpResponse res = httpService.send(req, 5);
        CustomerBaseResponse wrappedResponse;
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            wrappedResponse = (CustomerBaseResponse) JSON.deserialize(res.getBody(), CustomerBaseResponse.class);
            String encryptedBPID = res.getHeader('obscuredData');
            String token = req.getHeader('authorization').removeStart('Bearer ');
            wrappedResponse.customer.BPID = PBB_SRV_Decryptor.getBPID(encryptedBPID, token);
            return wrappedResponse;
        } else if (res.getStatusCode() == 204 || (res.getStatusCode() == 200 && String.isBlank(res.getBody()))) {
            throw new ApiException(String.format('Data not found for the client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    guid, URL_ACCOUNT, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        } else {
            throw new ApiException(String.format('Error! For client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    guid, URL_ACCOUNT, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
    }

    /**
     * A method that initiates GET HTTP callout to the external API system using gateway to get a list of
     * client's addresses information.
     * US-SGPRT-1010
     *
     * @param clientId - SF idea of the client that the API will call for.
     *
     * @return a list of wrapper class called Address which consists of list of all addresses information
     * in regards to the client.
     */
    public List<Address> getAddresses(Id clientId) {
        Account record = [SELECT Id, GUID__c FROM Account WHERE Id = :clientId];
        if (String.isBlank(record.GUID__c)) {
            throw new ServiceException('Client\'s GUID__c not specified');
        }
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + String.format(URL_ACCOUNT_ADDRESSES, new List<String>{
                Uuid.formatValue(record.GUID__c)
        }));
        req.setMethod('GET');
        HttpResponse res = httpService.send(req, 5);
        if (res.getStatusCode() == 200 && String.isNotBlank(res.getBody())) {
            return (List<Address>) JSON.deserialize(res.getBody(), List<Address>.class);
        } else if (res.getStatusCode() == 204 || (res.getStatusCode() == 200 && String.isBlank(res.getBody()))) {
            throw new ApiException(String.format('Data not found for the client {0}, {1} Got {2} with {3}, body {4}: ', new List<String>{
                    record.Id, URL_ACCOUNT_ADDRESSES, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        } else {
            throw new ApiException(String.format('Error! For client {0}, {1} Got {2} with {3}, body {4}', new List<String>{
                    record.Id, URL_ACCOUNT_ADDRESSES, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
    }

    private HttpRequest buildCallRequest() {
        HttpRequest req = requestProviderService.getRequestWithToken();
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(20000);
        return req;
    }

    public class Identification {
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String IDnumber;
        @AuraEnabled
        public String issuingCountry;
        @AuraEnabled
        public String issuedDate;
        @AuraEnabled
        public String expirationDate;

        public Identification(String type, String IDnumber) {
            this.type = type;
            this.IDnumber = IDnumber;
        }
    }

    public class ContactObject {
        @AuraEnabled
        public String error;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String countryCode;
        @AuraEnabled
        public String extension;
        @AuraEnabled
        public String preferredInd;
        @AuraEnabled
        public String contactPeriod;
        @AuraEnabled
        public String obsoleteInd;
    }

    public class Contacts {
        public ContactObject[] items { get; set; }
    }

    public class Status {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String effDate;
        @AuraEnabled
        public String expDate;
    }

    public class Statuses {
        public Status[] items;
    }

    public class ResponseComplianceType {
        @AuraEnabled
        public String description;
    }

    public class ResponseComplianceStatus {
        @AuraEnabled
        public String description;
    }

    public class ResponseComplianceData {
        @AuraEnabled
        public ResponseComplianceType ComplianceType { get; set; }
        @AuraEnabled
        public ResponseComplianceStatus ComplianceStatus { get; set; }
        @AuraEnabled
        public String ComplianceInd;
    }

    public class ResponsePartyValidityInfoStatus {
        @AuraEnabled
        public String PartyValidityInfoStatusCode;
        @AuraEnabled
        public String StatusDesc;
    }

    public class GetCustomerValidityInfoResponseObject {
        @AuraEnabled
        public ResponseComplianceData[] ComplianceData { get; set; }
        @AuraEnabled
        public ResponsePartyValidityInfoStatus PartyValidityInfoStatus { get; set; }
    }

    public class GetCustomerValidityInfoResponseWrapper {
        @AuraEnabled
        public GetCustomerValidityInfoResponseObject GetCustomerValidityInfoResponse { get; set; }
    }

    public class CustomerBaseResponse {
        public CustomerBase customer;
    }

    public class CustomerBase {
        public String uuid;
        public String BPID;
        public String customerType;
        public CustomerOrgDetails orgDetails;
        public Integer mktgSegment;
        public List<CustomerRole> customerRole;
        public String relManagerLink;
    }

    public class CustomerOrgDetails {
        public CustomerOrgDetails(String legalName, String companyName, String legalForm) {
            this.legalName = legalName;
            this.companyName = companyName;
            this.legalForm = legalForm;
        }

        public String legalName;
        public String companyName;
        public String legalForm;
    }

    public class CustomerRole implements Comparable {
        public String role;
        public String startDate;
        public String endDate;

        public CustomerRole(String role, String startDate, String endDate) {
            this.role = role;
            this.startDate = startDate;
            this.endDate = endDate;
        }

        public Integer compareTo(Object compareTo) {
            CustomerRole compareToCustomerRole = (CustomerRole) compareTo;
            if (compareToCustomerRole.endDate < endDate) {
                return 0;
            }
            return 1;
        }
    }

    public class Address implements Comparable {
        public String line1;
        public String province;
        public String city;
        public String postalCode;
        public String endDate;
        public String countryCode;

        public Address(String line1, String province, String city, String postalCode, String endDate, String countryCode) {
            this.line1 = line1;
            this.province = province;
            this.postalCode = postalCode;
            this.city = city;
            this.endDate = endDate;
            this.countryCode = countryCode;
        }

        public Integer compareTo(Object compareTo) {
            Address compareToCustomerRole = (Address) compareTo;
            if (compareToCustomerRole.endDate < endDate) {
                return 0;
            }
            return 1;
        }
    }
}