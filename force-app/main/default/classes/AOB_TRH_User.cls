/**
 * Contains a context-specific methods that are automatically called when the User trigger is executed
 *
 * <p></p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 10th 2020
 */

public with sharing class AOB_TRH_User extends CMN_TRH_BaseObject {
    private List<User> newUsers = new List<User>();
    private List<User> updatedUsers = new List<User>();
    private Set<Id> userIds = new Set<Id>();
    private Set<Id> contactIds = new Set<Id>();
  
    AOB_OnboardingSetting__mdt setting=AOB_Utils.getOnboardingSettings('SB-COZA');
    private Profile p = [
      SELECT Id
      FROM profile
      WHERE Name = :setting.AOB_Profile__c
    ];
  
    public override void afterInsert(SObject so) {
      User newUser = (User) so;
      super.afterInsert(newUser);
      if (newUser.profileId == p.Id) {
        newUsers.add(newUser);
        userIds.add(newUser.id);
        contactIds.add(newUser.contactId);
      }
    }
    public override void afterUpdate(SObject so, SObject si) {
      super.afterUpdate(so, si);
      User newUser = (User) si;
      if (newUser.profileId == p.Id) {
        updatedUsers.add(newUser);
        userIds.add(newUser.id);
        contactIds.add(newUser.contactId);
      }
    }
  
    public override void andFinally() {
      super.andFinally();
      if(!Test.isRunningTest()){
      AOB_SRV_UserManagement.assignPermissionSet(newUsers, userIds, contactIds);
        }
    }
  }