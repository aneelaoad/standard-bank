/***************************************************************************************
@Author            : Gill Lumley 
@Date              : 19-11-2022
@Name of the Class : AOB_CTRL_WFR_TEST
@description       : MVP1 Copy 	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP 27748
***************************************************************************************/
@isTest
public class AOB_CTRL_WFR_TEST {
    /**
    * @description test Set Up
    */
    @TestSetup
    private static void testSetUp() {
        User communityUser = AOB_DAL_TestFactory.createCommunityUserPing();
        Map<string, string> applicationData = new Map<string, string>();
        Account acc = [
            SELECT id
            FROM account
            WHERE id IN (SELECT accountId FROM contact WHERE id = :communityUser.contactId)
        ];
        System.runAs(communityUser) {
            ApplicationData.put('AOB_Client__c', acc.id);
            Insert AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c', applicationData);
        }
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.getWFRUrl
    * author dayakar
    */ 
    @isTest
    private static void getWFRUrlTest() {
        String idNumber='7710149032093';
        String cilentreference='b985bf32-5990-40a6-86ba-cf9d1fc3f476';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        try {
            String result2 = AOB_CTRL_WFR.getWFRUrl(idNumber, cilentreference, applicationId);
            Assert.areNotEqual(Null, result2,'Test Message');
        } catch (Exception ex) {
            Assert.areNotEqual(Null, ex.getMessage(),'Test Message');
        }    
        Test.stopTest();
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.getWFRUrl
    * author dayakar
    */ 
    @isTest
    private static void getWFRUrlNegTest() {
        String idNumber='7710149032093';
        String cilentreference='b985bf32-5990-40a6-86ba-cf9d1fc3f476';
        AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        try {
            String result2 = AOB_CTRL_WFR.getWFRUrl(idNumber, cilentreference,null);
            Assert.areEqual(Null, result2,'Test Message');
        } catch (Exception ex) { 
            Assert.areNotEqual(Null, ex.getMessage(),'Test Message');
        }    
        Test.stopTest();
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.callStartIDV
    * author dayakar
    */ 
    @isTest
    private static void callStartIDVTest() {   
        String idNumber='7710149032093';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try {
            Test.startTest();
            AOB_CTRL_WFR.callStartIDV(idNumber,applicationId);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(Null, ex.getMessage(),'Test Message');
        }    
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.updateBPGUID
    * author dayakar
    */ 
    @isTest
    private static void updateBPGUIDTest() {
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){
            Account acc = [
                SELECT id
                FROM account
                WHERE id IN (SELECT AccountId FROM user WHERE id=:communityUser.id)
            ];
            Test.startTest();
            try {
                String result = AOB_CTRL_WFR.updateBPGUID();
                Assert.areNotEqual(Null, result,'Test Message');
                Assert.areNotEqual(Null, acc,'Test Message');
            } catch (exception e) { 
                Assert.areNotEqual(Null, e.getMessage(),'Test Message');
            }
            Test.stopTest();
        }
    }
    
    
    /**
    * @description test method for AOB_CTRL_WFR.callGetIDVStatus
    * author dayakar
    */ 
    @isTest
    private static void callGetIDVStatusTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String idNumber='7710149032093';
        Test.startTest();
        try{
            AOB_CTRL_WFR.callGetIDVStatus(idNumber,applicationId);
        }
        catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }     
        Test.stopTest();
    }
    /**
    * @description test method for AOB_CTRL_WFR.callNotifyIDV
    * author dayakar
    */ 
    @isTest
    private static void callNotifyIDVTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String correlationId='b985bf32-5990-40a6-86ba-cf9d1fc3f476';
        try{
            Test.startTest();
            AOB_CTRL_WFR.callNotifyIDV(applicationId,correlationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message'); 
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.callNotifyIDV
    * author dayakar
    */ 
    @isTest
    private static void callNotifyIDVNegTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String correlationId='b985bf32-5990-40a6-86ba-cf9d1fc3f476';
        try{
            Test.startTest();
            AOB_CTRL_WFR.callNotifyIDV('',correlationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.cancelIDV
    * author dayakar
    */ 
    @isTest
    private static void cancelIDVTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String correlationId='b985bf32-5990-40a6-86ba-cf9d1fc3f476';
        try{
            Test.startTest();
            AOB_CTRL_WFR.cancelIDV(correlationId,applicationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.cancelIDV
    * author dayakar
    */ 
    @isTest
    private static void cancelIDVNegTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String correlationId='b985bf32-5990-40a6-86ba-cf9d1fc3f476';
        try{
            Test.startTest();
            AOB_CTRL_WFR.cancelIDV(correlationId,null);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.setCorrelationId
    * author dayakar
    */ 
    @isTest
    private static void setCorrelationIdIDVTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String correlationId='b985bf32-5990-40a6-86ba-cf9d1fc3f476';
        try{
            Test.startTest();
            AOB_CTRL_WFR.setCorrelationId(applicationId,correlationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.setCorrelationId
    * author dayakar
    */ 
    @isTest
    private static void setCorrelationIdNegTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String correlationId='negativeTest';
        try{
            Test.startTest();
            AOB_CTRL_WFR.setCorrelationId(null,correlationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.incrementWfrRetryReturn
    * author dayakar
    */ 
    @isTest
    private static void incrementWfrRetryReturnTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.incrementWfrRetryReturn(applicationId);
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.fetchRetryCounter
    * author dayakar
    */
    @isTest
    private static void fetchRetryCounterTest() {
        Test.startTest();
        try {
            AOB_CTRL_WFR.fetchRetryCounter();
        }catch (Exception ex) {
            Assert.areNotEqual(Null, ex.getMessage(),'Test Message');
        }
        Test.stopTest();
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.getAppSettingByCategory
    * author dayakar
    */
    @isTest
    private static void getAppSettingByCategoryTest() {
        Test.startTest();
        Map<String, String> result = AOB_CTRL_WFR.getAppSettingByCategory('FLOW');
        Assert.areNotEqual(result, null,'Test Message');
        try {
            Map<String, String> result2 = AOB_CTRL_WFR.getAppSettingByCategory(null);
            Assert.areEqual(null, result2,'Test Message');
        } catch (Exception e) {
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }    
        Test.stopTest(); 
    }
    
    
    /**
    * @description test method for AOB_CTRL_WFR.getWFRStatusIdNumberFromVerificationByAppId
    * author dayakar
    */ 
    @isTest
    private static void getWFRStatusIdNumberFromVerificationByAppIdTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Boolean correlationId=true;
        try{
            Test.startTest();
            AOB_CTRL_WFR.getWFRStatusIdNumberFromVerificationByAppId(applicationId,correlationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.getWFRStatusIdNumberFromVerificationByAppId
    * author dayakar
    */ 
    @isTest
    private static void getWFRStatusIdNumberFromVerificationByAppIdNegTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Boolean correlationId=true;
        try{
            Test.startTest();
            AOB_CTRL_WFR.getWFRStatusIdNumberFromVerificationByAppId(null,correlationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.getWFRRetryIndicator
    * author dayakar
    */ 
    @isTest
    private static void getWFRRetryIndicatorTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.getWFRRetryIndicator(applicationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.getWFRDetails
    * author dayakar
    */ 
    @isTest
    private static void getWFRDetailsTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.getWFRDetails(applicationId);
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.getWFRDetails
    * author dayakar
    */ 
    @isTest
    private static void getWFRDetailsNegTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.getWFRDetails(null);
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    
    /**
    * @description test method for AOB_CTRL_WFR.setWFRStatus
    * author dayakar
    */ 
    @isTest
    private static void setWFRStatusTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.setWFRStatus(applicationId,'SUCCESS');
            Test.stopTest();  
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    
    /**
    * @description test method for AOB_CTRL_WFR.setWFRStatus
    * author dayakar
    */ 
    @isTest
    private static void setWFRStatusStartedTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.setWFRStatus(applicationId,'Started');
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.setWFRStatus
    * author dayakar
    */ 
    @isTest
    private static void setWFRStatusCancelTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.setWFRStatus(applicationId,'CANCELLED');
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
* @description test method for AOB_CTRL_WFR.setWFRStatus
* author dayakar
*/ 
    @isTest
    private static void setWFRStatusNegTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.setWFRStatus(null,'SUCCESS');
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    
    /**
    * @description test method for AOB_CTRL_WFR.getWFRStatus
    * author dayakar
    */ 
    @isTest
    private static void getWFRStatusTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.getWFRStatus(applicationId);
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    
    /**
    * @description test method for AOB_CTRL_WFR.isWFRStep
    * author dayakar
    */ 
    @isTest
    private static void isWFRStepTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.isWFRStep(applicationId);
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    
    /**
* @description test method for AOB_CTRL_WFR.updateVerificationstatus
* author dayakar
*/ 
    @isTest
    private static void updateVerificationstatusTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.updateVerificationstatus(applicationId);
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }
    
    /**
    * @description test method for AOB_CTRL_WFR.completeAoIdvAPICall
    * @author dayakar
    */ 
    @isTest
    private static void completeAOIDVTest() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        try{
            Test.startTest();
            AOB_CTRL_WFR.completeAoIdvAPICall(applicationId);
            Test.stopTest();  
        }Catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test Message');
        }
        Assert.areNotEqual(null, applicationId,'Test Message');
    }  
}