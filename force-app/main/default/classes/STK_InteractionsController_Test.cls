/**
* @description Test class for the STK_InteractionsController class
*
* @author Augustine Chirombo
* @date 2024-03-01
*/
@IsTest
public class STK_InteractionsController_Test {

    @IsTest
    public static void testGetTagsByValues(){
        
        SingletrackCMS__Interaction_Type__c interactionType = new SingletrackCMS__Interaction_Type__c();
        interactionType.SingletrackCMS__Active__c = true;
        interactionType.Name = 'Interaction Type';
        insert interactionType;
        
        SingletrackCMS__Interaction_Method__c interactionMethod = new SingletrackCMS__Interaction_Method__c();
        interactionMethod.Name = 'Method';
        interactionMethod.SingletrackCMS__Active__c = true;
        insert interactionMethod;
        
        SingletrackCMS__Valid_Interaction__c validInteraction = new SingletrackCMS__Valid_Interaction__c();
        validInteraction.SingletrackCMS__Interaction_Type__c = interactionType.Id;
        validInteraction.SingletrackCMS__Interaction_Method__c = interactionMethod.Id;
        insert validInteraction;
        
        SingletrackCMS__Client_Activity__c interaction = new SingletrackCMS__Client_Activity__c();
        interaction.SingletrackCMS__Interaction_Method__c = interactionMethod.Id;
        interaction.SingletrackCMS__Interaction_Type__c = interactionType.Id;
        interaction.SingletrackCMS__Description__c = 'Test';
        interaction.SingletrackCMS__Date__c = System.now();
        interaction.SingletrackCMS__Internal_Participants__c = System.UserInfo.getUserId();
        insert interaction;
        
        Test.startTest();
        List<STK_FLOW_InteractionsController.SingletrackInteraction> results = STK_FLOW_InteractionsController.getInteractionsByIds(new List<Id>{interaction.Id});
        Assert.areEqual(results.size(), 1, 'Successfully found the record');
        Test.stopTest();
    }

}