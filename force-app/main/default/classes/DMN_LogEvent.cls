/**
 * Domain class for Log_Event__e platform event
 * <br/> US-4824
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
public inherited sharing class DMN_LogEvent {
    public enum Type { ERROR, INFO }

    /**
     * Creates actual Log__c records out of Log_Event__e
     *
     * @param logEvents Log_Event__e record to be changed
     */
    public static void createLogs(List<Log_Event__e> logEvents) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        for (Log_Event__e logEvent : logEvents) {
            uow.registerNew(new Log__c(
                    Source__c = logEvent.Source__c,
                    Message__c = logEvent.Message__c,
                    Stack_trace__c = logEvent.Stack_trace__c,
                    Type__c = logEvent.Type__c,
                    Context_User__c = logEvent.Context_User__c,
                    Area__c = logEvent.Area__c
            ));
        }
        uow.commitWork();
    }
}