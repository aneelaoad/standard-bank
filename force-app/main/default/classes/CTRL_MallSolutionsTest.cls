@isTest
public with sharing class CTRL_MallSolutionsTest {
@isTest
    static void testGetSolutionLinks() {
    
        Test.startTest();
        List<CTRL_MallSolutions.DenormalizedSolutionLink> solutionLinks = CTRL_MallSolutions.getSolutionLinks();
        Test.stopTest();
    }
}