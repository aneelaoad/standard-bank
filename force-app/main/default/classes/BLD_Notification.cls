/**
 * Builder class for Notification__c SObject
 *
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date April 2020
 */
@IsTest
public with sharing class BLD_Notification extends ABS_ObjectBuilderBase {
    private static final String DEF_CONTENT = 'Test Notification';
    private static final String DEF_SUBTITLE = 'This is a test Notification';
    private static final String DEF_TITLE = 'This is a test Notification';
    private static final String DEF_USER = 'All Users';

    public BLD_Notification() {
        this(getNewUnitOfWork());
    }

    public BLD_Notification(fflib_SObjectUnitOfWork uow) {
        super(Notification__c.SObjectType, uow);
    }

    public BLD_Notification(Notification__c notificationRecord, fflib_SObjectUnitOfWork uow) {
        super(notificationRecord, uow);
    }

    public BLD_Notification setOSBData() {
         return (BLD_Notification) setField(Notification__c.Content__c,  DEF_CONTENT)
        .setField(Notification__c.Subtitle__c,  DEF_SUBTITLE)
        .setField(Notification__c.Title__c,  DEF_TITLE)
        .setField(Notification__c.Users__c,  DEF_USER);
    }
    
    public BLD_Notification ownerId(Id ownerId) {
        return (BLD_Notification) setField(Notification__c.OwnerId, ownerId);
    }
}