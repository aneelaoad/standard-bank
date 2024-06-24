/*************************************************************************
    @ Author        : psvestka
    @ Date          : Jan 2016
    @ Test File     : KeyIndicatorsCPCommBControllerTest
    @ Description   : EN-927, controller is "without sharing" because this is the only place that should have access to the Revenue_and_Profitability__c object
    
    @ Last Modified By : Andrei Olteanu
    @ Last Modified Date: Oct 25, 2016
    @ Last Modified Description: RI-0117 Revenue_and_Profitability__c list size > 1 stoped logic
****************************************************************************/

public without sharing class KeyIndicatorsCPCommBController {
    private Boolean valuesComputed = false;
    private CurrencyConverter conv = new CurrencyConverter();

    public String currencyIsoCode {
        get;
        set {
            currencyIsoCode = value;
            
            if (clientId != null && currencyIsoCode != null && !valuesComputed) {
                fetchValues();
                valuesComputed = true;
            }
        }
    }

    public Id clientid {
        get;
        set {
            clientid = value;

            if (clientId != null && currencyIsoCode != null && !valuesComputed) {
                fetchValues();
                valuesComputed = true;
            }
        }
    }
    public Date pmtExtractDate { get; private set; }

    public PFAWrapper pfa { get; private set; }

    public Boolean getPmtExtractDateFilled() {
        return pmtExtractDate != null;
    }

    public KeyIndicatorsCPCommBController() {
        clientid = ApexPages.currentPage().getParameters().get('id');
    }

    public KeyIndicatorsCPCommBController(ApexPages.StandardController controller) {
        clientId = controller.getId();
        Client_Plan__c[] cPlan = 
            [ SELECT Id, LastModifiedDate, CurrencyIsoCode,Task_Selection__c,
              Opportunity_Selection__c,Team_Selection__c, CSI_Selection__c, 
              Name, Client_Name__c,Client_Plan_Status__c 
              FROM Client_Plan__c 
              WHERE Client_Name__c = :clientId 
              ORDER BY LastModifiedDate 
              DESC LIMIT 1 ];
        if (!cPlan.isEmpty()) {
            currencyIsoCode = cPlan[0].CurrencyIsoCode;
        }
    }

    private void fetchValues() {
        List<Revenue_and_Profitability__c> rps = [SELECT roe__c
                                                        ,pmt_extract_date__c
                                                        ,operating_income__c
                                                        ,non_interest_revenue__c
                                                        ,net_interest_income__c
                                                        ,headline_earnings__c
                                                        ,cost__c
                                                        ,currencyIsoCode
                                                    FROM Revenue_and_Profitability__c
                                                   WHERE client_name__c = :clientId
                                                   ORDER BY pmt_extract_date__c ASC];
        pfa = new PFAWrapper();

        if (rps.size() == 0) {
            return;
        }

        Revenue_and_Profitability__c rp = rps.get(0);
        pfa.operatingIncome = conv.convertCurrency(rp.operating_income__c, rp.currencyIsoCode, currencyIsoCode);
        pfa.roe = rp.roe__c;
        pfa.netInterestIncome = conv.convertCurrency(rp.net_interest_income__c, rp.currencyIsoCode, currencyIsoCode);
        pfa.headlineEarnings = conv.convertCurrency(rp.headline_earnings__c, rp.currencyIsoCode, currencyIsoCode);
        pfa.nonInterestRevenue = conv.convertCurrency(rp.non_interest_revenue__c, rp.currencyIsoCode, currencyIsoCode);
        pfa.cost = rp.cost__c;
        pmtExtractDate = rp.pmt_extract_date__c;
    }

    public class PFAWrapper {
        public Decimal operatingIncome { get; set {operatingIncome = zeroIn(value);} }
        public Decimal roe { get; set {roe = zeroIn(value);} }
        public Decimal netInterestIncome { get; set {netInterestIncome = zeroIn(value);} }
        public Decimal headlineEarnings { get; set {headlineEarnings = zeroIn(value);} }
        public Decimal nonInterestRevenue { get; set {nonInterestRevenue = zeroIn(value);} }
        public Decimal cost { get; set {cost = zeroIn(value);} }

        public PFAWrapper() {
            operatingIncome = 0.0;
            roe = 0.0;
            netInterestIncome = 0.0;
            headlineEarnings = 0.0;
            nonInterestRevenue = 0.0;
            cost = 0.0;
        }

        private Decimal zeroIn(Decimal n) {
            return n != null ? n : 0.0;
        }
    }
}