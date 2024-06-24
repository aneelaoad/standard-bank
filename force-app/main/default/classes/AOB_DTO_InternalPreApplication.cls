/**
 * @description Pre application DTO Class
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
public inherited sharing class AOB_DTO_InternalPreApplication
{

	private static final String PRODUCT_CATEGORY = 'optional';
	private static final String PREFERRED_METHOD_OF_COMM = 'Email';
	private static final String DEFAULT_ID_TYPE = 'ZFS001';
	private static final String DEFAULT_ID_COUNTRY_CODE = 'ZA';

	public List<AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail> directorDetails;
	public AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail businessDetails;
	public AOB_DTO_StaffAssistedOnboarding.DTO_ProductDetail productDetails;
	public AOB_DTO_StaffAssistedOnboarding.DTO_Consent consents;
	public AOB_DTO_StaffAssistedOnboarding.DTO_PreApplicationApplicationDetail applicationDetails;

	/**
	 * @description This method is used to set director details for the pre application request
	 *
	 * @param preApplication the pre application request input from the front-end
	 *
	 * @return Director Details
	 */
	public static AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail getDirectorDetails(AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication preApplication)
	{

		AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail director = new AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail();
		director.firstName = preApplication?.Name;
		director.lastName = preApplication?.Surname;
		director.cellphoneNumber = preApplication.PhoneNumber;
		director.emailAddress = preApplication?.EmailAddress;
		director.identificationNumber = preApplication?.IdNum;
		director.status = CMN_UTIL_String.EMPTY;
		director.digitalId = CMN_UTIL_String.EMPTY;
		director.bpId = CMN_UTIL_String.EMPTY;
		director.loggedInUser = true;
		director.mainApplicant = true;
		director.authorizedToApply = true;
		director.preferredCommunicationMethod = PREFERRED_METHOD_OF_COMM;
		director.identificationCountryCode = DEFAULT_ID_COUNTRY_CODE;
		director.identificationType = DEFAULT_ID_TYPE;

		AOB_DTO_StaffAssistedOnboarding.DTO_PipDetail pipDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_PipDetail();
		pipDetail.publicOfficialRelatedDetails = new AOB_DTO_StaffAssistedOnboarding.DTO_PublicOfficialRelatedDetail();
		director.pipDetails = pipDetail;

		return director;
	}

	/**
	 * @description This method is used to get business details for the pre application request
	 *
	 * @param preApplication the pre application request input from the front-end
	 * @param registrationNumber business registration number
	 *
	 * @return Business details
	 */
	public static AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail getBusinessDetail(AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication preApplication, String registrationNumber)
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail businessDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_BusinessDetail();
		businessDetail.businessRegistrationNumber = registrationNumber;
		businessDetail.soleShareholdingInd = Boolean.valueOf(preApplication?.soleOwner);
		businessDetail.businessCity = CMN_UTIL_String.EMPTY;
		businessDetail.businessProvince = preApplication.businessProvince != null ? preApplication.businessProvince : CMN_UTIL_String.EMPTY;
		businessDetail.businessName = preApplication.businessName != null ? preApplication.businessName : CMN_UTIL_String.EMPTY;
		businessDetail.businessType = preApplication.businessType != null ? preApplication.businessType : CMN_UTIL_String.EMPTY;
		businessDetail.businessTurnover = preApplication.businessTurnover != null ? preApplication.businessTurnover : CMN_UTIL_String.EMPTY;

		return businessDetail;
	}

	/**
	 * @description This method is used to get product details for the pre application request
	 *
	 * @param applicationLineItem application line item record
	 *
	 * @return product details
	 */
	public static AOB_DTO_StaffAssistedOnboarding.DTO_ProductDetail getProductDetail(AOB_ApplicationLineItem__c applicationLineItem)
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_ProductDetail productDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_ProductDetail();
		productDetail.productNumber = applicationLineItem?.AOB_ProductCode__c;
		productDetail.productDescription = applicationLineItem?.AOB_Product__r.Name;
		productDetail.productCategory = PRODUCT_CATEGORY;
		productDetail.pricingOption = applicationLineItem?.AOB_Pricing_Option__c;
		return productDetail;
	}

}