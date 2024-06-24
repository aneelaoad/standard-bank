/**
* @author Michal Lipinski
* @UserStory US-4426
* @Description controller for PBB_Lifestyle_HighlightPanel.cmp that calls the API for client data.
* @Date
*/
public without sharing class PBB_Lifestyle_HighlightPanelCtrl {
	private static final SRV_Logger LOGGER = (SRV_Logger) SRV_Logger.newInstance();

	@TestVisible
	private final static String DEBT_REVIEW_YES = 'Yes';
	@TestVisible
	private final static String DEBT_REVIEW_NO = 'No';
	@TestVisible
	private final static String KYC_DESCRIPTION = 'KYC Requirements';

	@AuraEnabled
	public static String getKycStatus(Id clientId) {
		try {
			PBB_SRV_GatewayApi_GetCustomers.GetCustomerValidityInfoResponseWrapper response = PBB_SRV_GatewayApi_GetCustomers.newInstance().getCustomerCompliance(clientId);
			if (response == null) {
				throw new AuraHandledException('Data unavailable');
			}
			if (response.GetCustomerValidityInfoResponse == null || response.GetCustomerValidityInfoResponse.ComplianceData.isEmpty()) {
				return null;
			}
			for (PBB_SRV_GatewayApi_GetCustomers.ResponseComplianceData complianceDataItem : response.GetCustomerValidityInfoResponse.ComplianceData) {
				if (complianceDataItem.ComplianceType != null &&
						complianceDataItem.ComplianceType.description == KYC_Description &&
						complianceDataItem.ComplianceStatus != null &&
						complianceDataItem.ComplianceStatus.description != null) {
					return complianceDataItem.ComplianceStatus.description;
				}
			}
		} catch(AuraHandledException ae) {
			throw ae;
		}
		catch(Exception e) {
			LOGGER.log(e, PBB_Lifestyle_HighlightPanelCtrl.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
			throw e;
		}
		return null;
	}

	@AuraEnabled
	public static String getDebtReview(Id clientId) {
		try {
			List<PBB_SRV_GatewayApi_GetCustomers.Status> response = PBB_SRV_GatewayApi_GetCustomers.newInstance().getCustomerStatuses(clientId);
			if (response != null && !response.isEmpty()) {
				for (PBB_SRV_GatewayApi_GetCustomers.Status status : response) {
					if (status.status == PBB_SRV_GatewayApi_GetCustomers.DEBT_REVIEW_STATUS_CODE &&
							(Date.today() >= Date.valueOf(status.effDate)) &&
							(Date.today() <= Date.valueOf(status.expDate))) {
						return DEBT_REVIEW_YES;
					}
				}
			} else {
				throw new AuraHandledException('Data unavailable');
			}
		}
		catch(AuraHandledException ae) {
			throw ae;
		}
		catch(Exception e) {
			LOGGER.log(e, PBB_Lifestyle_HighlightPanelCtrl.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
			throw e;
		}
		return DEBT_REVIEW_NO;
	}
}