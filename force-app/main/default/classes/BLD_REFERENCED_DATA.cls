/**
 * @description buidler class for AOB_REFERENCED_DATA__c
 * @author Emmanuel Mulea
 * @date Aug19 July 2023
 */
@isTest
public without sharing class BLD_REFERENCED_DATA extends ABS_ObjectBuilderBase{

   /**
    * @description :constructor
    *
    */
	public BLD_REFERENCED_DATA() {
		this(getNewUnitOfWork());
	}

   /**
    * @description : overloaded constructor
    *
    */
    public BLD_REFERENCED_DATA(fflib_SObjectUnitOfWork workUnit) {
        super(AOB_ReferencedData__c.SObjectType, workUnit);
    }

    /**
	* @description  :set AOB_Value__c
	* @param value string
	* @return BLD_REFERENCED_DATA 
	**/
	public BLD_REFERENCED_DATA setAOBValue(String value){
		return (BLD_REFERENCED_DATA)setField(AOB_ReferencedData__c.AOB_Value__c, value);

    }

    /**
	* @description : set AOB_Code__c
	* @param code string
	* @return BLD_REFERENCED_DATA 
	**/
	public BLD_REFERENCED_DATA setAOBCode(String code){
		return (BLD_REFERENCED_DATA)setField(AOB_ReferencedData__c.AOB_Code__c, code);

    }

    /**
	* @description set AOB_SAPExternalID__c
	* @param externalId string
	* @return BLD_REFERENCED_DATA 
	**/
	public BLD_REFERENCED_DATA setAOBSAPExternalId(String externalId){
		return (BLD_REFERENCED_DATA)setField(AOB_ReferencedData__c.AOB_SAPExternalID__c, externalId);

    }

    /**
	* @description :set AOB_SAPField__c
	* @param field string
	* @return BLD_REFERENCED_DATA 
	**/
	public BLD_REFERENCED_DATA setAOBSAPField(String field){
		return (BLD_REFERENCED_DATA)setField(AOB_ReferencedData__c.AOB_SAPField__c, field);

    }
}