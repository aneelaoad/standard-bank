/**
 * Created by zwalczewska on 08.05.2020.
 */

public without sharing class BLD_PbbNoteTypes extends ABS_ObjectBuilderBase {

    public static final String DEF_NAME = 'testNoteType';

    public BLD_PbbNoteTypes() {
        this(getNewUnitOfWork());
    }

    public BLD_PbbNoteTypes(fflib_SObjectUnitOfWork workUnit) {
        super(PBB_Note_Types__c.sObjectType, workUnit);
        setDefaultData();
    }

    public BLD_PbbNoteTypes(PBB_Note_Types__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    protected override void setDefaultData() {
        setField(PBB_Note_Types__c.Name, DEF_NAME);
    }

    public BLD_PbbNoteTypes name(String value) {
        return(BLD_PbbNoteTypes) setField(PBB_Note_Types__c.Name, value);
    }

    public BLD_PbbNoteTypes noteTypeName(String value) {
        return(BLD_PbbNoteTypes) setField(PBB_Note_Types__c.Note_Type_Name__c, value);
    }

    public BLD_PbbNoteTypes accountNotepad(Boolean value) {
        return(BLD_PbbNoteTypes) setField(PBB_Note_Types__c.Account_Notepad__c, value);
    }

    public BLD_PbbNoteTypes customerNotepad(Boolean value) {
        return(BLD_PbbNoteTypes) setField(PBB_Note_Types__c.Customer_Notepad__c, value);
    }
}