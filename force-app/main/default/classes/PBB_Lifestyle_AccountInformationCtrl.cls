/**
 * Controller class for PBB_AccountInformationDetails and PBB_AccountInformaActionList
 * SGPRT-1646
 *
 * @authors Damian Czapnik (dczapnik@deloittece.com) & Youssef Ibrahim (yibrahim@deloittece.com)
 * @date July 2020
 */
public with sharing class PBB_Lifestyle_AccountInformationCtrl {

    private static final PBB_SRV_GatewayApi_AccountInformation.IService accountInfoService = PBB_SRV_GatewayApi_AccountInformation.newInstance();
    private static final SRV_Logger loggerService = (SRV_Logger) SRV_Logger.newInstance();

    @AuraEnabled(Cacheable=true)
    public static Account getAccountData(Id clientId) {
        return SEL_Accounts.newInstance().selectById(new Set<Id>{
                clientId
        }).get(0);
    }

    @AuraEnabled(Cacheable=true)
    public static List<Account_Information__c> getAccountInformationSF(Id clientId) {
        return SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                clientId
        });
    }

    @AuraEnabled(Cacheable=true)
    public static List<PBB_SRV_GatewayApi_AccountInformation.accountBalance> getBalanceData(Id accountInformationId) {
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectWithParentAccountById(new Set<Id>{
                accountInformationId
        }).get(0);
        if (accInfo.Client__r.GUID__c != null) {
            try {
                PBB_SRV_GatewayApi_AccountInformation.accountBalances response = accountInfoService.getAccountBalance(accInfo.Client__r.GUID__c, accInfo.Name);
                if (response == null) {
                    return new List<PBB_SRV_GatewayApi_AccountInformation.accountBalance>();
                }
                return response.balances;
            } catch (Exception e) {
                loggerService.log(e, PBB_Lifestyle_AccountInformationCtrl.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
                throw new AuraHandledException(e.getMessage());
            }
        }
        return null;
    }

    @AuraEnabled(Cacheable=true)
    public static PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation getProactData(Id accountInformationId) {
        try {
            Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectWithParentAccountById(new Set<Id>{
                    accountInformationId
            }).get(0);
            Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> responseMap = getProactDataForAccount(accInfo.Client__r.GUID__c);
            if (responseMap != null && responseMap.containsKey(accInfo.Name)) {
                return responseMap.get(accInfo.Name);
            }
            return new PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation();
        } catch (Exception e) {
            loggerService.log(e, PBB_Lifestyle_AccountInformationCtrl.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled(Cacheable=true)
    public static Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> getAccountProactData(Id clientId) {
        try {
            Account acc = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{
                    clientId
            }).get(0);
            return getProactDataForAccount(acc.GUID__c);
        } catch (Exception e) {
            loggerService.log(e, PBB_Lifestyle_AccountInformationCtrl.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static Map<Id, PBB_SRV_GatewayApi_AccountInformation.accountBalances> getAccountBalances(Id clientId) {
        PBB_SRV_GatewayApi_AccountInformation.IService accountInfoService = PBB_SRV_GatewayApi_AccountInformation.newInstance();
        Account acc = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{
                clientId
        }).get(0);
        if (acc.GUID__c != null) {
            Map<Id, PBB_SRV_GatewayApi_AccountInformation.accountBalances> response = new Map<Id, PBB_SRV_GatewayApi_AccountInformation.AccountBalances>();
            try {
                response = accountInfoService.getAccountInfo2AccountsBalances(acc.GUID__c);
                return response;
            } catch (Exception e) {
                loggerService.log(e, PBB_Lifestyle_AccountInformationCtrl.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
                throw new AuraHandledException(e.getMessage());
            }
        }
        return null;
    }

    private static Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> getProactDataForAccount(String clientGUID) {

        if (clientGUID != null) {
            Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> response = new Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation>();
            response = accountInfoService.fetchData(clientGUID);
            if (response != null) {
                return response;
            }
            return new Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation>();
        }
        return null;
    }
}