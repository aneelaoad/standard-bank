public with sharing class CI_ClientOverviewController {

    @AuraEnabled
    public static CI_ResponseDto getBankStrategy(String clientId) {

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Account.fields.getMap(), new String[] {'Client_Strategy__c'})){ 
            return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }
        
        Account acc = [SELECT Id, Name, Client_Strategy__c FROM Account where Id =: clientId];

        CI_CardMapModel cmm = new CI_CardMapModel();
        cmm.cardDataMap.put('Text', acc.Client_Strategy__c);
        cmm.cardDataMap.put('Description', 'Bank Strategy');                                  

        return new CI_ResponseDto(cmm);
    }

    @AuraEnabled
    public static CI_ResponseDto getClientStrategy(String clientId) {

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardTextModel ctm = new CI_CardTextModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Account.fields.getMap(), new String[] {'Short_Term_Objectives__c','Long_Term_Strategy__c'})){ 
                return new CI_ResponseDto(false, 'You do not have the required permissions to view this data'); 
        }
        Account acc = [SELECT Id, Name, Short_Term_Objectives__c,Long_Term_Strategy__c FROM Account where Id =: clientId];
        
        CI_CardMapModel cmm = new CI_CardMapModel();
        cmm.cardDataMap.put('ShortTermGoal', acc.Short_Term_Objectives__c);
        cmm.cardDataMap.put('LongTermGoal', acc.Long_Term_Strategy__c);        
        cmm.cardDataMap.put('Description', 'Client Strategy');                                   

        return new CI_ResponseDto(cmm);
    }
    
 
    @AuraEnabled
    public static CI_ResponseDto getCSIRating(String clientId) {

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardMapModel cmm = new CI_CardMapModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Account.fields.getMap(), new String[] { 'Overall_CIB_CSI_Rating_Number__c' })){
                return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');  
        }
        
        Account acc = [SELECT Id, Name, Overall_CIB_CSI_Rating_Number__c FROM Account where Id =: clientId];

        String text = acc.Overall_CIB_CSI_Rating_Number__c!=null?String.valueOf(acc.Overall_CIB_CSI_Rating_Number__c):null;
        cmm.cardDataMap.put('Rating', text);

        List<Client_Satisfaction_Index__c> DivisionsCSI = [SELECT CSI_Survey_Contact__r.name ,Survey_Year__c ,TPS_CSI_Rating_Number__c ,CSI_TPS_Comment__c,GM_CSI_Rating_Number__c, CSI_GM_Comment__c, IB_CSI_Rating_Number__c, CSI_IB_Comment__c from Client_Satisfaction_Index__c where Client__c =: clientId Order by Survey_Year__c desc limit 1];
                 
        if(DivisionsCSI.size()>0) {
            String TPSRating = DivisionsCSI[0].TPS_CSI_Rating_Number__c!=null?String.valueOf(DivisionsCSI[0].TPS_CSI_Rating_Number__c):null;
            String GMRating = DivisionsCSI[0].GM_CSI_Rating_Number__c!=null?String.valueOf(DivisionsCSI[0].GM_CSI_Rating_Number__c):null;
            String IBRating = DivisionsCSI[0].IB_CSI_Rating_Number__c!=null?String.valueOf(DivisionsCSI[0].IB_CSI_Rating_Number__c):null;

            String TPSComment = DivisionsCSI[0].CSI_TPS_Comment__c!=null?DivisionsCSI[0].CSI_TPS_Comment__c:null;
            String GMComment = DivisionsCSI[0].CSI_GM_Comment__c!=null?String.valueOf(DivisionsCSI[0].CSI_GM_Comment__c):null;
            String IBComment = DivisionsCSI[0].CSI_IB_Comment__c!=null?String.valueOf(DivisionsCSI[0].CSI_IB_Comment__c):null;

            cmm.cardDataMap.put('TPSRating', TPSRating);
            cmm.cardDataMap.put('GMRating', GMRating);
            cmm.cardDataMap.put('IBRating', IBRating); 
                        
            cmm.cardDataMap.put('TPSDescription', sharedUtils.CSIDescription(TPSRating));
            cmm.cardDataMap.put('GMDescription', sharedUtils.CSIDescription(GMRating));
            cmm.cardDataMap.put('IBDescription', sharedUtils.CSIDescription(IBRating));  

            cmm.cardDataMap.put('TPSComment', TPSComment);
            cmm.cardDataMap.put('GMComment', GMComment);
            cmm.cardDataMap.put('IBComment', IBComment);     

            cmm.cardDataMap.put('Year', DivisionsCSI[0].Survey_Year__c);

            cmm.cardDataMap.put('SurveyContact', DivisionsCSI[0].CSI_Survey_Contact__r.name);                                                                
        }
     
        cmm.cardDataMap.put('Description', sharedUtils.CSIDescription(text));
                
        cmm.Description = 'CSI Rating';                                    
        return new CI_ResponseDto(cmm);        
    }   

    @AuraEnabled
    public static CI_ResponseDto getRelationshipStatus(String clientId) {   

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardMapModel cmm = new CI_CardMapModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Account.fields.getMap(), new String[] {'Nature_of_Relationship__c','Client_Current_Relationship__c'})){ 
            return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }
        
        Account acc = [SELECT Id, Name, Nature_of_Relationship__c,Client_Current_Relationship__c FROM Account where Id =: clientId];
                    
        String text = acc.Nature_of_Relationship__c!=null?acc.Nature_of_Relationship__c:'None';
        String description = acc.Client_Current_Relationship__c!=null?acc.Client_Current_Relationship__c:'None';
        
        cmm.cardDataMap.put('Status', text);
        cmm.cardDataMap.put('Description', description);
                 
        cmm.Description = 'Relationship Status'; 

        return new CI_ResponseDto(cmm);   
    }     

    @AuraEnabled
    public static CI_ResponseDto getSectorAndSubSubsector(String clientId) {   

        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();
        CI_CardMapModel cmm = new CI_CardMapModel();

        // Check to make sure all fields are accessible to this user
        if(!sharedUtils.canAccessFields(Schema.SObjectType.Account.fields.getMap(), new String[] {'Client_Sector__c','Client_Sub_Sector__c'})){ 
            return new CI_ResponseDto(false, 'You do not have the required permissions to view this data');
        }
        
        Account acc = [SELECT Id, Client_Sector__c, Client_Sub_Sector__c FROM Account where Id =: clientId];
                    
        cmm.cardDataMap.put('Sector', acc.Client_Sector__c);
        cmm.cardDataMap.put('Subsector', acc.Client_Sub_Sector__c);
                 
        cmm.Description = 'Sector'; 

        return new CI_ResponseDto(cmm);   
    }        
}