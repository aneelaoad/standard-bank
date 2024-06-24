public without sharing class UTL_Currency {

	public static final String corporateIsoCode = 'ZAR';

	private static Map<String, ConvertRate> isoCode2ConvertRate{
																	get{
																		if(isoCode2ConvertRate == null){
																			collectData();
																		}
																		return isoCode2ConvertRate;
																	}
																	set;
																}

	private static Boolean isUseArchival = false;
	private static Integer scale = 2;

	public void setScale(Integer scaleToSet){
		scale = scaleToSet;
	}

	public static void useArchival(){	
		if(!isUseArchival && isoCode2ConvertRate != null){
			isoCode2ConvertRate = null;
		}
		isUseArchival = true;
	}

	public static String[] getCurrencies(){ 
		List<String> currencies =  new List<String>(isoCode2ConvertRate.keyset());
		currencies.sort();
		return currencies;
	}

	private static void collectData(){

		String dataString = 'SELECT IsoCode, CreatedDate, StartDate, NextStartDate, Conversionrate FROM DatedConversionRate ';

		if(!isUseArchival){
			dataString += ' WHERE NextStartDate > TODAY AND  StartDate <= TODAY ';
		}
		dataString += ' ORDER BY CreatedDate DESC ';

		DatedConversionRate[] rates = Database.query(dataString);

		isoCode2ConvertRate = new Map<String, ConvertRate>();
		for(DatedConversionRate rate : rates){
			if(!isoCode2ConvertRate.containsKey(rate.isoCode)){
				isoCode2ConvertRate.put(rate.isoCode, new ConvertRate(rate.isoCode));
			}
			isoCode2ConvertRate.get(rate.isoCode).apply(rate);
		}
	}

	public static Decimal convert(Decimal value, String fromCurrency, String toCurrency){
		DateTime placeholder = null;
		return convert(value, fromCurrency, toCurrency, placeholder);
	}

	public static Decimal convert(Decimal value, String fromCurrency, String toCurrency, Date convertionDate){
		return convert(value, fromCurrency, toCurrency, DateTime.valueOf(convertionDate));
	}

	public static Decimal sumUp(SObject[] dataSources, String fieldName, String currencyCode){
		if(!isoCode2ConvertRate.containsKey(currencyCode)){
			throw new UTL_CurrencyException('No currency information for: ' + currencyCode);
		}

		Decimal sum = 0.0;
		try {
			for(SObject sObj : dataSources){
				Decimal value 	= (Decimal)sObj.get(fieldName);
				String recordCurrency = (String)sObj.get('CurrencyIsoCode');

				if(recordCurrency == null){
					throw new UTL_CurrencyException('No currency information for sObject With Id: ' + sObj.get('Id'));
				}
				if(value == null){
					continue;
				}

				sum += convert(value, recordCurrency, currencyCode);
			}
		} catch(Exception e) {
			throw new UTL_CurrencyException('Error Durring calculation: ' + e.getMessage());
		}
		return sum;
	}	
	
	public static Decimal convert(Decimal value, String fromCurrency, String toCurrency, DateTime convertionDate){

		if(convertionDate != null && !isUseArchival){
			useArchival();
		}

		if(value == null){
			throw new UTL_CurrencyException('You must provide value!');
		}
		else if (String.isBlank(fromCurrency)) {
			throw new UTL_CurrencyException('You must provide fromCurrency!');
		}
		else if (String.isBlank(toCurrency)) {
			throw new UTL_CurrencyException('You must provide toCurrency!');
		}
		else if (!isoCode2ConvertRate.containsKey(fromCurrency)) {
			throw new UTL_CurrencyException('No Data for currency: ' + fromCurrency);
		}
		else if (!isoCode2ConvertRate.containsKey(toCurrency)) {
			throw new UTL_CurrencyException('No Data for currency: ' + toCurrency);
		}

		Decimal fromCurrencyWeight 	= isoCode2ConvertRate.get(fromCurrency).getRate(convertionDate);
		Decimal toCurrencyWeight 	= isoCode2ConvertRate.get(toCurrency).getRate(convertionDate);

		if(fromCurrencyWeight == null) {
			throw new UTL_CurrencyException('No Convert rate for currency ' + fromCurrency);
		}
		else if (fromCurrencyWeight == 0) {
			throw new UTL_CurrencyException('Convert rate 0 for currency ' + fromCurrency);
		}
		else if(toCurrencyWeight == null) {
			throw new UTL_CurrencyException('No Convert rate for currency ' + toCurrency);
		}
		else if (toCurrencyWeight == 0) {
			throw new UTL_CurrencyException('Convert rate 0 for currency ' + toCurrency);
		}

		Decimal result;

		try {
			result = value / fromCurrencyWeight * toCurrencyWeight;
			result = result.setScale(scale);
		} 
		catch(Exception e) {
			throw new UTL_CurrencyException('Error when converting currency: ' + e.getMessage());
		}
		return result; 
	}

	public class ConvertRate {
		private String 	isoCode;
		private ConvertRateItem currentRate;
		private ConvertRateItem[] convertRateItems; 

		public ConvertRate(String isoCode){
			this.isoCode = isoCode;
			convertRateItems = new ConvertRateItem[]{};
		} 

		public void apply(DatedConversionRate dcr){
			if(dcr.isoCode != isoCode){
				throw new UTL_CurrencyException('Wrong ConvertRateItem(' + dcr.isoCode+ ') for ConvertRate(' + isoCode + ')');
			}

			ConvertRateItem cri = new ConvertRateItem(dcr);
			if(	currentRate == null
				||
				(	cri.startDate <= System.today() 
					&& cri.nextStartDate >= System.today()
					&& cri.startDate >= currentRate.startDate
					&& cri.createdDate > currentRate.createdDate)){
				currentRate = cri;
			}
			
			convertRateItems.add(cri);
		}

		public Decimal getRate(Date convertionDate){
			return getRate(DateTime.valueOf(convertionDate));
		}

		public Decimal getRate(){
			DateTime placeholder = null;
			return getRate(placeholder);
		}

		public Decimal getRate(DateTime convertionDate){
			if(UTL_Currency.isUseArchival || convertionDate == null){
				return currentRate.conversionrate;
			}

			for(ConvertRateItem cri : convertRateItems){
				if(cri.isInRange(convertionDate)){
					return cri.getRate();
				}
			}
			throw new  UTL_CurrencyException('No Rate for this Date');
		}
	}

	public class ConvertRateItem {
		private DateTime 	createdDate,
 							startDate,
							nextStartDate;
		private Decimal 	conversionrate;

		public ConvertRateItem(DatedConversionRate dcr){
			createdDate		= dcr.CreatedDate;
			startDate		= dcr.StartDate;
			nextStartDate	= dcr.NextStartDate;
			conversionrate	= dcr.Conversionrate;
		}

		public Boolean isInRange(Date convertionDate){
			return isInRange(DateTime.valueOf(convertionDate));
		}

		public Boolean isInRange(DateTime convertionDate){

			if((	createdDate <= convertionDate
					&&  startDate <= convertionDate)
				&& nextStartDate >= convertionDate){
				return true;
			}
			return false;
		}

		public Decimal getRate(){
			return conversionrate;
		}
	}

	public class UTL_CurrencyException extends Exception {}
}