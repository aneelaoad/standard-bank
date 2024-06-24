@IsTest
public without sharing class BLD_PermissionSet extends ABS_ObjectBuilderBase{
    public BLD_PermissionSet() {
        this(getNewUnitOfWork());
    }

    public BLD_PermissionSet(fflib_SObjectUnitOfWork workUnit) {
        super(PermissionSet.sObjectType, workUnit);
    }

    private BLD_PermissionSet(PermissionSet sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    public  BLD_PermissionSet name(String nameVal){
        return (BLD_PermissionSet) setField(PermissionSet.Name, nameVal);
    }
    public  BLD_PermissionSet label(String labelVal){
        return (BLD_PermissionSet) setField(PermissionSet.Label, labelVal);
    }
}