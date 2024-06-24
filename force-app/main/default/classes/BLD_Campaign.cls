/**
 * Builder class for Campaign SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @description Builder class
 * @date March 2020
 */
@IsTest
public without sharing class BLD_Campaign extends ABS_ObjectBuilderBase {

    private static final String DEF_NAME = 'campaign name';
    private static final String STATUS = 'Proposal';
    private static final String VENUE_NAME = 'venue name';
    private static final String LOCATION_CITY = 'location test';
    private static final String INVITATION_TYPE = 'Single';
    private static final Date SAVE_DATE_SENT = Date.today().addDays(2);
    private static final Date INVITATION_SENT = Date.today().addDays(2);
    private static final Date RSVP = Date.today().addDays(2);
    private static final String EVENT_NAME = 'event name';
    private static final Datetime EVENT_DATE_TIME = DateTime.newInstance(SAVE_DATE_SENT.year(), SAVE_DATE_SENT.month(), SAVE_DATE_SENT.day(), 9, 0, 0);
    public static final Date EVENT_START_DATE = Date.today().addDays(2);
    public static final Date EVENT_END_DATE = Date.today().addDays(5);
    public static final Time EVENT_START_TIME = Time.newInstance(1, 2, 3, 4);
    public static final Time EVENT_END_TIME = Time.newInstance(6, 2, 3, 4);
    private static final Date AIDE_MEMOIR_SENT = Date.today().addDays(2);
    private static final String MAP_URL = 'www.mapurl.com';
    private static final String PROGRAMME_URL = 'www.programmeurl.com';
    private static final String AGENDA_URL = 'www.agendaurl.com';
    private static final String RSVP_DISCLAIMER = 'rsvp disclaimer';
    private static final String HEADER_IMAGE_URL = 'https://www.standardbank.co.za/static_file/Campaigns/Studio/online2020/GMS-16258/GMS-16258-GInvite.jpg';

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public BLD_Campaign() {
        this(getNewUnitOfWork());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_Campaign(fflib_SObjectUnitOfWork uow) {
        super(Campaign.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(Campaign.Name, DEF_NAME);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param isActive 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign active(Boolean isActive) {
        return (BLD_Campaign) setField(Campaign.IsActive, isActive);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param category 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign category(String category) {
        return (BLD_Campaign) setField(Campaign.Campaign_Category__c, category);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param name 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign name(String name) {
        return (BLD_Campaign) setField(Campaign.Name, name);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param type 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign type(String type) {
        return (BLD_Campaign) setField(Campaign.Type, type);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param emailBody 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign emailBody(String emailBody) {
        return (BLD_Campaign) setField(Campaign.Email_Body__c, emailBody);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param emailSubject 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign emailSubject(String emailSubject) {
        return (BLD_Campaign) setField(Campaign.Email_Subject__c, emailSubject);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param emailSignature 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign emailSignature(String emailSignature) {
        return (BLD_Campaign) setField(Campaign.Email_Signature__c, emailSignature);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param lock 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign lock(Boolean lock) {
        return (BLD_Campaign) setField(Campaign.Lock_Campaign__c, lock);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventName 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign eventName(String eventName) {
        return (BLD_Campaign) setField(Campaign.Event_Name__c, eventName);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param url 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign addHeaderImage(String url) {
        return (BLD_Campaign) setField(Campaign.Email_Header_Image_URL__c, url);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param camMemberBld 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign addMember(BLD_CampaignMember camMemberBld) {
        return (BLD_Campaign) addChild(CampaignMember.CampaignId, camMemberBld);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param camMemberHostBld 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign addMemberHost(BLD_CampaignMemberHost camMemberHostBld) {
        return (BLD_Campaign) addChild(Campaign_Member_Host__c.Campaign__c, camMemberHostBld);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_Campaign 
    **/
    public BLD_Campaign isCampaignEvent() {
        return (BLD_Campaign) setField(Campaign.Venue_Name__c, VENUE_NAME)
        .setField(Campaign.Status, STATUS)
        .setField(Campaign.Location_City__c, LOCATION_CITY)
        .setField(Campaign.Invitation_Type__c, INVITATION_TYPE)
        .setField(Campaign.Save_The_Date_Sent__c, SAVE_DATE_SENT)
        .setField(Campaign.Date_Invitation_Sent__c, INVITATION_SENT)
        .setField(Campaign.RSVP__c, RSVP)
        .setField(Campaign.Event_Name__c, EVENT_NAME)
        .setField(Campaign.Event_Date_Time__c, EVENT_DATE_TIME)
        .setField(Campaign.EAP_Event_Start_Date__c, EVENT_START_DATE)
        .setField(Campaign.EAP_Event_End_Date__c, EVENT_END_DATE)
        .setField(Campaign.EAP_Event_Start_Time__c, EVENT_START_TIME)
        .setField(Campaign.EAP_Event_End_Time__c, EVENT_END_TIME)
        .setField(Campaign.Aide_Memoire_Sent__c, AIDE_MEMOIR_SENT)
        .setField(Campaign.Map_URL__c, MAP_URL)
        .setField(Campaign.Programme_URL__c, PROGRAMME_URL)
        .setField(Campaign.Agenda_URL__c, AGENDA_URL)
        .setField(Campaign.RSVP_Disclaimer__c, RSVP_DISCLAIMER)
        .setField(Campaign.Email_Header_Image_URL__c, HEADER_IMAGE_URL);
    }

}