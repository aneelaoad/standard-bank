@IsTest
public without sharing class BLD_EcosystemEntity extends ABS_ObjectBuilderBase{

    public BLD_EcosystemEntity() {  
        this(getNewUnitOfWork());        
    }

    public BLD_EcosystemEntity(fflib_SObjectUnitOfWork workUnit) { 
        super(Ecosystem_Entity__c.sObjectType, workUnit);
    }

    private BLD_EcosystemEntity(Ecosystem_Entity__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    public BLD_EcosystemEntity ecosystem(String ecosystemId){
    	return (BLD_EcosystemEntity)setField(Ecosystem_Entity__c.Ecosystem__c, ecosystemId); 
    }

    public BLD_EcosystemEntity client(String accountId){
    	return (BLD_EcosystemEntity)setField(Ecosystem_Entity__c.Entity__c, accountId); 
    }

    public BLD_EcosystemEntity entityType(String entityType){
    	return (BLD_EcosystemEntity)setField(Ecosystem_Entity__c.Entity_Type__c, entityType); 
    }

    public BLD_EcosystemEntity ecosystem(BLD_Ecosystem ecosystemBuilder) {
        return(BLD_EcosystemEntity) setRelation(Ecosystem_Entity__c.Ecosystem__c, ecosystemBuilder);
    }

}