/**
 * Controller class for PBB_RiskAndFacilitiesWrapper component.
 * US-1008
 *
 * @author Maria Pszonka (mpszonka@deloittece.com)
 * @date July 2020
 */
public with sharing class PBB_RiskAndFacilitiesController {

    private static final PBB_SRV_GatewayAPI_RiskAndFacilities.IService riskAndFacilitiesDataService = PBB_SRV_GatewayAPI_RiskAndFacilities.newInstance();
    private static final PBB_SRV_GatewayApi_AccountInformation.IService balanceDataService = PBB_SRV_GatewayApi_AccountInformation.newInstance();
    private static final String WATCHLIST_FLAG = 'watchlist flag';
    private static final SRV_Logger loggerService = (SRV_Logger) SRV_Logger.newInstance();
    private static final String ACTUAL_ACCOUNT_BALANCE_TYPE = 'Actual';

    public class ControllerException extends Exception {
    }
    /**
     * check if logged in user has access to see insights pro-act data
     *
     * @param client
     * @return Boolean
     */
    public static Boolean isPermited(Account client) {
        return RoleUtility.isManagerOfUsers(new Id[]{client.OwnerId}, UserInfo.getUserId()) || isPartOfCST(client)
        || bypassPBBProfile();
    }
    /**
     * exclude pbb profile on security checks
     * @return Boolean
     */
    public static Boolean bypassPBBProfile() {
        Profile pro = UTL_User.getUserProfile();
        return pro.Name == DMN_Profile.PERSONAL_BUSINESS_BANKING_CUSTOM_STD_USER_MOBILE;
    }
    /**
     * check if logged in user is part of cst 
     *
     * @param client
     * @return Boolean
     */
    public static Boolean isPartOfCST(Account client) {

        List<String> cstIds = new List<String>();
        List<Custom_Client_Team__c> cstMembers = [SELECT Id,Team_Member__c FROM Custom_Client_Team__c
                                                  WHERE Account__c =: client.Id];
        for(Custom_Client_Team__c member : cstMembers){
            cstIds.add(member.Team_Member__c);
        }

        if(cstIds.contains(UserInfo.getUserId())){ 
            return true;
        }
        else if(UserInfo.getUserId()==client.OwnerId){
            return true;
        }
        
        return false;
    }
    /**
     * Method fetches data for a specific client from two APIs: Proact risk and facilities API and Balance API
     * US-1008
     *
     * @param clientId client's id
     * @return wrapped response
     */
    @AuraEnabled
    public static DataWrapper fetchData(Id clientId) {

        Account account = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{
                clientId
        }).get(0);
        if (!isPermited(account)) {
            throw new ControllerException('unauthorized');
        }
        if (String.isBlank(account.GUID__c)) {
            throw new ControllerException('Unable to get data, client has no GUID specified');
        }

        DataWrapper dataWrapper = new DataWrapper();
        Exception balanceException, proactException;

        try {
            List<PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities> riskAndFacilitiesData = riskAndFacilitiesDataService.getData(account.GUID__c);
            if (riskAndFacilitiesData != null && riskAndFacilitiesData.size() > 0) {
                dataWrapper.riskAndFacilitiesData = new RiskAndFacilitiesDataWrapper(riskAndFacilitiesData);
            }
        } catch (Exception e) {
            dataWrapper.riskAndFacilitiesAPIReturnedError = true;
            proactException = e;
        }

        try {
            List<PBB_SRV_GatewayApi_AccountInformation.AccountBalances> balanceData = balanceDataService.getAccountsBalances(account.GUID__c);
            if (balanceData != null && balanceData.size() > 0) {
                dataWrapper.balanceData = new BalanceDataWrapper(balanceData);
            }
        } catch (Exception e) {
            balanceException = e;
            dataWrapper.balanceAPIReturnedError = true;
        }

        if (dataWrapper.riskAndFacilitiesAPIReturnedError || dataWrapper.balanceAPIReturnedError) {
            if (balanceException != null) {
                loggerService.log(balanceException, PBB_RiskAndFacilitiesController.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            }
            if (proactException != null) {
                loggerService.log(proactException, PBB_RiskAndFacilitiesController.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            }
        }

        return dataWrapper;
    }

    public class DataWrapper {
        @AuraEnabled public RiskAndFacilitiesDataWrapper riskAndFacilitiesData;
        @AuraEnabled public BalanceDataWrapper balanceData;
        @AuraEnabled public Boolean balanceAPIReturnedError;
        @AuraEnabled public Boolean riskAndFacilitiesAPIReturnedError;

        public DataWrapper() {
            balanceAPIReturnedError = false;
            riskAndFacilitiesAPIReturnedError = false;
        }
    }
    @TestVisible
    class BalanceDataWrapper {
        @AuraEnabled public Decimal totalExposure;
        @TestVisible
        BalanceDataWrapper(List<PBB_SRV_GatewayApi_AccountInformation.AccountBalances> accountsBalances) {
            setFields(accountsBalances);
        }
        @TestVisible
        void setFields(List<PBB_SRV_GatewayApi_AccountInformation.AccountBalances> accountsBalances) {
            if (accountsBalances == null || accountsBalances.isEmpty()) {
                return;
            }

            totalExposure = 0;
            for (PBB_SRV_GatewayApi_AccountInformation.AccountBalances accountBalances : accountsBalances) {
                for (PBB_SRV_GatewayApi_AccountInformation.AccountBalance accountBalance : accountBalances.balances) {
                    if (accountBalance.balanceType == ACTUAL_ACCOUNT_BALANCE_TYPE
                            && Decimal.valueOf(accountBalance.balance) < 0) {
                        totalExposure += Math.abs(Decimal.valueOf(accountBalance.balance));
                    }
                }
            }
        }
    }

    class RiskAndFacilitiesDataWrapper {
        @AuraEnabled public Decimal sumOfExpMonthlyCrTurn;
        @AuraEnabled public Decimal sumOfCurrentLimit;
        @AuraEnabled public Integer ERL1;
        @AuraEnabled public Decimal headroom;
        @AuraEnabled public Decimal totalDaysInExcess;
        @AuraEnabled public Decimal totalDaysInDishonours;
        @AuraEnabled public Integer ERI1;
        @AuraEnabled public Boolean judgementFlag;
        @AuraEnabled public Boolean directorJudgementFlag;
        @AuraEnabled public Boolean riskMonitoringFlag;

        public RiskAndFacilitiesDataWrapper(List<PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities> riskAndFacilitiesData) {
            setFields(riskAndFacilitiesData);
        }

        void setFields(List<PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities> riskAndFacilitiesData) {
            if (riskAndFacilitiesData == null || riskAndFacilitiesData.size() == 0) {
                return;
            }

            judgementFlag = riskAndFacilitiesData[0].JUDGEMENT_FLAG;
            directorJudgementFlag = riskAndFacilitiesData[0].DIRECTOR_JUDGEMENT_FLAG;
            headroom = !String.isBlank(riskAndFacilitiesData[0].HEADROOM) ? Decimal.valueOf(riskAndFacilitiesData[0].HEADROOM) : null;
            ERL1 = riskAndFacilitiesData[0].ERL1;
            ERI1 = riskAndFacilitiesData[0].ERI1;
            riskMonitoringFlag = !String.isBlank(riskAndFacilitiesData[0].RISK_MONITORING_TYPE) && !(riskAndFacilitiesData[0].RISK_MONITORING_TYPE.equalsIgnoreCase(WATCHLIST_FLAG));

            for (PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities accInfo : riskAndFacilitiesData) {
                if (String.isNotBlank(accInfo.EXP_MONTHLY_CR_TURN)) {
                    if (sumOfExpMonthlyCrTurn == null) {
                        sumOfExpMonthlyCrTurn = 0;
                    }
                    sumOfExpMonthlyCrTurn += Decimal.valueOf(accInfo.EXP_MONTHLY_CR_TURN);
                }
                if (accInfo.CURRENT_LIMIT != null) {
                    if (sumOfCurrentLimit == null) {
                        sumOfCurrentLimit = 0;
                    }
                    sumOfCurrentLimit += (Decimal) accInfo.CURRENT_LIMIT;
                }
                if (accInfo.DAYS_IN_EXCESS_L6M != null) {
                    if (totalDaysInExcess == null) {
                        totalDaysInExcess = 0;
                    }
                    totalDaysInExcess += (Decimal) accInfo.DAYS_IN_EXCESS_L6M;
                }
                if (accInfo.DAYS_DISHONOURS_L6M != null) {
                    if (totalDaysInDishonours == null) {
                        totalDaysInDishonours = 0;
                    }
                    totalDaysInDishonours += (Decimal) accInfo.DAYS_DISHONOURS_L6M;
                }
            }
        }
    }
}