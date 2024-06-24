@IsTest
public without sharing class BLD_Role extends ABS_ObjectBuilderBase{

	public BLD_Role() { 
		this(getNewUnitOfWork());        
	}

    public BLD_Role(fflib_SObjectUnitOfWork workUnit) { 
        super(UserRole.SObjectType, workUnit);
    }

    private BLD_Role(UserRole sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    protected override void setDefaultData(){
    	name('Test', 'Test');
    }

	public BLD_Role name(String name){
		return name(name, null);
	}

	public BLD_Role name(String name, String devName){
		devName = devName == null ? name : devName;

		return (BLD_Role)setField(UserRole.Name, name).setField(UserRole.DeveloperName, devName);
	}

	public class BuilderRoleException extends Exception {}
}