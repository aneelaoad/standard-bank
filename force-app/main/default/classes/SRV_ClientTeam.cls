public without sharing class SRV_ClientTeam {

    private static Client_Team_Config__mdt[]
    configs {get {  if(configs == null) {
        buildData();
    }
        return configs;
    }
        set;}

    private static Map<String, String> role2SortOrder{get{
        if(role2SortOrder == null){
            buildData();
        }
        return role2SortOrder;
    }
        set;}

    private static void buildData(){
        configs = [ SELECT Unique__c, Field__c, Value__c, Message__c, Role_Sort_Order__c, Account_Access__c,
                Opportunity_Access__c, Case_Access__c, Contact_Access__c, Sort_Order__c, Alternative_Field__c, Alternative_Value__c
        FROM Client_Team_Config__mdt
        ORDER BY Sort_Order__c ASC];
    }

    public static List<ClientTeamInfo> eveluate(Custom_Client_Team__c cct){
        List<ClientTeamInfo> retInfos = new List<ClientTeamInfo>();

        for(Client_Team_Config__mdt conf : configs ){
            if(!conf.Unique__c || conf.Field__c == 'User_Division_Coordinator_Key__c'){
                continue;
            }
            if(UTL_Sobject.isEqual(cct, conf.Field__c, conf.Value__c)){
                ClientTeamInfo ctr = new ClientTeamInfo(cct);
                ctr.isUnique = true;
                ctr.errorMessage = conf.Message__c;
                ctr.field = conf.Alternative_Field__c == null ? conf.Field__c : conf.Alternative_Field__c;
                ctr.value = conf.Alternative_Value__c == null ? conf.Value__c : conf.Alternative_Value__c;
                retInfos.add(ctr);
            }
        }
        return retInfos;
    }

    public static String[] getRequiredFields(){
        String[] fields = new String[]{};

        for(Client_Team_Config__mdt conf : configs){
            if(String.isNotBlank(conf.Field__c)){
                fields.add(conf.Field__c);
            }
        }
        return fields;
    }

    public static Integer getSortOrder(Custom_Client_Team__c cct){

        for(Client_Team_Config__mdt conf : configs){
            if(conf.Role_Sort_Order__c != null
                    && UTL_Sobject.isEqual(cct, conf.Field__c, conf.Value__c) ){
                return Integer.valueOf(conf.Role_Sort_Order__c) ;
            }
        }

        return null;
    }

    public static String getAccessLvl(Custom_Client_Team__c cct, Custom_Client_Team__c oldCct, SObjectType sType ){

        for(Client_Team_Config__mdt conf : configs){
            if(!isActionRequired(cct, oldCct, conf)){
                continue;
            }

            String accessLvl;

            if(sType == Account.SObjectType){
                accessLvl = conf.Account_Access__c;
            }
            else if(sType == Contact.SObjectType){
                accessLvl = conf.Contact_Access__c;
            }
            else if(sType == Opportunity.SObjectType){
                accessLvl = conf.Opportunity_Access__c;
            }
            else if(sType == Case.SObjectType){
                accessLvl = conf.Case_Access__c;
            }

            if(String.isNotBlank(accessLvl)){
                return accessLvl;
            }
        }

        return null;
    }

    private static Boolean isActionRequired(Custom_Client_Team__c record, Custom_Client_Team__c orgRecord,
            Client_Team_Config__mdt conf){

        if(UTL_Sobject.isEqual(record, conf.Field__c, conf.Value__c)){
            if(orgRecord == null){
                return true;
            }
            return UTL_Sobject.readValue(record, conf.Field__c) != UTL_Sobject.readValue(orgRecord, conf.Field__c);
        }
        return false;
    }

    public without sharing class ClientTeamInfo {
        private Custom_Client_Team__c record;
        public Boolean isUnique;
        public String errorMessage;
        public String field;
        public Object value;

        public String code {
            get{
                if(code == null && record != null && field != null){
                    return record.Account__c + '#' +  field + '#' + String.valueOf(UTL_Sobject.readValue(record, field));
                }
                return null;
            }
        }

        public Custom_Client_Team__c getRecord() {
            return record;
        }

        public String getErrorMessage() {
            return  errorMessage;
        }
        public ClientTeamInfo(Custom_Client_Team__c cct){
            this.record = cct;
            isUnique = false;
        }
    }
}