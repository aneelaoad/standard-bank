/**
 * API Update Rp details Configuration
 * 
 * @author Salesforce
 *
 * @date Oct 29th 2021
 */
public class AOB_DTO_UpadteRPDetails{
    
    public class Relationships {
		public String relationshipTypeCode;
	}

	public String inflightCustomerDataID;
	public List<PersonalDetails> personalDetails;
	

	public class PersonalDetails {
		public String customerUUID;
		public List<Relationships> relationship;
	}

	
	

}