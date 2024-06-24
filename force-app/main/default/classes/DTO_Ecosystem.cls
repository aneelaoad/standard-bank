/**
    @ Last Modified By  : Emmanuel Mulea Nocks
    @ Last Modified On  : Nov 19, 2019
    @description : Modified createAccount(). C-00003016 - CommB: query RG number from a client
*/
@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class DTO_Ecosystem {

	public static Map<String, String> eleType2Label = new Map<String, String>{
								DMN_Ecosystem.PARTNER => 'Partners',
								DMN_Ecosystem.SUBSIDIARY => 'Subsidiaries',
								DMN_Ecosystem.SHAREHOLDER_DIRECTOR => 'Shareholders / Directors',
								DMN_Ecosystem.DEBTOR_CREDITOR => 'Debtors / Creditors',
								DMN_Ecosystem.CLIENT_DISTRIBUTOR => 'Clients / Distributors',
								DMN_Ecosystem.EMPLOYEE => 'Employees'
							};
	/** 
    * @description Inner class to drive DTF values
    */
	public class DeliverTheFirm{ 

		@AuraEnabled public String 	clientName,
									elementType,
									oppName,
									oppStage,
									oppOwner,
									closeDate,
									description,
									comments,
									currencyCode,
									label;
		@AuraEnabled public Decimal notionalValue;
			/**
		* @description Constructor of DeliverTheFirm
		* @param elementType String
		* @param product SB_Product__c
		*/
		public DeliverTheFirm(String elementType, SB_Product__c product){
			clientName 			= 	product.Opportunity__r.Account.Name; 
			this.elementType 	= 	elementType; 
			oppName 			=	product.Opportunity__r.Name; 
			oppStage 			=	product.Opportunity__r.StageName; 
			notionalValue 		=	product.Facility_Size__c	 != null ?
												 product.Facility_Size__c	 : 0; 
			oppOwner 			=	product.Opportunity__r.Owner.Name; 
			closeDate 			=	String.valueOf(product.Opportunity__r.CloseDate); 
			description 		=	product.Opportunity__r.Description; 
			comments 			=	product.Opportunity__r.CommentsOnProgress__c;
			currencyCode		= 	product.CurrencyIsoCode;
			label				= 	DTO_Ecosystem.eleType2Label.get(elementType);
		}
		/**
		 * @description Constructor of DeliverTheFirm
		 * @param elementType String
		 * @param notionalValue Decimal
		 * @param currencyCode String
		 */
		public DeliverTheFirm(String elementType, Decimal notionalValue, String currencyCode){
			this.elementType 	= elementType;
			this.notionalValue 	= notionalValue;
			this.currencyCode 	= currencyCode; 
			this.label			= DTO_Ecosystem.eleType2Label.get(elementType);
		}
	}
	/**
    * @description Inner class to drive Revenue And Profitability values
    */
	public class RevenueAndProfitability{

		@AuraEnabled public String 	name,
									label,
									currencyCode;
		@AuraEnabled public Decimal	netIncome,
									netRevenue,
									nonRevenue,
									operationalIncome,
									headlineErnings,
									roe;
		@AuraEnabled public Integer count;
		/**
		 * @description Constructor of RevenueAndProfitability
		 * @param name String
		 * @param currencyCode string
		 */
		public RevenueAndProfitability(String name, String currencyCode){

			this.name 			= 	name;
			this.currencyCode	= 	currencyCode;
			label 				= 	DTO_Ecosystem.eleType2Label.get(name);
			netIncome 			= 	0;
			netRevenue 			= 	0;
			nonRevenue          =   0;
			operationalIncome 	= 	0;
			headlineErnings 	= 	0;
			roe 				= 	0;
			count               =   0;
		}
	}
	/**
    * @description Inner class to drive Revenue And Profitability values
    */
	public class EcosystemOverview{

		@AuraEnabled public String 	elementType,
									label;
		@AuraEnabled public Decimal	knownBanked,
									knownUnbanked,
									unknownUnbanked,
									total;
		/**
		 * @description Constructor of EcosystemOverview
		 * @param elementType String
		 * @param knownBanked Decimal
		 * @param knownUnbanked Decimal
		 * @param unknownUnbanked Decimal
		 */
		public EcosystemOverview(String elementType, Decimal knownBanked, Decimal knownUnbanked, 
									Decimal unknownUnbanked){
			this.elementType 		= elementType;
			label 					= 	DTO_Ecosystem.eleType2Label.get(elementType);
			this.knownBanked 		= knownBanked;
			this.knownUnbanked 		= knownUnbanked;
			this.unknownUnbanked 	= unknownUnbanked;
			total = knownBanked + knownUnbanked + unknownUnbanked;
		}
	}
	/**
    * @description Inner class for Hierarchy Member
    */
	public class HierarchyMember {
		
		@AuraEnabled public Id recordId;

		@AuraEnabled public String name;

		@AuraEnabled public RevenueAndProfitability profitability;
		/**
		 * @description Constructor of HierarchyMember
		 * @param acc Account
		 * @param profitability RevenueAndProfitability
		 */
		public HierarchyMember(Account acc, RevenueAndProfitability profitability) {
			
			this.recordId = acc.Id;
			this.name = acc.Name;
			this.profitability = profitability;

		}

			
	}
	/**
    * @description Inner class to Save records
    */
	public class SaveResult {
		@AuraEnabled
		public Id objectId;
		@AuraEnabled
		public Boolean success;
		/**
		 * @description Constructor of SaveResult
		 * @param result Database.SaveResult
		 */
		public SaveResult(Database.SaveResult result) {
			objectId = result.getId();
			success = result.isSuccess(); 
		}
		/**
		 * @description Constructor of SaveResult
		 * @param result Database.SaveResult
		 */
		public SaveResult(Database.UpsertResult result) {
			objectId = result.getId();
			success = result.isSuccess();
		}
	}
	/**
    * @description Inner class to delete records
    */
	public class DeleteResult {
		@AuraEnabled
		public Id objectId;
		@AuraEnabled 
		public Boolean success;
		/**
		 * @description Constructor of DeleteResult
		 * @param result Database.DeleteResult
		 */
		public DeleteResult(Database.DeleteResult result) {
			objectId = result.getId();
			success = result.isSuccess();
		}
	}
	/**
    * @description Inner class for Banked Client
    */
	public class BankedClient implements Comparable {
		@testVisible 	private Account client;
		@AuraEnabled 	public Option[] options;
		@AuraEnabled 	public Sobject entity;
		@AuraEnabled 	public String 	recordId,
									elementType,
									groupNo,
									cif,
									bpid,
									name,
									groupName,
									groupParentName,
									recordType,
									status,
									primaryRelationshipHolder,
									clientCoordinatorName,
									createdBy,
									entityId,
									cifClientStatus,
									ecosystemId,
									entityName,
									bpidStatus,
									ecosystemSfId;
		@AuraEnabled	public Date createdDate;
		@AuraEnabled	public Date customerStartDate;
		/**
		 * @description Constructor of BankedClient
		 * @param entity Ecosystem_Entity__c
		 */
		public BankedClient(Ecosystem_Entity__c entity) {
			this.options 	= getOptions(Ecosystem_Entity__c.Entity_Type__c.getDescribe());
			this.client 	= entity.Entity__r;
			entityId		= entity.Entity__c;
			recordId 		= entity.Id;
			elementType 	= entity.Entity_Type__c;
			groupNo			= entity.Ecosystem__r.Relationship_Group_Number__c;
			cif				= client==null ? null : client.CIF__c;
			cifClientStatus = client==null ? null : client.CIF_Client_Status__c;
			bpid            = entity==null ? null : entity.BPID__c;
			name			= client==null ? null : client.Name;
			entityName		= entity.Name;
			groupName	 	= entity.Ecosystem__r.Relationship_Group_Name__c == null ? null :
            	entity.Ecosystem__r.Relationship_Group_Name__c;
			groupParentName	= client==null ? null : client.Group_Parent__r.Name;
			recordType      = client==null ? null : client.RecordType.DeveloperName;
			status			= client==null ? null : client.Status__c;
			primaryRelationshipHolder = client==null ? entity.Primary_Relationship_Holder__c : client.Primary_Relationship_Holder__c;
			clientCoordinatorName = client==null ? null : client.Client_Coordinator_Name__c;
			ecosystemId     = entity.Ecosystem__r.Name;
			createdBy       = entity.CreatedBy.Name;
			createdDate     = entity.CreatedDate.date();
			bpidStatus 		= entity.Status__c;
			customerStartDate= entity.Customer_Start_Date__c;
			this.entity 	= new Ecosystem_Entity__c(Id = entity.Id, Entity_Type__c = entity.Entity_Type__c);
			ecosystemSfId	= entity.Ecosystem__r.Id;
		}
		/**
		 * Compare two client records so that they repect hierarchy
		 * @param obj Object
		 * @return Integer
		 */
		public Integer compareTo(Object obj) {
			BankedClient other = (BankedClient)obj;
			String thisParentName = getParentName();
			String otherParentName = other.getParentName();
			Integer parentNameCompare = thisParentName.compareTo(otherParentName);
			if (parentNameCompare == 0) {
				Integer thisIsParent = isParent() ? 0 : 1;
				Integer otherIsParent = other.isParent() ? 0 : 1;
				Integer compareParentChild = thisIsParent - otherIsParent;
				if (compareParentChild == 0) {
					String thisName = client.Name;
					String otherName = other.client.Name;
					return (thisName.compareTo(otherName));
				}
				else {
					return compareParentChild;
				}
			}
			else {
				return parentNameCompare;
			}
		}

		private String getParentName() {
			if(client!=null) {
				if (client.Group_Parent__c != null) {
					return client.Group_Parent__r.Name;
				} else {
					return client.Name;
				}
			}
			return null;
		}

		private Boolean isParent() {
			if(client!=null){
				return (client.Group_Parent__c == null);
			}
			return false;
		}

		private Option[] getOptions(Schema.DescribeFieldResult fieldResult) {
			Schema.PicklistEntry[] entries = fieldResult.getPicklistValues();
			Option[] result = new List<Option>();
			for (Schema.PicklistEntry entry : entries) {
				result.add(new Option(entry.getLabel(), entry.getValue()));
			}
			return result;
		}
	}
	/**
    * @description Inner class for Option values
    */
	public class Option {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
		/**
        * @description Constructor of Inner Option class
        * @param label String
        * @param value String
        */
		public Option(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}
	/**
	* @description Inner class to delete records
	*/
	public class EcosystemEntity {
		@AuraEnabled
		public Id ecosystemId;
		@AuraEnabled
		public Id accountId;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String prh;
		@AuraEnabled
		public String entityName;
		@AuraEnabled
		public String bpid;
	}
}