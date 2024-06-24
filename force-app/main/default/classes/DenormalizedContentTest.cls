/**
 * 
 * @description Test Class for DenormalizedContent
 * @author Maham Hasan
 * @since 
 */
@isTest
public class DenormalizedContentTest {

    /**
   * 
   * @description denormalizedContentTest
   */

 @IsTest
    static void getdenormalizedContentTest(){
        
       
        Test.startTest();
        DenormalizedContent denormalizedContent = new DenormalizedContent();
        Test.stopTest();

        Assert.areNotEqual(null, denormalizedContent, 'Expected Outcome');
        
    }
}