/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* @description Profile utility class
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Artur Kepczynski
* @version        1.0
* @created        2017-05-25
* @systemLayer    Utility ( Choose from: Invocation | Service | Utility | Selector | Domain | Test )
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Caro Reinecke
* 2018-01-08      Digitization Client Onboarding - Account Opening US-2668 - Added API User profile.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class DCN_Profile {

	public static final String
			SYS_ADMIN 			= 'System Administrator',
			SYS_ADMIN_SUPPORT 	= 'System Administrator - Premier Support',
			BUSINESS_ADMIN   	= 'Business Administrator',
			COMMB_STD 			= 'Commercial Banking Custom Std User',
			COMMB_STD_MOBILE 	= 'Commercial Banking Custom Std User - Mobile',
            COMMB_COMMUNITIES   = 'Commercial Banking Communities User',
			CUSTOM_STD_MOBILE	= 'Custom Standard Lightning Client Coverage Mobile User Insights',
			CUSTOM_STANDARD 	= 'Custom Standard Lightning Client Coverage Mobile User Insights',
			CUSTOM_STD_GENERIC 	= 'Custom Standard Lightning Generic Business Unit Mobile User Insights',
			API_USER 			= 'Api User',
        	API_ONLY_USER 		= 'API Only User',
    		BUSINESS_BANKNG     = 'BCC Custom Std User - Mobile';
}