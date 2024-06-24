public class PBB_SRV_GatewayAPI_GetNotes implements IService {
    private static final SRV_HttpRequestSender.IService httpService = SRV_HttpRequestSender.newInstance();
    private static final PBB_SRV_GatewayRequestProvider.IService requestProviderService = PBB_SRV_GatewayRequestProvider.newInstance();

    private static final String URL_GET_NOTES = '/notepad/notes/{0}?{1}&note-type=CUSTOMER&index={2}&offset={3}';
    private static final String URL_POST_NOTES = '/notepad/notes/';

    public interface IService {
        Response getNotes(Id contextId, Integer pageNumber, Integer pagesize, String[] categories);
        Integer createNote(Id accountId, String body, String category);
    }

    public static IService newInstance() {
        return(IService) ORG_Application.service.newInstance(IService.class);
    }

    public class ApiException extends Exception {
    }

    public Response getNotes(Id contextId, Integer pageNumber, Integer pagesize, String[] categories) {
        String queriedId;
        if (contextId.getSobjectType() == Account.getSobjectType()) {
            Account record = [SELECT id, GUID__c FROM Account WHERE id = :contextId];
            queriedId = Uuid.formatValue(record.GUID__c);
        } else {
            return null;
        }
        HttpRequest req = buildCallRequest();
        String[] categoriesEncodedWithParam = new List<String> ();
        for (String cat : categories) {
            categoriesEncodedWithParam.add('categories=' + EncodingUtil.urlEncode(cat, 'UTF-8'));
        }
        req.setEndpoint('callout:gatewaynp' + String.format(URL_GET_NOTES, new List<String>{
                queriedId, String.join(categoriesEncodedWithParam, '&'), String.valueOf(pageNumber), String.valueOf(pagesize)
        }));
        req.setMethod('GET');
        HttpResponse res = httpService.send(req, 2);
        if (res.getStatusCode() == 200) {
            Response response = (Response) JSON.deserialize(res.getBody(), Response.class);
            return response;
        } else {
            throw new ApiException(String.format('Error! For client {0} Got {1} with {2}, body {3}', new List<String>{
                    contextId, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
    }

    public Integer createNote(Id accountId, String body, String category) {
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + URL_POST_NOTES);
        req.setMethod('POST');
        Account relatedAccount = [SELECT GUID__c FROM Account WHERE Id = :accountId];
        User userRecord = [SELECT Id, EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()];
        NoteRequest noteToCreate = new NoteRequest();
        CustomerNotepad customerNotepad = new CustomerNotepad();
        customerNotepad.id = Uuid.formatValue(relatedAccount.GUID__c);
        customerNotepad.customerNoteType = category;
        noteToCreate.comments = body;
        noteToCreate.notepadType = 'CUSTOMER';
        noteToCreate.customer = customerNotepad;
        if (String.isNotBlank(userRecord.EmployeeNumber)) {
            noteToCreate.user = userRecord.EmployeeNumber;
        } else {
            throw new ApiException('You cannot create note, Please contact System Administrator.');
        }
        req.setBody(JSON.serialize(noteToCreate));
        HttpResponse res = httpService.send(req, 5);
        if (res.getStatusCode() != 201) {
            throw new ApiException(String.format('Error! For client {0} Got {1} with {2}, body {3}', new List<String>{
                    accountId, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
        return res.getStatusCode();
    }

    private HttpRequest buildCallRequest() {
        HttpRequest req = requestProviderService.getRequestWithToken();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(45000);
        return req;
    }

    public class Response {
        @AuraEnabled
        public SapNote[] notes { get; Set; }
        @AuraEnabled
        public Integer offset;
        @AuraEnabled
        public Integer index;
        @AuraEnabled
        public Boolean remainingPage;
    }

    public class SapNote {
        @AuraEnabled
        public String noteDatedOn;
        @AuraEnabled
        public String noteDate;
        @AuraEnabled
        public String noteTime;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String noteDetails;
        @AuraEnabled
        public String noteCreatedBy;

    }

    private class NoteRequest {
        public String comments;
        public CustomerNotepad customer;
        public String notepadType;
        public String user;
    }

    private class CreateNoteResponse {
        public Integer StatusCode;
    }

    private class AccountNotepad {
        public String accountNoteType;
        public String id;
        public String name;
    }

    private class CustomerNotepad {
        public String customerNoteType;
        public String id;
    }
}