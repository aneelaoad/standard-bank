/**
 * @description Selector class for User SObject
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class SEL_Users extends fflib_SObjectSelector {

    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return SEL_Users
     */
    public static SEL_Users newInstance() {
        return (SEL_Users) ORG_Application.selector.newInstance(User.SObjectType);
    }

    /**
     * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return SObjectType
     */
    public SObjectType getSObjectType() {
        return User.SObjectType;
    }

    /**
     * @description Returns list of User fields
     *
     * @return list of SObjectField
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                User.Address,
                User.AE_Number__c,
                User.Business_Unit__c,
                User.City,
                User.ContactId,
                User.AccountId,
                User.Country,
                User.Dialing_code__c,
                User.Email,
                User.FirstName,
                User.Frozen_Account__c,
                User.FullPhotoUrl,
                User.isActive,
                User.LastLoginDate,
                User.LastName,
                User.MobilePhone,
                User.Name,
                User.Ping_UUID__c,
                User.Phone,
                User.PostalCode,
                User.ProfileId,
                User.State,
                User.Street,
                User.Username,
                User.UserRoleId,
                User.Title,
                User.ManagerId,
                User.User_CIB_Global_Area__c,
                User.Contact_Sync_ID__c,
				User.EmployeeNumber,
                User.User_Franco__c,
                User.Ping_BPGUID__c
        };
    }

    /**
     * @description Selects Users by Id
     *
     * @param ids list of User's Ids
     *
     * @return list of User
     */
    public List<User> selectById(Set<Id> ids) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Id IN :ids')
                        .toSOQL()
        );
    }


    /**
     * @description Selects Users by Id
     *
     * @param ids list of User's Ids
     *
     * @return list of User
     */
    public List<User> selectUsersWithProfileByIds(Set<Id> ids) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('Profile.Name')
                        .setCondition('Id IN :ids')
                        .toSOQL()
        );
    }

    /**
     * @description Selects Users by Id with Role Name
     *
     * @param ids list of User's Ids 
     *
     * @return list of User
     */
    public List<User> selectByIdWithRoleName(Set<Id> ids) {
        try{
             return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('UserRole.Name')
                        .setCondition('Id IN :ids')
                        .toSOQL()
        );
        }catch(exception ex){
            return null;
        }
       
    }

    /**
    * @description Returns list of users by PingUUID
    *
    * @param idSet Set<String> set of contact ids
    * @return list of selected contacts
    */
    public List<User> selectByPingUUID(Set<String> idSet) {
        return (List<User>) Database.query(
                newQueryFactory()
                .setCondition('Ping_UUID__c IN: idSet')
                .toSOQL()
        );
    }

    /**
     * @description Selects Users by Contact's Id
     *
     * @param ids set of User's Ids
     *
     * @return list of User
     */
    public List<User> selectByContactId(Set<Id> ids) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('ContactId IN :ids')
                        .toSOQL()
        );
    }

    /**
     * @description Selects Users by Contact's Id
     *
     * @param ids set of User's Ids
     *
     * @return list of User
     */
    public List<User> selectByContactIds(List<Id> ids) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Contact_Sync_ID__c IN :ids')
                        .toSOQL()
        );
    }

    /**
     * @description Selects Users by Name
     *
     * @param names set of User's Names
     *
     * @return User
     */
    public List<User> selectByName(Set<String> names) {
       return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Name IN :names')
                        .toSOQL()
        );
    }

    /**
     * @description Selects Users by IsActive ind Profile's Name
     *
     * @param profileNames
     *
     * @return list of User
     */
    public List<User> selectByIsActiveAndProfileName(Set<String> profileNames) {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition('IsActive = TRUE')
                .setCondition('Profile.Name IN :profileNames')
                .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
                .toSOQL()
        );
    }

    /**
     * @description Selects Users by Username
     *
     * @param userNames
     *
     * @return list of User
     */
    public List<User> selectByUserName(Set<String> userNames) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Username IN :userNames')
                        .toSOQL()
        );
    }
    /**
     * @description Selects Users by Email
     *
     * @param emails
     *
     * @return list of User
     */
    public List<User> selectByEmail(Set<String> emails) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Email IN :emails')
                        .toSOQL()
        );
    }
    /**
     * @description Selects Users with AE Number
     *
     * @return list of User
     */
    public List<User> selectWithAeNumber() {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition('AE_Number__c != null')
                .toSOQL()
        );
    }
    /**
     * @description Selects Users with AE Number
     * @param aeNumber
     * @return list of User
     */
    public List<User> selectByAENumber(Set<String> aeNumber) {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition('AE_Number__c = :aeNumber')
                .toSOQL()
        );
    }
    /**
     * @description Selects User with fields of the associated contact.
     * Meant for use by community/experience users
     *
     * @param ids Ids of the users
     *
     * @return list of User
     */
    public List<User> selectWithContactFieldsById(Set<Id> ids){
        return Database.query(
                newQueryFactory(false, false, true)
            		.selectField('Contact_Sync_Id__c') //SFP-4835 - OneHub - MySupport Tab related component
                        .selectField('Contact.FirstName')
                        .selectField('Contact.LastName')
                        .selectField('Contact.CIF_Number__c')
                        .selectField('Contact.Email')
                        .setCondition('Id IN :ids')
                        .toSOQL()
        );
    }

    /**
     * @description Calls method selectById in without sharing context,
     * 'WoSharing' stands for 'Without Sharing'
     *
     * @param ids
     *
     * @return list of User
     */
    public List<User> selectByIdWoSharing(Set<Id> ids) {
        return new WithoutSharing().selectById(this, ids);
    }

    /**
     * @description Calls method selectByIsActiveAndProfileName in without sharing context,
     * 'WoSharing' stands for 'Without Sharing'
     *
     * @param profileNames
     *
     * @return list of User
     */
    public List<User> selectByIsActiveAndProfileNameWoSharing(Set<String> profileNames) {
        return new WithoutSharing().selectByIsActiveAndProfileName(this, profileNames);
    }

    /**
     * @description Selects User with Contact_Sync_ID__c field.
     * Meant for use by community users
     *
     * @param id
     * 
     * @return User
     */
    public User selectWithContactSyncFieldById(String id){
        try{
            return Database.query(
                newQueryFactory()
                .selectField('AboutMe')
                .selectField('Contact_Sync_ID__c')
                .selectField('Department')
                .selectField('TimeZoneSidKey')
                .selectField('UserEmail__c')
                .setCondition('Id =: id')
                .toSOQL()
        );
        }catch(Exception ex){
            return null;
        }
        
    }

    /**
     * @description Selects Users with Contact_Sync_ID__c field.
     * Meant for use by community users
     *
     * @param id Ids of the users
     *
     * @return list of User
     */
    public List<User> selectWithContactSyncFieldByIds(List<String> id){
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('Contact_Sync_ID__c')
                .setCondition('Id IN: id')
                .toSOQL()
        );
    }

    /**
     * @description Selects Users by Contact_Sync_ID__c
     *
     * @param ids list of User's Ids
     *
     * @return list of User
     */
    public List<User> selectByContactSyncId(Set<Id> ids) {
        return Database.query(
                newQueryFactory(false, false, true)
                .selectField('SmallPhotoUrl')
                .selectField('SmallPhotoUrl')
                .selectField('FederationIdentifier')
            	.selectField('User_Division__c')
            	.selectField('Contact_Sync_ID__c')
                .setCondition('Contact_Sync_ID__c IN :ids')
                .toSOQL()
        );
    }

    /**
     * @description Is used for omitting sharing setting, when needed
     */
    private without sharing class WithoutSharing {

        /**
         * @description Select Users by Id
         *
         * @param selUser
         * @param ids
         *
         * @return list of User
         */
        public List<User> selectById(SEL_Users selUser, Set<Id> ids ) {
            return selUser.selectById(ids);
        }

        /**
         * @description Selects active Users by profile name
         *
         * @param selUser
         * @param profileNames
         *
         * @return list of User
         */
        public List<User> selectByIsActiveAndProfileName(SEL_Users selUser, Set<String> profileNames ) {
            return selUser.selectByIsActiveAndProfileName(profileNames);
        }
    }
    /**
    * @description Selects active Users by User_CIB_Global_Area__c and Email
    * @param userCIBGlobal
    * @param conEmail
    * @return list of User
    */
    public List<User> selectByUserCIBGlobalAndEmail(String userCIBGlobal,Set<String> conEmail){

        return (List<User>) Database.query(
                newQueryFactory()
                        .setCondition('Email IN: conEmail')
                        .setCondition('IsActive = TRUE')
                        .setCondition('User_CIB_Global_Area__c =: userCIBGlobal')
                        .toSOQL()
        );


    }
    
    /**
    * @description selectByUserId active Users by User_CIB_Global_Area__c and Email
    * @param strUserId
    * @return Record User
    */
    public List<User> selectByUserId(String strUserId){

        return (List<User>) Database.query(
                newQueryFactory()
                        .setCondition('Id =: strUserId')
                        .toSOQL()
        );


    }
}