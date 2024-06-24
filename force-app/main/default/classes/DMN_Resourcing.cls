/**
 * @description Domain class for Resourcing__c SObject
 *
 * @author Konrad Bruszewski
 * @date June 2021
 */
public with sharing class DMN_Resourcing extends fflib_SObjectDomain {

    public static final String CORPORATE_FINANCE_RESOURCE_MANAGEMENT_GROUP = 'Corporate_Finance_Resourcing_Admins';
    public static final String OPPORTUNITY_SOURCE                          = 'Opportunity';

    private SEL_GroupMember groupMemberSelector {
        get {
            if (groupMemberSelector == null) {
                groupMemberSelector = (SEL_GroupMember) ORG_Application.selector.newInstance(GroupMember.SObjectType);
            }
            return groupMemberSelector;
        }
        set;
    }

    private SEL_Resourcing resourcingSelector {
        get {
            if (resourcingSelector == null) {
                resourcingSelector = (SEL_Resourcing) ORG_Application.selector.newInstance(Resourcing__c.SObjectType);
            }
            return resourcingSelector;
        }
        set;
    }

    /**
     * @description class for constructing Resourcing Domain instance
     *
     * @author Konrad Bruszewski
     * @date june 2021
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {

        /**
         * Constructs and returns new DMN_Resourcing instance with given records
         *
         * @param records
         *
         * @return New DMN_Resourcing instance
         */
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new DMN_Resourcing(records);
        }
    }

    /**
     * DMN_Resourcing constructor
     *
     * @param records - set of records on which domain will be performing operations
     */
    public DMN_Resourcing(List<SObject> records) {
        super(records);
    }

    /**
     * Loops through records from Records variable.
     * Populates Compound_Key__c field on Resourcing__c present in Records variable.
     */
    public void populateCompoundKeys() {
        for (Resourcing__c resourcing : (List<Resourcing__c>) Records) {
            String initiative = resourcing.Resourcing_Type__c == null ? '' : resourcing.Resourcing_Type__c;
            resourcing.Compound_Key__c = '' + resourcing.Opportunity__c +
                resourcing.Resource__c + String.valueOf(resourcing.Week_End_Date__c) +
                initiative;
        }
    }

    /**
     * Loops through records from Records variable.
     * Sets Owner of the records to be the same as User specified in Resource__c field.
     */
    public void setOwner() {
        for (Resourcing__c resourcing : (List<Resourcing__c>) Records) {
            if (resourcing.OwnerId != resourcing.Resource__c) {
                resourcing.OwnerId = resourcing.Resource__c;
            }
        }
    }

    /**
     * Loops through records from Records variable.
     * If Resource__c is not set it is being set to the current user.
     */
    public void setResource() {
        for (Resourcing__c resourcing : (List<Resourcing__c>) Records) {
            if (resourcing.Resource__c == null) {
                resourcing.Resource__c = System.UserInfo.getUserId();
            }
        }
    }

    /**
     * Loops through records from Records variable.
     * Set Previous_Week_Resourcing__c record for the same opportunity and Resource for previous week is found.
     */
    public void setPreviousWeekResourcing() {
        Set<Id> oppIds = new Set<Id>();
        Set<Id>userIds = new Set<Id>();
        Set<String> initiatives = new Set<String>();
        Set<Date> dates = new Set<Date>();
        Map<String, Resourcing__c> oppIdAndResourceIdAndDate2Resourcing = new Map<String, Resourcing__c>();
        for (Resourcing__c resourcing : (List<Resourcing__c>) Records) {
            oppIds.add(resourcing.Opportunity__c);
            userIds.add(resourcing.Resource__c);
            initiatives.add(resourcing.Resourcing_Type__c);
            dates.add(resourcing.Week_End_Date__c.addDays(-7));
            oppIdAndResourceIdAndDate2Resourcing.put(String.valueOf(resourcing.Opportunity__c) + resourcing.Resourcing_Type__c + String.valueOf(resourcing.Resource__c) + String.valueOf(resourcing.Week_End_Date__c), resourcing);
        }
        List<Resourcing__c> previousWeekResourcings = resourcingSelector.selectByOpportunityAndInitiativeAndResourceAndWeekEndDate(oppIds, initiatives, userIds, dates);
        if (previousWeekResourcings != null) {
            for (Resourcing__c resourcing : previousWeekResourcings) {
                String key = String.valueOf(resourcing.Opportunity__c) + resourcing.Resourcing_Type__c + String.valueOf(resourcing.Resource__c) + String.valueOf(resourcing.Week_End_Date__c.addDays(7));
                if (oppIdAndResourceIdAndDate2Resourcing.containsKey(key)) {
                    oppIdAndResourceIdAndDate2Resourcing.get(key).Previous_Week_Resourcing__c = resourcing.Id;
                }
            }
        }
    }

    /**
     * Loops through records from Records variable.
     * Adds error to record if Resource__c is not part of Opportunity Team on referenced Opportunity.
     */
    public void checkIfResourceIsTeamMember() {
        Set<Id> oppIds = getOpportunityIds();
        SEL_Opportunities oppSelector = (SEL_Opportunities) ORG_Application.selector.newInstance(Opportunity.SObjectType);
        List<Opportunity> opportunities = oppSelector.selectByIdWithActiveTeamMembers(oppIds);
        Map<Id, Set<Id>> opportunity2TeamMemberUserIds = getTeamMemberUserIds(opportunities);
        for (Resourcing__c resourcing : (List<Resourcing__c>) Records) {
            if (resourcing.Resourcing_Type__c == OPPORTUNITY_SOURCE && !opportunity2TeamMemberUserIds.get(resourcing.Opportunity__c).contains(resourcing.Resource__c)) {
                resourcing.addError(System.Label.Resourcing_NotOppTeamMember);
            }
        }
    }

    /**
     * Loops through records from Records variable.
     * Adds error to record if Resource are not the same as user and current user is not permitted to assign Resourcing
     * to other users.
     * Method's code is omitted in batch context.
     */
    public void checkIfUserCanAssignRecordsToOtherUsers() {
        if (!System.isBatch()) {
            Boolean isUserIsMemberOfManagementGroup = isUserIsMemberOfManagementGroup();
            for (Resourcing__c resourcing : (List<Resourcing__c>) Records) {
                if (resourcing.Resource__c != UserInfo.getUserId() && !isUserIsMemberOfManagementGroup) {
                    resourcing.addError(System.Label.Resourcing_NotManagementMember);
                }
            }
        }
    }

    /**
     * Returns Ids of opportunities with which Resourcing__c records are associated
     *
     * @return Set of Id -  opportunity Ids
     */
    private Set<Id> getOpportunityIds() {
        Set<Id> oppIds = new Set<Id>();
        for (Resourcing__c resourcing : (List<Resourcing__c>) Records) {
            oppIds.add(resourcing.Opportunity__c);
        }
        return oppIds;
    }

    /**
     * Creates a map of Opportunity Id to Set of Ids of Opportunity Team Members.
     * Opportunities need to be passed with Team Members.
     *
     * @param opportunities  Opportunities to process
     *
     * @return Map<Id, Set<Id> - Map of opportunity Id to opportunity team member Ids
     */
    private Map<Id, Set<Id>> getTeamMemberUserIds(List<Opportunity> opportunities) {
        Map<Id, Set<Id>> opportunity2TeamMemberUserIds = new Map<Id, Set<Id>>();
        for (Opportunity opportunity : opportunities) {
            opportunity2TeamMemberUserIds.put(opportunity.Id, new Set<Id>());
            for (OpportunityTeamMember opportunityTeamMember : opportunity.OpportunityTeamMembers) {
                opportunity2TeamMemberUserIds.get(opportunity.Id).add(opportunityTeamMember.UserId);
            }
        }
        return opportunity2TeamMemberUserIds;
    }

    /**
     * Checks if current user if member of Corporate_Finance_Resource_management group.
     *
     * @return True if user is member of the group
     */
    private Boolean isUserIsMemberOfManagementGroup() {
        String userId = System.UserInfo.getUserId();
        return groupMemberSelector.selectByUserOrGroupIdAndGroupDeveloperName(userId, CORPORATE_FINANCE_RESOURCE_MANAGEMENT_GROUP).size() == 1;
    }
}