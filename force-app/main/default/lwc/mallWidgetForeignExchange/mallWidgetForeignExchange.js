import { LightningElement, track } from 'lwc';
import getCurrencyExchangeRates from '@salesforce/apex/CTRL_MallDashboardWidgets.getCurrencyExchangeRates';

const MALL_WIDGET_FOREIGN_EXCHANGE_HEADING = "Global Exchange Rate";
export default class MallWidgetForeignExchange extends LightningElement {
    //Need to remove this check when we have data that passes through here.
    resultData = true;
    heading = MALL_WIDGET_FOREIGN_EXCHANGE_HEADING;
    countryName = "South African Rand";
    countryFlag = "/mall/resource/1697611117000/sbgVisualAssets/flag-south-africa.svg";
    countryCurrency = "ZAR";
    countryValue = "1.00";

    @track list = [];

    connectedCallback() {
        setTimeout(() => {
            this.getCurrencyExchangeRatesByBaseCode("ZAR");
        }, 1000);
    }

    async getCurrencyExchangeRatesByBaseCode(baseCode) {
        try {
            let currenciesToBeShown = ["USD", "EUR", "JPY", "GBP", "CHF", "NGN", "KES", "EGP", "AOA", "UGX"];
            let currenciesObject = {
                "USD" : "U.S. dollar", 
                "EUR": "Euro", 
                "JPY" : "Japanese yen", 
                "GBP" : "Great Britain pound (sterling)", 
                "CHF" : "Swiss Franc", 
                "NGN" : "Nigerian Naira", 
                "KES" : "Kenyan Shilling", 
                "EGP" : "Egyptian Pound",
                "AOA" : "Angolan Kwanza",
                "UGX" : "Ugandan Shilling"
            }

            let rateResponse = await getCurrencyExchangeRates({baseCode: baseCode})
            if(rateResponse.message.result == "success") {
                let conversionRates = rateResponse.message.conversion_rates;
                let formattedConversionRates = [];
                for (const property in conversionRates)  {
                    if(currenciesToBeShown.includes(property)) {
                        let conversionRate = {};
                        conversionRate["id"] = property;
                        conversionRate["currencyCode"] = property;
                        conversionRate["name"] = currenciesObject[property];
                        conversionRate["currencyCode"] = property;
                        conversionRate["value"] = conversionRates[property];
                        formattedConversionRates.push(conversionRate);
                    }
                }
                this.list = [...formattedConversionRates];
            }
        } catch(error) {
            this.error;
        }
    }
}