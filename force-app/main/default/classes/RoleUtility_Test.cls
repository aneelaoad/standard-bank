/*************************************************************************\
    @ Author        :     Jorel Naidoo
    @ Date          :     23/01/2013
    @ Description   :     Test Class for Contact Team Members Class and Trigger

    @ Last Modified By  :   Prabhanshu Agrawal    
    @ Last Modified On  :   20- Mar -2014
    @ Description       :   Increased code coverage, Implemented Best Practice    

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   15-Sep-2015
    @ Description       :   Fixed a run condition in a test (User records are visible despite seeAllData=false)
    
    @ Last Modified By  :   Deeksha Singhal
    @ Last Modified On  :   27-Jan-2016
    @description       :   EN1013: Role Name Changes
**************************************************************************/
@isTest (seeAllData = False)
public class RoleUtility_Test {

    /**********************************************************
    Scenario - Test for positive Scenarios.
    **********************************************************/
    
    @IsTest
    static void testForPositiveScenarios () {

        List<Id> userIds = new List<Id>();
        List<Id> usersCreated = new List<Id>();

        UserRole rl = [Select Id, Name from UserRole where Name = 'Corporate & Investment Banking'];

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        //User
        User testManager = (User) new BLD_USER(uow).useSysAdmin().role(rl.Id).getRecord();
        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();

        usersCreated.add(testManager.Id);
        usersCreated.add(testUser.Id);

        User testNonManager = (User) new BLD_USER().useSysAdmin().managerId(testManager.Id).role(rl.Id).getRecord();
        insert testNonManager;

        usersCreated.add(testNonManager.Id);

        //JN get Data for Tests
        list <User> testUsers = [Select Id, ManagerId from User where isActive = True AND Id in :usersCreated];
       
        for(User testUserManagers : testUsers){
            userIds.add(testUserManagers.Id);
        }
        
        Test.startTest();
        System.runAs(TestUser){
            try {
                RoleUtility rTest = new RoleUtility();
                Boolean testManagerResult = RoleUtility.isManagerOfUsers(userIds , testManager.Id);
                Boolean testSingleUserResult = RoleUtility.isManagerOfUser(testManager.UserRoleId, testNonManager.Id);
                Boolean testSingleUserRoleResult = RoleUtility.isManagerOfRole(testManager.UserRoleId, testNonManager.UserRoleId);
                Boolean testSingleUserHighManRoleResult = RoleUtility.isManagerOfRole(testManager.UserRoleId, testManager.UserRoleId);
            }
            catch (Exception ex) {
                System.assert(false);
            }
        } 
    }    

    /**********************************************************
    Scenario - Test for negative Scenarios.
    **********************************************************/
    
    @IsTest
    static void testForNegativeScenarios () {

        List<Id> userIds = new List<Id>();
        List<Id> usersCreated = new List<Id>();

        UserRole rl = [Select Id, Name from UserRole where Name = 'Corporate & Investment Banking'];

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        //User
        User testManager = (User) new BLD_USER(uow).useSysAdmin().role(rl.Id).getRecord();
        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();

        usersCreated.add(testManager.Id);
        usersCreated.add(testUser.Id);

        User testNonManager = (User) new BLD_USER().useSysAdmin().managerId(testManager.Id).role(rl.Id).getRecord();
        insert testNonManager;

        usersCreated.add(testNonManager.Id);

        //JN get Data for Tests
        List <User> testUsers = [Select Id, ManagerId from User where isActive = True AND Id in :usersCreated];
       
        for(User testUserManagers : testUsers){
            userIds.add(testUserManagers.Id);
        }
        
        Test.startTest();
        System.runAs(TestUser){
              
            RoleUtility rTest = new RoleUtility(); 
       
            //JN List of Users Test
            Boolean testNonManagerResult = RoleUtility.isManagerOfUsers(userIds , testNonManager.Id);       
            System.AssertEquals (testNonManagerResult,False);
       
            //JN Single User test based on Manager Role
            Boolean testSingleUserNMResult = RoleUtility.isManagerOfUser(testNonManager.UserRoleId, testManager.Id);
            System.AssertEquals (testSingleUserNMResult ,False);
       
            //JN Single User test based on User and Manager Role
            Boolean testSingleUserRoleNMResult = RoleUtility.isManagerOfRole(testNonManager.UserRoleId, testManager.UserRoleId);
            System.AssertEquals (testSingleUserRoleNMResult,False);       
        } 
    }    
}