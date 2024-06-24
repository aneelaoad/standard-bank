/**
 * Builder class for Conversations.
 *
 * @author Sandile Mathe
 * @date April 2021
 */
@isTest
public class BLD_Conversation extends ABS_ObjectBuilderBase {

	public BLD_Conversation() {
		this(getNewUnitOfWork());
	}

	public BLD_Conversation(fflib_SObjectUnitOfWork workUnit) {
		super(Conversation__c.sObjectType, workUnit);
	}

	public BLD_Conversation(Conversation__c sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

	public BLD_Conversation client(BLD_Account bAccount) {
		setRelation(Conversation__c.Client__c, bAccount);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation owner(BLD_USER bUser) {
		setRelation(Conversation__c.OwnerId, bUser);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation ownerId(Id value){
		setField(Conversation__c.OwnerId, value);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation category(String category) {
		setField(Conversation__c.Category__c, category);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation subcategory(String subcategory) {
		setField(Conversation__c.Subcategory__c, subcategory);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation reason(String category) {
		setField(Conversation__c.Reason__c, category);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation response(String subcategory) {
		setField(Conversation__c.Response__c, subcategory);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation externalId(String externalId) {
		setField(Conversation__c.ExternalId__c, externalId);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation externalIdLeadKey(String externalIdLeadKey) {
		setField(Conversation__c.ExternalIdLeadKey__c, externalIdLeadKey);
		return(BLD_Conversation) this;
	}

	public BLD_Conversation isActive(Boolean isActive) {
		setField(Conversation__c.IsActive__c, isActive);
		return(BLD_Conversation) this;
	}
}