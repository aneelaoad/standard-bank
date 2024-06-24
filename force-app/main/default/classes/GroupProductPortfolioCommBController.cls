/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : Jan 2016
	@ Test File 	: GroupProductPortfolioCommBControllerTest.cls
	@ Description	: EN-927
****************************************************************************/

public with sharing class GroupProductPortfolioCommBController {

	private Boolean valuesComputed = false;
	public String currencyIsoCode {
		get;
		set {
			currencyIsoCode = value;

			if (clientId != null && currencyIsoCode != null && !valuesComputed) {
				runOnlyIfBoth();
				valuesComputed = true;
			}
		}
	}

	public Id clientid {
		get;
		set {
			clientid = value;

			if (clientId != null && currencyIsoCode != null && !valuesComputed) {
				runOnlyIfBoth();
				valuesComputed = true;
			}
		}
	}

	public List<GPPWrapper> groupPortfolios { get; private set; }
	public Map<String, Decimal> sums { get; private set; }
	public Date pmtExtractDate { get; private set; }

	private CurrencyConverter currConv;

	public Boolean getPmtExtractDateFilled() {
		return pmtExtractDate != null;
	}

	public GroupProductPortfolioCommBController() {
		clientid = ApexPages.currentPage().getParameters().get('id');
		currConv = new CurrencyConverter();
	}

	public GroupProductPortfolioCommBController(ApexPages.StandardController controller) {
		clientId = controller.getId();
		currConv = new CurrencyConverter();
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

	private void runOnlyIfBoth() {
		computePortfolio();
	}

	private void computePortfolio() {
		AggregateResult[] res = [SELECT product_category__c 			productCategory
									   ,SUM(ytd_debit_balance__c)		ytdDebitBalance
									   ,SUM(ytd_credit_balance__c)		ytdCreditBalance
									   ,SUM(facility_limit__c)			facilityLimit
									   ,SUM(net_interest_income__c)		netInterestIncome
									   ,SUM(non_interest_revenue__c)	nonInterestRevenue
									   ,SUM(operating_income__c)		operatingIncome
									   ,MIN(pmt_extract_date__c)		pmtExtractDate
  								   FROM Account_Information__c
								  WHERE client__c = :clientid
								  GROUP BY product_category__c
								  ORDER BY product_category__c ASC]; // will return in corporate currency

		Date minExtractDate;
		sums = new Map<String, Decimal> { 'ytdDebitBalance' => 0.0
										 ,'ytdCreditBalance' => 0.0
										 ,'facilityLimit' => 0.0
										 ,'netInterestIncome' => 0.0
										 ,'nonInterestRevenue' => 0.0
										 ,'operatingIncome' => 0.0
		};

		groupPortfolios = new List<GPPWrapper>();
		for (AggregateResult r: res) {
			GPPWrapper w = new GPPWrapper();

			w.productCategory = (String)r.get('productCategory');

			// recompute aggregates to the desired currency

			w.ytdDebitBalance = currConv.convertCorporateCurrency((Decimal)r.get('ytdDebitBalance'), currencyIsoCode);
			sums.put('ytdDebitBalance', sums.get('ytdDebitBalance') + w.ytdDebitBalance);

			w.ytdCreditBalance = currConv.convertCorporateCurrency((Decimal)r.get('ytdCreditBalance'), currencyIsoCode);
			sums.put('ytdCreditBalance', sums.get('ytdCreditBalance') + w.ytdCreditBalance);

			w.facilityLimit = currConv.convertCorporateCurrency((Decimal)r.get('facilityLimit'), currencyIsoCode);
			sums.put('facilityLimit', sums.get('facilityLimit') + w.facilityLimit);

			w.netInterestIncome = currConv.convertCorporateCurrency((Decimal)r.get('netInterestIncome'), currencyIsoCode);
			sums.put('netInterestIncome', sums.get('netInterestIncome') + w.netInterestIncome);

			w.nonInterestRevenue = currConv.convertCorporateCurrency((Decimal)r.get('nonInterestRevenue'), currencyIsoCode);
			sums.put('nonInterestRevenue', sums.get('nonInterestRevenue') + w.nonInterestRevenue);

			w.operatingIncome = currConv.convertCorporateCurrency((Decimal)r.get('operatingIncome'), currencyIsoCode);
			sums.put('operatingIncome', sums.get('operatingIncome') + w.operatingIncome);

			if (r.get('pmtExtractDate') != null && minExtractDate == null) {
				minExtractDate = (Date)r.get('pmtExtractDate');
			} else if (r.get('pmtExtractDate') != null && (Date)r.get('pmtExtractDate') < minExtractDate) {
				minExtractDate = (Date)r.get('pmtExtractDate');
			}

			groupPortfolios.add(w);
		}

		pmtExtractDate = minExtractDate;
	}

	public class GPPWrapper {
		public String productCategory { get; set; }
		public Decimal ytdDebitBalance { get; set { ytdDebitBalance = zeroIn(value); } }
		public Decimal ytdCreditBalance { get; set { ytdCreditBalance = zeroIn(value); } }
		public Decimal facilityLimit { get; set { facilityLimit = zeroIn(value); } }
		public Decimal netInterestIncome { get; set { netInterestIncome = zeroIn(value); } }
		public Decimal nonInterestRevenue { get; set { nonInterestRevenue = zeroIn(value); } }
		public Decimal operatingIncome { get; set { operatingIncome = zeroIn(value); } }

		private Decimal zeroIn(Decimal n) {
			return n != null ? n : 0.0;
		}
	}
}