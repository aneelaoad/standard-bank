/**
* @description  Wrapper Class for Creating Contract API
* @author Dayakar
* @date  11-12-2022 
*/
public class AOB_DTO_Contract{
    
    public class CreateContractRequest {
		public HeaderDetails headerDetails;
		public String offerId;
	}

	public CreateContractRequest createContractRequest;

	public class HeaderDetails {
		public String requestCorrelation;
		public String originatorName;
		public SecurityDetails securityDetails;
		public Integer digitalId;
		public String respondToAddress;
		public String sourcePlatform;
		public String processType;
		public Boolean isSynchronous;
		public String channelId;
		public String customerInterface;
		public String requestTraceId;
	}

	public class SecurityDetails {
		public Boolean generateToken;
		public String tokenType;
		public String accessToken;
	}


}