public without sharing class CI_RevenueController {

    private static CurrencyConverter converter;


    private static CurrencyConverter getCurrencyConverter() {
        if (converter == null)
            converter = new CurrencyConverter();

        return converter;
    }

    @AuraEnabled
    public static CI_ResponseDto getClientReturnOverCapital(String clientId) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardMapModel cmm = new CI_CardMapModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Client_Capital_and_Revenue__c.fields.getMap(), new String[] {'CROC_ZAR__c' })){
                return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }
        List<Client_Capital_and_Revenue__c> acc = [SELECT Id, CROC_ZAR__c FROM Client_Capital_and_Revenue__c where  Client__c =: clientId];

        String text = 'None';
        if(acc.size() > 0)
        {
            text = String.valueOf(acc[0].CROC_ZAR__c)!=null?String.valueOf(acc[0].CROC_ZAR__c):'None';
        }
        cmm.cardDataMap.put('CROC', text);

        cmm.Description = 'CROC';

        return new CI_ResponseDto(cmm);
    }

    @AuraEnabled
    public static CI_ResponseDto getDeals(String clientId, List<String> dealTypes) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_SharedUtilities.ClientHierarchyTools sharedUtilsTools = new CI_SharedUtilities.ClientHierarchyTools();
        CI_CardListObjectModel clom = new CI_CardListObjectModel();

        //Return the client hierarchy from the top most parent of the selected client
        HierarchyComponentController.AccountNode accHierList = CI_ClientSearchController.getClientHierarchy(clientId);

        //Return a list of client id from the client hierarchy of the selected client
        List<String> clientIdList = sharedUtilsTools.getClientIdsInHierarchy(sharedUtilsTools.getAccountNodeInHierarchy(accHierList, clientId));

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Opportunity.fields.getMap(), new String[] {'StageName', 'Amount', 'CurrencyIsoCode', 'CloseDate', 'Actual_Close_Date__c', 'Priority__c', 'Short_Summary__c',
                                'Description', 'Start_Date__c', 'Probability', 'ReasonForWinLossPickList__c', 'Reason_Won_Lost_Detail__c', 'ExpectedRevenue'})){
                return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }
        clom.cardObjectList = [SELECT Account.Name, Id, Name, StageName, convertCurrency(Amount) Amount, CurrencyIsoCode, Actual_Close_Date__c, Priority__c, Short_Summary__c,
                                Description, Start_Date__c, Probability, ReasonForWinLossPickList__c, Reason_Won_Lost_Detail__c,
                                convertCurrency(ExpectedRevenue) ExpectedRevenue, CloseDate,
                                (SELECT Product_Division__c, SA_Product__c
                                FROM Products__r)
                                FROM Opportunity
                                WHERE AccountId IN :clientIdList
                                AND StageName IN :dealTypes
                                order by CloseDate DESC];

        clom.Description = 'Opportunities';

        return new CI_ResponseDto(clom);
    }

    @AuraEnabled
    public static CI_ResponseDto getShareOfWallet(String clientId) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardListObjectModel clom = new CI_CardListObjectModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Share_Wallet__c.fields.getMap(), new String[] {'Share_of_Wallet__c', 'Division__c', 'Revenue__c', 'Total_Wallet_Size__c', 'Financial_Year__c'})){
                return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }

        Date currentDate = System.today();

        List<Share_Wallet__c> financialYear = [select Financial_Year__c from Share_Wallet__c where client__c =: clientId order by Financial_Year__c desc limit 1];

        //No share of wallet found
        if(financialYear.Size() == 0)
            return new CI_ResponseDto(clom);

        clom.cardObjectList = [select Share_of_Wallet__c, Division__c, convertCurrency(Revenue__c) Revenue__c, convertCurrency(Total_Wallet_Size__c) Total_Wallet_Size__c, Financial_Year__c, createddate from Share_Wallet__c where client__c =: clientId and Financial_Year__c =: financialYear[0].Financial_Year__c order by Division__c ASC];

        clom.Description = 'Share of wallet';

        return new CI_ResponseDto(clom);
    }

    @AuraEnabled
    public static CI_ResponseDto getClientRevenueVsBudgetGap(String clientId) {
        Set<Id> clientIds = new Set<Id>();
        clientIds.add(clientId);

        return getRevenueVsBudgetGap(clientIds, null);
    }

    @AuraEnabled
    public static CI_ResponseDto getRevenueBudgetSnapshotDate() {
        Date lastestRevenueSnapshotDate = StdBank_Ltn_ClientsStatisticsController.getLatestRevenueSnapshotDate();
        CI_CardMapModel cmm = new CI_CardMapModel();

        if(lastestRevenueSnapshotDate == null){
            cmm.cardDataMap.put('Month_End_Snapshot_Date__c', String.valueOf(''));
        }
        else {
            cmm.cardDataMap.put('Month_End_Snapshot_Date__c', String.valueOf(lastestRevenueSnapshotDate));
        }

        return new CI_ResponseDto(cmm);
    }

    @AuraEnabled
    public static CI_ResponseDto getPortfolioRevenueVsBudgetGap(Map<String,Boolean> querySettings) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        Set<Id> currentUserHighestLevelClientsIds = sharedUtils.getCurrentUserHighestLevelClients(querySettings);

        return getRevenueVsBudgetGap(currentUserHighestLevelClientsIds, querySettings);
    }

    public static CI_ResponseDto getRevenueVsBudgetGap(Set<Id> clientIds, Map<String,Boolean> querySettings) {
        CI_CardMapModel cmm = new CI_CardMapModel();

        Date lastestSnapshotDate = StdBank_Ltn_ClientsStatisticsController.getLatestRevenueSnapshotDate();

        String query = CI_QueryBuilder.getRevenueVsBudgetGapQuery(querySettings, clientIds, lastestSnapshotDate);

        List<AggregateResult> revenueInfo = Database.query(query);

//        System.debug(revenueInfo);
//        System.debug(scenarioSelector);
//        System.debug(clientIds);
//        System.debug(revenueInfo[0].get('Client_Value_ZAR_Total'));
//        System.debug(revenueInfo[0].get('Budget_ZAR_Total'));

        if(revenueInfo[0].get('Client_Value_ZAR_Total') == null )
        {
            Decimal revenueSum = 0;
            Decimal budgetSum = (Decimal)revenueInfo[0].get('Budget_ZAR_Total');
            budgetSum = getCurrencyConverter().convertCorporateCurrency(budgetSum, UserInfo.getDefaultCurrency());
            cmm.cardDataMap.put('Revenue', String.valueOf(revenueSum));
            cmm.cardDataMap.put('Budget', String.valueOf(budgetSum));


            return new CI_ResponseDto(cmm);
        }
        else if (revenueInfo[0].get('Budget_ZAR_Total') == null){

            return new CI_ResponseDto(cmm);
        }

        Decimal revenueSum = (Decimal)revenueInfo[0].get('Client_Value_ZAR_Total');
        revenueSum = getCurrencyConverter().convertCorporateCurrency(revenueSum, UserInfo.getDefaultCurrency());
        Decimal budgetSum = (Decimal)revenueInfo[0].get('Budget_ZAR_Total');
        budgetSum = getCurrencyConverter().convertCorporateCurrency(budgetSum, UserInfo.getDefaultCurrency());

        //Calculate gap between revenue and budget 
        Double budgetGapPercent = 0; 
        
        if(budgetSum > 0){
            Double diff = revenueSum - budgetSum;
            budgetGapPercent = (diff / budgetSum) * 100;
        }
        
        cmm.cardDataMap.put('Revenue', String.valueOf(revenueSum));   
        cmm.cardDataMap.put('Budget', String.valueOf(budgetSum));         
        cmm.cardDataMap.put('BudgetGapPercent', String.valueOf(budgetGapPercent));                       
        
        cmm.Description = 'Revenue vs Budget Gap';   
        return new CI_ResponseDto(cmm);
    }   

    @AuraEnabled
    public static CI_ResponseDto getPortfolioRevenueYoY(Integer startYear, Integer numYearsBack, Integer toMonth, Map<String,Boolean> querySettings) {
        //SF bug
        startYear = Integer.valueOf(startYear);
        numYearsBack = Integer.valueOf(numYearsBack);
        toMonth = Integer.valueOf(toMonth);

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        Set<Id> currentUserHighestLevelClientsIds = sharedUtils.getCurrentUserHighestLevelClients(querySettings);
        CI_CardListObjectModel clom = new CI_CardListObjectModel();
        Map<String, Decimal> revenueMapp;

        for(Integer i = startYear; i >= startYear - numYearsBack; i--)
        {
            revenueMapp = new Map<String, Decimal>();
            revenueMapp.put('Year', i);
            Decimal amount = getRevenueForPeriod(currentUserHighestLevelClientsIds, i, toMonth);
            revenueMapp.put('Amount', getCurrencyConverter().convertCorporateCurrency(amount, UserInfo.getDefaultCurrency()));
//            revenueMapp.put('Amount', getRevenueForPeriod(currentUserHighestLevelClientsIds, i, toMonth));
            clom.cardObjectList.add(revenueMapp);
        }

        clom.Description = 'Revenue YoY';
        return new CI_ResponseDto(clom);
    }

    private static Decimal getRevenueForPeriod(Set<Id> clientId, Integer year, Integer month) {
        Decimal totalRevenue = 0;

        if (clientId != null) {
            AggregateResult[] aggrRevenues = [SELECT SUM(Client_Value_ZAR_Current_Month__c) rev
                                                        FROM Global_Client_Revenue__c
                                                        WHERE Client__c IN :clientId
                                                        AND CALENDAR_YEAR(Snapshot_Date__c) =: year
                                                        AND CALENDAR_MONTH(Snapshot_Date__c) <=: month];

            if (aggrRevenues.size() == 1 && aggrRevenues[0].get('rev') != null) {
                totalRevenue = Math.roundToLong((Decimal) aggrRevenues[0].get('rev'));
            }
        }
        return totalRevenue;
    }

    @AuraEnabled
    public static CI_ResponseDto getPortfolioCROC(Map<String,Boolean> querySettings) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        Set<Id> currentUserHighestLevelClientsIds = sharedUtils.getCurrentUserHighestLevelClients(querySettings);

        Decimal portfolioCroc = getCROC(currentUserHighestLevelClientsIds);

        CI_CardMapModel cmm = new CI_CardMapModel();
        if(portfolioCroc == 0)
        {
            cmm.cardDataMap.put('CROC', 'None');
            return new CI_ResponseDto(cmm);
        }
        else {
            cmm.cardDataMap.put('CROC', String.valueOf(portfolioCroc));
            return new CI_ResponseDto(cmm);
        }
    }
    @AuraEnabled
    public static CI_ResponseDto getRevenueClientByDivision(Id clientId) {

        Date latestSnapshotDate = StdBank_Ltn_ClientsStatisticsController.getLatestRevenueSnapshotDate();
        String[] fieldsToQuery = new String[] {
            'Client__r.Name'
            , 'Client__c'
            , 'Trading_Division__c'
            , 'SUM(Client_Value_ZAR_Current_Year__c) rev'
            , 'SUM(Budget_ZAR_Next_Year__c) budget'
            , 'Client__r.RecordType.DeveloperName ClientRecordType'
        };
        Set<String> clientsRecordTypesToDisplay = new Set<String> {
            DMN_Account.RT_ULTIMATE_PARENT
            , DMN_Account.RT_IMMEDIATE_PARENT
            , DMN_Account.RT_CHILD
        };
        String[] filteringConditions = new String[] {
            'RecordType.DeveloperName = \'' + DMN_GlobalClientRevenue.RTD_CURRENT_PREVIOUS_YEAR + '\''
            , 'CALENDAR_YEAR(Snapshot_Date__c) = ' + latestSnapshotDate.year()
            , 'Client__c ' +
                (String.isNotBlank(clientId) ?
                    ' = :clientId' :
                    ' IN (SELECT Account__c FROM Custom_Client_Team__c WHERE Team_Member__c = \'' + UserInfo.getUserId() + '\') ' +
                        'AND Client__r.RecordType.DeveloperName IN :clientsRecordTypesToDisplay'
                )
        };
        String[] groupingFields = new String[] {
            'Client__c'
            , 'Client__r.Name'
            , 'Trading_Division__c'
            , 'Client__r.RecordType.DeveloperName'
        };
        String[] orderFields = new String[] {
            'Client__r.Name'
            , 'Trading_Division__c'
            , 'Client__r.RecordType.DeveloperName DESC'
        };
        String query =  'SELECT ' + String.join(fieldsToQuery, ', ');
        query +=        ' FROM ' + DMN_GlobalClientRevenue.OBJ_NAME;
        query +=        ' WHERE ' + String.join(filteringConditions, ' AND ');
        query +=        ' GROUP BY ' + String.join(groupingFields, ', ');
        query +=        ' ORDER BY ' + String.join(orderFields, ', ');

        AggregateResult[] revenues = Database.query(query);
        List<Map<String,Object>> responseDTO = new List<Map<String,Object>>();
        for (AggregateResult row : revenues) {
            Map<String,Object> divisionRevenue = new Map<String,Object>();
            divisionRevenue.put('Trading_Division__c', row.get('Trading_Division__c'));
            divisionRevenue.put('Name', row.get('Name'));
            divisionRevenue.put('Id', row.get('Client__c'));
            Decimal convertedRevenue = getCurrencyConverter().convertCorporateCurrency((Decimal)(row.get('rev')), UserInfo.getDefaultCurrency());
            divisionRevenue.put('Revenue', String.valueof(convertedRevenue));
            Decimal convertedBudget = getCurrencyConverter().convertCorporateCurrency((Decimal)(row.get('budget')), UserInfo.getDefaultCurrency());
            divisionRevenue.put('Budget', String.valueof(convertedBudget));
            divisionRevenue.put('ClientRecordType', row.get('ClientRecordType'));
           // divisionRevenue.put('UserCurrency', UserInfo.getDefaultCurrency());
            responseDTO.add(divisionRevenue);
        }
        return new CI_ResponseDto(responseDTO);
    }

    @AuraEnabled
    public static CI_ResponseDto getPortfolioROE(Map<String,Boolean> querySettings) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        Set<Id> currentUserHighestLevelClientsIds = sharedUtils.getCurrentUserHighestLevelClients(querySettings);

        Decimal portfolioCroc = getCROC(currentUserHighestLevelClientsIds);

        CI_CardMapModel cmm = new CI_CardMapModel();
        if(portfolioCroc == 0)
        {
            cmm.cardDataMap.put('ROE', 'None');
            return new CI_ResponseDto(cmm);
        }
        else {
            Decimal roe = portfolioCroc * 0.5 * 0.8; //calculation to change!!
            cmm.cardDataMap.put('ROE', String.valueOf(roe));
            return new CI_ResponseDto(cmm);
        }
    }

    public static Decimal getCROC(Set<Id> clientIds) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();

        List<Client_Capital_and_Revenue__c> crocs = [SELECT Id, CROC_ZAR__c FROM Client_Capital_and_Revenue__c where  Client__c IN: clientIds];

        if(crocs.size() == 0)
        {
            return 0;
        }

        Decimal totalCroc = 0;
        for(Client_Capital_and_Revenue__c croc : crocs)
        {
            totalCroc += croc.CROC_ZAR__c;
        }

        Decimal avgCroc = totalCroc / crocs.size();
        return avgCroc;
    }

    @AuraEnabled
    public static CI_ResponseDto getPortfolioMonthlyRevenueVariance() {
        //Get porfolio clients
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        Set<Id> portfolioClientIds = sharedUtils.getCurrentUserTeamClients();
        //System.debug('getPortfolioMonthlyRevenueVariance portfolioClientIds ' + portfolioClientIds);

        //Get latest snapshot date
        Date latestSnapshotDate = StdBank_Ltn_ClientsStatisticsController.getLatestRevenueSnapshotDate();
        //System.debug('getPortfolioMonthlyRevenueVariance latestSnapshotDate ' + latestSnapshotDate);

        //Get revenue records for lastest month and previous month, ordered by client
        Date previousMonthSnapshotDate = latestSnapshotDate.toStartOfMonth().addDays(-1);
        //System.debug('getPortfolioMonthlyRevenueVariance previousMonthSnapshotDate ' + previousMonthSnapshotDate);

        List<AggregateResult> monthlyGCRList = [SELECT
                                                    Client__r.Id,
                                                    Client__r.Name,
                                                    SUM(Client_Value_ZAR_Current_Month__c) Client_Value_ZAR_Current_Month__c,
                                                    Snapshot_Date__c
                                                FROM Global_Client_Revenue__c
                                                WHERE Client__c IN :portfolioClientIds
                                                AND Snapshot_Date__c >=: previousMonthSnapshotDate
                                                AND RecordType.Name = 'Historical Revenue'
                                                /*AND Client__r.RecordType.DeveloperName = :DMN_Account.RT_ULTIMATE_PARENT*/
                                                GROUP BY Client__r.Id, Client__r.Name, Snapshot_Date__c
                                                ORDER BY Client__r.Id, Snapshot_Date__c DESC];
        //System.debug('getPortfolioMonthlyRevenueVariance monthlyGCRList ' + monthlyGCRList);

        //Loop through records and create comparison
        CI_CardListObjectModel clientMonthComparisonList = new CI_CardListObjectModel();
        Map<String, String> clientMonthComparison = new Map<String, String>();
        Integer clientLoopCounter = 0;
        Integer iterationCounter = 1;

        for(AggregateResult monthlyGCR : monthlyGCRList) {

            //System.debug('getPortfolioMonthlyRevenueVariance monthlyGCR ' + monthlyGCR);

            if(iterationCounter > 1
                && String.valueOf(monthlyGCR.get('Id')) != clientMonthComparison.get('ClientId')) {
                //Client has changed, and we're not on the first iteration, so calculate variance
                clientMonthComparison.put('PercentVariance', sharedUtils.calculatePercentVariance(clientMonthComparison.get('PreviousMonthRevenue'), clientMonthComparison.get('CurrentMonthRevenue')));

                //Add to list, reset map and counter
                clientMonthComparisonList.cardObjectList.add(clientMonthComparison);
                clientMonthComparison = new Map<String, String>();
                clientLoopCounter = 0;
            }

            clientMonthComparison.put('ClientId', String.valueOf(monthlyGCR.get('Id')));
            clientMonthComparison.put('ClientName', String.valueOf(monthlyGCR.get('Name')));

            if((Date)monthlyGCR.get('Snapshot_Date__c') == latestSnapshotDate){
                //Current month
                clientMonthComparison.put('CurrentMonth', String.valueOf(((Date)monthlyGCR.get('Snapshot_Date__c')).month()));
                String currentMonthRevenue = String.valueOf(monthlyGCR.get('Client_Value_ZAR_Current_Month__c'));
                Decimal convertedCurrentMonthRevenue = getCurrencyConverter().convertCorporateCurrency(Decimal.valueof(currentMonthRevenue), UserInfo.getDefaultCurrency());
                clientMonthComparison.put('CurrentMonthRevenue', String.valueof(convertedCurrentMonthRevenue));
            } else if ((Date)monthlyGCR.get('Snapshot_Date__c') == previousMonthSnapshotDate) {
                //Previous month
                clientMonthComparison.put('PreviousMonth', String.valueOf(((Date)monthlyGCR.get('Snapshot_Date__c')).month()));
                String previousMonthRevenue = String.valueOf(monthlyGCR.get('Client_Value_ZAR_Current_Month__c'));
                Decimal convertedPreviousMonthRevenue = getCurrencyConverter().convertCorporateCurrency(Decimal.valueof(previousMonthRevenue), UserInfo.getDefaultCurrency());
                clientMonthComparison.put('PreviousMonthRevenue', String.valueOf(convertedPreviousMonthRevenue));
            }

            if(monthlyGCRList.size() == iterationCounter){
                //This is the last iteration, so calculate variance and add to list
                clientMonthComparison.put('PercentVariance', sharedUtils.calculatePercentVariance(clientMonthComparison.get('PreviousMonthRevenue'), clientMonthComparison.get('CurrentMonthRevenue')));
                clientMonthComparisonList.cardObjectList.add(clientMonthComparison);
            }

            //System.debug('getPortfolioMonthlyRevenueVariance clientMonthComparison ' + clientMonthComparison);

            clientLoopCounter++;
            iterationCounter++;
        }
        //System.debug('getPortfolioMonthlyRevenueVariance clientMonthComparisonList ' + clientMonthComparisonList);

        return new CI_ResponseDto(clientMonthComparisonList);
    }

    @AuraEnabled
    public static CI_ResponseDto getClientCROC(String clientId) {

        Set<Id> clientIds = new Set<Id>();
        clientIds.add(clientId);
        Decimal portfolioCroc = getCROC(clientIds);

        CI_CardMapModel cmm = new CI_CardMapModel();
        if(portfolioCroc == 0)
        {
            cmm.cardDataMap.put('CROC', 'None');
            return new CI_ResponseDto(cmm);
        }
        else {
            cmm.cardDataMap.put('CROC', String.valueOf(portfolioCroc));
            return new CI_ResponseDto(cmm);
        }
    }

    @AuraEnabled
    public static CI_ResponseDto getClientROE(String clientId) {

        Set<Id> clientIds = new Set<Id>();
        clientIds.add(clientId);
        Decimal portfolioCroc = getCROC(clientIds);

        CI_CardMapModel cmm = new CI_CardMapModel();
        if(portfolioCroc == 0)
        {
            cmm.cardDataMap.put('ROE', 'None');
            return new CI_ResponseDto(cmm);
        }
        else {
            Decimal roe = portfolioCroc * 0.5 * 0.8; //calculation to change!!
            cmm.cardDataMap.put('ROE', String.valueOf(roe));
            return new CI_ResponseDto(cmm);
        }
    }

    @AuraEnabled
    public static CI_ResponseDto getPortfolioRevenueYTD() {
        //Get porfolio clients
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        Set<Id> portfolioClientIds = sharedUtils.getCurrentUserTeamClients();

        CI_CardMapModel cmm = new CI_CardMapModel();
        cmm.cardDataMap.put('PortfolioRevenueYTD', String.valueOf(getRevenueYTD(portfolioClientIds)));

        return new CI_ResponseDto(cmm);
    }

    public static Decimal getRevenueYTD(Set<Id> clientIds) {
        Decimal totalRevenue = 0;

        AggregateResult[] aggrRevenues = [SELECT SUM(Client_Value_ZAR_Current_Year__c) revenue
                                                        FROM Global_Client_Revenue__c
                                                        WHERE Client__c IN :clientIds
                                                        AND RecordType.Name = 'Current & Previous Year'];

        if (aggrRevenues.size() == 1 && aggrRevenues[0].get('revenue') != null) {
            totalRevenue = Math.roundToLong((Decimal) aggrRevenues[0].get('revenue'));
        }

        return totalRevenue;
    }

     @AuraEnabled
    public static CI_ResponseDto getPortfolioVarianceAction() {
        //Get porfolio clients
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        Set<Id> portfolioClientIds = sharedUtils.getCurrentUserTeamClients();

        //Get latest snapshot date
        Date latestSnapshotDate = StdBank_Ltn_ClientsStatisticsController.getLatestRevenueSnapshotDate();

        List<AggregateResult> currentAndPreviousRevenueYTDList = [SELECT
                                                                    Client__c,
                                                                    Client__r.Name,
                                                                    SUM(Client_Value_ZAR_Current_Month__c) Revenue,
                                                                    Calendar_Year(Snapshot_Date__c) Year
                                                                FROM Global_Client_Revenue__c
                                                                WHERE Client__c IN :portfolioClientIds
                                                                AND (Calendar_Year(Snapshot_Date__c) =: latestSnapshotDate.year()
                                                                    OR (Calendar_Year(Snapshot_Date__c) =: latestSnapshotDate.addYears(-1).year() AND Snapshot_Date__c <=: latestSnapshotDate.addYears(-1)))
                                                                AND RecordType.Name = 'Historical Revenue'
                                                               /* AND Client__r.RecordType.DeveloperName = :DMN_Account.RT_ULTIMATE_PARENT*/
                                                                GROUP BY Client__c, Client__r.Name, Calendar_Year(Snapshot_Date__c)
                                                                ORDER BY Client__c, Calendar_Year(Snapshot_Date__c) DESC];

        CI_CardListObjectModel clientYearlyComparisonList = new CI_CardListObjectModel();

        for(Id clientId : portfolioClientIds){
            Map<String, String> clientYearlyComparison = new Map<String, String>();
            AggregateResult currentAndPreviousRevenueYTD = sharedUtils.getAggregateResultByValue('Client__c', String.valueOf(clientId), currentAndPreviousRevenueYTDList);
            //If no revenue records are found for the current client, skip
            if(currentAndPreviousRevenueYTD == null)
                continue;

            clientYearlyComparison.put('ClientId', String.valueOf(clientId));
            clientYearlyComparison.put('ClientName', (String)currentAndPreviousRevenueYTD.get('Name'));
            //Current year
            clientYearlyComparison.put('CurrentYear', String.valueOf(latestSnapshotDate.year()));
            String currentYearRevenue = String.valueOf(getRevenueForYear(clientId, currentAndPreviousRevenueYTDList, latestSnapshotDate.year()));
            Decimal convertedCurrentYearRevenue = getCurrencyConverter().convertCorporateCurrency(Decimal.valueOf(currentYearRevenue), UserInfo.getDefaultCurrency());
            clientYearlyComparison.put('CurrentYearRevenue', String.valueOf(convertedCurrentYearRevenue));
            //Previous year
            clientYearlyComparison.put('PreviousYear', String.valueOf(latestSnapshotDate.addYears(-1).year()));
            String previousYearRevenue = String.valueOf(getRevenueForYear(clientId, currentAndPreviousRevenueYTDList, latestSnapshotDate.addYears(-1).year()));
            Decimal convertedPreviousYearRevenue = getCurrencyConverter().convertCorporateCurrency(Decimal.valueof(previousYearRevenue), UserInfo.getDefaultCurrency());
            clientYearlyComparison.put('PreviousYearRevenue', String.valueOf(convertedPreviousYearRevenue));
            //Percent variance
            clientYearlyComparison.put('PercentVariance', sharedUtils.calculatePercentVariance(clientYearlyComparison.get('PreviousYearRevenue'), clientYearlyComparison.get('CurrentYearRevenue')));

            clientYearlyComparisonList.cardObjectList.add(clientYearlyComparison);
        }

        return new CI_ResponseDto(clientYearlyComparisonList);
    }

    private static Decimal getRevenueForYear(Id clientId, List<AggregateResult> revenueList, Integer year){
        for(AggregateResult revenueRec : revenueList){
            if((Id)revenueRec.get('Client__c') == clientId && (Integer)revenueRec.get('Year') == year)
                return (Decimal)revenueRec.get('Revenue');
        }
        return 0;
    }

    @AuraEnabled
    public static CI_ResponseDto getPortfolioCYPipelineAction(Id clientId, Map<String,Boolean> querySettings) {
//        String scenarioSelector = CI_QueryBuilder.setScenarioSelector();
        Set<Id> ids = new Set<Id>();
        if(clientId != null){
            ids.add(clientId);
        }

        Set<Id> clientsIds = StdBank_Ltn_ClientsStatisticsController.getClientsForPipeline(ids, querySettings);

        List<Object> portfolioPipeline =StdBank_Ltn_ClientsCYPipelineController.getPortfolioCYPipeline(clientsIds, querySettings);

        return new CI_ResponseDto(portfolioPipeline);
    }

    @AuraEnabled
    public static CI_ResponseDto getUserIsoCodeAction() {
        return new CI_ResponseDto(UserInfo.getDefaultCurrency());
    }

    // getting component to redirect and title based on user division on CI_ClientsRevenueBudget
    @AuraEnabled
    public static CI_ResponseDto getCustomSettingsAction(Map<String, Boolean> querySettings){
        Map<String, String> name2value = new Map<String, String>();
        String title = 'Revenue vs Budget',
                redirectComponent = 'CI_RevenueSecondLevel';
        CI_Parameters__c divisions = CI_Parameters__c.getValues(DCN_CustomSetting.CI_REVENUE_SECOND_LEVEL_NAVIGATE_DISABLE);

        redirectComponent = divisions.Value__c.contains(UTL_User.getUserDivision()) ? 'CI_RevenueDrillDown' : 'CI_RevenueSecondLevel';

        if(querySettings != null) {
            title = querySettings.get('filteringOnIBC') ? System.Label.Total_IBC_Client_Revenue_Budget : 'Revenue vs Budget';
        }
        name2value.put('redirectComponent', redirectComponent);
        name2value.put('title', title);


        return new CI_ResponseDto(name2value);
    }


}