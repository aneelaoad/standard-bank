/**
 * Builder class for Child_products__c
 *
 * @author      Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date        July 2021
 */
@isTest
public without sharing class BLD_Child_Products extends ABS_ObjectBuilderBase{
	public static final String DEF_TITLE = 'Test article';
    public static final String DEF_INTRODUCTION = 'Test introduction';
    public static final String DEF_URL = 'Test url';
    public static final String DEF_URL_NAME = 'Test name';
    private static final String TEST_URL_NAME = 'TestURL';
    
    public BLD_Child_Products() { 
		this(getNewUnitOfWork());        
	}
    
    public BLD_Child_Products(fflib_SObjectUnitOfWork uow) {
        super(Child_products__c.SObjectType, uow);
    }

    public BLD_Child_Products(Child_products__c sol, fflib_SObjectUnitOfWork uow) {
        super(sol, uow);
    }
    
    public BLD_Child_Products setOSBData() {
        
        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
                .setOSBData()
                .isComingSoon(false)
                .setField(Knowledge__kav.UrlName, TEST_URL_NAME)
                .setField(Knowledge__kav.RecordtypeId, UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API))
                .commitWork().getRecord();

        return (BLD_Child_Products) 
                setField(Child_products__c.Knowledge_Parent__c, article.Id);
    }
}