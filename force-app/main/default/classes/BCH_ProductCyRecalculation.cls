/**
 * Bach class to recalculate the current year fees and margin
 * on product records at the start of each year
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		February 2021
 *
 * @Last Modified By   : Dzianisik Maksim
 * @Last Modified on   : Sep. 2021
 * @description        : SFP-6290 Added logic for recalculating Current_Year_Commission__c for Insurance Product
 *
 * @Last Modified By    : Dzianisik Maksim
 * @Last Modified on    : Feb. 2022
 * @description         : SFP-9856
 *      1)in start method -     removed checking using RecordType, now the Batch class has to update all Products that have Estimated Revenue Schedules.
 *      2)in execute method -   updated calculation approach, aggregate SOQL query returns values for currency fields in the default currency,
 *                              multiplying the result on the exchange rate can return a little bit different value than summarize values from ERS.
 *                              Fixed bug for correct calculation if there are no ERS for the current year.
 * 
 * @Last Modified By    : Dzianisik Maksim
 * @Last Modified on    : Jan. 2023
 * @description         : SFP-21196 Added Opportunity Lead stage to the filter logic to the start method
*/
public with sharing class BCH_ProductCyRecalculation implements Database.Batchable<SObject>, Database.Stateful{
    @TestVisible private Map<Id, String> failedRecId2ErrorMessage = new Map<Id, String>();
    public static final String CRM_HELPDESK_SB_PARAMETER_NAME = 'CRMHelpdeskEmail';
    /**
    * @description Overridden start Batchable method
    *
    * @param bcContext default reference to Database.BatchableContext
    * @return QueryLocator object for a SELECT query
    */
    public Database.QueryLocator start(Database.BatchableContext bcContext){
        String developStage = DMN_Opportunity.ST_DEVELOP;
        String leadStage = DMN_Opportunity.ST_LEAD;
        String query = 'SELECT Id, Current_Year_Margin__c, Current_Year_Commission__c,' +
                            ' Current_Year_Fees__c, Total_Fees__c, Total_Margin__c, Total_Commission__c' +
                        ' FROM SB_Product__c' +
                        ' WHERE Id IN (SELECT Product__c FROM Estimated_Revenue_Schedule__c)' +
                        ' AND (Opportunity__r.StageName = :developStage OR Opportunity__r.StageName = :leadStage)' +
                        ' AND Client__c != NULL';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Overridden execute Batchable method
    *
    * @param bcContext default reference to Database.BatchableContext
    * @param prodsList list of SB_Product__c records
    */
    public void execute(Database.BatchableContext bcContext, List<SB_Product__c> prodsList) {

        Map<Id, SB_Product__c> id2Product = new Map<Id, SB_Product__c>(prodsList);
        Map<Id, CalculationWrapper> id2CalculationWrapper = new Map<Id, CalculationWrapper>();
        List<SB_Product__c> prodsForUpdate = new List<SB_Product__c>();

        List<Estimated_Revenue_Schedule__c> actualErs = [
                SELECT Fee_Amount__c, Margin_Amount__c, Commission_Amount__c, Product__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c IN: id2Product.keySet()
                AND Estimated_Revenue_Date__c = THIS_YEAR
                ORDER BY Product__c
        ];

        for (Estimated_Revenue_Schedule__c tempErs : actualErs) {
            Id productId = tempErs.Product__c;
            if(id2CalculationWrapper.containsKey(productId)) {
                CalculationWrapper tempWrapper = id2CalculationWrapper.get(productId);
                id2CalculationWrapper.put(productId, calculateWrapper(tempWrapper, tempErs));
            }else {
                CalculationWrapper tempWrapper = new CalculationWrapper(id2Product.get(productId));
                id2CalculationWrapper.put(productId, calculateWrapper(tempWrapper, tempErs));
            }
        }

        for(Id productId : id2Product.keySet()) {
            if(id2CalculationWrapper.containsKey(productId)) {
                if(shouldRecalculate(id2Product.get(productId), id2CalculationWrapper.get(productId))) {
                    prodsForUpdate.add(updateProductValues(id2Product.get(productId), id2CalculationWrapper.get(productId)));
                }
            } else {
                if(shouldRecalculate(id2Product.get(productId), null)) {
                    prodsForUpdate.add(updateProductValues(id2Product.get(productId), null));
                }
            }
        }

        if (prodsForUpdate.size() > 0) {
            updateAndProcessErrors(prodsForUpdate);
        }
    }

    /**
    * @description Overridden finish Batchable method to send emails to CRM HelpDesk
    *
    * @param bcContext default reference to Database.BatchableContext
    */
    public void finish(Database.BatchableContext bcContext) {
        if (failedRecId2ErrorMessage.size() > 0) {
            sendEmails();
        }
    }

    private void updateAndProcessErrors(List<SB_Product__c> prodsForUpdate) {
        Database.SaveResult[] srList = Database.update(prodsForUpdate, false);
        String errorMessage = '';
        for (Integer i = 0; i < srList.size(); i++) {
            if (!(srList[i].isSuccess())) {
                for (Database.Error err : srList[i].getErrors()) {
                    errorMessage = err.getStatusCode() + ': ' + err.getMessage();
                    failedRecId2ErrorMessage.put(prodsForUpdate.get(i).Id, errorMessage);
                }
            }
        }
    }

    @TestVisible
    private void sendEmails() {
        SB_Parameters__c crmHelpdeskEmail = SB_Parameters__c.getValues(CRM_HELPDESK_SB_PARAMETER_NAME);
        String toAddress;
        if (crmHelpdeskEmail != null) {
            toAddress = crmHelpdeskEmail.Value__c;
        }
        String subject = 'Batch BCH_ProductCyRecalculation failures';
        String body = '';
        for (Id prodId : failedRecId2ErrorMessage.keySet()) {
            body += '<b>PRODUCT_ID:</b> '+ prodId + ', <b>ERROR_MESSAGE:</b> ' + failedRecId2ErrorMessage.get(prodId) + '<br /><br />';
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {
                UTL_Email.createEmails(subject, body, new List<String> { toAddress })
        };
        Messaging.sendEmail(emails);
    }

    private static CalculationWrapper calculateWrapper(CalculationWrapper wrapper, Estimated_Revenue_Schedule__c ers) {
        if(wrapper.sumCyFee != null) {
            wrapper.sumCyFee += ers.Fee_Amount__c != null ? ers.Fee_Amount__c : 0.0;
        }
        if(wrapper.sumCyMargin != null) {
            wrapper.sumCyMargin += ers.Margin_Amount__c != null ? ers.Margin_Amount__c : 0.0;
        }
        if(wrapper.sumCyCommission != null) {
            wrapper.sumCyCommission += ers.Commission_Amount__c != null ? ers.Commission_Amount__c : 0.0;
        }
        return wrapper;
    }

    private static Boolean shouldRecalculate(SB_Product__c product, CalculationWrapper wrapper) {
        Boolean shouldRecalculate = false;

        if(wrapper != null) {
            shouldRecalculate = (product.Current_Year_Fees__c != wrapper.sumCyFee ||
                    product.Current_Year_Margin__c != wrapper.sumCyMargin ||
                    product.Current_Year_Commission__c != wrapper.sumCyCommission);
        } else {
            shouldRecalculate = (!((product.Current_Year_Fees__c == null || product.Current_Year_Fees__c == 0) &&
                    (product.Current_Year_Margin__c == null || product.Current_Year_Margin__c == 0) &&
                    (product.Current_Year_Commission__c == null || product.Current_Year_Commission__c == 0)));
        }

        return shouldRecalculate;
    }

    private static SB_Product__c updateProductValues(SB_Product__c product, CalculationWrapper wrapper) {
        if (wrapper != null) {
            product.Current_Year_Fees__c = wrapper.sumCyFee;
            product.Current_Year_Margin__c = wrapper.sumCyMargin;
            product.Current_Year_Commission__c = wrapper.sumCyCommission;
        } else {
            product.Current_Year_Fees__c = product.Total_Fees__c != null ? 0.0 : null;
            product.Current_Year_Margin__c = product.Total_Margin__c != null ? 0.0 : null;
            product.Current_Year_Commission__c = product.Total_Commission__c != null ? 0.0 : null;
        }
        return product;
    }

    private class CalculationWrapper {
        Decimal sumCyFee;
        Decimal sumCyMargin;
        Decimal sumCyCommission;

        /**
         * @param product SB_Product__c
         * @description class constructor
         */
        public CalculationWrapper(SB_Product__c product) {
            this.sumCyFee = product.Total_Fees__c != null ? 0.0 : null;
            this.sumCyMargin = product.Total_Margin__c != null ? 0.0 : null;
            this.sumCyCommission = product.Total_Commission__c != null ? 0.0 : null;
        }
    }
}