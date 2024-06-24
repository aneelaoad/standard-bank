/**
 * Test class for OSB_SolutionCaseImage class
 *
 * @author Milica Milicevic(milica@ignitesolutions.co.za)
 * @date February 2022
 */
@IsTest(IsParallel=true)
public class OSB_SolutionCaseImage_Test {
    @IsTest
    static void shouldgetImageUrl(){
        string url = '<img alt="Test.png" src="/servlet/rtaImage?eid=ka03N000000Gx1J&amp;feoid=00N2X0000091RwL&amp;refid=0EM3N000000Irgk"></img>';
        string test_src = '/servlet/rtaImage?eid=ka03N000000Gx1J&feoid=00N2X0000091RwL&refid=0EM3N000000Irgk';
        Test.startTest();
        string result = OSB_SolutionCaseImage.getImageURL(url);
        Test.stopTest();
        System.assertEquals(test_src, result);
    }

}