/**
 * 
 * @description MallStoreProfileController
 * @author Ankit Kumar
 * @since 
*/
public with sharing class MallStoreProfileController {
    /**
     * 
     * @description getStoreProfile
     * @param accountId String
     * @return AccountInfo
     */
    @AuraEnabled
    public static AccountInfo getStoreProfile(String accountId){
        try {
            List<Account> accounts = SEL_Accounts.newInstance().selectById(new Set<Id>{accountId});
            Account account = new Account();
            if(accounts.size() > 0) {
                account = accounts[0];
            }

            //Get Related Contacts
            List<Contact> contacts = SEL_Contacts.newInstance().selectByClientId(new Set<Id>{(Id)accountId});

            //Get Related tagShops
            String whereClause = ' Provider__r.Related_Client__c IN (\'' + String.join(new List<String>{accountId}, '\',\'') + '\')';
            List<Tag_Provider__c> tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);

            List<String> tagIds = new List<String>();
            for(Tag_Provider__c tagProvider : tagProviders) {
                tagIds.add(tagProvider.Tag__c);
            }
            List<DenormalizedTag> tags = MallDataService.getTagsByIds(tagIds);
            AccountInfo accountInfo = new AccountInfo();
            accountInfo.contacts = contacts;
            accountInfo.account = account;

            //Get segments and categories from the Tags
            List<DenormalizedTag> segments = new List<DenormalizedTag>();
            List<DenormalizedTag> categories = new List<DenormalizedTag>();
            String country;
            Date createdDate = Date.newInstance(1800, 1, 1);
            for(DenormalizedTag tag : tags) {
                if(tag.parentName == 'Segment') {
                    segments.add(tag);
                }
                if(tag.parentName == 'Category') {
                    categories.add(tag);
                }
            }
            for(Tag_Provider__c tagProvider : tagProviders) {
                if(tagProvider.Tag__r.Root_name__c == 'Country') {
                    if(createdDate < tagProvider.CreatedDate) {
                        country = tagProvider.Tag__r.Name;
                    }
                }
            }
            accountInfo.segments = segments;
            accountInfo.categories = categories;
            accountInfo.country = country;
            return accountInfo;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStoreProfileController.getStoreProfile', e);
        }
    }

    /**
     * 
     * @description ApexType wrapper for Account Information
     */
    public class AccountInfo {
        @AuraEnabled
        public Account account;
        @AuraEnabled
        public List<Contact> contacts;
        @AuraEnabled
        public List<DenormalizedTag> segments;
        @AuraEnabled
        public List<DenormalizedTag> categories;
        @AuraEnabled
        public String country;
    }
}