/**
 * 
 * @description Test Class for MallAboutUsContainerCtrl
 * @author Ankit Kumar
 * @since 
 */
@isTest
public with sharing class MallAboutUsContainerCtrlTest {
    
    @isTest
    public static void testGetAboutUsValuePropositions() {
        Test.startTest();
        List<Mall_About_Us_Value_Proposition__mdt> valueProps = MallAboutUsContainerCtrl.getAboutUsValuePropositions();
        Assert.areEqual(4, valueProps.size(),'should be 4');
        Test.stopTest();
    }
}