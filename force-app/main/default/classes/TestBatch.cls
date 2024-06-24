/*****************************************************************************************************\
    @ Author        : Jonathan Brayshaw  
    @ Date          : 27/02/2008
    @description   :
   
    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : Mar 2013
    @ Last Modified Reason  : Implemented TestDataUtility Class  
                              Changed the version from 20 to 27. 
******************************************************************************************************/
@IsTest
private class TestBatch {

    @IsTest
    static void testBatchAction() {
        try {
            insert new Batch_Operation__c(Object__c='Sales_Credit');
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

}