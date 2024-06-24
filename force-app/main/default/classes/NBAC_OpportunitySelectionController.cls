/**
* DM NBAC: Starting an SPV
* As an SPV user, I want to be able to start an SPV NBAC on a prospect, PBB,
* Commercial Banking and Inactive client in order to complete a SPV NBAC. In this code I
* amended NBAC_OpportunitySelectionController.getOpportunities method to bypass an exception for
* prospect records.  The NBAC_OpportunitySelectionController.OpportunitySelector.getOpportunitiesByClientId
* method has been updated to check for the viewing user's joint venture permissions and return
* the appropriate opps. Cleaned up some existing code, spelling errors and corrected some code indentations.
* US-3376
*
* @author Wayne Solomon
* @date 2020-03-12
*/
public without sharing class NBAC_OpportunitySelectionController {

	public static final String NO_CLIENT_DEFINED = 'Client Id is not defined.';
	public static final String NO_OPPORTUNTIES_DEFINED = 'No opportunity was selected.';
	public static final String INSUFFICIENT_PRIVILEGES = Label.Insufficient_Privileges;
	public static final String BUSINESS_ASSESSMENT_INSUFFICIENT_PRIVILEGES = Label.Business_Assessment_Insufficient_Privileges;
	public static final String BUSINESS_ASSESSMENT_SPV_INSUFFICIENT_PRIVILEGES = Label.Business_Assessment_Spv_Insufficient_Privileges;
	public static final String BUSINESS_ASSESSMENT_NOT_AVAILABLE = Label.Business_Assessment_Not_Available;
	public static final String BUSINESS_ASSESSMENT_NOT_AVAILABLE_CLIENTS = Label.Business_Assessment_Not_Available_Clients;
	public static final String PRH_REQUIRED = Label.Prh_Required;
	static final String CIBNBACSPVNOCIF = 'CibNbacSpvNoCif';
	static final String CIBNBACSPVCIF = 'CibNbacSpvCif';
   /**
    * @description isEconomicOrUltimateParent
	* @param clt Account
    * @return Boolean result
    **/
	private static Boolean isEconomicOrUltimateParent(Account clt){
		return [select count() from Account where Id =: clt.Id and (RecordType.DeveloperName = :DMN_Account.RT_ULTIMATE_PARENT or (Economic_Group_Parent_Client_Name__c =: clt.Name and Adaptive_Flag__c = true))]>0;
	}

   /**
    * @description hasEconomicOrUltimateParent
	* @param clt Account
    * @return Boolean result
    **/
    @TestVisible
	private static Boolean hasEconomicOrUltimateParent(Account clt){
		return [select count() from Account where Id =: clt.Id and (ParentId != null or (Economic_Group_Parent_Client_Name__c != null and Adaptive_Flag__c = true))]>0;
	}
   /**
    * @description isCommBAndParentClient
	* @param clientId String
    * @return Boolean result
    **/
    @TestVisible
	private static Boolean isCommBAndParentClient(Id clientId){
		//Declaration of client
		Account client;
		try{ client = [SELECT Name,RecordType.DeveloperName ,Parentid FROM Account WHERE Id =: clientId];}
		// this would be a SOQL error not finding specified recordId
		catch(DmlException e){ throw new AuraHandledException('An error occurred when querying client,'+e.getDmlMessage(0)); }
		// this CommB and is a parent because parentId is blank
		if(client.RecordType.DeveloperName=='Commercial_Banking_Client' && String.IsBlank(client.Parentid))return true;
		else if(client.RecordType.DeveloperName=='Commercial_Banking_Client' && !String.IsBlank(client.Parentid)){
			// because is CommB record but it does not have parent is not blank,we throw an error below
			throw new AuraHandledException('Please use parent client to create new business assessment');
		}
		//this is either NBAC recordtype, this will be handled inside getOpportunities();
		else return false;
	}
   /**
    * @description check hasPermissions for BA
    * @return Boolean result
    **/
	private static Boolean hasPermissions(){
		return Business_Assessment__c.SObjectType.getDescribe().isCreateable();
	}
   /**
    * @description getOpportunities
	* @param clientId String
    * @return Opportunity result List
    **/
	@AuraEnabled
	public static Opportunity[] getOpportunities(Id clientId){
		Opportunity[] resultsWithSharing;
		Opportunity[] resultsWithoutSharing;
		if(!String.IsEmpty(clientId)) {
			Account clt = [select Name, Primary_Relationship_Holder__c,CIF__c from Account where Id = :clientId];

			switch on clt.Primary_Relationship_Holder__c{
				when 'Corporate and Investment Banking'{ // check if its a cib client
					if(!isEconomicOrUltimateParent(clt) && hasEconomicOrUltimateParent(clt))
							throw new AuraHandledException(BUSINESS_ASSESSMENT_NOT_AVAILABLE_CLIENTS);
					if(!isEconomicOrUltimateParent(clt) && !hasEconomicOrUltimateParent(clt) && !FeatureManagement.checkPermission(CIBNBACSPVNOCIF)
							&& String.isBlank(clt.CIF__c)) throw new AuraHandledException(BUSINESS_ASSESSMENT_SPV_INSUFFICIENT_PRIVILEGES);
				}
				when 'Commercial Banking','Personal Banking','Business Banking','Other PBB Divisions'{ // check if its a non-cib client
					Boolean isCommbUser = UTL_User.isCommBUser(UserInfo.getUserId());
					// if the client is CommB and parent not blank it wont enter the code block
					if (!isCommBAndParentClient(clientId) && clt.Primary_Relationship_Holder__c=='Commercial Banking' && isCommbUser)
						if(!isEconomicOrUltimateParent(clt)) throw new AuraHandledException(BUSINESS_ASSESSMENT_NOT_AVAILABLE);
					if(String.isBlank(clt.CIF__c) && (isCommbUser || (!isCommbUser && !FeatureManagement.checkPermission(CIBNBACSPVNOCIF))))
						throw new AuraHandledException(BUSINESS_ASSESSMENT_SPV_INSUFFICIENT_PRIVILEGES);
				}
				when null,''{
					throw new AuraHandledException(PRH_REQUIRED);
				}
				when else{
					throw new AuraHandledException(INSUFFICIENT_PRIVILEGES);
				}
			}

			resultsWithSharing = (new OpportunitySelectorWithSharing()).getOpportunitiesByClientId(clientId);
			resultsWithoutSharing = (new OpportunitySelector()).getOpportunitiesByClientId(clientId);
			if((resultsWithSharing.size()!= resultsWithoutSharing.size() && DMN_Account.NON_CIB_PRH.contains(clt.Primary_Relationship_Holder__c) &&
					(!FeatureManagement.checkPermission(CIBNBACSPVNOCIF) && !FeatureManagement.checkPermission(CIBNBACSPVCIF))) ||
					(resultsWithSharing.size()!= resultsWithoutSharing.size() && !DMN_Account.NON_CIB_PRH.contains(clt.Primary_Relationship_Holder__c) &&
							String.isNotBlank(clt.CIF__c)))
				throw new AuraHandledException(BUSINESS_ASSESSMENT_INSUFFICIENT_PRIVILEGES);


			if(!hasPermissions())
				throw new AuraHandledException(INSUFFICIENT_PRIVILEGES);
		}
		return resultsWithSharing;
	}
   /**
    * @description saveAssessment
	* @param clientId ID
	* @param opportunitiesIds List of Ids
    * @return Business_Assessment__c result
    **/
	@AuraEnabled
	public static Business_Assessment__c saveAssessment(Id clientId, List<Id> opportunitiesIds){
		if(String.IsEmpty(clientId)) throw new AuraHandledException(NO_CLIENT_DEFINED);
		if(opportunitiesIds==null || opportunitiesIds.isEmpty()) throw new AuraHandledException(NO_OPPORTUNTIES_DEFINED);

		Schema.SObjectType[] sObjectTypes = new Schema.SObjectType[]{Business_Assessment__c.SObjectType
				,Assessment_Opportunity__c.SObjectType};
		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(sObjectTypes);
		Business_Assessment__c businessAssessment = new Business_Assessment__c();
		businessAssessment.Account__c = clientId;
		uow.registerNew(businessAssessment);
		try{ uow.commitWork(); }
		catch (Exception e){
			if(e.getMessage().contains('No more updates')) throw new AuraHandledException('No more updates can be made as support has been received.');
			else throw new AuraHandledException('Error has occurred. Please contact system administrator.');
		}
		DMN_BusinessAssessment.assignOpportunities(businessAssessment.Id, opportunitiesIds, uow);
		try{ uow.commitWork(); }
		catch (Exception e){
			if(e.getMessage().contains('No more updates')) throw new AuraHandledException('No more updates can be made as support has been received.');
			else throw new AuraHandledException('An unknown error has occurred. Please contact your Salesforce system administrator.');
		}

		DMN_BusinessAssessment.addRelatedOpportunityTeamUsers(businessAssessment.Id, opportunitiesIds);
		return businessAssessment;
	}
   /**
    * @description Inner Class OpportunitySelector
    **/
	public class OpportunitySelector {
  
	   /**
		* @description Method getOpportunitiesByClientId for none Sharing
		* @param clientId Id
		* @return Opportunity result
		**/
		public Opportunity[] getOpportunitiesByClientId(Id clientId) {
			Opportunity[] results;
			if (!String.isBlank(clientId)) {
				String ownerWhereQuery =!UTL_User.isCommBUser(UserInfo.getUserId())?
				'AND Owner.User_Division__c != \''+ UTL_User.COMMB_DIVISION +'\'':'AND Owner.User_Division__c = \''+ UTL_User.COMMB_DIVISION +'\'';
				String sbGrossParticipation = !UTL_User.isCommBUser(UserInfo.getUserId()) ? 'AND Total_SB_Gross_Participation__c > 0 ' :'';
				results = Database.query('SELECT Id'+
				', Name '+
				', Account.Name '+
				', Owner.Name '+
				', Total_SB_Gross_Participation__c '+
				', CloseDate '+
				', CurrencyIsoCode '+
				'FROM Opportunity '+
				'WHERE (AccountId = \''+ clientId +'\''+
				'OR Account.ParentId = \''+ clientId +'\''+
				'OR Account.Parent.ParentId = \''+ clientId +'\')'+
				'AND StageName = \''+ DMN_Opportunity.ST_DEVELOP +'\''+
				'AND IsPrivate = false '+
				 sbGrossParticipation + ownerWhereQuery);
			}
			return results;
		}
	}
	/**
	* @description Inner Class OpportunitySelectorWithSharing
	**/
	public with sharing class OpportunitySelectorWithSharing {
		/**
		* @description Method getOpportunitiesByClientId for with Sharing
		* @param clientId Id
		* @return Opportunity result
		**/
		public Opportunity[] getOpportunitiesByClientId(Id clientId) {
			Opportunity[] results;
			results = (new OpportunitySelector()).getOpportunitiesByClientId(clientId);
			return results;
		}
	}
}