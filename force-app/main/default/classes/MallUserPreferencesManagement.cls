/**
 * 
 * @description MallUserPreferencesManagement
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallUserPreferencesManagement {
    
    @TestVisible
    private static final String DEFAULT_CONTENT_LANGUAGE_ISO = 'en';

    /**
     * 
     * @description getUserPreferences
     * @return UserPreference
     */
    @AuraEnabled
    public static UserPreference getUserPreferences() {
        try {
            List<User_Preference__c> userPreferences = SEL_UserPreferences.newInstance().selectByRootNamesAndUserId(new Set<String>{'Language'}, UserInfo.getUserId());
            UserPreference userPreference = new UserPreference();
            userPreference.userLanguage = (userPreferences.size() > 0) ? userPreferences.get(0)?.Tag__r?.Name : DEFAULT_CONTENT_LANGUAGE_ISO;
            return userPreference;
        } catch (Exception e) { 
            throw MallExceptionUtil.throwAuraException('MallUserPreferencesManagement.getUserPreferences', e);
        }
    }

    /**
     * 
     * @description getUserPreferences
     * @param langugeISOCode String
     * @param userId String
     * @return UserPreference
     */
    @AuraEnabled
    public static String setUserPreferences(String langugeISOCode, String userId) {
        try {
            List<User_Preference__c> userPreferences = SEL_UserPreferences.newInstance().selectByRootNamesAndUserId(new Set<String>{'Language'}, UserInfo.getUserId());
            if(userPreferences != NULL && userPreferences.size() > 0) {
                if(userPreferences.get(0).Name != langugeISOCode) {
                    List<Tag__c> tags= SEL_Tags.newInstance().selectTagsByNames(new Set<String>{langugeISOCode});
                    String languageTagId = (tags.size() > 0) ? tags.get(0).Id : NULL; 
                    if(String.isNotBlank(languageTagId)) {
                        userPreferences.get(0).Tag__c = languageTagId;
                    }
                    update userPreferences;
                }
            } else {
                List<Tag__c> tags = SEL_Tags.newInstance().selectTagsByNames(new Set<String>{langugeISOCode});
                system.debug('Nick :: '+tags.size()+langugeISOCode);
                if(tags.isEmpty()) {
                    return NULL;
                }
                User_Preference__c preference = new User_Preference__c();
                preference.User__c = userId;
                preference.Tag__c = tags.get(0).Id;
                preference.Name = 'User Prefernce ' + langugeISOCode + ' ' + userId;
                insert preference;
            }
            return langugeISOCode;
        }catch (Exception e) { 
            throw MallExceptionUtil.throwAuraException('MallUserPreferencesManagement.setUserPreferences', e);
        }

    }

    public class UserPreference {
        @AuraEnabled public String userLanguage;
    }
}