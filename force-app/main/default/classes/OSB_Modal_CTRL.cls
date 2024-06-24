/**
 * @description OSB_Modal_CTRL class for OSBModal Lightning Component
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date August 2020
 *
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason New method for adding multiple subscribed solutions
 **/
public class OSB_Modal_CTRL {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('OSB_Modal_CTRL');
    public static final String OBJ_NAME = 'Subscribed_Solutions__c';
    public static final String RT_APPLICATION = 'Subscribed_Applications';
    public static final String RT_SHORTCUTS = 'Subscribed_Shortcuts';
    private static final String PING_START_VALUE = 'entryUUID=';
    private static final String PING_END_VALUE = ',ou=People,dc=sbsa,dc=com';
    private static final String TEST_SHORTCUT = 'shortcut';
    private static final String TEST_SOLUTIONAME = 'FRDM';
    private static final String TEST_USER_NAME = 'test@test.com';
    private static final String TEST_PING_ID = 'samplePingId';

    /**
     * @description inserts a new Subscribed Solution record and returns true if successful and false if not
     *
     * @param  solutionId String
     **/
    @AuraEnabled(Cacheable=false)
    public static void createUserSubscribedSolution(Id solutionId) {
        LOGGER.info(
            'OSB_Modal_CTRL : createUserSubscribedSolution Create an application that the user subscribed to'
        );
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try {
            Contact userContact = SEL_Contacts.newInstance()
                .selectByUserIdWoSharing(new Set<Id>{ userInfo.getUserId() })[0];
            Subscribed_Solutions__c subscribedSolution = new Subscribed_Solutions__c();
            subscribedSolution.User__c = UserInfo.getUserId();
            subscribedSolution.Solution__c = solutionId;
            subscribedSolution.Contact__c = userContact.Id;
            subscribedSolution.RecordTypeId = UTL_RecordType.getRecordTypeId(
                OBJ_NAME,
                RT_APPLICATION
            );
            uow.registerNew(subscribedSolution);
            uow.commitWork();
        } catch (Exception e) {
            LOGGER.error(
                'OSB_Modal_CTRL : createUserSubscribedSolution  Create an application that the user subscribed to Exception logged: ',
                e
            );
            OSB_SRV_ActionFailureHandler.newInstance()
                .handleError(e, OSB_Modal_CTRL.class.getName());
        }
        LOGGER.info(
            'OSB_Modal_CTRL : createUserSubscribedSolution Successfullu created an application that the user subscribed to'
        );
    }

    /**
     * @description inserts multiple new Subscribed Solution records and returns true if successful and false if not
     * <br/>SFP-21026
     *
     * @param  shortcutsList List<Subscribed_Solutions__c>
     **/
    @AuraEnabled(Cacheable=false)
    public static void createUserSubscribedShorcut(
        List<Subscribed_Solutions__c> shortcutsList
    ) {
        LOGGER.info(
            'OSB_Modal_CTRL : createUserSubscribedShorcut Create an shortcut that the user subscribed to'
        );
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try {
            Contact userContact = SEL_Contacts.newInstance()
                .selectByUserIdWoSharing(new Set<Id>{ userInfo.getUserId() })[0];

            List<Subscribed_Solutions__c> subscribedShortcutsList = new List<Subscribed_Solutions__c>();

            for (Subscribed_Solutions__c subscribedSolution : shortcutsList) {
                Subscribed_Solutions__c subscribedShortcut = new Subscribed_Solutions__c();
                subscribedShortcut.User__c = UserInfo.getUserId();
                subscribedShortcut.Solution__c = subscribedSolution.Solution__c;
                subscribedShortcut.Contact__c = userContact.Id;
                subscribedShortcut.RecordTypeId = UTL_RecordType.getRecordTypeId(
                    OBJ_NAME,
                    RT_SHORTCUTS
                );
                subscribedShortcut.Short_Cut_Name__c = subscribedSolution.Short_Cut_Name__c;
                subscribedShortcut.Short_Cut_Redirect_URL__c = subscribedSolution.Short_Cut_Redirect_URL__c;
                subscribedShortcutsList.add(subscribedShortcut);
            }

            uow.registerNew(subscribedShortcutsList);
            uow.commitWork();
        } catch (Exception e) {
            LOGGER.error(
                'OSB_Modal_CTRL : createUserSubscribedShorcut Create an shortcut that the user subscribed to Exception logged: ',
                e
            );
            OSB_SRV_ActionFailureHandler.newInstance()
                .handleError(e, OSB_Modal_CTRL.class.getName());
        }
        LOGGER.info(
            'OSB_Modal_CTRL : createUserSubscribedShorcut Successfully created an shortcut that the user subscribed to'
        );
    }

    /**
     * @description Retrieve shortcuts available to the user
     * <br/>SFP-21026
     *
     * @param  solutionName String
     *
     * @return Map<String, Object> of the shortcuts returned
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> viewShortcuts(String solutionName) {
        LOGGER.info(
            'OSB_Modal_CTRL : viewShortcuts Retrieving details of the shortcuts for the user'
        );
        Contact userContact = new Contact();
        Map<String, Object> results = new Map<String, Object>();
        try {
            if (UTL_User.isLoggedInUser()) {
                userContact = SEL_Contacts.newInstance()
                    .selectByUserId(new Set<Id>{ UserInfo.getUserId() })[0];
            }
            String contactPingUUID = userContact.Ping_Id__c.substringBetween(
                PING_START_VALUE,
                PING_END_VALUE
            );
            String contactEmail = userContact.Email;
            if (Test.isRunningTest()) {
                String mockBody =
                    '{\n' +
                    '"userId":"' +
                    TEST_PING_ID +
                    '",\n' +
                    '"email": "' +
                    TEST_USER_NAME +
                    '",\n' +
                    '"shopname": "' +
                    TEST_SOLUTIONAME +
                    '",\n' +
                    '"data": {\n' +
                    ' "shortcut": "' +
                    TEST_SHORTCUT +
                    '"\n' +
                    '}\n' +
                    '}\n' +
                    '}';
                results = (Map<String, Object>) JSON.deserializeUntyped(
                    mockBody
                );
            } else {
                results = OSB_SRV_SolutionAPI.newInstance()
                    .getShortcutsAvailable(
                        contactPingUUID,
                        contactEmail,
                        solutionName
                    );
            }
        } catch (Exception e) {
            LOGGER.error(
                'OSB_Modal_CTRL : viewShortcuts  Retrieve shortcuts Exception logged: ',
                e
            );
            OSB_SRV_ActionFailureHandler.newInstance()
                .handleError(e, OSB_Modal_CTRL.class.getName());
        }
        LOGGER.info(
            'OSB_Modal_CTRL : viewShortcuts Successfully retrieved details of the shortcuts for the user'
        );
        return results;
    }
}