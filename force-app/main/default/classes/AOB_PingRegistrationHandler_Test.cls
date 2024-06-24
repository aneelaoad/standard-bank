/**
* Ping Registration handler Test to create User and person account
*
* <p>DBP-1106</p>
*
* @author salesforce
*
* @date Nov 3th 2020
*/
@isTest
public class AOB_PingRegistrationHandler_Test {  
    /**
	 * @description Test setup method to insert all Test data
	 */
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
    * Helper method to Validate the the User we've created
    * @param theUser - the User that we created
    * @param data - the original AuthData supplied by FaceBook
    */ 
    private static void validate(User theUser, Auth.UserData data) {
        System.Assert(theUser != null,'User must not be null');
        System.AssertEquals(theUser.email,data.email,'Email address must be the same');
    }
    
    /**
    * Helper method to instantiate the handler UserData
    * @param email
    * @param lastName
    * @param firstName
    * @return Auth.UserData that looks like what we expect from FaceBook
    */ 
    private static Auth.UserData createUser(String email,String lastName, String firstName, String id, String sub, String num) {
         Map<String, String> attributeMap = new Map<String,String>();
	     attributeMap.put(AOB_Constants.PING_LAST_NAME, lastName);
         attributeMap.put(AOB_Constants.PING_FIRST_NAME, firstName);
         attributeMap.put(AOB_Constants.PING_EMAIL, email);
         attributeMap.put(AOB_Constants.ID_STRING, id);
         attributeMap.put(AOB_Constants.PING_SUB, sub);
         attributeMap.put(AOB_Constants.PING_BPID, num);
         attributeMap.put(AOB_Constants.PING_BPGUID, AOB_Utils.generateGUID());
         String identifier = lastName+System.currentTimeMillis();
         String locale = 'en_US';
         return new Auth.UserData(identifier,
               firstName,
               lastName,
              '', // fullname
               email,
               '', // link
               '', // userName
               locale,
               '', // provider
               '', // siteLoginUrl
               attributeMap);        
    }
    /**
    * Simple scenario to create a Community user
    */ 
    @isTest
    private static void createCommunityUserTest() {
        AOB_PingRegistrationHandler handler = new AOB_PingRegistrationHandler();
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew', '0000000000','aaaaa','1111111');              
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', true);
        System.runAs(admin){
            Test.startTest();
            String theCommunityId = '00000001';
            data.attributeMap.put('sfdc_networkid',theCommunityId);
            User theUser = handler.createUser(null, data);
            Test.stopTest();      
            validate(theUser,data);  
            // Additional validations for Community User
            System.Assert(theUser.ContactId != null,'Contact must be set for user');      
        }            
    }

}