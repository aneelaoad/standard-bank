public without sharing class CI_CreditController {
    @AuraEnabled
    public static CI_ResponseDto getInternalCreditRating(String clientId) {   

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardMapModel cmm = new CI_CardMapModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Account.fields.getMap(), new String[] {'Internal_Credit_Rating__c'})){ 
                return new CI_ResponseDto(false, 'You do not have the required permissions to view this data.');    
        }            
        Account acc = [SELECT Id, Name, Internal_Credit_Rating__c FROM Account where Id =: clientId];
                    
        String text = acc.Internal_Credit_Rating__c!=null?acc.Internal_Credit_Rating__c:'None';
        cmm.cardDataMap.put('Description', 'Ratings');
        cmm.cardDataMap.put('Rating', text);
                            
        cmm.Description = 'Ratings';                                      
        return new CI_ResponseDto(cmm);        
    }
    
    @AuraEnabled
    public static CI_ResponseDto getCreditUtilisation(String clientId) {   

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardMapModel ctm = new CI_CardMapModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Credit_Line__c.fields.getMap(), new String[] {'Credit_Limit__c', 'Total_utilisation__c', 'Product__c', 'Name', 'CurrencyIsoCode'})){ 
                return new CI_ResponseDto(false, 'Permission error'); 
        }            
        
        List<Credit_Line__c> creditLines = [SELECT Id, Credit_Limit__c, Total_utilisation__c, Product__c, CurrencyIsoCode, Name from Credit_Line__c where Client_Name__r.Id =: clientId];

        Integer facilitiesCount = creditLines.size();
        Integer inExcessCount = 0;
        Decimal creditTotal = 0;
        Decimal utilisationTotal = 0;
        Decimal percentCreditUsed = 0;
        Decimal percentCreditAvail = 0;

        CI_SharedUtilities.CurrencyConverter currConverter =  new CI_SharedUtilities.CurrencyConverter();

        for (Integer i = 0; i < facilitiesCount; i++) {
            creditTotal += currConverter.convert(Double.valueOf(creditLines[i].Credit_Limit__c), String.valueOf(creditLines[i].CurrencyIsoCode), 'ZAR');
            utilisationTotal += currConverter.convert(Double.valueOf(creditLines[i].Total_utilisation__c), String.valueOf(creditLines[i].CurrencyIsoCode), 'ZAR');

            if (creditLines[i].Total_utilisation__c > creditLines[i].Credit_Limit__c)
                inExcessCount++;
        }

        if(facilitiesCount > 0){
            
            if(creditTotal > 0)//creditTotal can be zero because Credit_Limit__c can be zero for some reason
                percentCreditUsed = (utilisationTotal / creditTotal) * 100;
            
            percentCreditAvail = 100 - percentCreditUsed;
            if (percentCreditAvail < 0)//Gone into excess, make percentCreditAvail = 0
                percentCreditAvail = 0;
        }
        else
        {
            //No credit facilities, fill bar with grey emptyness
            percentCreditAvail = 100;
        }

        CI_CardMapModel cmm = new CI_CardMapModel();
        cmm.cardDataMap.put('facilitiesCount', String.valueOf(facilitiesCount));
        cmm.cardDataMap.put('inExcessCount', String.valueOf(inExcessCount));
        cmm.cardDataMap.put('creditTotal', String.valueOf(creditTotal));
        cmm.cardDataMap.put('utilisationTotal', String.valueOf(utilisationTotal));
        cmm.cardDataMap.put('percentCreditUsed', String.valueOf(percentCreditUsed));
        cmm.cardDataMap.put('percentCreditAvail', String.valueOf(percentCreditAvail));
        
        return new CI_ResponseDto(cmm);        
    }

    @AuraEnabled
    public static CI_ResponseDto getCreditLines(String clientId) {
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardMapModel ctm = new CI_CardMapModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Credit_Line__c.fields.getMap(), new String[] {'Credit_Limit__c', 'Total_utilisation__c', 'Limit_Tenor__c', 'Product__c', 'Name', 'CurrencyIsoCode'})){ 
                return new CI_ResponseDto(false, 'Permission error'); 
        }            
        
        List<Credit_Line__c> creditLines = [SELECT Id, Limit_Tenor__c, Credit_Limit__c, Total_utilisation__c, Product__c, CurrencyIsoCode, Name from Credit_Line__c where Client_Name__r.Id =: clientId order by Product__c, Credit_Limit__c];

        CI_SharedUtilities.CurrencyConverter currConverter =  new CI_SharedUtilities.CurrencyConverter();
        for(Credit_Line__c creditLine : creditLines) {
            creditLine.Credit_Limit__c = currConverter.convert(Double.valueOf(creditLine.Credit_Limit__c), String.valueOf(creditLine.CurrencyIsoCode), 'ZAR');
            creditLine.Total_utilisation__c = currConverter.convert(Double.valueOf(creditLine.Total_utilisation__c), String.valueOf(creditLine.CurrencyIsoCode), 'ZAR');
        }

        return new CI_ResponseDto(creditLines);
    } 

    @AuraEnabled
    public static CI_ResponseDto getCreditRiskRating(String clientId) {  

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardMapModel cmm = new CI_CardMapModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Account.fields.getMap(), new String[] {'Internal_Credit_Rating__c'})){ 
                return new CI_ResponseDto(false, 'You do not have the required permissions to view this data.');    
        }               
        Account acc = [SELECT Id, Name, Internal_Credit_Rating__c FROM Account where Id =: clientId];
                    
        String text = acc.Internal_Credit_Rating__c!=null?acc.Internal_Credit_Rating__c:'None';

        //These are 2 values where there is no PD rating present
        if(text == 'None' || text == 'Not Available in CRS')
            cmm.cardDataMap.put('Rating', 'None');
        else
        {
            List<Probability_of_default__c> rating = [SELECT Fitted_PD__c FROM Probability_of_default__c where Name =: text];
            if(rating.size()==0){
                cmm.cardDataMap.put('Rating', 'None');
            }else{
                cmm.cardDataMap.put('Rating', rating[0].Fitted_PD__c);
            }
        }

        cmm.Description = 'Credit Risk Rating';                                   
        return new CI_ResponseDto(cmm);        
    }

    @AuraEnabled
    public static CI_ResponseDto getRiskAppetite(String clientId) {
        
        List<Account> account = [SELECT Client_Sub_Sector__c, Country_Risk__c
                                FROM Account
                                WHERE Id =: clientId];

        account[0].Country_Risk__c = account[0].Country_Risk__c != null ? account[0].Country_Risk__c : 'Unknown';

        Boolean found = false;
        for (AggregateResult countries : [SELECT Country__c FROM Credit_Risk_Appetite__c GROUP BY Country__c])  
            if(account[0].Country_Risk__c == countries.get('Country__c'))
                found = true;

        if(!found)
            account[0].Country_Risk__c = 'Unknown';

        List<Credit_Risk_Appetite__c> riskAppetite = [SELECT Country_Credit_Appetite__c 
                                                        FROM Credit_Risk_Appetite__c
                                                        WHERE Country__c =: account[0].Country_Risk__c
                                                        AND Sub_Sector__c =: account[0].Client_Sub_Sector__c];

        CI_CardMapModel cmm = new CI_CardMapModel();
        
        if(riskAppetite.size() == 0)
            return new CI_ResponseDto(cmm);

        cmm.cardDataMap.put('Credit_Risk_Appetite__c', String.valueOf(riskAppetite[0].Country_Credit_Appetite__c));

        return new CI_ResponseDto(cmm);
    }       
}