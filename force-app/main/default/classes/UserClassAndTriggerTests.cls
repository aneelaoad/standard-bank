/*************************************************************************\
    @Author        :     Anurag Jain
    @Date          :     23 June 2011
    @Test File     :     N/A
    @description   :     Test Class for User object Inserts / Updates.
    
    @ Last Modified By  : Anurag Jain  
    @ Last Modified On  : 17 Aug 2011  
    @ Last Modified Reason  : The method in UserTriggerUtility class was changed to future method. 
                              Modification in this Test class were made to include the StartTest() and StopTest() statements.
                              
    @ Last Modified By  : Charles Mutsu  
    @ Last Modified On  : 25 Feb 2013  
    @ Last Modified Reason  : TestDataUtilityClass class was implemented to generate test data for User and Cases. 
                              Changed the version from 20 to 27.  
    
    @ Last Modified By:     Vishnu Vundavalli
    @ Last Modified On:     27 July 2015
    @ Last Modified Reason: EN-0606 - Removing CFX and FX references as a part of CFX and FX decomissioning

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015 
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By  : Maciej Dudek
    @ Last Modified On  : Aug 24, 2021
    @ Modification Description : Added test methods for isUserChanged and needsContactUpdate methods, refactored code for
   PMD compliance.
****************************************************************************/
@isTest
private class UserClassAndTriggerTests {

    @IsTest
    static void testUserTriggerUtility() {
        User user1 = (User) new BLD_USER().useSysAdmin().commitWork().getRecord();
        Boolean isDMLSuccessful;
        System.runAs(user1) {
            try {
                Case caseRec = (Case) new BLD_Case().useChangeRequest().commitWork().getRecord();
                Test.StartTest();
                user1.City = 'johannesburg';
                user1.Sync_with_Contact__c = true;
                update user1;
                Test.StopTest();
                caseRec.Status = 'Closed';
                update caseRec;
                isDMLSuccessful = true;
            }
            catch(Exception ex) {
                isDMLSuccessful = false;
            }
        }
        System.assert(isDMLSuccessful);
    }

    @IsTest
    static void testIsFieldOnUserChanged() {
        User userOld = (User) new BLD_USER().useSysAdmin().commitWork().getRecord();
        User userNew = userOld.clone();
        Test.startTest();
        Boolean resultNoChange = UserTriggerUtility.isFieldOnUserChanged(userOld, userNew);

        userNew.FirstName += '#changed';

        Boolean resultWithChange = UserTriggerUtility.isFieldOnUserChanged(userOld, userNew);
        Test.stopTest();

        System.assert(!resultNoChange);
        System.assert(resultWithChange);
    }

    @IsTest
    static void testNeedsContactUpdateNeverTrueOnNoSyncWithContact() {
        User userOld = (User) new BLD_USER().useSysAdmin().commitWork().getRecord();
        User userNew = userOld.clone();
        userNew.Sync_with_Contact__c = false;
        Map<Id, User> id2UserOld = new Map<Id, User>();
        id2UserOld.put(userOld.Id, userOld);
        Boolean isTriggerInsert = true;
        Test.startTest();
        Boolean resultNoSyncWithContact = UserTriggerUtility.needsContactUpdate(userNew, isTriggerInsert, id2UserOld);
        Test.stopTest();
        System.assert(!resultNoSyncWithContact);
    }

    @IsTest
    static void testNeedsContactUpdateTrueOnInsert() {
        User userOld = (User) new BLD_USER().useSysAdmin().commitWork().getRecord();
        User userNew = userOld.clone();
        userNew.Sync_with_Contact__c = true;
        Map<Id, User> id2UserOld = new Map<Id, User>();
        id2UserOld.put(userOld.Id, userOld);
        Boolean isTriggerInsert = true;
        Test.startTest();
        Boolean resultOnInsert = UserTriggerUtility.needsContactUpdate(userNew, isTriggerInsert, id2UserOld);
        Test.stopTest();
        System.assert(resultOnInsert);
    }
}