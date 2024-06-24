/**
 * EmailMessages Selector Layer class.
 *
 * @author Kyle Cockcroft (kcockcroft@deloitte.co.za)
 * @date 2019-04-24
 */
public with sharing class SEL_EmailMessages extends fflib_SObjectSelector {
 
   public Schema.SObjectType getSObjectType(){
      return EmailMessage.sObjectType;
   }
    
    public static SEL_EmailMessages newInstance() {
        return (SEL_EmailMessages) ORG_Application.selector.newInstance(EmailMessage.SObjectType);
    }
    
   public List<Schema.SObjectField> getSObjectFieldList(){
      return new List<Schema.SObjectField> {
         EmailMessage.Id,
         EmailMessage.ParentId,
         EmailMessage.Status,
         EmailMessage.Parent.Status,
         EmailMessage.ThreadIdentifier,
         EmailMessage.TextBody,
         EmailMessage.HtmlBody,
         EmailMessage.Subject,
         EmailMessage.FromName,
         EmailMessage.FromAddress,
         EmailMessage.Incoming,
         EmailMessage.HasAttachment,
         EmailMessage.MessageDate,
         EmailMessage.IsDeleted,
         EmailMessage.ReplyToEmailMessageId,
         EmailMessage.MessageIdentifier,
         EmailMessage.CreatedDate
    
      };
   }
    
   public List<EmailMessage> selectById(Set<ID> idSet) {

        return (List<EmailMessage>) selectSObjectsById(idSet);
    } 
    
    public List<EmailMessage> selectByParentId(Set<ID> allCasesIds){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ParentId IN :allCasesIds');
        return (List<EmailMessage>) Database.query( query.toSOQL() );
    }
    
    /**
    * 
    * @description Returns list of email message objects By condition
    * Added on 23rd March 2023
    * @author Raja Kumar (raja.kumar@standardbank.co.za)
    * @param ThreadIdentifier of Email Message Object
    * 
    * @return list of selected Email Message Object order by createdDate in desc order
    * updated on 1ST June 2023 - replaced addordering to setordering function with Null last parameter.
    */
    public List<EmailMessage> selectByThreadIdentifier(set<String> emailMessageThreadIdentifier) {
		List<EmailMessage> emailMessageList = new List<EmailMessage>();
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Id')
             .selectField('Subject')
             .selectField('ParentId')
             .selectField('Parent.Status')
			 .setCondition('ThreadIdentifier in :emailMessageThreadIdentifier')
        	 .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING,TRUE)
        	 .setLimit(1);
        return (List<EmailMessage>) Database.query( query.toSOQL() );
    } 
   
}