/**
* @description Interactions controller class to interface flow actions
*
* @author Augustine Chirombo
* @date 2024-03-01
*/
public class STK_FLOW_InteractionsController {

    /**
     * @description invocable method to return the Interactions by Ids
     * @param ids
     * @return List<STK_FLOW_InteractionsController.SingletrackInteraction> - with query results
     */
    @InvocableMethod(label='Get Singletrack Interactions by record Ids' description='Returns a list of Singletrack Interactions formatted by an inner class SingletrackInteraction based on the list of Ids passed' category='SingleTrack Actions' )
    public static List<STK_FLOW_InteractionsController.SingletrackInteraction> getInteractionsByIds(List<Id> ids) {
        List<STK_FLOW_InteractionsController.SingletrackInteraction> results = new List<STK_FLOW_InteractionsController.SingletrackInteraction>();
        List<SingletrackCMS__Client_Activity__c> interactions = new SEL_SingletrackCMS_ClientActivity().selectByIdsWithoutSharing(new Set<Id>(ids));
        for(SingletrackCMS__Client_Activity__c interaction: interactions) {
            STK_FLOW_InteractionsController.SingletrackInteraction result = new STK_FLOW_InteractionsController.SingletrackInteraction();
            result.description = interaction.SingletrackCMS__Description__c ?? '';
            result.interactionType = interaction.SingletrackCMS__Interaction_Type__r.Name ?? '';
            result.interactionMethod = interaction.SingletrackCMS__Interaction_Method__r.Name ?? '';
            result.startDate = interaction.SingletrackCMS__Date__c ?? null;
            result.endDate = interaction.SingletrackCMS__End_Date__c ?? null;
            results.add(result);
        }
        return results;
    }

    /**
     * @description Subclass to return the Interaction details
     *
     * @author Augustine Chirombo
     * @date 2024-03-01
     */
    public class SingletrackInteraction{
        @InvocableVariable(label='Description Output value' description='The Singletrack interaction description')
        public String description;
        @InvocableVariable(label='Interaction Type Output value' description='The Singletrack interaction type ')
        public String interactionType;
        @InvocableVariable(label='Interaction Method Output value' description='The Singletrack interaction method')
        public String interactionMethod;
        @InvocableVariable(label='Start Date Output value' description='The Singletrack interaction Start date and time')
        public Datetime startDate;
        @InvocableVariable(label='End Date Output value' description='The Singletrack interaction End Date and time')
        public Datetime endDate;
    }

}