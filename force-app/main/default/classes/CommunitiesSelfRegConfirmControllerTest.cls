/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest
public with sharing class CommunitiesSelfRegConfirmControllerTest {
    @IsTest
    static void testCommunitiesSelfRegConfirmController() {
        Boolean isExceptionThrown = false;
        try{
            CommunitiesSelfRegConfirmController controller = new CommunitiesSelfRegConfirmController();
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
      }
}