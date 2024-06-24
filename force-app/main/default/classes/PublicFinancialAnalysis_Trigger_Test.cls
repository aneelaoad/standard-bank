/**
    @ Author                   : Charles Mutsu
    @ Date                     : 03/05/2014
    @ Description              : PublicFinancialAnalysis_Trigger_Test
                      Trigger  : PublicFinancialAnalysis_Trigger
                      Class    : PublicFinancialAnalysis_TriggerFunctions 
 */
@isTest(SeeAllData=false)
private class PublicFinancialAnalysis_Trigger_Test {

    static testMethod void spreadPacPFATest() {
        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild();

        new BLD_ClientFinancialAnalysis(uow).useSpread()
            .client(accBld);

        uow.commitWork();

        try{
            new BLD_ClientFinancialAnalysis(uow).useManual()
                .client(accBld)
                .commitWork();
        }catch(Exception e){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0) );
        }
        
    } 
    
    static testMethod void manualPFATest() {

        BLD_Account accBld = (BLD_Account) new BLD_Account().useChild().commitWork();

        new BLD_ClientFinancialAnalysis().useManual()
            .client(accBld)
            .commitWork();
        try{
            new BLD_ClientFinancialAnalysis().useManual()
                .client(accBld)
                .commitWork();
        }catch(Exception e){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0) );
        }

        new BLD_ClientFinancialAnalysis().useSpread()
            .client(accBld)
            .commitWork();
        
    } 
}