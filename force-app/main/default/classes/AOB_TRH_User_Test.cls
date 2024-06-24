@IsTest
public class AOB_TRH_User_Test {
    @IsTest
    private static void createUserTest() {  
    Test.startTest();       
    User user = AOB_DAL_TestFactory.createCommunityUser();
    Test.stopTest();
    }
    
    @IsTest
    private static void updateUserTest() {  
        Test.startTest(); 
        User adminUser =[SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        User user = AOB_DAL_TestFactory.createCommunityUser();
        user.lastName = 'test 123';
		System.runAs(adminUser)
		{
                  
             update user;
            
        }
    Test.stopTest();
    }
}