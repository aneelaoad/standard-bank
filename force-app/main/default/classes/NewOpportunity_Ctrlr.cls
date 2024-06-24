public with sharing class NewOpportunity_Ctrlr {

    @AuraEnabled
    public Opportunity oppRecord;
    @AuraEnabled
    public String[] additionalFields;
    @AuraEnabled
    public Boolean isCommBUser;
    @AuraEnabled
    public DTO_SelectOption[] stages;

    private static Id userId = UserInfo.getUserId();
    @TestVisible private static final String LEAD_OPPORTUNITY_PICKLIST_CATEGORY = 'Lead Opportunity Sales Process';

    @AuraEnabled
    public static NewOpportunity_Ctrlr getOpportunityData(String sObjectName, Id recordId) {
        SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectName);
        if (sObjType == null) {
            throw new AuraHandledException('SObject Type ' + sObjectName + ' does not exist.');
        }

        NewOpportunity_Ctrlr response = new NewOpportunity_Ctrlr();

        response.additionalFields = getAdditionalFields(sObjType);
        response.oppRecord = getPrepopulatedOpportunity(recordId);
        response.isCommBUser = UTL_User.isCommBUser(userId);
        response.stages = new DTO_SelectOption[]{};
        for (SelectOption selOption :  UTL_GlobalPicklistValues.getPicklist(LEAD_OPPORTUNITY_PICKLIST_CATEGORY)) {
            response.stages.add(new DTO_SelectOption(selOption));
        }

        return response;
    }

    @AuraEnabled
    public static Id save(Opportunity oppRecord, Id recordId) {
        Savepoint sp = Database.setSavepoint();
        try {
            insert oppRecord;
            if (recordId != null && recordId.getSobjectType() == Contact.SObjectType) {
                insert new OpportunityContactRole(
                    ContactId = recordId
                , OpportunityId = oppRecord.Id
                );
            }
            return oppRecord.Id;
        } catch (Exception e) {
            Database.rollback(sp);
            String errmsg=e.getMessage();
            if(errmsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
               String errmsg1=errmsg.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,').get(1); 
               String errmsg2=errmsg1.split(':').get(0); 
                throw new AuraHandledException(errmsg2);
                
                }
            throw new AuraHandledException(e.getMessage());
            return null;
        }
    }

    private static Map<SObjectType, SObjectField[]> sObjectType2AdditionalFields = new Map<SObjectType, SObjectField[]>{
        Opportunity.SObjectType => new SObjectField[]{
            Opportunity.Parent_Opportunity__c
            , Opportunity.Primary_Event_Report_Source__c
            , null
            , Opportunity.Game_Changer__c
        },
        Contact.SObjectType => new SObjectField[]{
            null
            , Opportunity.Primary_Event_Report_Source__c
            , null
            , Opportunity.Game_Changer__c
        },
        Call_Report__c.SObjectType => new SObjectField[]{
            null
            , Opportunity.Primary_Event_Report_Source__c
            , null
            , Opportunity.Game_Changer__c
        },
        Game_Changer__c.SObjectType => new SObjectField[]{
            null
            , Opportunity.Game_Changer__c
        },
        Campaign.SObjectType => new SObjectField[]{
            null
            , Opportunity.CampaignId
        },
        Account.SObjectType => new SObjectField[]{
            null
            , Opportunity.Game_Changer__c
        }
    };

    @TestVisible private static SObjectField[] commBAdditionalFields = new SObjectField[]{
        Opportunity.Parent_Opportunity__c
        , Opportunity.CampaignId
    };

    private static String[] getAdditionalFields(SObjectType sObjType) {
        SObjectField[] additionalFields;
        if (UTL_User.isCommBUser(userId)) {
            additionalFields = commBAdditionalFields;
        }
        else if (sObjectType2AdditionalFields.containsKey(sObjType)) {
            additionalFields = sObjectType2AdditionalFields.get(sObjType);
        }
        else {
            return null;
        }

        String[] results = new String[]{};
        for (SObjectField sObjField : additionalFields) {
            String fieldName = sObjField == null ? '' : String.valueOf(sObjField);
            results.add(fieldName);
        }
        return results;
    }

    private static Map<SObjectType, Map<SObjectField, SObjectField>> sObjectType2PrepopulatedFields = new Map<SObjectType, Map<SObjectField, SObjectField>>{
        Contact.SObjectType => new Map<SObjectField, SObjectField>{
            Contact.AccountId => Opportunity.AccountId
        },
        Call_Report__c.SObjectType => new Map<SObjectField, SObjectField>{
            Call_Report__c.Id => Opportunity.Primary_Event_Report_Source__c
            , Call_Report__c.Relate_to_Client__c => Opportunity.AccountId
        },
        Game_Changer__c.SObjectType => new Map<SObjectField, SObjectField>{
            Game_Changer__c.Id => Opportunity.Game_Changer__c
        },
        Campaign.SObjectType => new Map<SObjectField, SObjectField>{
            Campaign.Id => Opportunity.CampaignId
        },
        Opportunity.SObjectType => new Map<SObjectField, SObjectField>{
            Opportunity.Id => Opportunity.Parent_Opportunity__c
            , Opportunity.AccountId => Opportunity.AccountId
        },
        Account.SObjectType => new Map<SObjectField, SObjectField>{
            Account.Id => Opportunity.AccountId
        }
    };

    private static Opportunity getPrepopulatedOpportunity(Id recordId) {
        try {
            Opportunity oppRecord = new Opportunity();

            if (recordId == null) {
                return oppRecord;
            }

            SObjectType sObjType = recordId.getSobjectType();

            Map<SObjectField, SObjectField> recordFields2OppFields = sObjectType2PrepopulatedFields.get(sObjType);
            if (recordFields2OppFields == null) {
                return oppRecord;
            }

            String query = 'SELECT ';
            for (SObjectField sObjField : recordFields2OppFields.keySet()) {
                query += String.valueOf(sObjField) + ', ';
            }
            query = query.removeEnd(', ');

            query += ' FROM ' + String.valueOf(sObjType);
            query += ' WHERE Id = :recordId';

            SObject sObj = Database.query(query);

            for (SObjectField sObjField : recordFields2OppFields.keySet()) {
                oppRecord.put(recordFields2OppFields.get(sObjField), sObj.get(sObjField));
            }

            return oppRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            return new Opportunity();
        }

    }

}