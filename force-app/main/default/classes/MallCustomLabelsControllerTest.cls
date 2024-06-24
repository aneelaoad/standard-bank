/**
 * 
 * @description Test Class for MallCustomLabelsController
 * @author Ankit Kumar
 * @since 
 */
@isTest
private with sharing class MallCustomLabelsControllerTest {

    @isTest
    public static void testGetCustomLabels() {
        Test.startTest();
        List<Unsupported_Language_Translation__mdt> labels = MallCustomLabelsController.getCustomLabels();
        Assert.isTrue(labels.size() > 0,'labels created');
        Test.stopTest();
    }
   
}