/**
 * A class that implements controller for the CiCcap lwc component to provide Ccap value to end users.
 * TBD
 *
 * @author Nikita Haruk
 * @date 2022-09-07
 *
 */
public with sharing class CiCcap_Controller {
    private static SRV_RasCcap ccapService = new SRV_RasCcap();

    /**
     * A method that pulls Ccap value from the Risk App Store by a record Id.
     *
     * @param String - The id of the record to which we need to pull Ccap value.
     *
     * @return a wrapper class that contains result of the pulling Ccap value from the Risk App Store.
     */
    @AuraEnabled
    public static CcapWrapper getCcapValue(String recordId) {
        SObjectType objectType = Id.valueOf(recordId).getSobjectType();
        Map<String, String> accName2Ccap = new Map<String, String>();
        Boolean isAllowedToViewCcap = false;
        CcapWrapper result;
        if (CR_Container_Controller.isUserCib()) {
            try {
                if (objectType == Account.SObjectType) {
                    isAllowedToViewCcap = ccapService.isAllowedToViewCcap(recordId);
                    if (isAllowedToViewCcap) {
                        getCcapForAccounts(new Set<Id>{ recordId }, accName2Ccap);
                    } else {
                        accName2Ccap.put('error', System.Label.CCAP_NotAvailable);
                    }
                } else if (objectType == Business_Assessment__c.SObjectType) {
                    isAllowedToViewCcap = true;
                    Set<Id> accountIds = ccapService.getAccountIds(recordId);
                    getCcapForAccounts(accountIds, accName2Ccap);
                }

                if (accName2Ccap.get('error') != null) {
                    result = new CcapWrapper(isAllowedToViewCcap, true, accName2Ccap.get('error'), new Map<String, String>());
                } else {
                    result = new CcapWrapper(isAllowedToViewCcap, false, null, accName2Ccap);
                }
            } catch (Exception e) {
                SRV_Logger.newInstance().log(e, DMN_Log.AREA_CIB_CCAP, IB_SRV_GatewayAPI_GetCCAP.class.getName());
                result = new CcapWrapper(isAllowedToViewCcap, true, System.Label.CCAP_UnknowExceptionMessage, new Map<String, String>());
            }
        } else {
            result = new CcapWrapper(false, true, System.Label.CCAP_NotAvailable, new Map<String, String>());
        }
        return result;
    }

    /**
     * A method that pulls Ccap value from the Risk App Store by account Ids.
     *
     * @param Set<Id> - The set of account Ids.
     * @param Map<String, String> - the map of Ccap value by account name.
     * 
     */
    private static void getCcapForAccounts(Set<Id> accountIds, Map<String, String> accName2Ccap) {
        Map<String, String> cif2AccountName = ccapService.getCifNumbers(accountIds);
        Map<String, String> cif2Ccap        = ccapService.getCcapValues(cif2AccountName.keySet());

        if (cif2Ccap.get('error') != null) {
            accName2Ccap.put('error', cif2Ccap.get('error'));
        } else {
            for (String cif : cif2Ccap.keySet()) {
                accName2Ccap.put(cif2AccountName.get(cif), cif2Ccap.get(cif));
            }
        }
    }

    public class CcapWrapper {
        @AuraEnabled
        public Boolean isUserAllowedToViewCcap;
        @AuraEnabled
        public Boolean hasErrors;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public Map<String, String> accountName2Ccap;

        public CcapWrapper(Boolean isUserAllowedToViewCcap, Boolean hasErrors, String errorMessage, Map<String, String> accountName2Ccap) {
            this.isUserAllowedToViewCcap = isUserAllowedToViewCcap;
            this.hasErrors = hasErrors;
            this.errorMessage = errorMessage;
            this.accountName2Ccap = accountName2Ccap;
        }
    }
}