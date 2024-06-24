/**
 * @author Michal Lipinski milipinski@deloittece.com
 * @description Domain class for Assessment_Opportunity object
 *
**/
@SuppressWarnings('PMD.CognitiveComplexity')
public inherited sharing class DMN_Assessment_Opportunity extends fflib_SObjectDomain{

	public static final String TO_BE_COMPLETED	= 'To be completed';

	/**
     * @description class for constructing Assessment_Opportunity__c Domain instance
     *
     * @author Konrad Bruszewski
     * @date june 2021
     */
	public class Constructor implements fflib_SObjectDomain.IConstructable {

		/**
         * Constructs and returns new DMN_Assessment_Opportunity instance with given records
         *
         * @param records
         *
         * @return New DMN_Assessment_Opportunity instance
         */
		public fflib_SObjectDomain construct(List<SObject> records) {
			return new DMN_Assessment_Opportunity(records);
		}
	}

	/**
     * DMN_Assessment_Opportunity constructor
     *
     * @param records - set of records on which domain will be performing operations
     */
	public DMN_Assessment_Opportunity(List<SObject> records) {
		super(records);
	}

	/**
	 * @description Updates fields on related Business_Assessment__c records.
	 *				Populated fields :
	 *				  GCCR_Status__c
	 *				  Booking_Countries__c
	 *				  MNPI__c
	 * @param assessmentOpportunities List of Assessment_Opportunity__c Ids that changed and need to be recalculated
	 * @param unitOfWork fflibInstance to limit number of dml operations
	 */
	public static void populateFieldsOnBusinessAssessment(Assessment_Opportunity__c[] assessmentOpportunities, fflib_ISObjectUnitOfWork unitOfWork) {
		Map<Id, Opportunity> id2Opportunity = new Map<Id, Opportunity> ([
			SELECT
				Total_SB_Gross_Participation__c,
				GCCR_Status__c,
				AccountId,
				Price_Sensitive__c, (SELECT Balance_Sheet_of_Booking__c, SB_Gross_Participation__c FROM Products__r), (SELECT Business_Assessment__c FROM Assessment_Opportunities__r)
			FROM Opportunity
			WHERE Id IN (
				SELECT Opportunity__c
				FROM Assessment_Opportunity__c
				WHERE Business_Assessment__c IN :UTL_Collections.builMap(assessmentOpportunities, Assessment_Opportunity__c.Business_Assessment__c).keySet()
			)
		]);

		Map<Id, KYC_Status__c> id2KYCstatus = new Map<Id, KYC_Status__c> ([
			SELECT Id, Client__r.Name, Entity_Code__c, KYC_Status__c
			FROM KYC_Status__c
			WHERE Client__c IN (SELECT AccountId FROM Opportunity WHERE Id IN :id2Opportunity.keySet())
		]);

		Map<Id, List<Opportunity>> bAssessmentId2Opportunities = DMN_Assessment_Opportunity.buildCollection(assessmentOpportunities, id2Opportunity);
		Map<Id, List<KYC_Status__c>> accountId2kycStatuses = UTL_Collections.builListMap(id2KYCstatus.values(), KYC_Status__c.Client__c);

		List<Business_Assessment__c> bAssessmentsToUpdate = getBAssessmentsToUpdate(bAssessmentId2Opportunities, accountId2kycStatuses);

		if (unitOfWork == null && !bAssessmentsToUpdate.isEmpty()) {
			update bAssessmentsToUpdate;
		}
		else if (!bAssessmentsToUpdate.isEmpty()) {
			unitOfWork.registerDirty(bAssessmentsToUpdate);
		}
	}

	private static List<Business_Assessment__c> getBAssessmentsToUpdate(Map<Id, List<Opportunity>> bAssessmentId2Opportunities,
		Map<Id, List<KYC_Status__c>> accountId2kycStatuses) {

		List<Business_Assessment__c> bAssessmentsToUpdate = new List<Business_Assessment__c> ();
		for (Id businessAssessmentId : bAssessmentId2Opportunities.keySet()) {
			Set<String> bookingCountries = new Set<String>();
			Set<String> gccrStatuses = new Set<String>();
			Set<String> kycStatuses = new Set<String>();
			Boolean isMnpi = false;
			for (Opportunity opp : bAssessmentId2Opportunities.get(businessAssessmentId)) {
				if (!(opp.Total_SB_Gross_Participation__c > 0)) {
					continue;
				}
				if (String.isNotBlank(opp.GCCR_Status__c)) {
					gccrStatuses.add(opp.GCCR_Status__c);
				}
				if (opp.Price_Sensitive__c == true) {
					isMnpi = true;
				}
				addParsedKycValues(kycStatuses, accountId2kycStatuses.get(opp.AccountId));
				collectBookingCountries(opp, bookingCountries);
			}
			String kycString = String.join(new List<String> (kycStatuses), '\n');
			bAssessmentsToUpdate.add(
				new Business_Assessment__c(
					Id = businessAssessmentId,
					Booking_Countries__c = String.join(new List<String> (bookingCountries), ';'),
					GCCR_Status__c = String.join(new List<String> (gccrStatuses), ';'),
					KYC_Status__c = kycString.trim() == '' ? TO_BE_COMPLETED : kycString,
					MNPI__c = isMnpi
				)
			);
		}
		return bAssessmentsToUpdate;
	}

	/**
	 * @description Builds Map Id(Bussiness_Assemsment) -> List of Opportunities with related Products
	 * @param assessmentOpportunities List of Assessment_opportunity records with Business_Assessment__c and Opportunity__c field provided
	 * @param mId2Opp Standard Map Id - Opportunity, Opportunity must have Products__r and Business_Assemesnet__r relations filled.
	 * @return  Map Id(Bussiness_Assemsment) -> List of related Opportunities
	 */
	private static Map<Id, List<Opportunity>> buildCollection(List<Assessment_Opportunity__c> assessmentOpportunities, Map<Id, Opportunity> mId2Opp) {
		Map<Id, List<Opportunity>> bAssessmentId2Opportunities = new Map<Id, List<Opportunity>> ();
		for (Assessment_Opportunity__c assessOpp : assessmentOpportunities) {
			bAssessmentId2Opportunities.put(assessOpp.Business_Assessment__c, new List<Opportunity> ());
		}
		for (Opportunity opp : mId2Opp.values()) {
			for (Assessment_Opportunity__c child : opp.Assessment_Opportunities__r) {
				if (bAssessmentId2Opportunities.containsKey(child.Business_Assessment__c)) {
					bAssessmentId2Opportunities.get(child.Business_Assessment__c).add(opp);
				} else {
					bAssessmentId2Opportunities.put(child.Business_Assessment__c, new List<Opportunity> { opp });
				}
			}
		}
		return bAssessmentId2Opportunities;
	}

	private static void addParsedKycValues(Set<String> kycStatuses, List<KYC_Status__c> kycObjects) {
		if (kycObjects == null) { return; }
		for (KYC_Status__c kycRecord : kycObjects) {
			kycStatuses.add(getParsedKycValue(kycRecord));
		}
	}

	private static void collectBookingCountries(Opportunity opp, Set<String> bookingCountries) {
		for (SB_Product__c product : opp.Products__r) {
			if (product.SB_Gross_Participation__c > 0 && String.isNotBlank(product.Balance_Sheet_of_Booking__c)) {
				bookingCountries.add(product.Balance_Sheet_of_Booking__c.split('-') [0]);
			}
		}
	}

	@TestVisible
	private static String getParsedKycValue(KYC_Status__c status) {
		return String.join(new List<String> { status.Client__r.Name, status.KYC_Status__c, status.Entity_Code__c }, ', ');
	}

	/**
	 * Sets conditional default values (Currency and Related Opportunity Owner)
	 *
	 * @param assessmentOpportunities New Assessment Opportunity records
	 */
	public static void setDefaults(List<Assessment_Opportunity__c> assessmentOpportunities) {
		if (assessmentOpportunities == null) {
			throw new AssessmentOpportunityException('No Assessment Opportunity specifed.');
		}
		Set<Id> opportunityIds = new Set<Id> ();
		for (Assessment_Opportunity__c assessmentOpportunity : assessmentOpportunities) {
			setCorporateCurrency(assessmentOpportunity);
			opportunityIds.add(assessmentOpportunity.Opportunity__c);
		}
		Map<Id, Opportunity> id2opportunity = new Map<Id, Opportunity> ();
		id2opportunity = getOpportunities(opportunityIds);
		if (id2opportunity != null && !id2opportunity.isEmpty()) {
			for (Assessment_Opportunity__c assessmentOpportunity : assessmentOpportunities) {
				Opportunity opp = id2opportunity.get(assessmentOpportunity.Opportunity__c);
				if(opp != null) {
					assessmentOpportunity.Related_Opportunity_Owner__c = opp.OwnerId;
				}
			}
		}
	}

	private static Map<Id, Opportunity> getOpportunities(Set<Id> opportunityIds) {
		Map<Id, Opportunity> results = new Map<Id, Opportunity> ([SELECT Id, OwnerId
				       											FROM Opportunity WHERE Id IN :opportunityIds]);
		return results;
	}

	@TestVisible
	private static void setCorporateCurrency(Assessment_Opportunity__c assessmentOpportunity) {
		assessmentOpportunity.CurrencyIsoCode = UTL_Currency.corporateIsoCode;
	}

	/**
	 * @description Updates fields on related Bussiness_Assesment__c records.
	 *				Populated fields :
	 *				  MNPI__c
	 * @param assessmentOpportunities List of Assesment_Opportunity__c Ids that changed and need to be recalculated
	 * @param unitOfWork fflibInstance to limit number of dml operations
	 */
	public static void populateMNPIOnBusinessAssessment(Assessment_Opportunity__c[] assessmentOpportunities, fflib_ISObjectUnitOfWork unitOfWork) {

				Map<Id, Opportunity> id2Opportunity = new Map<Id, Opportunity> (
		[SELECT
				id,
				AccountId,
				Price_Sensitive__c,
		(Select Business_Assessment__c FROM Assessment_Opportunities__r )
		FROM Opportunity
		WHERE Id in
		(
				Select Opportunity__c From Assessment_Opportunity__c
				WHERE Business_Assessment__c IN : UTL_Collections.builMap(assessmentOpportunities, Assessment_Opportunity__c.Business_Assessment__c).keySet()
		)
		]
		);

		Map<Id, List<Opportunity>> bAssessmentId2Opportunities = DMN_Assessment_Opportunity.buildCollection(assessmentOpportunities, id2Opportunity);
		List<Business_Assessment__c> bAssessmentsToUpdate = new List<Business_Assessment__c> ();
		for (Id bussinessAssessmentId : bAssessmentId2Opportunities.keySet()) {

			Boolean isMnpi = false;
			for (Opportunity opp : bAssessmentId2Opportunities.get(bussinessAssessmentId)) {
				if (opp.Price_Sensitive__c == true) {
					isMnpi = true;
				}
			}

			if(isMnpi == true) {
				bAssessmentsToUpdate.add(
						new Business_Assessment__c(
								Id = bussinessAssessmentId,
								MNPI__c = true
						)
				);
			}
			else {
				bAssessmentsToUpdate.add(
						new Business_Assessment__c(
								Id = bussinessAssessmentId,
								MNPI__c = false
						)
				);
			}
		}
		if (unitOfWork == null && !bAssessmentsToUpdate.isEmpty()) {
			update bAssessmentsToUpdate;
		} else if (!bAssessmentsToUpdate.isEmpty()) {
			unitOfWork.registerDirty(bAssessmentsToUpdate);
		}
	}

	/**
	 * Trigger recalculation of fields from Risk and Distribution Management section on Business Assessments
	 *
	 * @param assessmentOpportunities
	 * @param unitOfWork
	 */
	public void recalculateRiskAndDistributionManagementFieldsOnBusinessAssessment(List<Assessment_Opportunity__c> assessmentOpportunities, fflib_ISObjectUnitOfWork unitOfWork) {
		Set<Id> businessAssessmentIds = new Set<Id>();
		for (Assessment_Opportunity__c aop : assessmentOpportunities) {
			businessAssessmentIds.add(aop.Business_Assessment__c);
		}
		SEL_BusinessAssessments baSelector = SEL_BusinessAssessments.newInstance().withCrudAssert(false).withFlsEnforced(false);
		List<Business_Assessment__c> baRecords = baSelector.selectByIds(businessAssessmentIds, false);
		DMN_BusinessAssessment_Injectable baDomain = (DMN_BusinessAssessment_Injectable) ORG_Application.domain.newInstance(baRecords);
		baDomain.recalculateDistributionAndRiskManagementFields(unitOfWork);
	}

	/**
	 * Initiate DCP fields recalculation on opportunities
	 *
	 * @param assessmentOpportunities - List<Assessment_Opportunity__c>
	 * @param unitOfWork - fflib_ISObjectUnitOfWork
	 */
	public void recalculateDcpFieldsOnOpportunities(List<Assessment_Opportunity__c> assessmentOpportunities, fflib_ISObjectUnitOfWork unitOfWork){
		Set<Id> oppIds = new Set<Id>();
		for (Assessment_Opportunity__c aop :assessmentOpportunities) {
			oppIds.add(aop.Opportunity__c);
		}
		SEL_Opportunities oppSelector = SEL_Opportunities.newInstance().withCrudAssert(false).withFlsEnforced(false);
		List<Opportunity> opps = oppSelector.selectByIdsWithoutSharing(oppIds);
		DMN_Opportunity.recalculateDcpFields(opps, unitOfWork);
	}

	/**
	 * @description custom exception for Assessment Opportunity Object
	 */
	public class AssessmentOpportunityException extends Exception { }
}