/**
 * 
 * @description Controller class of Navigation bar
 * @author Maham Hasan
 * @since 
 */
public with sharing class SBGNavigationBarController {

    private static Map<String, Country_Information__mdt>  mapCountryInfo;
    private static Map<String, Language_Information__mdt> maplangISOCodeVSLanguageInfo;
    private static final String LOGIN_ALERT_NOTIFICATION_TYPE_NAME = 'BCB_Platform_Login_Alert_Notification';
    private static final String LOGIN_ALERT_EMAIL_TEMPLATE_DEVELOPERNAME = 'BCB_Platform_User_Login_Alert_Notification';

    /**
     * @description Continent class
     */
    public class Continent {
        @AuraEnabled
        public string name;
        @AuraEnabled
        public List<Country> countries;
    }

    /**
     * @description : Country class
     */
    public class Country {
        @AuraEnabled
        public string countryName;
        @AuraEnabled
        public string flagImage;
        @AuraEnabled
        public List<Language> languages;
    }

    /**
     * @description : Language Class
     */
    public class Language {
        @AuraEnabled
        public string languageName;
        @AuraEnabled
        public string styleClass = 'icon';
        @AuraEnabled
        public String languageISOCode;
    }

    /**
     * @description : MobileTab class
     */
    public class MobileTab {
        @AuraEnabled
        public string id;
        @AuraEnabled
        public string parentId;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string url;
        @AuraEnabled
        public string target;
        @AuraEnabled
        public List<MobileTab> subMenuItems;
    }

    /**
     * 
     * @description : getNavItems by Position
     * @param position String
     * @return  `List<SBG_Navigation_Items__mdt>`
     */
    @AuraEnabled(cacheable=true)
    public static List<SBG_Navigation_Items__mdt> getNavItems(String position){
        List<SBG_Navigation_Items__mdt> navItems = new List<SBG_Navigation_Items__mdt>();
        List<SBG_Navigation_Items__mdt> navItemsFiltered = new List<SBG_Navigation_Items__mdt>();
        try{
            navItems = SBG_Navigation_Items__mdt.getAll().values();
             System.debug('nav items: '+navItems);

            if(Auth.CommunitiesUtil.isGuestUser()) {
                for(Integer row = 0; row < navItems.size(); row++) {
                    if(navItems[row].Available_for_guest_user__c == TRUE && navItems[row].Item_Position__c == position && navItems[row].IsActive__c == TRUE) {
                        navItemsFiltered.add(navItems[row]);
                    }
                }
            }
            else if(!Auth.CommunitiesUtil.isGuestUser()) {
                for(Integer row = 0; row < navItems.size(); row++) {
                    User user = getCurrentUser();
                    if(user.Ping_BPGUID__c != NULL && navItems[row].Item_Position__c == position && navItems[row].IsActive__c == TRUE) {
                        navItemsFiltered.add(navItems[row]);
                    }
                    else if(user.Ping_BPGUID__c == NULL && navItems[row].Available_for_Mall_Experience_User__c == TRUE && navItems[row].Item_Position__c == position && navItems[row].IsActive__c == TRUE) {
                        navItemsFiltered.add(navItems[row]);
                    }
                }
            }
        }catch(Exception e){ 
            throw MallExceptionUtil.throwAuraException('SBGNavigationBarController.getNavItems', e); 
        }
       System.debug('nav items: '+navItemsFiltered);
        return navItemsFiltered;
    }

    /**
     * 
     * @description : getCountryList
     * @return  `List<Continent>`
     */
    @AuraEnabled(cacheable=true)
    public static List<Continent> getCountryList(){
        Map<String, Continent> continentMap = new Map<String, Continent>();
        try{
            List<Tag__c> countryTags = new List<Tag__c>();
            List<Tag__c> languageTags = new List<Tag__c>();
            countryTags = SEL_Tags.newInstance().selectTagsByParentNames(new Set<String>{'Country'});
            languageTags = SEL_Tags.newInstance().selectTagsByRootNames(new Set<String>{'Language'});
            for (Tag__c countryTag: countryTags) {
                if (continentMap.get(countryTag.Related_Tag__r.Name) == null) {
                    Continent continent = new Continent();
                    continent.name = countryTag.Related_Tag__r.Name;
                    continent.countries = new List<Country>();
                    continentMap.put(countryTag.Related_Tag__r.Name, continent);
                }
                Country country = new Country();
                country.countryName = countryTag.Name;
                String flagCountryName = countryTag.Name.toLowercase();
                flagCountryName = flagCountryName.replace(' ', '-');
                country.flagImage = 'flag-' + flagCountryName + '.svg';
                country.languages = new List<Language>();
                for (Tag__c languageTag: languageTags) {
                    String languageName = SBGNavigationBarController.getLanguageName(languageTag.Name);
                    if (languageTag.Related_Tag__r.Name == country.countryName) {
                        Language lang = new Language();
                        lang.languageName = languageName;
                        lang.languageISOCode = languageTag.Name;
                        country.languages.add(lang);
                    }
                    if (languageName == 'English') {
                        Language lang = new Language();
                        lang.languageName = languageName;lang.languageISOCode = languageTag.Name;country.languages.add(lang);
                    }
                }
                continentMap.get(countryTag.Related_Tag__r.Name).countries.add(country);
            }
        }catch(Exception e){ 
            throw MallExceptionUtil.throwAuraException('SBGNavigationBarController.getCountryList', e); 
        }
        return continentMap.values();
    }

    /**
     * 
     * @description : updateUserPreference
     * @param userId Id
     * @param languageName String
     * @exception 
     */
    @AuraEnabled
    public static void updateUserPreference(Id userId, String languageName) {
        try{
            if (String.isNotBlank(languageName) && languageName != 'undefined' && !Auth.CommunitiesUtil.isGuestUser()) {
                MallUserPreferencesManagement.setUserPreferences(languageName, userId);
            }
        }catch(Exception e){ 
            throw MallExceptionUtil.throwAuraException('SBGNavigationBarController.updateUserPreference', e); 
        }
    }

    /**
     * 
     * @description : getCurrentUser
     * @return  `User`
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static User getCurrentUser() {
        try{
            String currentUserId = UserInfo.getUserId();
            List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{(Id)currentUserId});

            return users[0];
        }catch(Exception e){ 
            throw MallExceptionUtil.throwAuraException('SBGNavigationBarController.getCurrentUser', e); 
        }
    }

  
    /**
     * 
     * @description : getLanguageName
     * @param languageISOCode String
     * @return  `string`
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static string getLanguageName(String languageISOCode){
        try {
            if(mapCountryInfo == null) {
                mapCountryInfo = Country_Information__mdt.getAll();
                Map<String, Language_Information__mdt> mapLanguageInfo = Language_Information__mdt.getAll();
                maplangISOCodeVSLanguageInfo = new Map<String, Language_Information__mdt>();
                for(Language_Information__mdt langInfo : mapLanguageInfo.values()) {
                    maplangISOCodeVSLanguageInfo.put(langInfo.ISO_Code_2_Letters__c.toLowercase(), langInfo);
                }
            }

            String languageNameISOPart;
            String countryNamePart;
            String languageName;
            if(languageISOCode.contains('-')) {
                List<String> languageParams = languageISOCode.split('-',-1);
                languageNameISOPart =  languageParams[0];
                countryNamePart = languageParams[1];
            } else {
                languageNameISOPart = languageISOCode;
                countryNamePart = '';
            }
            languageName = maplangISOCodeVSLanguageInfo.get(languageNameISOPart).MasterLabel;
            if(String.isNotBlank(countryNamePart)) {
                languageName += ' (' + mapCountryInfo.get(countryNamePart).Country_Name__c + ')';
            }
            return languageName;
        } catch (Exception e) { 
            throw MallExceptionUtil.throwAuraException('SBGNavigationBarController.getLanguageName', e); 
        }
    }

    /**
     * 
     * @description : sendLoginAlertNotifications
     * @param userId String
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static void sendLoginAlertNotifications(String userId) {
        try {
            Boolean loginHistoryStatus = getLoginHistoryStatus(userId);
            if(loginHistoryStatus || Test.IsRunningTest()) {
                List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{(Id)userId});

                User user = new User();
                if(users.size() > 0) {
                    user = users[0];
                }
    
                if(!Test.IsRunningTest()) {
                    MallSendSMSService.sendSMSNotification(formatLoginSMSNotification(user));
                }

                if(!Test.IsRunningTest()) {
                    MallSendEmailService.createEmailsForUsersBasedOnEmailTemplate(new List<String>{userId}, LOGIN_ALERT_EMAIL_TEMPLATE_DEVELOPERNAME);
                }
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('SBGNavigationBarController.sendLoginAlertNotifications', e);
        }
    }

    /**
     * 
     * @description : formatLoginSMSNotification
     * @param user User
     * @return MallCentralMessagingWebService.CMSSMSRequest
     */
    public static MallCentralMessagingWebService.CMSSMSRequest formatLoginSMSNotification(User user) {
        try {
            Mall_SMS_Notification_Configuration__mdt smsSetting = Mall_SMS_Notification_Configuration__mdt.getInstance('Mall_Login_Alert_SMS_Configuration');
            MallCentralMessagingWebService.CMSSMSRequest request = new MallCentralMessagingWebService.CMSSMSRequest();
            if(smsSetting.IsActive__c || Test.IsRunningTest()) {
                String smsContent = smsSetting.SMS_Text_Message__c;
                if(String.isNotBlank(smsContent)) {
                    smsContent = smsContent.replace('{{0}}', user.FirstName);
                    smsContent = smsContent.replace('{{1}}', System.now().format('MM-dd-YYYY'));
                    smsContent = smsContent.replace('{{2}}', System.now().format('HH:mm:ss'));
                    smsContent = smsContent.replace('{{3}}', smsSetting.SMS_Callback_Number__c);
                }
                request.content = smsContent;
                request.senderAddress = smsSetting.Sender_Number__c;
                request.reciepientAddress = user.MobilePhone;
            }
            return request;
        }catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('SBGNavigationBarController.formatLoginSMSNotification', e);
        }
    }

     /**
     * 
     * @description : getLoginHistoryStatus
     * @param userId String
     * @return  Boolean
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static Boolean getLoginHistoryStatus(String userId) {
        try {
            List <LoginHistory> loginHistoryRecords = new List<LoginHistory> ();
            Boolean lastLoginInFiveMinute = false;
            loginHistoryRecords = SEL_LoginHistories.newInstance().selectByUserIds(new Set<Id>{(Id)userId}, 1);
            if(loginHistoryRecords.size() > 0){
                lastLoginInFiveMinute = (loginHistoryRecords[0].LoginTime > Datetime.now().addMinutes(-5));
            } 
            return lastLoginInFiveMinute;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('SBGNavigationBarController.getLoginHistoryStatus', e);
        }
    }
}