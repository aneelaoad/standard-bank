/**
* @description       : Internal DTO class for create Contract
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 08-11-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification Description: SFP-25088
* 1.0   03-17-2023   Tukelo Moseamo   Initial Version
**/
public class AOB_Internal_DTO_CreateContract{

    /*
    *@description Contract transformation request
    */
    public class DTO_Request {
        public DTO_CreateContractRequest createContractRequest;
    }   

    /*
    *@description Contract transformation object
    */
    public class DTO_CreateContractRequest {
		public String digitalOfferID;
		public AOB_DTO_StaffAssistedOnboarding.DTO_User user;
	}

    /*
    *@description Contract transformation object
    */
    public class DTO_Response {
        public DTO_CreateContractResponse createContractResponse;
    }

    /*
    *@description Contract Response transformation object
    */
    public class DTO_CreateContractResponse {
		public DTO_OrchestrationHeaderResponse orchestrationHeaderResponse;
		public List<DTO_Contracts> contracts;
	}

    /*
    *@description ResponseStatus transformation object
    */
	public class DTO_ResponseStatus {
        @AuraEnabled
		public String severity;
        @AuraEnabled
		public String serverStatusCode;
        @AuraEnabled
        public String variant;
        @AuraEnabled
		public String statusDescription;
        @AuraEnabled
		public String statusCode;
	}

    /*
    *@description OrchestrationHeaderResponse transformation object
    */
	public class DTO_OrchestrationHeaderResponse {
		public String requestTimeStamp;
		public String responseTimeStamp;
		public String correlationId;
		public DTO_ResponseStatus responseStatus;
		public List<DTO_ErrorResponse> errorResponse;
		public String channelId;
	}

    /*
    *@description Contract transformation object
    */
	public class DTO_Contracts {
		public String documentCode;
		public String itemId;
		public String documentId;
		public String documentName;
	}

    /*
    *@description Error transformation object
    */
	public class DTO_ErrorResponse {
		public String step;
		public String responseMessage;
		public String stepStatus;
	}

}