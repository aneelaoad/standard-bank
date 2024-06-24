/**
* Test class for OSB_Maintenance Visualforce controller
*
* @author Wayde Fagan (wayde.fagan@tetrad.co.za)
* @date December 2020
*
**/
@IsTest
private class OSB_Maintenance_CTRL_Test {
    
	@isTest
	static void getImageResourceOne() {
        Test.startTest();
        OSB_Maintenance_CTRL controller = new OSB_Maintenance_CTRL();
		String resultLogo = controller.getImageLogo();
        Test.stopTest();
        System.assertNotEquals(null, resultLogo);
    } 
    
    @isTest
	static void getImageResourceTwo() {
        Test.startTest();
        OSB_Maintenance_CTRL controller = new OSB_Maintenance_CTRL();
		String resultImage = controller.getImageName();
        Test.stopTest();
        System.assertNotEquals(null, resultImage);
    }
}