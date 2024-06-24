/**
 * @description       : Test for CTRL_EventOverrideAction
 * @author            : Derek Hughes
 * @group             : Test
 * @last modified on  : 07-05-2023
 * @last modified by  : Derek Hughes
**/
@IsTest
public with sharing class CTRL_EventOverrideAction_TEST {
     
    private static User currentUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];

    /**
    * @description Test the controller
    * @author Derek Hughes | 04-05-2023 
    **/
    @IsTest
    static void testController() {
        
        Boolean exceptionCaught = false;

        Test.startTest();

            CTRL_EventOverrideAction.actionOverrideResult result = CTRL_EventOverrideAction.getActionOverride('new', NULL, UserInfo.getUserId());
            try {
                CTRL_EventOverrideAction.actionOverrideResult result2 = CTRL_EventOverrideAction.getActionOverride('new', NULL, '001000000000000');
            }
            catch (Exception e) {
                exceptionCaught = true;
            }
        Test.stopTest();

        Assert.areEqual(currentUser.Profile.Name, result.profileName, 'Incorrect profile returned.');
        Assert.areNotEqual('n/a', result.overrideUrl, 'URL should be n/a for new action.');

    }

}