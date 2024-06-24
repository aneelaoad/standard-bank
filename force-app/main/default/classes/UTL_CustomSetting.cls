/***
    @ Func Area         : Custom Settins 
    @ Author            : Artur Kępczynski 
    @ Date              : 08.2017   
    @ Specification     : wrapper class to serve as proxy for Custom settings we want to replace in future.
***/
public without sharing class UTL_CustomSetting {

	private static Environment_Variable__c env{
												get{
													if(env == null){
														env = Environment_Variable__c.getInstance();
													}
													return env;
												}
												set;
											}						
	 
	public static Id getPbbUserId(){
		return env.CCRejectionPBBUserID__c;
	}

	public static Id getSfAdminUserId(){
		return env.Salesforce_Administration_Id__c;
	} 

	public static Id getApiUserProfileId(){
		return env.CCRejectionProfileID__c;
	} 
}