/**
 * @description US-4418 The class validates values added to Product and recalculates Revenue Values on Product
 * @author jmilosz@deloittece.com
 * @date Jan 2020
 * 
 * @last modified by  : Augustine Chirombo
 * @last modified on  : Sep 13, 2023
 * @modification description : Change the static reference of Record types to new labels 
 * 
 * @last modified by  : Augustine Chirombo
 * @last modified on  : Nov 14, 2023
 * @modification description : Change the field references of Profit Centre Field to Franchise Country
 *
 * @last modified by  : Maksim Dzianisik
 * @last modified on  : Feb 2024
 * @modification description : SFP-35396 added additional checking to the populateProfitCenterCountry(...)
 *
 * @last modified by  : Maksim Dzianisik
 * @last modified on  : Apr 2024
 * @description       : SFP-37196 added logic to prepopulate Non_Advisory_IB_Fees_Product__c and Risk_Weighted_Value__c
 *                      from Product2 record
 * 
 * @last modified by  : Maksim Dzianisik
 * @last modified on  : Apr 2024
 * @description       : SFP-38424 fixed ERS calculation
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class DMN_SB_Product extends fflib_SObjectDomain{

    public static final String GPP_CASH_MANAGEMENT = 'Cash Management';
    public static final String GPP_INVESTOR_SERVICES = 'Investor Services';
    public static final String GPP_LOANS = 'Loans';
    public static final String GPP_EQUITY_FINANCE = 'Equity Finance';
    public static final String GPP_ADVISORY_FEES = 'Advisory Fees';
    public static final String PP_GUARANTEES = 'Guarantees';
    public static final String OBJ_NAME = SB_Product__c.SObjectType.getDescribe().getName();
    public static final String RT_ADVISORY = 'Advisory';
    public static final String RT_CAPITAL_MARKETS = 'Capital_Markets';
    public static final String RT_COMMB_LENDING = 'CommB_Lending';
    public static final String RT_COMMB = 'Commercial_Banking';
    public static final String RT_LENDING_COMMIT = 'Lending_Deposits';
    public static final String RT_PRIM_ARRANGE_ADV = 'Primary_Arranging_Advisory';
    public static final String RT_SINGLE_RISK = 'CIBGM_Single_Risk';
    public static final String RT_MULTI_RISK = 'CIBGM_Multi_Risk';
    public static final String RT_TRANSACTIONAL_2014 = 'Transactional_New';
    public static final String RT_TRANSACTIONAL_LEGACY = 'Transactional';
    public static final String RT_INSURANCE = 'Insurance';
    public static final String RT_TPS2022 = 'TPS_2022';
    public static final String FREQ_ONCE_OFF = 'Once off';
    public static final String FREQ_MONTHLY = 'Monthly';
    public static final String FREQ_QUARTERLY = 'Quarterly';
    public static final String FREQ_ANNUAL = 'Annual';
    public static final String FREQ_BIANNUAL = 'Bi-annual';

    public static final Set<Id> CIB_RECORDTYPE_IDS = new Set<Id>{
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_PRIM_ARRANGE_ADV),
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SINGLE_RISK),
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_TRANSACTIONAL_2014),
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CAPITAL_MARKETS),
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_LENDING_COMMIT),
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_MULTI_RISK),
            UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_TPS2022)
    };

    private static Boolean isFirstTimeTrigger = true;
    private static Boolean isNotYetValidated = true;
    @TestVisible private final static String ERROR = 'You cannot add or make changes to a Product on an Opportunity that is in Closed - Lost or Cancel stages.';


    /**
     * @description class for constructing SB_Product__c Domain instance
     *
     * @author Konrad Bruszewski
     * @date june 2021
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {

        /**
         * @description Constructs and returns new DMN_SB_Product instance with given records
         *
         * @param records
         * @return New DMN_SB_Product instance
         */
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new DMN_SB_Product(records);
        }
    }

    /**
     * @description DMN_SB_Product constructor
     *
     * @param records - set of records on which domain will be performing operations
     */
    public DMN_SB_Product(List<SObject> records) {
        super(records);
    }

    /**
	 * @description Method to validate parent Opportunity
	 *
	 * @param products List of updated Product records.
	 * @param id2OldRecords Map of old Product records before the update.
	 */
    public static void validateOpportunity (SB_Product__c[] products, Map<Id, SB_Product__c> id2OldRecords) {
        Set<Id> parentsIds = new Set<Id>();
        for (SB_Product__c prod : products){
            parentsIds.add(prod.Opportunity__c);
        }
        Map<Id, Opportunity> parentOpps = new Map<Id, Opportunity>([SELECT Id, StageName, IsClosed, IsWon FROM Opportunity WHERE Id IN :parentsIds]);
        if (!isNotYetValidated || parentOpps.isEmpty()) {
            return;
        }
        for (SB_Product__c prod : products){
            Opportunity opp = parentOpps.get(prod.Opportunity__c);
            if (opp.StageName == DMN_Opportunity.ST_CLOSED_CANCEL ||
                    opp.StageName == DMN_Opportunity.ST_CLOSED_LOST   ) {
                if (id2OldRecords != null && id2OldRecords.get(prod.Id).ExchangeRate__c == prod.ExchangeRate__c) {
                    prod.Opportunity__c.addError(ERROR); 
                } else if (id2OldRecords == null) {
                    prod.Opportunity__c.addError(ERROR); 
                }
            }

        }
        isNotYetValidated = false;
    }

    /**
	 * @description Method to calculate exchange rates
	 *
	 * @param products List of inserted Product records.
	 * @return List<SB_Product__c> List of Product records to be updated.
	 */
    public static List<SB_Product__c> calculateExchangeRate (SB_Product__c[] products) {

        List<CurrencyType> conversion = new List<CurrencyType>([SELECT ConversionRate, IsoCode FROM CurrencyType]);
        Map<String, Decimal> isoCode2CurrencyType = new Map<String, Decimal>();
        for (CurrencyType curType : conversion){
            isoCode2CurrencyType.put(curType.IsoCode, curType.ConversionRate);
        }
        List<SB_Product__c> productsToUpdate = new List<SB_Product__c>();

        for (SB_Product__c prod : products){
            if (prod.ExchangeRate__c != isoCode2CurrencyType.get(prod.CurrencyIsoCode)) {
                prod.ExchangeRate__c = isoCode2CurrencyType.get(prod.CurrencyIsoCode);
                productsToUpdate.add(prod);
            }
        }
        return productsToUpdate;
    }

    /**
	 * @description Method to recalculate exchange rates
	 *
	 * @param products List of updated Product records.
	 * @param id2OldRecords Map of Id to Product records before update.
	 */
    public static void recalculateExchangeRate (SB_Product__c[] products, Map<Id, SB_Product__c> id2OldRecords) {
        Set<Id> parentsIds = new Set<Id>();
        List<SB_Product__c> siblingProductsToProcess = new List<SB_Product__c>();
        for (SB_Product__c prod : products){
            parentsIds.add(prod.Opportunity__c);
        }
        Map<Id, Opportunity> parentOpps = new Map<Id, Opportunity>([
                SELECT StageName,
                        IsClosed,
                        IsWon,
                (SELECT ExchangeRate__c, CurrencyIsoCode FROM Products__r)
                FROM Opportunity
                WHERE Id IN :parentsIds]);
        if (isFirstTimeTrigger) {
            isFirstTimeTrigger = false;
            for (SB_Product__c prod : products){
                Opportunity opp = parentOpps.get(prod.Opportunity__c);
                if (prod.Opportunity__c == opp.Id) {
                    if (!opp.IsClosed) {
                        siblingProductsToProcess.addAll(opp.Products__r);
                    }
                }
            }
        }

        if (!siblingProductsToProcess.isEmpty()) {
            List<SB_Product__c> prds = calculateExchangeRate(siblingProductsToProcess);
            update prds;
        }

    }

    /**
     * @description Method to process SB Product records and create related estimated revenue schedule records accordingly.
     * SGPRT-1937 - Revenue Forecasting: Updated calculation of Fee Amount
     * 
     * @param id2OldRecords Map of old SB_Product records before the update.
     * @param newRecords List of updated SB_Product records.
     */
    public static void updateEstimatedRevenueSchedule(Map<Id, SB_Product__c> id2OldRecords, List<SB_Product__c> newRecords) {

        Map<Id, SB_Product__c> id2ProductsToProcess = new Map<Id, SB_Product__c>();
        Set<Id> relatedOppsIds = new Set<Id>();
        for (Integer i = 0; i < newRecords.size(); i++) {
            relatedOppsIds.add(newRecords[i].Opportunity__c);
        }
        Map<Id, Opportunity> relatedOpps = new Map<Id, Opportunity>([
                SELECT Id, Actual_Close_Date__c, StageName
                FROM Opportunity
                WHERE Id IN :relatedOppsIds
        ]);

        for (Integer i = 0; i < newRecords.size(); i++) {
            if (shouldCalculateERS(newRecords[i], id2OldRecords.get(newRecords[i].Id), relatedOpps.get(newRecords[i].Opportunity__c))) {
                id2ProductsToProcess.put(newRecords[i].Id, newRecords[i]);
            }
        }

        if (id2ProductsToProcess.keySet().size() == 0) {
            return ;
        }
        if (!System.isBatch()){
            createEstimatedRevenueSchedule(id2ProductsToProcess.keySet());
        }
    }

    /** 
     * @description Future method to update (delete and insert) estimated revenue schedule records.
     * SGPRT-1937 - Revenue Forecasting: Updated calculation of Fee Amount
     * 
     * @param productIds Set of SB_Product Ids for which estimated revenue schedule records will be created.
     */
    @Future
    public static void createEstimatedRevenueSchedule(Set<Id> productIds) {

        Set<Id> cibRecordTypeIds = new Set<Id>{
                UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME, DMN_EstimatedRevenueSchedule.RT_ESR_NII_NIR),
                UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME, DMN_EstimatedRevenueSchedule.RT_ESR_NIR)

        };

        List<Estimated_Revenue_Schedule__c> relatedErs = [
                SELECT Id
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c IN :productIds
                AND RecordTypeId IN :cibRecordTypeIds
        ];
        if (relatedErs.size() > 0) {
            delete relatedErs;
        }

        List<SB_Product__c> prodsToProcess = [
                SELECT
                        Id, Opportunity__r.StageName,
                        Opportunity__r.CloseDate,
                        Opportunity__r.Actual_Close_Date__c,
                        Term_Tenor__c, CurrencyIsoCode,
                        Total_Fees__c, RecordTypeId,
                        Finance_Approved_Fee_Recognition__c,
                        Client__r.Client_Sector__c,Earliest_Draw_Date_Rollup__c,
                        Product_Division__c,RecordType.Name
                FROM SB_Product__c
                WHERE Id IN :productIds
                AND RecordTypeId IN :CIB_RECORDTYPE_IDS
        ];

        Id nirRecordTypeId = UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME,
                DMN_EstimatedRevenueSchedule.RT_ESR_NIR);
        Id niiNirRecordTypeId = UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME,
                DMN_EstimatedRevenueSchedule.RT_ESR_NII_NIR);

        Map<Id, List<Id>> esrRtId2ProdRtdIds = new Map<Id, List<Id>>{
                nirRecordTypeId => new List<Id>{
                        UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_PRIM_ARRANGE_ADV),
                        UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SINGLE_RISK),
                        UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_TRANSACTIONAL_2014)
                },
                niiNirRecordTypeId => new List<Id>{
                        UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CAPITAL_MARKETS),
                        UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_LENDING_COMMIT),
                        UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_MULTI_RISK),
                        UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SINGLE_RISK),
                        UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_TPS2022)
                }
        };

        Date oppDate = System.today();
        Decimal feeAmount = 0.0;
        List<Estimated_Revenue_Schedule__c> esrsToInsert = new List<Estimated_Revenue_Schedule__c>();

        for (Integer i = 0; i < prodsToProcess.size(); i++) {
            SB_Product__c prod = prodsToProcess[i];
            oppDate =
                    prod.Opportunity__r.StageName == DMN_Opportunity.ST_DEVELOP || prod.Opportunity__r.StageName == DMN_Opportunity.ST_LEAD ?
                            prod.Opportunity__r.CloseDate :
                            prod.Opportunity__r.StageName == DMN_Opportunity.ST_CLOSED_WON ?
                                    prod.Opportunity__r.Actual_Close_Date__c :
                                    null;
            //SFP-16242: If product Division is IB then Draw Date is used for ERS calculations
            Date dtIBProductDate = prod.Product_Division__c == 'Investment Banking' && prod.RecordType.Name == 'Lending and Commitments' ?
                    prod.Earliest_Draw_Date_Rollup__c : NULL ;
            
            //SFP-38424 Prod incident with x2 ERS
            Boolean needErsBasedOnOpp = true;
            if (dtIBProductDate != null && (prod.Total_Fees__c == null || prod.Total_Fees__c == 0)) {
                needErsBasedOnOpp = false;
            }

            //SFP-16242

            if (prod.Term_Tenor__c != null && oppDate != null) {
                if (prod.Term_Tenor__c > 1) {
                    if(needErsBasedOnOpp && prod.Finance_Approved_Fee_Recognition__c != null && prod.Finance_Approved_Fee_Recognition__c != 0) {
                        oppDate = oppDate.addDays(1);
                        feeAmount = (prod.Total_Fees__c != null && prod.Finance_Approved_Fee_Recognition__c != null) ?
                                prod.Total_Fees__c * (prod.Finance_Approved_Fee_Recognition__c / 100) : 0;
                        esrsToInsert.add(
                                new Estimated_Revenue_Schedule__c(
                                        Fee_Amount__c = feeAmount,
                                        Estimated_Revenue_Date__c = oppDate,
                                        Product__c = prod.Id,
                                        CurrencyIsoCode = prod.CurrencyIsoCode,
                                        Updated_by_LEX__c = false,
                                        RecordTypeId = esrRtId2ProdRtdIds.get(nirRecordTypeId)
                                                .contains(prod.RecordTypeId) ? nirRecordTypeId : niiNirRecordTypeId
                                )
                        );
                    }

                    //SFP-16242: creating additional ERS record for IB Division products
                    if(dtIBProductDate != null)
                    {
                        dtIBProductDate = dtIBProductDate.addDays(1);
                        esrsToInsert.add(
                                new Estimated_Revenue_Schedule__c(
                                        Fee_Amount__c = 0,
                                        Estimated_Revenue_Date__c = dtIBProductDate,
                                        Product__c = prod.Id,
                                        CurrencyIsoCode = prod.CurrencyIsoCode,
                                        Updated_by_LEX__c = false,
                                        RecordTypeId = esrRtId2ProdRtdIds.get(nirRecordTypeId)
                                                .contains(prod.RecordTypeId) ? nirRecordTypeId : niiNirRecordTypeId
                                )
                        );
                    }
                    //SFP-16242: Modification Ends

                    feeAmount = prod.Total_Fees__c != null ? (prod.Total_Fees__c - feeAmount) / (prod.Term_Tenor__c - 1) : 0;
                    Integer y = (Integer) prod.Term_Tenor__c; 
                    for (Integer x = 1; x < y; x++) {
                        if (needErsBasedOnOpp) {
                            oppDate = oppDate.addMonths(1);
                            esrsToInsert.add(
                                    new Estimated_Revenue_Schedule__c(
                                            Fee_Amount__c = feeAmount,
                                            Estimated_Revenue_Date__c = oppDate,
                                            Product__c = prod.Id,
                                            CurrencyIsoCode = prod.CurrencyIsoCode,
                                            Updated_by_LEX__c = false,
                                            RecordTypeId = esrRtId2ProdRtdIds.get(nirRecordTypeId)
                                                    .contains(prod.RecordTypeId) ? nirRecordTypeId : niiNirRecordTypeId
                                    )
                            );
                        }
                        //SFP-16242: Creating additional ERS record for IB division
                        if(dtIBProductDate != null)
                        {
                            dtIBProductDate = dtIBProductDate.addMonths(1);
                            esrsToInsert.add(
                                    new Estimated_Revenue_Schedule__c(
                                            Fee_Amount__c = 0,
                                            Estimated_Revenue_Date__c = dtIBProductDate,
                                            Product__c = prod.Id,
                                            CurrencyIsoCode = prod.CurrencyIsoCode,
                                            Updated_by_LEX__c = false,
                                            RecordTypeId = esrRtId2ProdRtdIds.get(nirRecordTypeId)
                                                    .contains(prod.RecordTypeId) ? nirRecordTypeId : niiNirRecordTypeId
                                    )
                            );
                        }
                        //SFP-16242: Modification Ends
                    }
                } else if (prod.Term_Tenor__c == 1){
                    if (needErsBasedOnOpp) {
                        esrsToInsert.add(
                                new Estimated_Revenue_Schedule__c(
                                        Fee_Amount__c = prod.Total_Fees__c,
                                        Estimated_Revenue_Date__c = oppDate.addDays(1),
                                        Product__c = prod.Id,
                                        CurrencyIsoCode = prod.CurrencyIsoCode,
                                        Updated_by_LEX__c = false,
                                        RecordTypeId = esrRtId2ProdRtdIds.get(nirRecordTypeId)
                                                .contains(prod.RecordTypeId) ? nirRecordTypeId : niiNirRecordTypeId
                                )
                        );
                    }

                    //SFP-16242: ERS Changes
                    if(dtIBProductDate != null)
                    {
                        esrsToInsert.add(
                                new Estimated_Revenue_Schedule__c(
                                        Fee_Amount__c = 0,
                                        Estimated_Revenue_Date__c = dtIBProductDate.addDays(1),
                                        Product__c = prod.Id,
                                        CurrencyIsoCode = prod.CurrencyIsoCode,
                                        Updated_by_LEX__c = false,
                                        RecordTypeId = esrRtId2ProdRtdIds.get(nirRecordTypeId)
                                                .contains(prod.RecordTypeId) ? nirRecordTypeId : niiNirRecordTypeId
                                )
                        );
                    }
                    //SFP-16242: Modification Ends
                }
            }
        }
        if (esrsToInsert.size() > 0) {
            insert esrsToInsert;
        }
    }

    /** 
     * @description Method to calculate the CY Fees and CY Margin upon insert/update.
     * SGPRT-2153 - Revenue Forecasting: Update of CY Fees and CY Margin
     * 
     * @param products List of SB_Product records to be inserted/updated.
     * @param id2OldProducts Map of old SB_Product records before the update.
     */
    public static void calculateCYFeesAndMargin(List<SB_Product__c> products, Map<Id, SB_Product__c> id2OldProducts) {
        Map<Integer, Decimal> year2EsrMarginAmount = new Map<Integer, Decimal>();
        Map<Integer, Decimal> year2EsrFeeAmount = new Map<Integer, Decimal>();
        Date oppDate = System.today();
        Decimal feeAmount = 0.0;
        Decimal totalFeeAmount = 0.0;
        Decimal totalMarginAmount = 0.0;
        Decimal totalMargin = 0.0;

        Set<Id> oppIds = new Set<Id>();

        for (Integer i = 0; i < products.size(); i++) {
            oppIds.add(products[i].Opportunity__c);
        }

        Map<Id, Opportunity> relatedOpps = new Map<Id, Opportunity>();
        if (!oppIds.isEmpty()) {
            relatedOpps = new Map<Id, Opportunity>([
                    SELECT StageName,
                            CloseDate,
                            Actual_Close_Date__c
                    FROM Opportunity
                    WHERE Id IN :oppIds
            ]);
        }
        //List to store Product ID's
        List<ID> listProductIds = new List<ID>();

        List<SB_Product__c> prodsToProcess = new List<SB_Product__c>();
        for (Integer i = 0; i < products.size(); i++) {
            if (isCibRecordType(products[i].RecordTypeId)
                    && (id2OldProducts == null
                    || shouldCalculateERS(products[i],
                    id2OldProducts.get(products[i].Id),
                    relatedOpps.get(products[i].Opportunity__c)))) {
                prodsToProcess.add(products[i]);
                listProductIds.add(products[i].Id);
            }
        }

        //SFP-16242: ERS Calculation changes if product division is IB
        Map<Object,Object> mapDrawDatesByProductIDs = new Map<Object,Object>();
        if(!listProductIds.isEmpty()) {
            AggregateResult[] listDrawDownProfileRecords = [SELECT Product__c, MIN(Draw_Date__c)Draw_Date__c
            FROM Draw_Down_Profile__c
            WHERE Product__c IN : listProductIds
            GROUP BY Product__c];
            for(AggregateResult objDrawProfile : listDrawDownProfileRecords) {
                mapDrawDatesByProductIDs.put(objDrawProfile.get('Product__c'),objDrawProfile.get('Draw_Date__c'));
            }
        }

        for (Integer i = 0; i < prodsToProcess.size(); i++) {
            SB_Product__c prod = prodsToProcess[i];
            oppDate =
                    relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_DEVELOP ||
                            relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_LEAD ?
                            relatedOpps.get(prod.Opportunity__c).CloseDate :
                            relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_CLOSED_WON ?
                                    relatedOpps.get(prod.Opportunity__c).Actual_Close_Date__c :
                                    null;
            //SFP-16242: ERS Calculation changes if product division is IB
            Date dtIBProductMarginDate;
            if(prod.RecordType.Name == 'Lending and Commitments' && prod.Product_Division__c == 'Investment Banking' && !mapDrawDatesByProductIDs.isEmpty()) {
                dtIBProductMarginDate = mapDrawDatesByProductIDs.get(prod.Id) != NULL ? Date.ValueOf(mapDrawDatesByProductIDs.get(prod.Id)) : NULL;
            }

            if (prod.Term_Tenor__c != null && oppDate != null) {
                if (prod.Term_Tenor__c > 1) {
                    oppDate = oppDate.addDays(1);
                    totalMargin = prod.Total_Margin__c == null ? 0 : prod.Total_Margin__c;

                    if(dtIBProductMarginDate != Null) {
                        dtIBProductMarginDate = dtIBProductMarginDate.addDays(1);
                        year2EsrMarginAmount.put(dtIBProductMarginDate.year(), totalMargin / prod.Term_Tenor__c);
                    }
                    else {
                        year2EsrMarginAmount.put(oppDate.year(), totalMargin / prod.Term_Tenor__c);
                    }
                    feeAmount = (prod.Total_Fees__c != null && prod.Finance_Approved_Fee_Recognition__c != null) ?
                            prod.Total_Fees__c * (prod.Finance_Approved_Fee_Recognition__c / 100) : 0;
                    year2EsrFeeAmount.put(oppDate.year(), feeAmount);

                    feeAmount = prod.Total_Fees__c != null ? (prod.Total_Fees__c - feeAmount) / (prod.Term_Tenor__c - 1) : 0;
                    Integer y = (Integer) prod.Term_Tenor__c;
                    for (Integer x = 1; x < y; x++) {
                        oppDate = oppDate.addMonths(1);
                        totalFeeAmount = year2EsrFeeAmount.get(oppDate.year()) != null ? year2EsrFeeAmount.get(oppDate.year()) + feeAmount : feeAmount;
                        year2EsrFeeAmount.put(oppDate.year(), totalFeeAmount);
                        totalMargin = prod.Total_Margin__c == null ? 0 : prod.Total_Margin__c;
                        if(dtIBProductMarginDate != Null) {
                            dtIBProductMarginDate = dtIBProductMarginDate.addMonths(1);
                            totalMarginAmount = year2EsrMarginAmount.get(dtIBProductMarginDate.year()) != null ? year2EsrMarginAmount.get(dtIBProductMarginDate.year()) + (totalMargin / prod.Term_Tenor__c) : (totalMargin / prod.Term_Tenor__c);
                            year2EsrMarginAmount.put(dtIBProductMarginDate.year(), totalMarginAmount);
                        }
                        else {
                            totalMarginAmount = year2EsrMarginAmount.get(oppDate.year()) != null ? year2EsrMarginAmount.get(oppDate.year()) + (totalMargin / prod.Term_Tenor__c) : (totalMargin / prod.Term_Tenor__c);
                            year2EsrMarginAmount.put(oppDate.year(), totalMarginAmount);
                        }
                    }
                    if (relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_DEVELOP || relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_LEAD) {
                        prod.Current_Year_Margin__c = year2EsrMarginAmount.get(System.today().year()) == null ? 0.0 : year2EsrMarginAmount.get(System.today().year());
                        prod.Current_Year_Fees__c = year2EsrFeeAmount.get(System.today().year()) == null ? 0.0 : year2EsrFeeAmount.get(System.today().year());
                    } else if (relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_CLOSED_WON) {
                        Integer currentYearOpp = relatedOpps.get(prod.Opportunity__c).Actual_Close_Date__c.year();
                        if(dtIBProductMarginDate != Null) {
                            Integer intCurrentYearMargin = System.today().year();
                            prod.Current_Year_Margin__c = year2EsrMarginAmount.get(intCurrentYearMargin) == null ? 0.0 : year2EsrMarginAmount.get(intCurrentYearMargin);
                        }
                        else {
                            prod.Current_Year_Margin__c = year2EsrMarginAmount.get(currentYearOpp) == null ? 0.0 : year2EsrMarginAmount.get(currentYearOpp);
                        }
                        prod.Current_Year_Fees__c = year2EsrFeeAmount.get(currentYearOpp) == null ? 0.0 : year2EsrFeeAmount.get(currentYearOpp);
                    }
                } else if (prod.Term_Tenor__c == 1){
                    oppDate = oppDate.addDays(1);
                    totalMargin = prod.Total_Margin__c == null ? 0 : prod.Total_Margin__c;
                    if(dtIBProductMarginDate != Null) {
                        dtIBProductMarginDate = dtIBProductMarginDate.addDays(1);
                        year2EsrMarginAmount.put(dtIBProductMarginDate.year(), totalMargin / prod.Term_Tenor__c);
                    }
                    else {
                        year2EsrMarginAmount.put(oppDate.year(), totalMargin / prod.Term_Tenor__c);
                    }
                    feeAmount = prod.Total_Fees__c;
                    year2EsrFeeAmount.put(oppDate.year(), feeAmount);
                    if (relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_DEVELOP || relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_LEAD) {
                        prod.Current_Year_Margin__c = year2EsrMarginAmount.get(System.today().year()) == null ? 0.0 : year2EsrMarginAmount.get(System.today().year());
                        prod.Current_Year_Fees__c = year2EsrFeeAmount.get(System.today().year()) == null ? 0.0 : year2EsrFeeAmount.get(System.today().year());
                    } else if (relatedOpps.get(prod.Opportunity__c).StageName == DMN_Opportunity.ST_CLOSED_WON) {
                        Integer currentYearOpp = relatedOpps.get(prod.Opportunity__c).Actual_Close_Date__c.year();
                        if(dtIBProductMarginDate != Null) {
                            Integer intCurrentYearMargin = System.today().year();
                            prod.Current_Year_Margin__c = year2EsrMarginAmount.get(intCurrentYearMargin) == null ? 0.0 : year2EsrMarginAmount.get(intCurrentYearMargin);
                        }
                        else {
                            prod.Current_Year_Margin__c = year2EsrMarginAmount.get(currentYearOpp) == null ? 0.0 : year2EsrMarginAmount.get(currentYearOpp);
                        }
                        prod.Current_Year_Fees__c = year2EsrFeeAmount.get(currentYearOpp) == null ? 0.0 : year2EsrFeeAmount.get(currentYearOpp);
                    }
                }
            }
            year2EsrFeeAmount.clear();
            year2EsrMarginAmount.clear();
        }
    }

    /**
     * @description Method to default Finance Approved Fee Recognition based on Client Sector value on Product Insert.
     * SGPRT-1703 - Revenue Forecasting: Creation of new product revenue fields
     * 
     * @param products SB_Products to be Inserted. 
     */
    public static void defaultFinanceApprovedFeeRecognition(List<SB_Product__c> products) {
        Set<Id> relatedAccountIds = new Set<Id>();
        List<SB_Product__c> productsToProcess = new List<SB_Product__c>();

        for (Integer i = 0; i < products.size(); i++) {
            if (isCibRecordType(products[i].RecordTypeId)) {
                productsToProcess.add(products[i]);
                relatedAccountIds.add(products[i].Client__c);
            }
        }

        if (relatedAccountIds.size() == 0 || productsToProcess.size() == 0) {
            return;
        }

        Map<Id, Account> relateId2AccountsMap = new Map<Id, Account>([
                SELECT Client_Sector__c
                FROM Account
                WHERE Id IN :relatedAccountIds
        ]);

        setFinanceApprovedFeeRecognition(productsToProcess, relateId2AccountsMap);
    }

    /**
     * @description Method to default Finance Approved Fee Recognition based on Client Sector value
     * (Helper method and used in other DMN classes).
     * SGPRT-1703 - Revenue Forecasting: Creation of new product revenue fields
     * 
     * @param products List of SB_Product records to be inserted/updated.
     * @param id2AccountMap Map of Account records related to the products.
     */
    public static void setFinanceApprovedFeeRecognition(List<SB_Product__c> products, Map<Id, Account> id2AccountMap) {

        List<Product_Fee_Rec_Client_Sector_Map__c> mappingCustomSetting = Product_Fee_Rec_Client_Sector_Map__c.getAll().values();

        Map<String, Double> clientSector2Percents = new Map<String, Double>();

        for (Product_Fee_Rec_Client_Sector_Map__c mapping : mappingCustomSetting) {
            clientSector2Percents.put(mapping.Client_Sector__c, mapping.Product_Total_Revenue_Percentage__c);
        }

        for (Integer i = 0; i < products.size(); i++) {
            if (products[i].Grand_Parent_Product__c == GPP_CASH_MANAGEMENT
                    || products[i].Grand_Parent_Product__c == GPP_INVESTOR_SERVICES
                    || products[i].Parent_Product__c == PP_GUARANTEES) {
                products[i].Finance_Approved_Fee_Recognition__c = 1 / (products[i].Term_Tenor__c) * 100;
            } else if (products[i].Grand_Parent_Product__c == GPP_LOANS
                    || products[i].Grand_Parent_Product__c == GPP_EQUITY_FINANCE) {
                if (id2AccountMap.get(products[i].Client__c).Client_Sector__c == null
                        || id2AccountMap.get(products[i].Client__c).Client_Sector__c == '') {
                    products[i].Finance_Approved_Fee_Recognition__c = clientSector2Percents.get(DMN_Account.UNKNOWN_SECTOR);
                } else {
                    products[i].Finance_Approved_Fee_Recognition__c = id2AccountMap.get(products[i].Client__c) != null ?
                            clientSector2Percents.get(id2AccountMap.get(products[i].Client__c).Client_Sector__c) : 0;
                }
            } else {
                products[i].Finance_Approved_Fee_Recognition__c = 100;
            }
        }

    }

    private static Boolean shouldCalculateERS(SB_Product__c newProd, SB_Product__c oldProd, Opportunity opp) {
        return ((newProd!= null && oldProd != null && opp != null)
                && (((opp.StageName != null && opp.StageName == DMN_Opportunity.ST_CLOSED_WON
                && opp.Actual_Close_Date__c != null
                && opp.Actual_Close_Date__c.year() == System.today().year())
                || opp.StageName != null && (opp.StageName == DMN_Opportunity.ST_DEVELOP || opp.StageName == DMN_Opportunity.ST_LEAD))
                && ((newProd.Term_Tenor__c != null && oldProd.Term_Tenor__c != null
                && newProd.Term_Tenor__c != oldProd.Term_Tenor__c)
                || (newProd.Total_Fees__c != null && oldProd.Total_Fees__c != null
                && newProd.Total_Fees__c != oldProd.Total_Fees__c)
                || (newProd.Total_Margin__c != null && oldProd.Total_Margin__c != null
                && newProd.Total_Margin__c != oldProd.Total_Margin__c)
                || (newProd.Finance_Approved_Fee_Recognition__c != null
                && oldProd.Finance_Approved_Fee_Recognition__c != null
                && newProd.Finance_Approved_Fee_Recognition__c != oldProd.Finance_Approved_Fee_Recognition__c)
                || (newProd.CurrencyIsoCode != null && oldProd.CurrencyIsoCode != null && newProd.CurrencyIsoCode != oldProd.CurrencyIsoCode))
                && (newProd.SA_Net_P_L_Amount_in_R__c != null
                && oldProd.SA_Net_P_L_Amount_in_R__c != null
                && newProd.SA_Net_P_L_Amount_in_R__c == oldProd.SA_Net_P_L_Amount_in_R__c)
                && (newProd.SA_Gross_P_L_Amount_in_R__c != null
                && oldProd.SA_Gross_P_L_Amount_in_R__c != null
                && newProd.SA_Gross_P_L_Amount_in_R__c == oldProd.SA_Gross_P_L_Amount_in_R__c)));
    }

    /**
     * @description Method to check for CIB record types.
     * SGPRT-1703 - Revenue Forecasting: Creation of new product revenue fields
     * 
     * @param recordTypeId recordType Id to compare against
     * @return Boolean indicating if recordtype belongs to CIB
     */
    public static Boolean isCibRecordType(Id recordTypeId) {
        return CIB_RECORDTYPE_IDS.contains(recordTypeId);
    }

    /**
     * @description Method to lock records which have approved fee recongition updated
     * SGPRT-2885 - Update to Finance Approved Fee field
     * 
     * @param products list of updated product records
     * @param oldProductsMap map of product records before update
     */
    public static void lockFinanceApprovedFeeRecognition(List<SB_Product__c> products, Map<Id, SB_Product__c> oldProductsMap) {
        for (SB_Product__c prod : products) {
            if (isWorkflowNotUpdating(prod, oldProductsMap.get(prod.Id))
                    && prod.Finance_Approved_Fee_Recognition__c != oldProductsMap.get(prod.Id).Finance_Approved_Fee_Recognition__c
                    && CIB_RECORDTYPE_IDS.contains(prod.RecordTypeId)) {
                prod.Locked_Fee_Recognition__c = true;
            }
        }
    }
    /**
     * @description Method to recalculate finance approved fee based on grand parent product
     * SGPRT-3051 - Fix for Finance Approved Fee Recognition
     * 
     * @param products list of updated product records
     * @param oldProductsMap map of product records before update
     */
    public static void updateFinanceApprovedFeeRecognition(List<SB_Product__c> products, Map<Id, SB_Product__c> oldProductsMap) {
        for (SB_Product__c prod : products) {
            if (isWorkflowNotUpdating(prod, oldProductsMap.get(prod.Id))
                    && (prod.Term_Tenor__c != oldProductsMap.get(prod.Id).Term_Tenor__c
                    || prod.Parent_Product__c != oldProductsMap.get(prod.Id).Parent_Product__c
                    || prod.Grand_Parent_Product__c != oldProductsMap.get(prod.Id).Grand_Parent_Product__c)
                    && prod.Term_Tenor__c != null
                    && prod.Term_Tenor__c >= 1
                    && CIB_RECORDTYPE_IDS.contains(prod.RecordTypeId)
                    && !prod.Locked_Fee_Recognition__c) {
                defaultFinanceApprovedFeeRecognition(products);
            }
        }
    }

    private static Boolean isWorkflowNotUpdating(SB_Product__c newProd, SB_Product__c oldProd) {
        return (newProd.SA_Net_P_L_Amount_in_R__c != null
                && oldProd.SA_Net_P_L_Amount_in_R__c != null
                && newProd.SA_Net_P_L_Amount_in_R__c == oldProd.SA_Net_P_L_Amount_in_R__c)
                && (newProd.SA_Gross_P_L_Amount_in_R__c != null
                && oldProd.SA_Gross_P_L_Amount_in_R__c != null
                && newProd.SA_Gross_P_L_Amount_in_R__c == oldProd.SA_Gross_P_L_Amount_in_R__c);
    }

    /**
     * @description Method to populate Bank Role field on Product Distribution every time Bank Role on related Product changes.
     * SGPRT-624
     * 
     * @param products list of updated product records
     * @param oldProductsMap map of product records before update
     */
    public static void populateBankRoleOnProdDistr(Map<Id, SB_Product__c> products, Map<Id, SB_Product__c> oldProductsMap) {
        SEL_ProductDistributions selProductsDistr = SEL_ProductDistributions.newInstance();
        List<Product_Distribution__c> prodDistr = selProductsDistr.selectByProductId(products.keySet());

        for (Product_Distribution__c pd : prodDistr){
            if (oldProductsMap.get(pd.Product__c).Bank_Role__c != products.get(pd.Product__c).Bank_Role__c){
                pd.Bank_Role__c = products.get(pd.Product__c).Bank_Role__c;
            }
        }
        if (!prodDistr.isEmpty()) {
            update prodDistr;
        }
    }

    /**
     * @description SFP-21730: Method to populate Profit Center Country if Profit Centre value is not general code
	 *
	 * @param products list of updated product records
	 * @param id2OldProducts map of product records before update
	 */
    public static void populateProfitCenterCountry(List<SB_Product__c> products, Map<Id, SB_Product__c> id2OldProducts) {

        Map<Id,SB_Product__c> productsToProcess = new Map<Id,SB_Product__c>();
        List<Id> listProfitCentreIds = new List<Id>();

        for (Integer i = 0; i < products.size(); i++) {
            if (products[i].RecordTypeId == UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_PRIM_ARRANGE_ADV) ||
                    products[i].RecordTypeId == UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_LENDING_COMMIT) ||
                    products[i].RecordTypeId == UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CAPITAL_MARKETS) ||
                    products[i].RecordTypeId == UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_ADVISORY))
            {
                productsToProcess.put(products[i].Id,products[i]);
                listProfitCentreIds.add(products[i].Profit_Centre__c);
            }
        }

        if(productsToProcess.size() > 0) {

            Schema.DescribeFieldResult schemaProduct = SB_Product__c.Franchise_Country__c.getDescribe();
            List<Schema.PicklistEntry> schemaProfitCentreValues = schemaProduct.getPicklistValues();

            List<Option_List_Item__c> listOptionListItems = SEL_Option_List_Item.newInstance().selectById(listProfitCentreIds);

            Map<String,Boolean> mapProfitCentre = new Map<String,Boolean>();
            For(Option_List_Item__c objOptnLstItm : listOptionListItems) {
                mapProfitCentre.put(objOptnLstItm.ID,objOptnLstItm.is_Profit_Centre_General__c);
            }

            for (SB_Product__c prod : productsToProcess.values()) {
                if(mapProfitCentre.size() > 0 && prod.Profit_Centre__c != null && !mapProfitCentre.get(prod.Profit_Centre__c)) {
                    prod.Franchise_Country__c = getProfitCenterCountry(prod.Balance_Sheet_of_Booking__c,
                            schemaProfitCentreValues);
                }
            }
        }
    }

    /**
     * @description SFP-21730: get string value for profit centre country
     *
     * @param strLegalEntityVal string Legal Entity value
     * @param schemaProfitCentreValues Schema.PicklistEntry of Legal Entity of booking
     * @return String strProfitCentreCountry
     */
    public static string getProfitCenterCountry(String strLegalEntityVal,
            List<Schema.PicklistEntry> schemaProfitCentreValues) {

        String strProfitCentreCountry='';
        List<String> listTempStringValue = new List<String>();
        listTempStringValue = strLegalEntityVal.split(' - ');
        for(Schema.PicklistEntry schemaProfit : schemaProfitCentreValues) {
            if(schemaProfit.getValue() == listTempStringValue[0]) {
                strProfitCentreCountry = listTempStringValue[0];
                Break;
            }
        }
        return strProfitCentreCountry;
    }

    /** 
     * @description Trigger recalculation of fields from Risk and Distribution Management section on Business Assessments
     *
     * @param products
     * @param oldProductsMap
     * @param unitOfWork
     */
    public void populateDistributionAndRiskOnBusinessAssessment(Map<Id, SB_Product__c> products, Map<Id, SB_Product__c> oldProductsMap, fflib_ISObjectUnitOfWork unitOfWork) {
        Set<Id> opportunityIds = getOpportunityIdsOfModifiedProducts(products, oldProductsMap);

        if (opportunityIds.size() == 0 || !Assessment_Opportunity__c.SObjectType.getDescribe().isAccessible()
                || !Business_Assessment__c.SObjectType.getDescribe().isAccessible() || !Business_Assessment__c.SObjectType.getDescribe().isUpdateable()) {
            return;
        }
        // get assessment opportunities with business assessment ids and opportunity ids where opportunities are parents of modified products
        SEL_AssessmentOpportunities assessmentOpportunitiesSelector = SEL_AssessmentOpportunities.newInstance().withCrudAssert(false).withFlsEnforced(false);
        List<Assessment_Opportunity__c> assessmentOpportunities = assessmentOpportunitiesSelector.selectByOpportunityId(opportunityIds, false);
        if(assessmentOpportunities.isEmpty()){
            return;
        }
        //get ids of business assessments
        Set<Id> businessAssessmentIds = new Set<Id>();
        for (Assessment_Opportunity__c aop : assessmentOpportunities) {
            businessAssessmentIds.add(aop.Business_Assessment__c);
        }
        SEL_BusinessAssessments baSelector = SEL_BusinessAssessments.newInstance().withCrudAssert(false).withFlsEnforced(false);
        List<Business_Assessment__c> baRecords = baSelector.selectByIds(businessAssessmentIds, false);
        DMN_BusinessAssessment_Injectable baDomain = (DMN_BusinessAssessment_Injectable)ORG_Application.domain.newInstance(baRecords);
        baDomain.recalculateDistributionAndRiskManagementFields(unitOfWork);
    }

    private Set<Id> getOpportunityIdsOfModifiedProducts(Map<Id, SB_Product__c> products, Map<Id, SB_Product__c> oldProductsMap){
        Set<Id> opportunityIds = new Set<Id>();
        if(Trigger.isDelete) {
            for (Id productId : oldProductsMap.keySet()) {
                if (isDistributionAndRiskModified(products.get(productId), oldProductsMap.get(productId))) {
                    opportunityIds.add(oldProductsMap.get(productId).Opportunity__c);
                }
            }
        } else {
            for (Id productId : products.keySet()) {
                if (isDistributionAndRiskModified(products.get(productId), oldProductsMap.get(productId))) {
                    opportunityIds.add(products.get(productId).Opportunity__c);
                }
            }
        }
        return opportunityIds;
    }

    private static Boolean isDistributionAndRiskModified(SB_Product__c productNew, SB_Product__c productOld){
        return (productOld == null
                || productNew == null
                || productNew.Bank_Role__c != productOld.Bank_Role__c
                || productNew.SB_Gross_Participation__c != productOld.SB_Gross_Participation__c
                || productNew.SB_Hold__c != productOld.SB_Hold__c
                || productNew.SB_Sell_Down__c != productOld.SB_Sell_Down__c
                || productNew.Facility_Size__c != productOld.Facility_Size__c
                || productNew.Transaction_Type__c != productOld.Transaction_Type__c
        );
    }

    /**
     * @param newProducts List<SB_Product__c>
     * @param oldProductsMap Map<Id, SB_Product__c>
     * @description method checks that Product was updated and run prepopulate logic. Used in Before Update logic
     */
    public static void isNeedToBePrepopulated(List<SB_Product__c> newProducts, Map<Id, SB_Product__c> oldProductsMap) {
        List<SB_Product__c> toPrepopulate = new List<SB_Product__c>();

        for (SB_Product__c newProduct : newProducts) {
            SB_Product__c oldProduct = oldProductsMap.get(newProduct.Id);
            if (
                    newProduct.Grand_Parent_Product__c != oldProduct.Grand_Parent_Product__c
                    || newProduct.Parent_Product__c != oldProduct.Parent_Product__c
                    || newProduct.SA_Product__c != oldProduct.SA_Product__c
            ) {
                toPrepopulate.add(newProduct);
            }
        }

        if (toPrepopulate.size() > 0) {
            prepopulateFromProduct2(toPrepopulate);
        }
    }

    /**
     * @param products List<SB_Product__c>
     * @description method prepopulates several fields from Product2 record
     */
    public static void prepopulateFromProduct2(List<SB_Product__c> products) {
        if (hasAccessToNonAdvisoryIbFees()) {
            Set<String> productNames = new Set<String>();
            Map<String, List<Product2>> productName2Product2records = new Map<String, List<Product2>>();

            for (SB_Product__c sbProduct : products) {
                productNames.add(sbProduct.SA_Product__c);
            }

            if (productNames.size() > 0) {
                List<Product2> standardProducts = SEL_Products2.newInstance().selectByProductName(productNames);
                if (standardProducts.size() > 0) {
                    for (Product2 p2 : standardProducts) {
                        if (productName2Product2records.containsKey(p2.Name)) {
                            productName2Product2records.get(p2.Name).add(p2);
                        } else {
                            productName2Product2records.put(p2.Name, new List<Product2>{p2});
                        }
                    }
                } else {
                    return;
                }
            } else {
                return;
            }

            for (SB_Product__c sbProduct : products) {
                if (productName2Product2records.containsKey(sbProduct.SA_Product__c)) {
                    prepopulateNonAdvisoryIbFees(sbProduct, productName2Product2records.get(sbProduct.SA_Product__c));
                }
            }
        }

    }

    private static Boolean hasAccessToNonAdvisoryIbFees() {
        return (Schema.SObjectType.SB_Product__c.fields.Non_Advisory_IB_Fees_Product__c.isUpdateable()
                && Schema.SObjectType.SB_Product__c.fields.Risk_Weighted_Value__c.isUpdateable()
                && Schema.SObjectType.Product2.fields.Non_Advisory_IB_Fees_Product__c.isAccessible()
                && Schema.SObjectType.Product2.fields.Risk_Weighted_Value__c.isAccessible()
        );
    }

    private static void prepopulateNonAdvisoryIbFees(SB_Product__c sbProduct, List<Product2> p2Products) {
        Boolean hasProduct = false;

        for (Product2 p2Product : p2Products) {
            if (
                    sbProduct.Grand_Parent_Product__c == p2Product.Grand_Parent_Product__c
                    && sbProduct.Parent_Product__c == p2Product.Parent_Product__c
                    && sbProduct.SA_Product__c == p2Product.Name
                    && sbProduct.Product_Division__c == p2Product.Product_Division__c
                    && p2Product.IsActive
            ) {

                hasProduct = true;
                if (p2Product.Risk_Weighted_Value__c != null) {
                    sbProduct.Risk_Weighted_Value__c = p2Product.Risk_Weighted_Value__c;
                }
                sbProduct.Non_Advisory_IB_Fees_Product__c = p2Product.Non_Advisory_IB_Fees_Product__c;
            }

            if (!hasProduct) {
                sbProduct.Non_Advisory_IB_Fees_Product__c = false;
            }
        }
    }
}