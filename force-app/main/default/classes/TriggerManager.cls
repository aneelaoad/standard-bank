/**
* Copyright (c), Artur Kepczynski Jakub Oracki
* Deloitte Poland
* All rights reserved...
*
* Redistribution and use in source and binary forms, with or without modification,
*   are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
*  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
*  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
*  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
*  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/
@SuppressWarnings('PMD.AvoidDirectAccessTriggerMap')
/**
 * @description TriggerManager
 */
public class TriggerManager {
    // Ths map is source of instances, add mapping to ensure execution of logic
    private Map<SObjectType, Type> sobject2Handler;

    private static TriggerManager singleton;
    /**
    * @description TriggerManager
     */
    public static TriggerManager instance {
        get {
            if (singleton == null) {
                singleton = new TriggerManager();
            }
            return singleton;
        }
    }



    private Map<SObjectType, ABS_TriggerHandlerBase> name2TriggerHandler;

    private TriggerManager(){
        name2TriggerHandler = new Map<SObjectType, ABS_TriggerHandlerBase>();
        sobject2Handler = new Map<SObjectType, Type>{
            Account.SObjectType => TRH_Account.class,
            Account_Information__c.SObjectType => TRH_AccountInformation.class,
            Assessment_Opportunity__c.SObjectType => TRH_Assessment_Opportunity.class,
            Business_Assessment__c.SObjectType => TRH_BusinessAssessment.class,
            Call_Report__c.SObjectType => TRH_CallReport.class,
            Call_Report_Attendees__c.SObjectType => TRH_CallReportAttendee.class,
            Campaign.SObjectType => TRH_Campaign.class,
            CampaignMember.SObjectType => TRH_CampaignMember.class,
            Case.SObjectType => TRH_Case.class,
            Change_Request__e.SObjectType => TRH_ChangeRequest.class,
            Client_Data_Change__c.SObjectType => TRH_ClientDataChange.class,
            Client_Plan__c.SObjectType => TRH_ClientPlan.class,
            Client_Satisfaction_Index__c.SObjectType => TRH_ClientSatisfactionIndex.class,
            Contact.SObjectType => TRH_Contact.class,
            ContentDocument.SObjectType => TRH_ContentDocument.class,
            ContentDocumentLink.SObjectType => TRH_ContentDocumentLink.class,
            Conversation__c.SObjectType => TRH_Conversation.class,
            Credit_Line__c.SObjectType => TRH_CreditLine.class,
            Custom_Client_Team__c.SObjectType => TRH_ClientTeam.class,
            EAP_AppEvent__c.SObjectType => TRH_EAP_AppEvent.class,
			EAP_Attendance__c.SObjectType => TRH_EAP_Attendance.class,
			EAP_Attendee__c.SObjectType => TRH_EAP_Attendee.class,
			EAP_Document__c.SObjectType => TRH_EAP_EventDocument.class,
			EAP_Meeting__c.SObjectType => TRH_EAP_Meeting.class,
            Ecosystem__c.SObjectType => TRH_Ecosystem.class,
            Ecosystem_Entity__c.SObjectType => TRH_EcosystemEntity.class,    
            EmailMessage.SObjectType => TRH_EmailMessage.class,
            Event.SObjectType => TRH_Event.class,
            FinServ__Revenue__c.SObjectType => TRH_Revenue.class,
            Global_Client_Revenue__c.SObjectType => TRH_GlobalClientRevenue.class,
            Knowledge_Entitlement_Exception__c.SObjectType => TRH_KnowledgeExceptions.class,
            Log__c.SObjectType => TRH_Logs.class,
            Log_Event__e.SObjectType => TRH_LogEvents.class,
            Option_List_Item__c.SOBjectType => TRH_Option_List_Item.class,
            Opportunity.SObjectType => TRH_Opportunity.class,
            Resourcing__c.SObjectType => TRH_Resourcing.class,
            Revenue_and_Profitability__c.SObjectType => TRH_RevenueAndProfitability.class,
            SB_Product__c.SObjectType => TRH_SB_Product.class,
            Task.SObjectType => TRH_Task.class,
            Investor_Participation__c.SObjectType => TRH_Investor_Participation.class,
            Product_Distribution__c.SObjectType => TRH_Product_Distribution.class,
            ContentVersion.SObjectType => TRH_ContentVersion.class,
            Financial_Account_Permission__c.SObjectType => TRH_FAP.class,
            Finserv__FinancialAccount__c.SObjectType => TRH_finserv_FinancialAccount.class,
            CMN_Account_Contact_Relationship_Detail__c.SObjectType => TRH_CMN_AccountContactRelationshipDetail.class,
            Financial_Account__c.SObjectType => TRH_FinancialAccount.class,
            OpportunityTeamMember.SObjectType => TRH_OpportunityTeamMember.class
        };
    }

    /**
     * @description Use this function to execute trigger
     * @usage  TriggerManager.instance.execute();
     */
    public void execute(){
        if(!Trigger.isExecuting){
            throw new TriggerManagerException('Can\'t invoke in context other than trigger');
        }

        // Workaround for Knowledge__kav due to "System.NoAccessException: Entity is not api accessible"
        List<SObject> recordsList = Trigger.new != null ? Trigger.new : Trigger.old;
        String objName = recordsList?.getSObjectType().getDescribe().getName();
        if (objName == 'Knowledge__kav') {
            sobject2Handler.put(Knowledge__kav.SObjectType, TRH_Knowledge.class);
        }

        ABS_TriggerHandlerBase th = fetchHandler();

        th.handleTrigger();
    }


    private ABS_TriggerHandlerBase fetchHandler(){

        if(Trigger.size == 0){
            throw new TriggerManagerException('No record to Process');
        }

        SObject sObj = Trigger.new != null ? Trigger.new[0] : Trigger.old[0];
        SObjectType st = sObj.getSObjectType();

        if(!sobject2Handler.containsKey(st)){
            throw new TriggerManagerException('There is no instance of handler for Sobject: ' + String.valueOf(st));
        }

        if(!name2TriggerHandler.containsKey(st)){
            Type customType = sobject2Handler.get(st);
            ABS_TriggerHandlerBase th = (ABS_TriggerHandlerBase)customType.newInstance();
            name2TriggerHandler.put(st, th);
        }

        return name2TriggerHandler.get(st);
    } 
    /**
    * @description TriggerManagerException
    */
    public class TriggerManagerException extends Exception{} 
}