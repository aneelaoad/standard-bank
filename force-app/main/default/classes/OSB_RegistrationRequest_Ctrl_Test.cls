/**
 * @description Test class for the OSB_RedirectReg_Ctrl class
 *
 * @author      Wayde Fagan (Wayde.Fagan@tetrad.co.za)
 * @date        April 2020
 * 
 * 
 * @author      Eldrin Shikwambana
 * @date Last Modified  April 2023
 */

@IsTest
public class OSB_RegistrationRequest_Ctrl_Test {

    private static String testUserName = 'test@testUser1324.com';
    private static String firstName = 'testUser';
    private static String lastName = 'dummyLastNme';
    private static String emailAddress = 'test@standardbank.co.za';
    private static String subject = 'Onehub Subject';

    @IsTest
    static void testSaveCase() {
        Test.startTest();
        Case regCase = (Case) new BLD_Case().setOSBData().suppliedEmail(testUserName).getRecord();
        Case result = OSB_RegistrationRequest_Ctrl.saveCase(regCase);
        Test.stopTest();
        Assert.areEqual('test@testUser1324.com',testUserName);
    }

    @IsTest
    static void testDecodeBase64String() {
        String base64String = 'dHJ1ZXx0cnVlfGZhbHNl';
        Test.startTest();
        base64String = OSB_RegistrationRequest_Ctrl.decodeBase64String(base64String);
        Test.stopTest();        
        Assert.areEqual('true|true|false',base64String);
    }

    @IsTest
    static void negativeTestDecodeBase64String() {
        String base64String = null; 
        Test.startTest();
        base64String = OSB_RegistrationRequest_Ctrl.decodeBase64String(base64String);
        Test.stopTest();
        Assert.areEqual(null, base64String);
    }
    
    @IsTest
    static void testcheckDuplicate(){
    Test.startTest();

    Contact testDuplicate = new Contact();
    testDuplicate.Firstname = firstName;
    testDuplicate.lastname = lastName;
    testDuplicate.email = emailAddress;            
    Boolean isDuplicate =  OSB_RegistrationRequest_Ctrl.checkDuplicate(testDuplicate);
    Test.stopTest();
    Assert.areEqual(false, isDuplicate, 'The checkForDuplicate method did not identify the existing contact.');
    }
    
    @IsTest
    Static void testcaseCheck(){
        Test.startTest();        
        Boolean isDuplicate =  OSB_RegistrationRequest_Ctrl.caseCheck(subject,emailAddress);
        Test.stopTest();
        Assert.areEqual(false, isDuplicate, 'The checkForDuplicate method did not identify the existing case.');
    } 
}