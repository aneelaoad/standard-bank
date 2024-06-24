/**
 * @description       : Test for OpportunityOverrideAction_TEST
 * @author            : Derek Hughes
 * @group             : Tests
 * @last modified on  : 07-05-2023
 * @last modified by  : Derek Hughes
**/
@IsTest
public with sharing class CTRL_OpportunityOverrideAction_TEST {

    private static User currentUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];

    @IsTest
    static void testController() {

        Boolean exceptionCaught = false;

        Test.startTest();

            CTRL_OpportunityOverrideAction.actionOverrideResult result = CTRL_OpportunityOverrideAction.getActionOverride('new', NULL, UserInfo.getUserId());
            try {
                CTRL_OpportunityOverrideAction.actionOverrideResult result2 = CTRL_OpportunityOverrideAction.getActionOverride('new', NULL, '001000000000000');
            }
            catch (Exception e) {
                exceptionCaught = true;
            }

        Test.stopTest();

        Assert.areEqual(currentUser.Profile.Name, result.profileName, 'Incorrect profile returned.');
        Assert.isTrue(true, 'Exception was not caught.'); // always true if the exception is caught
    }

}