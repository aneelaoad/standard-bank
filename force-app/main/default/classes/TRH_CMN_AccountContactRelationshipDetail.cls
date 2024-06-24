/**
 * @description Trigger class for CMN_Account_Contact_Relationship_Detail__c SObject
 * @author		Emmanuel Mulea(Nocks)
 * @date		March 2022
 */
public class TRH_CMN_AccountContactRelationshipDetail extends ABS_TriggerHandlerBase {

    private CMN_Account_Contact_Relationship_Detail__c[] records{
                            get{
                                return (CMN_Account_Contact_Relationship_Detail__c[])Trigger.new;
                            }
                        } 

    private CMN_Account_Contact_Relationship_Detail__c[] oldRecords{
                                get{
                                    return (CMN_Account_Contact_Relationship_Detail__c[])Trigger.old;
                                }
                            }
    private Map<Id,CMN_Account_Contact_Relationship_Detail__c> oldMap{
                                get{
                                    return (Map<Id,CMN_Account_Contact_Relationship_Detail__c>)Trigger.oldMap;
                                }
                            }
    public override void handleBeforeInsert(){
        DMN_CMN_AccountContactRelationshipDetail.createAccountContactRelationship(records,oldRecords);
    }

    public override void handleAfterInsert(){
    }

    public override void handleAfterUpdate(){
        DMN_CMN_AccountContactRelationshipDetail.updateAccountContactRelationship(records,oldMap);
    }
    public override void handleBeforeUpdate(){
    }
    public override void handleAfterDelete(){
        DMN_CMN_AccountContactRelationshipDetail.deleteAccountContactRelationship(oldRecords);
    }
}