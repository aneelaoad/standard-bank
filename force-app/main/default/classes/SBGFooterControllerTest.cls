@isTest
public class SBGFooterControllerTest {
    
     /*
	 * @description This method queries all the SBG Sub footer Item 
	 * @param : None
	 * Author:sai praveen
	 *Date:13/10/2022
	 */
    @isTest
    static void getFooterItemsTest(){
        Test.startTest();
        List<SBGFooterBarController.FooterItem> footerItemList = SBGFooterBarController.getFooterItems();
        Assert.isTrue(footerItemList!=null, 'message');
        Test.stopTest();
    }    
}