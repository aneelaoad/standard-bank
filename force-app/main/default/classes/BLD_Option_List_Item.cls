/**
 * Builder class for Option List Item object.
 * <br/>SGPRT-3817
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date January 2021
 */
@IsTest
public with sharing class BLD_Option_List_Item extends ABS_ObjectBuilderBase{


    public BLD_Option_List_Item() {
        this(getNewUnitOfWork());
    }

    public BLD_Option_List_Item(fflib_SObjectUnitOfWork workUnit) {
        super(Option_List_Item__c.SObjectType, workUnit);
    }

    public BLD_Option_List_Item(Option_List_Item__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit);
    }

    public BLD_Option_List_Item name(String name) {
        return(BLD_Option_List_Item) setField(Option_List_Item__c.Name, name);
    }

    public BLD_Option_List_Item proftCenterObject(String proftCenterObject) {
        return(BLD_Option_List_Item) setField(Option_List_Item__c.Object__c, proftCenterObject);
    }

    public BLD_Option_List_Item companyCode(Integer companyCode) {
        return(BLD_Option_List_Item) setField(Option_List_Item__c.Company_Code__c, companyCode);
    }

}