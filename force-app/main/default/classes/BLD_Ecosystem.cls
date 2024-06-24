/**
*
* @ModifiedBy Emmanuel Mulea Nocks(BlueSky)
* @date April 2021
* @description This is a builder class for Ecosystem custom object
*/
@IsTest
public without sharing class BLD_Ecosystem extends ABS_ObjectBuilderBase{

    public BLD_Ecosystem() {
        this(getNewUnitOfWork());        
    }

    public BLD_Ecosystem(fflib_SObjectUnitOfWork workUnit) { 
        super(Ecosystem__c.sObjectType, workUnit);
    }

    private BLD_Ecosystem(Ecosystem__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    public BLD_Ecosystem groupNumber(String groupNumber){
    	return (BLD_Ecosystem)setField(Ecosystem__c.Relationship_Group_Number__c, groupNumber);
    }
    public BLD_Ecosystem groupName(BLD_Account groupName){
    	return (BLD_Ecosystem)setRelation(Ecosystem__c.Client_Name__c, groupName);
    }
}