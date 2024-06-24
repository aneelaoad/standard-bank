/**
 * @description       : US: SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_LiveChatTranscripts extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            LiveChatTranscript.Id,
            LiveChatTranscript.CaseId,
            LiveChatTranscript.OwnerId,
            LiveChatTranscript.BrowserLanguage,
            LiveChatTranscript.ContactId,
            LiveChatTranscript.ChatKey
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return LiveChatTranscript.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_LiveChatTranscripts 
    **/
    public static SEL_LiveChatTranscripts newInstance() {
        return(SEL_LiveChatTranscripts) ORG_Application.selector.newInstance(LiveChatTranscript.SObjectType);
    }

    /**
     * @description LiveChatTranscript by chatkeys
     * @param chatKeys Set<String>
     * @return List<LiveChatTranscript> - with query results
     */
    public List<LiveChatTranscript> selectByChatKeys(Set<String> chatKeys) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .setCondition(' ChatKey in : chatKeys')
            .toSOQL());
    } 
}