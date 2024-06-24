/**
 *   This is Selector class is used for Conversation Object
 *   @author       Sandile Mathe
 *   @date         April 2021
**/
public with sharing class SEL_ConversationValues extends fflib_SObjectSelector{
    /**
    * This method getSObjectFieldList
    * @return    Conversation Value Object Schema List
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                Conversation_Value__c.Name,
                Conversation_Value__c.Id,
                Conversation_Value__c.CurrencyIsoCode,
                Conversation_Value__c.OwnerId,
                Conversation_Value__c.Reason__c,
                Conversation_Value__c.Response__c,
                Conversation_Value__c.Sub_Category__c
        };
    }

    /**
    * This method getSObjectType
    * 
    * @return    Conversation Value Object type
    **/
    public Schema.SObjectType getSObjectType() {
        return Conversation_Value__c.SObjectType;
    }

    /**
    * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
    * and inject a mock instead of this class or to switch out this class for a new version.
    * 
    * @return       List Of results from Conversation object
    */
    public static SEL_ConversationValues newInstance() {
        return(SEL_ConversationValues) ORG_Application.selector.newInstance(Conversation_Value__c.SObjectType);

    }

    /**
    * This method to Select Conversation values
    * 
    * @return Results of a Query
    **/
    public List<Conversation_Value__c> selectAllConversationValues() {
        fflib_QueryFactory responseQueryFactory = newQueryFactory();
        responseQueryFactory.setLimit(50000);
        return Database.query(responseQueryFactory.toSOQL());
    }

    /**
    * This method to Select Conversation by SubCategory
    * 
    * @param	subCat Set String set of Strings
    * @return   Results of a query
    **/
    public List<Conversation_Value__c> selectConversationValueBySubCat(Set<String> subCat) {
        fflib_QueryFactory responseQueryFactory = newQueryFactory();
        responseQueryFactory.setCondition('Sub_Category__c in :subCat');
        return Database.query(responseQueryFactory.toSOQL());
    }

    /**
    * @description  This method Select Response Value
    * @param	resp Set Stringset of Strings
    * @return   Results of a query
    **/
    public List<Conversation_Value__c> selectConversationValueByResponse(Set<String> resp) {
        fflib_QueryFactory responseQueryFactory = newQueryFactory();
        responseQueryFactory.setCondition('Response__c in :resp');
        return Database.query(responseQueryFactory.toSOQL());
    }

    /**
    * @description  This method Select Response Value
    * @param	reas String set of Strings
    * @return   Results of a query
    **/
    public List<Conversation_Value__c> selectConversationValueByReason(Set<String> reas) {
        fflib_QueryFactory responseQueryFactory = newQueryFactory();
        responseQueryFactory.setCondition('Reason__c in :reas');
        return Database.query(responseQueryFactory.toSOQL());
    }
}