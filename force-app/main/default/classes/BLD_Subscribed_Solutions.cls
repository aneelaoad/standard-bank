/**
 * @description Builder class for Subscribed solutions
 *
 * @author      Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date        March 2021
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason New method for assigning contact to subscribed contact
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Addition of methods for record types being set
 */
@isTest
public without sharing class BLD_Subscribed_Solutions extends ABS_ObjectBuilderBase {
    public static final String DEF_TITLE = 'Test article';
    public static final String DEF_INTRODUCTION = 'Test introduction';
    public static final String DEF_URL = 'Test url';
    public static final String DEF_URL_NAME = 'Test name';
    private static final String TEST_URL_NAME = 'TestURL';
    public static final String OBJ_NAME = 'Subscribed_Solutions__c';
    public static final String RT_APPLICATION = 'Subscribed_Applications';
    public static final String RT_SHORTCUTS = 'Subscribed_Shortcuts';

     /**
     * @description New unit of work
     *
     */
    public BLD_Subscribed_Solutions() {
        this(getNewUnitOfWork());
    }

    /**
     * @description New unit of work with subscribe solutions object
     * 
     * @param uow fflib_SObjectUnitOfWork
     *
     */
    public BLD_Subscribed_Solutions(fflib_SObjectUnitOfWork uow) {
        super(Subscribed_Solutions__c.SObjectType, uow);
    }

    /**
     * @description New unit of work with subscribe solutions object
     * @param sol Subscribed_Solutions__c
     * @param uow fflib_SObjectUnitOfWork
     *
     */
    public BLD_Subscribed_Solutions(
        Subscribed_Solutions__c sol,
        fflib_SObjectUnitOfWork uow
    ) {
        super(sol, uow);
    }

    /**
     * @description Set up basic Data for Builder
     * 
     * @return BLD_Subscribed_Solutions
     */
    public BLD_Subscribed_Solutions setOSBData() {
        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .isComingSoon(false)
            .setField(Knowledge__kav.UrlName, TEST_URL_NAME)
            .setField(Knowledge__kav.Title, DEF_TITLE)
            .setField(
                Knowledge__kav.RecordtypeId,
                UTL_RecordType.getRecordTypeId(
                    DMN_Knowledge.OBJ_NAME,
                    DMN_Knowledge.RT_API
                )
            )
            .commitWork()
            .getRecord();

        return (BLD_Subscribed_Solutions) setField(
            Subscribed_Solutions__c.Solution__c,
            article.Id
        );
    }

    /**
     * @description sets Contact to subscribed solution
     *
     * @param contactId Id
     * 
     * @return BLD_Subscribed_Solutions object
     */
    public BLD_Subscribed_Solutions setContact(Id contactId) {
        return (BLD_Subscribed_Solutions) setField(Subscribed_Solutions__c.Contact__c, contactId);
    }

    /**
     * @description sets Subscribed Application Record Type
     *
     * @return BLD_Subscribed_Solutions object
     */
    public BLD_Subscribed_Solutions setApplicationRecordType() {
        return (BLD_Subscribed_Solutions) setField(Subscribed_Solutions__c.RecordTypeId, UTL_RecordType.getRecordTypeId(OBJ_NAME,RT_APPLICATION));
    }

    /**
     * @description sets Subscribed Shortcut Record Type
     *
     * @return BLD_Subscribed_Solutions object
     */
    public BLD_Subscribed_Solutions setShortcutRecordType() {
        return (BLD_Subscribed_Solutions) setField(Subscribed_Solutions__c.RecordTypeId, UTL_RecordType.getRecordTypeId(OBJ_NAME,RT_SHORTCUTS));
    }

    /**
     * @description sets the Subscribed_Solutions__c Shortcut Name Field
     *
     * @param shortcutName String
     * @return BLD_Subscribed_Solutions object
     */
    public BLD_Subscribed_Solutions setShortcutName(String shortcutName) {
        return (BLD_Subscribed_Solutions) setField(
            Subscribed_Solutions__c.Short_Cut_Name__c,
            shortcutName
        );
    }

    /**
     * @description sets the Subscribed_Solutions__c Shortcut Name Field
     * <br/>SFP-21026
     * 
     * @param shortcutName String
     * @return BLD_Subscribed_Solutions object
     */
    public BLD_Subscribed_Solutions setShortcutURL(String shortcutUrl) {
        return (BLD_Subscribed_Solutions) setField(
            Subscribed_Solutions__c.Short_Cut_Redirect_URL__c,
            shortcutUrl
        );
    }

}