/**
 * @description       : check complaince DTO class
 * @author            : Tukelo Moseamo
 * @group             : 
 * @last modified on  : 06-08-2023
 * @last modified by  : Tukelo Moseamo
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
**/
public with sharing class AOB_DTO_Internal_CheckComplianceRP {
    
   /**
	 * @description Request DTO
	 */
	public class DTO_Request
	{
		public DTO_CheckComplainceRPRequest checkComplianceRPandShareholderRequest;
	}
    
    /**
	 * @description Check Complaince request
	 */
	public class DTO_CheckComplainceRPRequest
	{
		public String  businessBPID;
		public AOB_DTO_StaffAssistedOnboarding.DTO_User user;

	}

}