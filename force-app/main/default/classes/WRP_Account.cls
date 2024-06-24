/**
* @LastModifiedBy Emmanuel Mulea Nocks(BlueSky)
* @date Oct 2021
* @description This class determines account record properties
*/
public class WRP_Account extends WRP_SObject{

	private String gtRequestCode;
	/**
	* WRP_Account constructor
	* @param record Account
	*/
	public WRP_Account(Account record) {
		super(record);
	}
	/**
	* get account record
	* @return Account
	*/
	public Account getRecord(){
		return (Account)record;
	}
	/**
	* checks if is an ultimate group parent
	* @return Boolean
	*/
	public Boolean isUltimateGroupParent(){
		return getRecord()!=null 
				&& getRecord().RecordType.DeveloperName == DMN_Account.RT_ULTIMATE_PARENT;  
	}
	/**
	* checks if is immediate parent
	* @return Boolean
	*/
	public Boolean isImmediateParent(){
		return getRecord()!=null 
				&& getRecord().RecordType.DeveloperName == DMN_Account.RT_IMMEDIATE_PARENT; 
	}
	/**
	* checks if is a child
	* @return Boolean
	*/
	public Boolean isChild(){
		return getRecord()!=null 
				&& getRecord().RecordType.DeveloperName == DMN_Account.RT_CHILD; 
	}
	/**
	* checks if is an economic group parent
	* @return Boolean
	*/
	public Boolean getIsEconomicGroupParent(){
		return (getRecord()!=null 
				&& getRecord().Name == getRecord().Economic_Group_Parent_Client_Name__c); 
	}
	/**
	* checks if is a commB record
	* @return Boolean
	*/
	public Boolean isCommB(){
		return (getRecord().primary_relationship_holder__c == DMN_Account.PRIMARY_REL_HOLDER_COMMB);
	}
	/**
	* checks if is a businessB record
	* @return Boolean
	*/
	public Boolean isBusinessB(){
		return (getRecord().primary_relationship_holder__c == DMN_Account.PRIMARY_REL_HOLDER_BUSINESS);
	}
	/**
	* checks if is a CIB record
	* @return Boolean
	*/
	public Boolean isCIB(){
		return (getRecord().primary_relationship_holder__c == DMN_Account.PRIMARY_REL_HOLDER_CIB);
	}
	/**
	* Suveer Mohunlal C-00002569 Changed contains to equals on 'Client' to prevent 'Potential Client' from getting Potential (Goldtier) record type
	* @return Boolean
	*/
	public Boolean isSARelationshipRoles(){
		return getRecord().Relationship_Roles__c != null
                && ( getRecord().Relationship_Roles__c.equals(DMN_Account.REL_ROLE_CLIENT)
                    || getRecord().Relationship_Roles__c.contains(DMN_Account.REL_ROLE_CORRESPONDING_BANK)
                    || getRecord().Relationship_Roles__c.contains(DMN_Account.REL_ROLE_MANAGED_FUND) 
                    );
	}
	/**
	* get GT Request Code
	* @return string
	*/
	public String getGTRequestCode(){
		if(gtRequestCode==null){
			String locationCode = getRecord().KYC_Location__c.split('-',2)[0].trim();
	        String gtRequestKey = DMN_Account.GT_REQ_CODE_PREFIX+locationCode;
	        SB_Parameters__c gtRequestCodeSettings = SB_Parameters__c.getValues(gtRequestKey);
	        if(gtRequestCodeSettings!=null) {
				gtRequestCode = gtRequestCodeSettings.Value__c;
			}
		}

		return gtRequestCode;
	}
}