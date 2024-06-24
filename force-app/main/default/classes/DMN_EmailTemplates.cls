/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description Domain layer for EmailTemplate object
 */
public class DMN_EmailTemplates  {
	public static final String TEMPLATE_PBB_API_FAILURE = 'Api_Failed';
	public static final String EMAIL_ERROR_TEMP = 'API_Request_Consent_Error_Log';
	public static final String RELATIONSHIP_MANAGER_EMAIL = 'Reltionship Manager Mail';
	public static final String DIGISIGN_EMAIL_TEMPLATE =  SB_Parameters__c.getValues('DIGISIGN_CONSENT_INVITATION').Value__c;
}