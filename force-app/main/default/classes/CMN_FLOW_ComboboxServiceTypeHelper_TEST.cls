/**
 * @description Test class for CMN_FLOW_ComboboxServiceTypeHelper
 *
 * @author Raja Kumar
 *
 * @date April 2023
 */
@isTest
public with sharing class CMN_FLOW_ComboboxServiceTypeHelper_TEST {
    @isTest
    public static void getServiceTypesByTeamTest() {
        CMN_SupportTeam__c team = new CMN_SupportTeam__c(
            Name = 'Service Team', 
            CMN_Active__c = true
        );
        insert team;
        Service_Type__c stype = new Service_Type__c(
            Name = 'Data - Management', 
            Active__c = true, 
            Category__c = 'Data', 
            Sub_Category__c = 'Management',
            ServiceType__c='query'
        );
        insert stype;
        insert new SVC_SupportServiceTypes__c(
            CMN_Team__c = team.Id, 
            Service_Type__c = stype.Id, 
            SVC_Active__c = true,
            Service_Tier__c='Standard'
        );

        CMN_FLOW_ComboboxServiceTypeHelper.DTO_ServiceTypeRequest req = new CMN_FLOW_ComboboxServiceTypeHelper.DTO_ServiceTypeRequest();
        req.teamId = team.Id;
        req.AccountId=null;
        Test.startTest();
        List<CMN_FLOW_ComboboxServiceTypeHelper.DTO_ServiceTypeResponse> result = 
        CMN_FLOW_ComboboxServiceTypeHelper.getServiceTypesByTeam(
            new List<CMN_FLOW_ComboboxServiceTypeHelper.DTO_ServiceTypeRequest>{req}
        );
        Test.stopTest();
        Assert.areEqual((!result[0].serviceTypes.isEmpty()),true,'service type is present');
    }
}