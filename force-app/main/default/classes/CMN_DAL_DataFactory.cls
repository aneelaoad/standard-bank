/**
 * @description Used to create Data, mostly for unit tests
 *
 * @author Accenture
 *
 * @date 2020
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed MVP1 Copy 19-11-2022 Gill Lumley   Change method newOutboundWebserviceQueue to public as per MVP1
 */
public without sharing class CMN_DAL_DataFactory
{
    private static final String DEFAULT_CHRON_EXPRESSION = '0 0 * * * ?';

    /**
     * @description Will create feature switch that indicates a particular API should be disabled for the running user
     *
     * @param apiName The class name of the API to disable
     */  
    @TestVisible
    private static void disableAPI(String apiName)
    {
        CMN_FeatureSwitches__c newSwitch = CMN_FeatureSwitches__c.getInstance();
        newSwitch.CMN_APIsToDisableList1__c = apiName;
        upsert newSwitch;
    }

    /**
     * @description Will Create feature custom setting and upsert it
     *
     * @param setupOwnerId The owner of the custom setting
     */
    @TestVisible
    private static void createFeatureSwitch(Id setupOwnerId)
    {
        CMN_FeatureSwitches__c newSwitch = CMN_FeatureSwitches__c.getInstance();

        newSwitch.SetupOwnerId = setupOwnerId;
        newSwitch.CMN_DisableAllOutboundAPICalls__c = false;

        upsert newSwitch;
    }

    /**
     * @description This method is use to create new record in Custom Setting newSpcUsersToEnable
     *
     * @param name Setting Name
     * @param profileName Profile Name for Setting
     * @param userName User Name for Setting
     *
     * @return A new Custom Setting Row
     */
    @TestVisible
    private static CMN_SPC_UsersToEnable__c newSpcUsersToEnable(String name, String profileName, String userName)
    {
        CMN_SPC_UsersToEnable__c newUsersToEnable = new CMN_SPC_UsersToEnable__c();

        newUsersToEnable.Name = name;

        newUsersToEnable.CMN_SPC_EnableProfileName__c = profileName;
        newUsersToEnable.CMN_SPC_EnableUsername__c = userName;

        return newUsersToEnable;
    }

    /**
     * @description Will create a row in the custom setting CMN_TriggersToDisable__c, thereby disabling said trigger
     *
     * @param triggerName The name of the trigger to disable
     */
    @TestVisible
    private static void disableTrigger(String triggerName)
    {
        CMN_TriggersToDisable__c newTriggersToDisable = new CMN_TriggersToDisable__c();

        newTriggersToDisable.Name = triggerName;
        newTriggersToDisable.CMN_ClassName__c = triggerName;

        insert newTriggersToDisable;
    }

    /**
     * @description This method is use to get the user with profile
     *
     * @param profileName The profile that should be linked to the new user
     *
     * @return A user that's not inserted
     */
    public static User newUser(String profileName)
    {
        User newUser = new User();

        newUser.ProfileId = CMN_DAL_Profile.findByName(profileName).Id;

        newUser.Username = CMN_DAL_SObjectDomain.generateRandomEmail();
        newUser.Email = newUser.Username.toLowerCase();
        newUser.LastName = CMN_DAL_SObjectDomain.generateRandomName();
        newUser.FirstName = CMN_DAL_SObjectDomain.generateRandomName();
        newUser.Alias = CMN_DAL_SObjectDomain.generateRandomName().substring(0, 7);
        newUser.CommunityNickname = CMN_DAL_SObjectDomain.generateRandomName();

        User currentUser = CMN_DAL_User.getCurrentUser();

        newUser.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        newUser.LocaleSidKey = currentUser.LocaleSidKey;
        newUser.EmailEncodingKey = currentUser.EmailEncodingKey;
        newUser.LanguageLocaleKey = currentUser.LanguageLocaleKey;

        newUser.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();

        newUser.IsActive = true;

        return newUser;
    }

    /**
     * @description Method is use return the new Account with record type
     *
     * @return newAccount
     */
    public static Account newAccount()
    {
        Account newAccount = new Account();

        newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
        newAccount.AnnualRevenue = CMN_DAL_SObjectDomain.generateRandomDecimal();
        newAccount.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();

        return newAccount;
    }

    /**
     * @description Method is use insert a new Account (Can Use this method in Test class)
     *
     * @return newAccount
     */
    @TestVisible
    private static Account insertAccount()
    {
        Account newAccount = newAccount();
        newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
        newAccount.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
        insert newAccount;

        return newAccount;
    }

    /**
     * @description Method is use return the a new Contact
     *
     * @return newly created Contact, not committed yet
     */
    public static Contact newContact()
    {
        Contact newContact = new Contact();

        newContact.LastName = CMN_DAL_SObjectDomain.generateRandomName();
        newContact.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
        newContact.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
        newContact.HomePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
        newContact.Email = CMN_DAL_SObjectDomain.generateRandomEmail();
        newContact.Birthdate = CMN_DAL_SObjectDomain.generateRandomDate();
        newContact.HasOptedOutOfFax = true;

        return newContact;
    }

    /**
     * @description Will save email binary attachments as content associated with an Object
     *
     * @param linkToObjectId The object against which the attachments should be saved
     * @param binaryAttachments The binary attachments of an email
     *
     * @return Newly created ContentVersion, not inserted
     */
    public static List<ContentVersion> newContentVersionsFromBinaryAttachments(Id linkToObjectId, List<Messaging.InboundEmail.BinaryAttachment> binaryAttachments)
    {
        List<ContentVersion> newContentVersions = new List<ContentVersion>();

        if(binaryAttachments != null)
        {
            for(Messaging.InboundEmail.BinaryAttachment binaryAttachment : binaryAttachments)
            {
                newContentVersions.add(newContentVersion(linkToObjectId, binaryAttachment.fileName, binaryAttachment.body));
            }
        }

        return newContentVersions;
    }

    /**
     * @description Will save email text attachments as content associated with an Object
     *
     * @param linkToObjectId The object against which the attachments should be saved
     * @param textAttachments The text attachments of an email
     *
     * @return Newly created ContentVersion, not inserted
     */
    public static List<ContentVersion> newContentVersionsFromTextAttachments(Id linkToObjectId, List<Messaging.InboundEmail.TextAttachment> textAttachments)
    {
        List<ContentVersion> newContentVersions = new List<ContentVersion>();

        if(textAttachments != null)
        {
            for(Messaging.InboundEmail.TextAttachment textAttachment : textAttachments)
            {
                newContentVersions.add(newContentVersion(linkToObjectId, textAttachment.fileName, Blob.valueOf(textAttachment.body)));
            }
        }

        return newContentVersions;
    }

    /**
     * @description Will create a new Content Version
     *
     * @param linkToObjectId To which object should this Content be linked
     * @param fileName The file name of the Content
     * @param body The binary body of the content
     *
     * @return A newly created item, (not inserted)
     */
    public static ContentVersion newContentVersion(Id linkToObjectId, String fileName, Blob body)
    {
        ContentVersion newContentVersion = new ContentVersion();

        newContentVersion.FirstPublishLocationId = linkToObjectId;
        newContentVersion.PathOnClient = fileName;
        newContentVersion.Title = fileName;
        newContentVersion.VersionData = body;

        return newContentVersion;
    }

    /**
     * @description Will generate an inbound email envelope
     *
     * @return Email Envelope
     */
    @TestVisible
    private static Messaging.InboundEnvelope newInboundEnvelope()
    {
        Messaging.InboundEnvelope newEnvelope = new Messaging.InboundEnvelope();

        newEnvelope.fromAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
        newEnvelope.toAddress = CMN_DAL_SObjectDomain.generateRandomEmail();

        return newEnvelope;
    }

    private static final String DUMMY_FILE_PATH = '/dummy/local/directory/';
    private static final String TEXT_FILE_EXTENSION = '.txt';
    @TestVisible
    private static final Integer NUMBER_ATTACHMENTS_TO_CREATE = 10;

    /**
     * @description Will generate an inbound email
     *
     * @return Inbound Email
     */
    @TestVisible
    private static Messaging.InboundEmail newInboundEmail()
    {
        Messaging.InboundEmail newEmail = new Messaging.InboundEmail();

        newEmail.fromAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
        newEmail.fromName = CMN_DAL_SObjectDomain.generateRandomName();
        newEmail.subject = CMN_DAL_SObjectDomain.generateRandomDescription();
        newEmail.plainTextBody = CMN_DAL_SObjectDomain.generateRandomDescription();
        newEmail.messageId = CMN_DAL_SObjectDomain.generateRandomNumber();

        newEmail.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        newEmail.textAttachments = new List<Messaging.InboundEmail.TextAttachment>();

        for(Integer i = 0; i < NUMBER_ATTACHMENTS_TO_CREATE; i++)
        {
            Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();

            binaryAttachment.body = Blob.valueOf(CMN_DAL_SObjectDomain.generateRandomDescription());
            binaryAttachment.fileName = DUMMY_FILE_PATH + CMN_DAL_SObjectDomain.generateRandomName() + TEXT_FILE_EXTENSION;
            binaryAttachment.mimeTypeSubType = TEXT_FILE_EXTENSION;

            newEmail.binaryAttachments.add(binaryAttachment);

            Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();

            textAttachment.body = binaryAttachment.body.toString();
            textAttachment.fileName = binaryAttachment.fileName;
            textAttachment.mimeTypeSubType = binaryAttachment.mimeTypeSubType;

            newEmail.textAttachments.add(textAttachment);
        }

        return newEmail;
    }

    /**
     * @description This method is use to get the scheduler class to run the schedule job
     *
     * @param schedulerClassName The name of the class to run
     *
     * @return a scheduler object not inserted
     */
    @TestVisible
    private static CMN_JobScheduler__c newJobScheduler(String schedulerClassName)
    {
        CMN_JobScheduler__c scheduler = new CMN_JobScheduler__c();

        scheduler.CMN_Description__c = CMN_DAL_SObjectDomain.generateRandomDescription();
        scheduler.CMN_SchedulerName__c = CMN_DAL_SObjectDomain.generateRandomName();
        scheduler.CMN_ScheduleClassName__c = schedulerClassName;
        scheduler.CMN_CronExpression__c = DEFAULT_CHRON_EXPRESSION;

        return scheduler;
    }

    /**
     * @description This method is use to insert the object in scheduler class
     *
     * @param schedulerClassName The name of the class to run
     *
     * @return a newly inserted row
     */
    @TestVisible
    private static CMN_JobScheduler__c insertJobScheduler(String schedulerClassName)
    {
        CMN_JobScheduler__c scheduler = newJobScheduler(schedulerClassName);

        CMN_DAL_SObjectDomain.insertDBObject(scheduler);

        return scheduler;
    }

    /**
     * @description This method is use to display Webservice call queue date.
     *
     * @return A webservice queue object, not inserted
     */
    public static CMN_WebserviceCallQueue__c newWebserviceQueue()
    {
        CMN_WebserviceCallQueue__c queueItem = new CMN_WebserviceCallQueue__c();

        queueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_QUEUED;
        queueItem.CMN_Retries__c = 0;

        return queueItem;
    }

    /**
     * @description This method is use to display Webservice call queue date.
     *
     * @param serviceName The name of the webservice class
     *
     * @return A webservice queue object, not inserted
     */
    public static CMN_WebserviceCallQueue__c newWebserviceQueue(String serviceName)
    {
        CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue();

        queueItem.CMN_Service__c = serviceName;

        return queueItem;
    }

    /**
     * @description This method is use to display Webservice call queue date.
     *
     * @param serviceName The name of the webservice class
     *
     * @return An inbound webservice queue object, not inserted
     */
    public static CMN_WebserviceCallQueue__c newInboundWebserviceQueue(String serviceName)
    {
        CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue(serviceName);

        queueItem.CMN_Type__c = CMN_DAL_WebserviceCallQueue.TYPE_INBOUND;
        queueItem.CMN_StatusCode__c = CMN_UTIL_String.EMPTY;
        queueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_COMPLETED;
        queueItem.CMN_Response__c = CMN_UTIL_String.EMPTY;
        queueItem.CMN_Request__c = System.RestContext.request.requestBody != null ? System.RestContext.request.requestBody.toString() : CMN_UTIL_String.EMPTY;
        queueItem.CMN_Errors__c = CMN_UTIL_String.EMPTY;

        return queueItem;
    }

    /**
     * @description This method is use to get the outbound of webservice call queue.
     *
     * @param serviceName The name of the service for this queue item
     *
     * @return An outbound webservice queue object, not inserted
     */
    public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName)
    {
        CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue(serviceName);
        queueItem.CMN_Type__c = CMN_DAL_WebserviceCallQueue.TYPE_OUTBOUND;

        return queueItem;
    }

    /**
     * @description This method is use to get the outbound of webservice call queue.
     *
     * @param serviceName The name of the webservice class
     * @param triggeringObjectId The object that is triggering the service class
     *
     * @return An outbound webservice queue object, not inserted
     */
    @TestVisible
    private static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName, Id triggeringObjectId)
    {
        CMN_WebserviceCallQueue__c queueItem = newOutboundWebserviceQueue(serviceName);

        queueItem.CMN_TriggeringObjectId__c = triggeringObjectId;

        return queueItem;
    }

    /**
     * @description Will instantiate a new case with relevant fields filled
     *
     * @param contactId The Contact to which this case should be related, can be null
     *
     * @return A completed case, note this case is not saved to the database
     */
    public static Case newCase(Id contactId)
    {
        Case newCase = new Case();

        newCase.Subject = CMN_DAL_SObjectDomain.generateRandomName();
        newCase.Description = CMN_DAL_SObjectDomain.generateRandomDescription();
        newCase.ContactId = contactId;
        newCase.Reason = CMN_DAL_SObjectDomain.generateRandomName();

        return newCase;
    }
    
}