/**
 * Builder class for Contact SObject
 * @description Builder class
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Addition of method for Manage_Site_Features__c field addition
 * 
 */
@IsTest
@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class BLD_Contact extends ABS_ObjectBuilderBase{

    public static final String DEF_FIRST_NAME = 'testFirstName';
    public static final String DEF_LAST_NAME = 'testContact';
    public static final String DEF_EMAIL = 'test@Contact.testcom';
    public static final String DEF_PHONE = '192837465';
    public static final String DEF_PHONE_COUNTRY = 'South Africa';
    public static final String DEF_OPERATING_COUNTRY = 'Angola;South Africa';

    private static Integer counter = 0;

    private static Boolean allowDuplicates = false;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public BLD_Contact() {
        this(getNewUnitOfWork());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param workUnit 
    **/
    public BLD_Contact(fflib_SObjectUnitOfWork workUnit) {
        super(Contact.SObjectType, workUnit);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param sObj 
    * @param workUnit 
    **/
    public BLD_Contact(Contact sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(Contact.LastName,  counter + DEF_LAST_NAME + counter)
                .setField(Contact.Phone, counter + DEF_PHONE + counter)
                .setField(Contact.Email, counter + DEF_EMAIL + counter);
        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param birthDayMonth 
    * @return BLD_Contact 
    **/
    public BLD_Contact birthDayMonth(String birthDayMonth) {
        return(BLD_Contact) setField(Contact.Birth_Day_Month__c, birthDayMonth);
    }
    
         /**
    * @description 
    * @author Vipeen Keshavrao | 08-14-2023 
    * @param userDivisionSync 
    * @return BLD_Contact 
    **/
    public BLD_Contact userDivisionSync(String userDivisionSync) {
        return(BLD_Contact) setField(Contact.User_Division_Sync__c, userDivisionSync);
    }
    
    /**
    * @description 
    * @author Vipeen Keshavrao | 08-14-2023  
    * @param userBusinessUnitSync 
    * @return BLD_Contact 
    **/
    public BLD_Contact userBusinessUnitSync(String userBusinessUnitSync) {
        return(BLD_Contact) setField(Contact.User_Business_Unit_Sync__c, userBusinessUnitSync);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param cifNumber 
    * @return BLD_Contact 
    **/
    public BLD_Contact cifNumber(String cifNumber) {
        return(BLD_Contact) setField(Contact.CIF_Number__c, cifNumber);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param email 
    * @return BLD_Contact 
    **/
    public BLD_Contact email(String email) {
        return(BLD_Contact)setField(Contact.Email, email);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param mobilePhone 
    * @return BLD_Contact 
    **/
    public BLD_Contact mobilePhone(String mobilePhone) {
        return(BLD_Contact)setField(Contact.MobilePhone, mobilePhone);
    }

    /**
    * @description 
    * @author Vipeen Keshavrao
    * @param boolean 
    * @return BLD_Contact 
    **/
    public BLD_Contact isActive(boolean flag) {
        return(BLD_Contact)setField(Contact.Inactive__c, flag);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param phone 
    * @return BLD_Contact 
    **/
    public BLD_Contact phone(String phone) {
        return(BLD_Contact)setField(Contact.Phone, phone);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param fax 
    * @return BLD_Contact 
    **/
    public BLD_Contact fax(String fax) {
        return (BLD_Contact) setField(Contact.Fax, fax);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param firstName 
    * @param lastName 
    * @return BLD_Contact 
    **/
    public BLD_Contact name(String firstName, String lastName) {
        return(BLD_Contact)setField(Contact.LastName, lastName).setField(Contact.FirstName, firstName);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param lastName 
    * @return BLD_Contact 
    **/
    public BLD_Contact lastName(String lastName) {
        return(BLD_Contact)setField(Contact.LastName, lastName);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param mailingStreet 
    * @param mailingCity 
    * @param mailingCountry 
    * @param mailingPostalCode 
    * @return BLD_Contact 
    **/
    public BLD_Contact mailingAddress(String mailingStreet, String mailingCity, String mailingCountry, String mailingPostalCode){
        return(BLD_Contact)setField(Contact.MailingStreet, mailingStreet).setField(Contact.MailingCity, mailingCity)
                .setField(Contact.MailingCountry, mailingCountry)
                .setField(Contact.MailingPostalCode, mailingPostalCode);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param recordTypeId 
    * @return BLD_Contact 
    **/
    public BLD_Contact recordTypeId(Id recordTypeId){
        return(BLD_Contact) setField(Contact.RecordTypeId, recordTypeId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param title 
    * @return BLD_Contact 
    **/
    public BLD_Contact contactCategory(String title) {
        return(BLD_Contact)setField(Contact.Contact_Category__c, title);

    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param icbcContact 
    * @return BLD_Contact 
    **/
    public BLD_Contact icbcContact(Boolean icbcContact) {
        return(BLD_Contact)setField(Contact.ICBC_Contact__c, icbcContact);

    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param inactive 
    * @return BLD_Contact 
    **/
    public BLD_Contact inactive(Boolean inactive) {
        return(BLD_Contact)setField(Contact.Inactive__c, inactive);

    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param reasonForInactive 
    * @return BLD_Contact 
    **/
    public BLD_Contact reasonForInactive(String reasonForInactive) {
        return(BLD_Contact)setField(Contact.Reason_for_Inactive__c, reasonForInactive);

    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param role 
    * @return BLD_Contact 
    **/
    public BLD_Contact roleAtClient(String role){
        return(BLD_Contact)setField(Contact.Contact_Role_s_at_Client__c, role);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_Contact 
    **/
    public BLD_Contact useBankContact(){
        return (BLD_Contact)setField(Contact.RecordTypeId,
                UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK));
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_Contact 
    **/
    public BLD_Contact useClientContact(){
        return (BLD_Contact)setField(Contact.RecordTypeId,
                UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_CLIENT));
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param accountId 
    * @return BLD_Contact 
    **/
    public BLD_Contact accountId(Id accountId){
        return (BLD_Contact)setField(Contact.AccountId, accountId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param accountBld 
    * @return BLD_Contact 
    **/
    public BLD_Contact account(ABS_ObjectBuilderBase accountBld){
        return (BLD_Contact) setRelation(Contact.AccountId, accountBld);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param ownerId 
    * @return BLD_Contact 
    **/
    public BLD_Contact ownerId(Id ownerId){
        return (BLD_Contact) setField(Contact.OwnerId, ownerId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param keyClientContactBuilder 
    * @return BLD_Contact 
    **/
    public BLD_Contact addKeyClientContact(BLD_KeyClientContact keyClientContactBuilder) {
        return (BLD_Contact) addChild(Key_Client_Contact__c.Contact_Name__c, keyClientContactBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param caseBuilder 
    * @return BLD_Contact 
    **/
    public BLD_Contact addResolvedCase(BLD_Case caseBuilder) {
        return (BLD_Contact) addChild(Case.Resolved_By__c, caseBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param contactBuilder 
    * @return BLD_Contact 
    **/
    public BLD_Contact addTeamMember(BLD_ContactTeamMember contactBuilder) {
        return (BLD_Contact) addChild(SA_Contact_Team_Member__c.SA_Contact__c, contactBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param taskBuilder 
    * @return BLD_Contact 
    **/
    public BLD_Contact addTask(BLD_Task taskBuilder) {
        return (BLD_Contact) addChild(Task.WhoId, taskBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_Contact 
    **/
    public BLD_Contact allowDuplicates(){
        allowDuplicates = true;
        return this;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param pingId 
    * @return BLD_Contact 
    **/
    public BLD_Contact pingId(String pingId){
        return (BLD_Contact) setField(Contact.Ping_Id__c, pingId);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param companyName 
    * @return BLD_Contact 
    **/
    public BLD_Contact companyName(String companyName){
        return (BLD_Contact) setField(Contact.OSB_Company_name__c, companyName);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param communityAccessManager 
    * @return BLD_Contact 
    **/
    public BLD_Contact communityAccessManager(Id communityAccessManager){
        return (BLD_Contact) setField(Contact.OSB_Community_Access_Manager__c, communityAccessManager);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param communityManager 
    * @return BLD_Contact 
    **/
    public BLD_Contact communityAccessManager(BLD_Contact communityManager){
        return (BLD_Contact) setRelation(Contact.OSB_Community_Access_Manager__c, communityManager);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param communityAccessRole 
    * @return BLD_Contact 
    **/
    public BLD_Contact communityAccessRole(String communityAccessRole){
        return (BLD_Contact) setField(Contact.OSB_Community_Access_Role__c, communityAccessRole);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param identityNumber 
    * @return BLD_Contact 
    **/
    public BLD_Contact identityNumber(String identityNumber){
        return (BLD_Contact) setField(Contact.Identity_Number__c, identityNumber);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param communityAccessStatus 
    * @return BLD_Contact 
    **/
    public BLD_Contact communityAccessStatus(String communityAccessStatus){
        return (BLD_Contact) setField(Contact.OSB_Community_Access_Status__c, communityAccessStatus);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param operatingCountry 
    * @return BLD_Contact 
    **/
    public BLD_Contact operatingCountry(String operatingCountry){
        return (BLD_Contact) setField(Contact.OSB_Operating_Country__c, operatingCountry);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param businessInterests 
    * @return BLD_Contact 
    **/
    public BLD_Contact businessInterests(String businessInterests){
        return (BLD_Contact) setField(Contact.Business_Interests__c, businessInterests);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param interests 
    * @return BLD_Contact 
    **/
    public BLD_Contact interests(String interests){
        return (BLD_Contact) setField(Contact.Interests__c, interests);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param communityAccessRole 
    * @param communityAccessStatus 
    * @return BLD_Contact 
    **/
    public BLD_Contact setOSBDefaultData(String communityAccessRole, String communityAccessStatus){
        return (BLD_Contact)
                setField(Contact.FirstName, DEF_FIRST_NAME)
                        .setField(Contact.LastName, DEF_LAST_NAME)
                        .setField(Contact.Email, DEF_EMAIL)
                        .setField(Contact.MobilePhone, DEF_PHONE)
                        .setField(Contact.Phone, DEF_PHONE)
                        .setField(Contact.Phone_Country__c, DEF_PHONE_COUNTRY)
                        .setField(Contact.OSB_Community_Access_Role__c, communityAccessRole)
                        .setField(Contact.OSB_Community_Access_Status__c, communityAccessStatus)
                        .setField(Contact.OSB_Operating_Country__c, DEF_OPERATING_COUNTRY);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return ABS_ObjectBuilderBase 
    **/
    public override ABS_ObjectBuilderBase commitWork(){

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = allowDuplicates;
        dml.OptAllOrNone = false;
        Contact con = (Contact)getRecord();
        if(con.Id == null){
            Database.insert(con, dml);
        }
        else{
            Database.update(con, dml);
        }
        return this;
    }

    /**
    * @description Addition for Manage_Site_Features__c
    * @author Milica Milicevic
    * @param feature 
    * @return BLD_Contact 
    **/
    public BLD_Contact manageSiteFeature(String feature){
        return (BLD_Contact) setField(Contact.Manage_Site_Features__c, feature);
    }

}