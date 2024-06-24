@IsTest
public class AOB_DTO_Section_Test {
 @isTest
 public static void  SelectMultipleMethod()
    {
        Test.StartTest();
       AOB_DTO_Section dtosection=new AOB_DTO_Section();
        dtosection.gridClass='test';
        dtosection.title='test1';
        dtosection.mediumDeviceColumns=680;
        dtosection.rank=11;
        dtosection.smallDeviceColumns=360;
        dtosection.largeDeviceColumns=1200;
         Test.stopTest(); 
    }
}