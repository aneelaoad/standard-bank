/**
 * Builder class for Log_Event__e platform event
 * <br/> US-4824
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
@IsTest
public without sharing class BLD_LogEvent extends ABS_ObjectBuilderBase {

    public BLD_LogEvent() {
        this(getNewUnitOfWork());
    }

    public BLD_LogEvent(fflib_SObjectUnitOfWork uow) {
        super(Log_Event__e.SObjectType, uow);
    }

    protected override void setDefaultData() {
        setField(Log_Event__e.Context_User__c, UserInfo.getUserId());
    }

    public BLD_LogEvent area(String area) {
        return (BLD_LogEvent) setField(Log_Event__e.Area__c, area);
    }

    public BLD_LogEvent message(String message) {
        return (BLD_LogEvent) setField(Log_Event__e.Message__c, message);
    }

    public BLD_LogEvent source(String source) {
        return (BLD_LogEvent) setField(Log_Event__e.Source__c, source);
    }

    public BLD_LogEvent stackTrace(String stackTrace) {
        return (BLD_LogEvent) setField(Log_Event__e.Stack_trace__c, stackTrace);
    }

    public BLD_LogEvent type(String type) {
        return (BLD_LogEvent) setField(Log_Event__e.Type__c, type);
    }
}