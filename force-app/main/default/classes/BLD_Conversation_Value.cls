/**
* @description  Build class for SEL_Conversations_Value.
*
* @author       Sandile Mathe
* @date         April 2021
*/
@isTest(IsParallel=true)
public class BLD_Conversation_Value extends ABS_ObjectBuilderBase {
	
	/**
	* This method Serve object pointer
	**/
	public BLD_Conversation_Value() {
		this(getNewUnitOfWork());
	}
	
	/**
	* This method Serve as pointer for Object type
	* @param   workUnit for fflib_SObjectUnitOfWork
	**/
	public BLD_Conversation_Value(fflib_SObjectUnitOfWork workUnit) {
		super(Conversation_Value__c.sObjectType, workUnit);
	}
	
	/**
	* This method for Build Class to Commit Changes
	* @param  sObj  
	* @param  workUnit 
	**/
	public BLD_Conversation_Value(Conversation_Value__c sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}
	
	/**
	* This method for Build Class to return Sub Category
	* @param    subcategory string
	* @return   Build Class for Conversation Value
	**/
	public BLD_Conversation_Value subcategory(String subcategory) {
		setField(Conversation_Value__c.Sub_Category__c, subcategory);
		return(BLD_Conversation_Value) this;
	}
	
	/**
	* This method for Build Class to return Reason
	* @param    reason string
	* @return   Build Class for Conversation Value
	**/
	public BLD_Conversation_Value reason(String reason) {
		setField(Conversation_Value__c.Reason__c, reason);
		return(BLD_Conversation_Value) this;
	}
	
	/**
	* This method for Build Class to return Response
	* @param    response string
	* @return   Build Class for Conversation Value
	**/
	public BLD_Conversation_Value response(String response) {
		setField(Conversation_Value__c.Response__c, response);
		return(BLD_Conversation_Value) this;
	}
	
	
}