/**
 * @description TRH test class for TRH_Logs
 * @author		Emmanuel Mulea(Nocks)
 * @date		March 2022
 */
@isTest
public class TRH_LogsTest {
    @isTest
    public static void testInstance() {
        
        Test.startTest();
        TRH_Logs log = new TRH_Logs();
        List<Log__c> logList = log.logs;
        Test.stopTest();
    }
}