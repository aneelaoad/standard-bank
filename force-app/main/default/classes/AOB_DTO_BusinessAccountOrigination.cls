/**
 * @description Start Business Account Origination DTO Class
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */

public inherited sharing class AOB_DTO_BusinessAccountOrigination
{

	public static final String BUSINESS_ORIGINATION_RESPONSE = 'businessAOResponse';
	public DTO_BusinessAORequest businessAORequest;

	/**
	 * @description Business account origination request data transformation object
	 */
	public class DTO_BusinessAORequest
	{
		public AOB_DTO_StaffAssistedOnboarding.DTO_Consent consents;
		public AOB_DTO_StaffAssistedOnboarding.DTO_ApplicationDetail applicationDetails;
		public AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail businessDetails;
		public AOB_DTO_StaffAssistedOnboarding.DTO_User user;
		public List<AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail> directorDetails;
	}

	/**
	 * @description This method is used to generate the business account origination request
	 *
	 * @param preApplicationResponse the pre application response
	 *
	 * @return Business Account Origination Request
	 */
	public static DTO_BusinessAORequest getBusinessAccountOriginationReq(AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse)
	{
		DTO_BusinessAORequest businessAORequest = new DTO_BusinessAORequest();
		businessAORequest.businessDetails = getBusinessDetail(preApplicationResponse);
		businessAORequest.directorDetails = getDirectorDetails(preApplicationResponse);
		businessAORequest.consents = AOB_DTO_StaffAssistedOnboarding.getDefaultedConsent();//Consent is defaulted due to not getting the values from the front-end
		return businessAORequest;
	}

	/**
	 * @description This method is used to generate business details for the request
	 *
	 * @param preApplicationResponse The pre application response
	 *
	 * @return AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail
	 */
	public static List<AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail> getDirectorDetails(AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse)
	{
		List<AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail> directorDetails = new List<AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail>();
		for(AOB_DTO_StaffAOResponse.DTO_DirectorDetail director : preApplicationResponse.cipcRegisteredDetails.directorDetails)
		{
			AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail directorDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail();
			directorDetail.firstName = director.firstName;
			directorDetail.lastName = director.lastName;
			directorDetail.identificationNumber = director.identificationNumber;
			directorDetail.identificationType = director.identificationType;
			directorDetail.cellphoneNumber = director.cellphoneNumber;
			directorDetail.emailAddress = director.emailAddress;
			directorDetail.identificationCountryCode = director.identificationCountryCode;
			directorDetail.preferredCommunicationMethod = director.preferredCommunicationMethod;
			directorDetail.status = director.status;
			directorDetail.bpId = director.bpId;
			directorDetail.authorizedToApply = director.authorizedToApply;
			directorDetail.loggedInUser = director.loggedInUser;
			directorDetail.mainApplicant = director.mainApplicant;
			directorDetail.digitalId = director.digitalId;
			directorDetail.pipDetails = getPipDetails(director.pipDetails);
			directorDetails.add(directorDetail);
		}
		return directorDetails;
	}
	/**
	 * @description This method is used to generate business details for the request
	 *
	 * @param pipDetail PIP Details from the pre application response
	 *
	 * @return AOB_DTO_StaffAssistedOnboarding.DTO_PipDetail
	 */
	public static AOB_DTO_StaffAssistedOnboarding.DTO_PipDetail getPipDetails(AOB_DTO_StaffAOResponse.DTO_PipDetail pipDetail)
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_PublicOfficialRelatedDetail publicOfficialDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_PublicOfficialRelatedDetail();
		publicOfficialDetail.name = pipDetail.publicOfficialRelatedDetails.name;
		publicOfficialDetail.surname = pipDetail.publicOfficialRelatedDetails.surname;
		publicOfficialDetail.typeOfRelationship = pipDetail.publicOfficialRelatedDetails.typeOfRelationship;
		publicOfficialDetail.relatedToPublicOfficial = pipDetail.publicOfficialRelatedDetails.relatedToPublicOfficial;

		AOB_DTO_StaffAssistedOnboarding.DTO_PipDetail dtoPipDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_PipDetail();
		dtoPipDetail.publicOfficial = pipDetail.publicOfficial;
		dtoPipDetail.publicOfficialRelatedDetails = publicOfficialDetail;
		return dtoPipDetail;
	}

	/**
	 * @description This method is used to generate business details for the request
	 *
	 * @param preApplicationResponse the pre application response
	 *
	 * @return AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail
	 */
	public static AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail getBusinessDetail(AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse)
	{
		AOB_DTO_StaffAOResponse.DTO_BusinessDetail preApplicationBusinessDetail = preApplicationResponse?.cipcRegisteredDetails?.businessDetails;

		AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail businessDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail();
		businessDetail.businessRegistrationNumber = preApplicationBusinessDetail?.businessRegistrationNumber;
		businessDetail.soleShareholdingInd = preApplicationBusinessDetail?.soleShareholdingInd;
		businessDetail.businessCity = preApplicationBusinessDetail?.businessCity;
		businessDetail.businessProvince = preApplicationBusinessDetail?.businessProvince;
		businessDetail.businessName = preApplicationBusinessDetail?.businessName;
		businessDetail.businessType = preApplicationBusinessDetail?.businessType;
		businessDetail.businessTurnover = preApplicationBusinessDetail?.businessTurnover;

		return businessDetail;
	}

	/**
	 * @description Method generates an application detail object for the request
	 *
	 * @param preApplication Pre Application request details
	 * @param applicationId Application record Id
	 *
	 * @return AOB_DTO_StaffAssistedOnboarding.DTO_ApplicationDetail
	 */
	public static AOB_DTO_StaffAssistedOnboarding.DTO_ApplicationDetail getApplicationDetail(AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication preApplication,
			String applicationId)
	{
		List<AOB_ApplicationLineItem__c> applicationLineItems = new SEL_AOBApplicationLineItem().selectAppLineItemsById(applicationId);

		AOB_DTO_StaffAssistedOnboarding.DTO_ApplicationDetail applicationDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_ApplicationDetail();
		applicationDetail.applicationID = applicationId;
		applicationDetail.productDetails = getProductDetails(applicationLineItems);
		applicationDetail.bpGuid = CMN_UTIL_String.EMPTY;
		applicationDetail.inflightCustomerDataID = CMN_UTIL_String.EMPTY;
		return applicationDetail;
	}

	/**
	 * @description This method is used to get product details for the pre application request
	 *
	 * @param applicationLineItems application line item records
	 *
	 * @return product details
	 */
	public static List<AOB_DTO_StaffAssistedOnboarding.DTO_ProductDetail> getProductDetails(List<AOB_ApplicationLineItem__c> applicationLineItems)
	{
		List<AOB_DTO_StaffAssistedOnboarding.DTO_ProductDetail> productDetails = new List<AOB_DTO_StaffAssistedOnboarding.DTO_ProductDetail>();
		for(AOB_ApplicationLineItem__c lineItem : applicationLineItems)
		{
			productDetails.add(AOB_DTO_InternalPreApplication.getProductDetail(lineItem));
		}
		return productDetails;
	}
}