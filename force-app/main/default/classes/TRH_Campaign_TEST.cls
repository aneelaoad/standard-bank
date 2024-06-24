/**
 * Test class for TRH_Campaign class
 *
 * @author    Michal Pesko (mpesko@deloittece.com)
 * @date    December 2020
 */
@IsTest
public with sharing class TRH_Campaign_TEST {
    private static final String USERNAME='pesko.testUserApi@example.com';
    private static final String TYPE_CLIENT_RESEARCH='Client Research';
    private static final String TYPE_DIRECT_MARKETING='Direct Marketing';
    private static final String TYPE_MARKETING_EVENT='Marketing Event';
    
    private static Map<PicklistEntry, List<PicklistEntry>> parent2Dependent = UTL_Picklist.getControllingToDependentMap(Campaign.Campaign_Category__c, Campaign.Campaign_Category_Type__c);

    @IsTest(SeeAllData=true)
    public static void shouldInsertNewSurveyCampaignMemberStatuses() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User apiUser = (User) new BLD_USER(USERNAME, uow).useAPIUser().commitWork().getRecord();

        BLD_Campaign bldCampaign = new BLD_Campaign(uow).name('test survey campaign')
            .type(TYPE_CLIENT_RESEARCH)
            .category(DMN_Campaign.CATEGORY_SURVEY);
        setRequiredFieldsForSurvey(bldCampaign);

        System.runAs(apiUser) {
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }

        Id campId = bldCampaign.getRecordId();

        List<CampaignMemberStatus> memberStatuses = [
            SELECT Label
            FROM CampaignMemberStatus
            WHERE CampaignId = :campId
                AND Label IN :(new Set<String> {DMN_CampaignMember.STATUS_NOT_SENT,
                    DMN_CampaignMember.STATUS_SENT,
                    DMN_CampaignMember.STATUS_RESPONDED})];

        System.assertEquals(3, memberStatuses.size());
    }

    @IsTest(SeeAllData=true)
    private static void shouldInsertNewPAEventCampaignMemberStatuses() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User apiUser = (User) new BLD_USER(USERNAME, uow).useAPIUser().commitWork().getRecord();
        BLD_Campaign bldCampaign = new BLD_Campaign(uow).name('test PA Event campaign')
            .type(TYPE_MARKETING_EVENT)
            .category(DMN_Campaign.CATEGORY_PA_EVENT);
        setCampaignCategoryType(bldCampaign, DMN_Campaign.CATEGORY_PA_EVENT);
        setRequiredFieldsFor7PA(bldCampaign);

        System.runAs(apiUser) {
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }

        Id campId = bldCampaign.getRecordId();

        List<CampaignMemberStatus> memberStatuses = [
            SELECT Label
            FROM CampaignMemberStatus
            WHERE CampaignId = :campId
                AND Label IN :(new Set<String> { DMN_CampaignMember.STATUS_NOT_SENT,
                    DMN_CampaignMember.STATUS_SENT,
                    DMN_CampaignMember.STATUS_SENT_REMINDER,
                    DMN_CampaignMember.STATUS_ACCEPTED,
                    DMN_CampaignMember.STATUS_DECLINED})];

        System.assertEquals(5, memberStatuses.size());
    }

    @IsTest(SeeAllData=true)
    private static void shouldInsertNewOpMailerCampaignMemberStatuses() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User apiUser = (User) new BLD_USER(USERNAME, uow).useAPIUser().commitWork().getRecord();
        BLD_Campaign bldCampaign = new BLD_Campaign(uow).name('test Operational Mailer Campaign')
            .type(TYPE_DIRECT_MARKETING)
            .category(DMN_Campaign.CATEGORY_OPERATIONAL_MAILER);
        setCampaignCategoryType(bldCampaign, DMN_Campaign.CATEGORY_OPERATIONAL_MAILER);
        setRequiredFieldsForOpMailer(bldCampaign);
        bldCampaign.setField(Campaign.Email_Subject__c, 'test_email_subject');
        bldCampaign.setField(Campaign.Email_Body__c, 'test_email_body');
        bldCampaign.setField(Campaign.Email_Signature_rt__c, 'test_email_signature');

        System.runAs(apiUser) {
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }

        Id campId = bldCampaign.getRecordId();

        List<CampaignMemberStatus> memberStatuses = [
            SELECT Label
            FROM CampaignMemberStatus
            WHERE CampaignId = :campId
                AND Label IN :(new Set<String> { DMN_CampaignMember.STATUS_NOT_SENT,
                    DMN_CampaignMember.STATUS_SENT})];

        System.assertEquals(2, memberStatuses.size());
    }

    @IsTest(SeeAllData=true)
    private static void shouldInsertNewRegularCampaignMemberStatuses() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User apiUser = (User) new BLD_USER(USERNAME, uow).useAPIUser().commitWork().getRecord();

        BLD_Campaign bldCampaign = new BLD_Campaign(uow)
            .category(DMN_Campaign.CATEGORY_GROUP_EVENT);

        System.runAs(apiUser) {
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }

        Id campId = bldCampaign.getRecordId();

        List<CampaignMemberStatus> memberStatuses = [
            SELECT Label
            FROM CampaignMemberStatus
            WHERE CampaignId = :campId
                AND Label IN :(new Set<String> {
                    DMN_CampaignMember.STATUS_ACCEPTED,
                    DMN_CampaignMember.STATUS_DECLINED
                })];

        System.assertEquals(2, memberStatuses.size());
    }

    @IsTest(SeeAllData=true)
    private static void shouldNotHitAnyLimits() {
        Set<Id> ids = new Set<Id>();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User apiUser = (User) new BLD_USER(USERNAME, uow).useAPIUser().commitWork().getRecord();
        List<BLD_Campaign> campaigns = new List<BLD_Campaign>();
        for (Integer i = 0; i < 10; i++) {
            BLD_Campaign bldCampaignSurvey = new BLD_Campaign(uow).name('test survey campaign' + i)
                .type(TYPE_CLIENT_RESEARCH)
                .category(DMN_Campaign.CATEGORY_SURVEY);
            setRequiredFieldsForSurvey(bldCampaignSurvey);
            campaigns.add(bldCampaignSurvey);

            BLD_Campaign bldCampaign7PA = new BLD_Campaign(uow).name('test PA Event campaign' + i)
                .type(TYPE_MARKETING_EVENT)
                .category(DMN_Campaign.CATEGORY_PA_EVENT);
            setCampaignCategoryType(bldCampaign7PA, DMN_Campaign.CATEGORY_PA_EVENT);
            setRequiredFieldsFor7PA(bldCampaign7PA);
            campaigns.add(bldCampaign7PA);
        }

        System.runAs(apiUser) {
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }

        for(BLD_Campaign campaign: campaigns){
            ids.add(campaign.getRecordId());
        }

        List<CampaignMemberStatus> memberStatuses = [
            SELECT Label
            FROM CampaignMemberStatus
            WHERE CampaignId IN :ids
                AND Label IN :(new Set<String> {DMN_CampaignMember.STATUS_NOT_SENT,
                    DMN_CampaignMember.STATUS_SENT,
                    DMN_CampaignMember.STATUS_SENT_REMINDER,
                    DMN_CampaignMember.STATUS_ACCEPTED,
                    DMN_CampaignMember.STATUS_DECLINED,
                    DMN_CampaignMember.STATUS_RESPONDED})];
        System.assertEquals(4 * ids.size(), memberStatuses.size());
    }

    private static void setRequiredFieldsForSurvey(BLD_Campaign bldCampaign) {
        bldCampaign.setField(Campaign.Research_Partner__c, UTL_Picklist.getPicklistValues(Campaign.Research_Partner__c)[0].getValue());
        bldCampaign.setField(Campaign.Bank__c, UTL_Picklist.getPicklistValues(Campaign.Bank__c)[0].getValue());
        bldCampaign.setField(Campaign.Email_Subject__c, 'test_email_subject');
    }
    
    private static void setRequiredFieldsFor7PA(BLD_Campaign bldCampaign) {
        bldCampaign.setField(Campaign.Venue_Name__c, 'test_venue_name');
        bldCampaign.setField(Campaign.Location_City__c, UTL_Picklist.getPicklistValues(Campaign.Location_City__c)[0].getValue());
        bldCampaign.setField(Campaign.Invitation_Type__c, UTL_Picklist.getPicklistValues(Campaign.Invitation_Type__c)[0].getValue());
        bldCampaign.setField(Campaign.Save_The_Date_Sent__c, System.today());
        bldCampaign.setField(Campaign.Date_Invitation_Sent__c, System.today());
        bldCampaign.setField(Campaign.RSVP__c, System.today());
        bldCampaign.setField(Campaign.Event_Name__c, 'test_event_name');
        bldCampaign.setField(Campaign.Event_Date_Time__c, System.now());
        bldCampaign.setField(Campaign.Aide_Memoire_Sent__c, System.today());
        bldCampaign.setField(Campaign.Map_URL__c, 'www.google.es');
        bldCampaign.setField(Campaign.Programme_URL__c, 'www.google.es');
        bldCampaign.setField(Campaign.Agenda_URL__c, 'www.google.es');
        bldCampaign.setField(Campaign.RSVP_Disclaimer__c, 'test disclaimer');
        bldCampaign.setField(Campaign.EAP_Event_End_Date__c, System.today());
        bldCampaign.setField(Campaign.EAP_Event_End_Time__c, Time.newInstance(18, 30, 2, 0));
        bldCampaign.setField(Campaign.EAP_Event_GMT_Timezone__c, '-3');
        bldCampaign.setField(Campaign.EAP_Event_Start_Date__c, System.today());
        bldCampaign.setField(Campaign.EAP_Event_Start_Time__c, Time.newInstance(18, 30, 2, 0));
    }

    private static void setRequiredFieldsForOpMailer(BLD_Campaign bldCampaign) {
        bldCampaign.setField(Campaign.Email_Subject__c, 'test_email_subject');
        bldCampaign.setField(Campaign.Email_Body__c, 'test_email_body');
        bldCampaign.setField(Campaign.Email_Signature_rt__c, 'test_email_signature');
    }
    
    private static void setCampaignCategoryType(BLD_Campaign bldCampaign, String campaignCategory) {
        String campaignCategoryTypeValue = '';
        for(PicklistEntry key : parent2Dependent.keySet()){
            if(key.getValue() == campaignCategory) {
                campaignCategoryTypeValue = parent2Dependent.get(key)[0].getValue();
            }
        }
        bldCampaign.setField(Campaign.Campaign_Category_Type__c, campaignCategoryTypeValue);
    }

    @IsTest(SeeAllData=true)
    private static void shouldCreateLocalTimeField() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User apiUser = (User) new BLD_USER(USERNAME, uow).useAPIUser().commitWork().getRecord();
        BLD_Campaign bldCampaignTimezone = new BLD_Campaign(uow).name('test PA Event campaign')
        .type(TYPE_MARKETING_EVENT)
        .category(DMN_Campaign.CATEGORY_MM_EVENT);
        setCampaignCategoryType(bldCampaignTimezone, DMN_Campaign.CATEGORY_MM_EVENT);
        setRequiredFieldsFor7PA(bldCampaignTimezone);
        BLD_Contact bldContact = new BLD_Contact(uow).useClientContact();
        BLD_CampaignMember bldCm = new BLD_CampaignMember(uow)
        .campaign(bldCampaignTimezone)
        .invitationResponseAccepted()
        .status('Responded')
        .contact(bldContact);

        System.runAs(apiUser) {
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }

        Id campId = bldCampaignTimezone.getRecordId();

        List<Campaign> campaign = [Select EAP_Event_Start_Date_Local_Time__c, EAP_Event_End_Date_Local_Time__c, Deploy_to_MC__c FROM Campaign Where Id =: campId];

        campaign[0].Deploy_to_MC__c = true;
        update campaign[0];

        System.assertNotEquals(campaign[0].EAP_Event_End_Date_Local_Time__c, null, 'Local time should not be null');

    }

}