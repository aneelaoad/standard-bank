/**
 * Selector layer class for Support Service Type SObject
 *
 * @author		Raja Kumar (raja.kumar@standardbank.co.za)
 * @date		April 2023
 */
public with sharing class SEL_SupportServiceType extends fflib_SObjectSelector {

    public static SEL_SupportServiceType newInstance() {
        return (SEL_SupportServiceType) ORG_Application.selector.newInstance(SVC_SupportServiceTypes__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return SVC_SupportServiceTypes__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<SObjectField> {
            SVC_SupportServiceTypes__c.id,
            SVC_SupportServiceTypes__c.Service_Tier__c,
            SVC_SupportServiceTypes__c.SVC_Active__c,
            SVC_SupportServiceTypes__c.CMN_Team__c,
            SVC_SupportServiceTypes__c.Entitlement__c,
            SVC_SupportServiceTypes__c.Service_Type__c
                
           };
    }
    
    /**
    * 
    * @description Returns list of cases by caseId
    *
    * @param set of SVC_SupportServiceTypes__c ids
    * 
    * @return list of selected Support Service Type
    */
    public List<SVC_SupportServiceTypes__c> selectById(Set<ID> idSet) {

        return (List<SVC_SupportServiceTypes__c>) selectSObjectsById(idSet);
    } 
    
    /**
    * 
    * @description Returns list of SVC_SupportServiceTypes__c objects By condition
    * 
    * @author Raja Kumar (raja.kumar@standardbank.co.za)
    * @param active, team id and service tier
    * 
    * @return list of selected SVC_SupportServiceTypes__c Object
    */
    public List<SVC_SupportServiceTypes__c> selectByTeamIdAndServiceTier(set<Id> teamIds,String serviceTier) {
		//List<EmailMessage> emailMessageList = new List<EmailMessage>();
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Id')
             .selectField('Service_Tier__c')
             .selectField('Service_Type__c')
			 .setCondition('CMN_Team__c in :teamIds AND Service_Tier__c = :serviceTier AND SVC_Active__c = true');
        return (List<SVC_SupportServiceTypes__c>) Database.query( query.toSOQL() );
    }

    /**
    * 
    * @description Returns list of SVC_SupportServiceTypes__c objects By condition
    * 
    * @author Chazz (nkosivile.mazima@standardbank.co.za) 7/26/2023
    * @param active, team id, serviceType id and service tier 
    * 
    * @return list of selected SVC_SupportServiceTypes__c Object
    */

    public List<SVC_SupportServiceTypes__c> selectByServiceTypeIdTeamIdAndTier( set<Id> teamIds, set<Id> serviceTypeIds, set<String> serviceTier) 
    {
    fflib_QueryFactory query = newQueryFactory();
    query.selectField('Id')
         .selectField('Service_Tier__c')
         .selectField('Service_Type__c')
         .selectField('Entitlement__c')
         .selectField('CMN_Team__c')
         .setCondition('CMN_Team__c in :teamIds AND Service_Type__c in :serviceTypeIds AND Service_Tier__c in :serviceTier AND SVC_Active__c = true');
    return (List<SVC_SupportServiceTypes__c>) Database.query(query.toSOQL());
    }

}