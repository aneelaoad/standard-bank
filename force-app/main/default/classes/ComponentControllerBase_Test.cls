/**
 	@ Author        : Charles Mutsu
    @ Date          : 21/1/2014
    @description   : Created for Test Coverage of ComponentControllerBase class
 */
@isTest
private class ComponentControllerBase_Test {

    @IsTest
    static void componentControllerBasePositiveTest() {
        Boolean isExceptionThrown = false;
        try {
            ComponentControllerBase testComponentControllerBase = new ComponentControllerBase();
            PageControllerBase testPageControllerBase = new PageControllerBase();
            testPageControllerBase.getThis();
            testComponentControllerBase.pageController = testPageControllerBase.getThis();
            testComponentControllerBase.key = 'Test';
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }
}