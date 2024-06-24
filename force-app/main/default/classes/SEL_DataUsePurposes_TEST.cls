/**
 * Selector layer class for DataUsePurpose SObject
 *
 * @author 
 * @date 2023-8-20
 */
@isTest
private class SEL_DataUsePurposes_TEST {
    @TestSetup
    private static void createTestData() {        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();                              
        
        DataUsePurpose dup= new DataUsePurpose();
        dup.Name = 'Direct Marketing';
        dup.IsActive =false;
        uow.registerNew(dup);

        uow.commitWork();
    }
    
    @isTest
    static void selectIdByDataUsePurposeNameTest() {
        Assert.isFalse(String.isNotBlank(SEL_DataUsePurposes.newInstance().selectIdByDataUsePurposeName('')));
        Assert.isTrue(String.isNotBlank(SEL_DataUsePurposes.newInstance().selectIdByDataUsePurposeName('Direct Marketing')));
    }

}