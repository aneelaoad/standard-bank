/**
 * Controller class for PBB_Lifestyle_Transaction_Charts aura component.
 * The class retrieves data from Gateway API.
 * US-1463
 *
 * @author Maria Pszonka (mpszonka@deloittece.com)
 * @date August 2020
 */
public with sharing class PBB_Lifestyle_TransactionChartController {
    private static final SRV_Logger loggerService = (SRV_Logger) SRV_Logger.newInstance();
    private static final PBB_SRV_GatewayAPI_GetTransactions.IService transactionInfoService = PBB_SRV_GatewayAPI_GetTransactions.newInstance();

    /**
     * Method retrieves rollup transactions data from the gateway class and prepares it for the charts.
     * US-1463
     *
     * @param clientId: Client id for which the data will be retrieved.
     * @return list of rollup transactions prepared to be consumed by the charts or null if response was empty or error when unable to fetch information from API
     */
    @AuraEnabled
    public static List<RollUpTransaction> fetchRollUpTransactionsInfo(Id clientId) {
        try {
            Account account = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{
                clientId
            }).get(0);
    
            if (!PBB_RiskAndFacilitiesController.isPermited(account)) {
            throw new PBB_RiskAndFacilitiesController.ControllerException('unauthorized');
            }
            List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData> rollUpTransactions =
                    transactionInfoService.fetchRollUpTransactionsData(clientId);
            if (rollUpTransactions != null && !rollUpTransactions.isEmpty()) {
                return prepareRollUpTransactionsData(rollUpTransactions);
            }
            return null;
        } catch (Exception e) {
            loggerService.log(e, PBB_Lifestyle_TransactionChartController.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            throw e;
        }
    }

    /**
     * Method retrieves narrative transactions data from the gateway class and prepares it for the charts.
     * US-1463
     *
     * @param clientId: Client id for which the data will be retrieved.
     * @return list of narrative transactions prepared to be consumed by the charts or null if response was empty or error when unable to fetch information from API
     */
    @AuraEnabled
    public static NarrativeTransactions fetchNarrativeTransactionInfo(Id clientId) {
        try {
            Account account = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{
                clientId
            }).get(0);
    
            if (!PBB_RiskAndFacilitiesController.isPermited(account)) {
            throw new PBB_RiskAndFacilitiesController.ControllerException('unauthorized');
            }
            List<PBB_SRV_GatewayAPI_GetTransactions.NarrativeTransactionData>
                    narrativeTransactions = transactionInfoService.fetchNarrativeTransactionsData(clientId);
            if (narrativeTransactions != null && !narrativeTransactions.isEmpty()) {
                return prepareNarrativeTransactionsData(narrativeTransactions);
            }
            return null;
        } catch (Exception e) {
            loggerService.log(e, PBB_Lifestyle_TransactionChartController.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            throw e;
        }
    }

    /**
    * Method aggregates rollup transactions data firstly by period and then by Flag_Pos_Trans_Amt
    * US-1463
    *
    * @param  transactions: list of rollup transactios fetched from API
    * @return List<RollUpTransaction>: tranctions aggregated by period and Flag_Pos_Trans_Amt
    */
    private static List<RollUpTransaction> prepareRollUpTransactionsData(PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData[] transactions) {
        List<RollUpTransaction> rollUpTransactions = new List<RollUpTransaction>();

        for (PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData rollUpDetail : transactions) {
            if (!listContains(rollUpTransactions, rollUpDetail.Period)) {
                rollUpTransactions.addAll(aggregateByFlagPosTransAmt(filterByPeriod(rollUpDetail.Period, transactions)));
            }
        }

        return rollUpTransactions;
    }

    /**
    * Method parses narrative transactions data from PBB_SRV_GatewayAPI_GetTransactions.NarrativeTransactionData[] format to NarrativeTransactions class
    * US-1463
    *
    * @param  transactions: list of narrative transactios fetched from API
    * @return NarrativeTransactions: tranctions prepared to be consumed by the charts
    */
    private static NarrativeTransactions prepareNarrativeTransactionsData(PBB_SRV_GatewayAPI_GetTransactions.NarrativeTransactionData[] transactions) {
        List<InflowTransaction> inflowTransactions = new List<InflowTransaction>();
        List<OutflowTransaction> outflowTransactions = new List<OutflowTransaction>();

        for (PBB_SRV_GatewayAPI_GetTransactions.NarrativeTransactionData narrativeDetail : transactions) {
            if (narrativeDetail.Debtor_Creditor_Amount < 0) {
                outflowTransactions.add(new OutflowTransaction(narrativeDetail.Debtor_Creditor_Count, narrativeDetail.Debtor_Creditor, Math.abs(narrativeDetail.Debtor_Creditor_Amount)));
            } else {
                inflowTransactions.add(new InflowTransaction(narrativeDetail.Debtor_Creditor_Count, narrativeDetail.Debtor_Creditor, Math.abs(narrativeDetail.Debtor_Creditor_Amount)));
            }
        }

        return new NarrativeTransactions(inflowTransactions, outflowTransactions);
    }

    private static List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData> filterByPeriod(String period, List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData> rollupTransactions) {
        List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData> filteredRollupTransactions = new List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData>();

        for (PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData rollUpTransaction : rollupTransactions) {
            if (rollUpTransaction.Period == period) {
                filteredRollupTransactions.add(rollUpTransaction);
            }
        }

        return filteredRollupTransactions;
    }

    private static List<RollUpTransaction> aggregateByFlagPosTransAmt(List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData> rollupTransactions) {
        String period = rollupTransactions[0].Period;
        RollUpTransaction aggregatedInflowTransaction = new RollUpTransaction(period, 1);
        RollupTransaction aggregatedOutflowTransaction = new RollUpTransaction(period, 0);

        for (PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData rollUpTransaction : rollupTransactions) {
            if (rollUpTransaction.Flag_Pos_Trans_Amt == 1) {
                aggregatedInflowTransaction.accountBalance += rollUpTransaction.Account_Balance;
                aggregatedInflowTransaction.accountODLimit += rollUpTransaction.Account_OD_Limit;
                aggregatedInflowTransaction.transactionAmount += rollUpTransaction.Transaction_Amount;
                aggregatedInflowTransaction.transactionCount += rollUpTransaction.Transaction_Count;

            } else {
                aggregatedOutflowTransaction.accountBalance += rollUpTransaction.Account_Balance;
                aggregatedOutflowTransaction.accountODLimit += rollUpTransaction.Account_OD_Limit;
                aggregatedOutflowTransaction.transactionAmount += rollUpTransaction.Transaction_Amount;
                aggregatedOutflowTransaction.transactionCount += rollUpTransaction.Transaction_Count;
            }
        }

        List<RollUpTransaction> aggregatedRollupTransactions = new List<RollUpTransaction>();
        aggregatedRollupTransactions.add(aggregatedOutflowTransaction);
        aggregatedRollupTransactions.add(aggregatedInflowTransaction);
        return aggregatedRollupTransactions;
    }

    private static Boolean listContains(List<RollUpTransaction> rollUpTransactions, String period) {
        for (RollUpTransaction trans : rollUpTransactions) {
            if (trans.period == period) {
                return true;
            }
        }
        return false;
    }

    public class RollUpTransaction {
        @AuraEnabled
        public String period;
        @AuraEnabled
        public Integer transactionCount;
        @AuraEnabled
        public Decimal accountODLimit;
        @AuraEnabled
        public Integer flagPosTransAmt;
        @AuraEnabled
        public Decimal accountBalance;
        @AuraEnabled
        public String accountType;
        @AuraEnabled
        public Decimal transactionAmount;

        public RollUpTransaction(String period, Integer flagPosTransAmt) {
            this.period = period;
            this.flagPosTransAmt = flagPosTransAmt;
            this.accountBalance = 0;
            this.accountODLimit = 0;
            this.transactionAmount = 0;
            this.transactionCount = 0;
        }

        public RollUpTransaction(Decimal accountBalance, Decimal accountODLimit, Integer flagPosTransAmt, String period, Decimal transactionAmount, Integer transactionCount) {
            this.period = period;
            this.flagPosTransAmt = flagPosTransAmt;
            this.accountBalance = accountBalance;
            this.accountODLimit = accountODLimit;
            this.transactionAmount = transactionAmount;
            this.transactionCount = transactionCount;
        }
    }

    public class NarrativeTransactions {
        @AuraEnabled
        public InflowTransaction[] inflowTransactions;
        @AuraEnabled
        public OutflowTransaction[] outflowTransactions;

        public NarrativeTransactions(InflowTransaction[] inflowTransactions, OutflowTransaction[] outflowTransactions) {
            this.inflowTransactions = inflowTransactions;
            this.outflowTransactions = outflowTransactions;
        }
    }

    public class InflowTransaction {
        @AuraEnabled
        public Decimal transactionCount;
        @AuraEnabled
        public String creditor;
        @AuraEnabled
        public Decimal transactionAmount;

        public InflowTransaction(Decimal transactionCount, String creditor, Decimal transactionAmount) {
            this.transactionCount = transactionCount;
            this.creditor = creditor;
            this.transactionAmount = transactionAmount;
        }
    }

    public class OutflowTransaction {
        @AuraEnabled
        public Decimal transactionCount;
        @AuraEnabled
        public String debtor;
        @AuraEnabled
        public Decimal transactionAmount;

        public OutflowTransaction(Decimal transactionCount, String debtor, Decimal transactionAmount) {
            this.transactionCount = transactionCount;
            this.debtor = debtor;
            this.transactionAmount = transactionAmount;
        }
    }
}