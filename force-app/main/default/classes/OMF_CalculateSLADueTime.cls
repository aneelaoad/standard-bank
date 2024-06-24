/**
 * @description  Invocable Apex to calculate SLADueTime as per SLA Hours and Business Hours
 * @author Manisha
 * @company Absyz
 * @test Class OMF_CalculateSLADue_Time
 * @JIRA Tickets   SFP-19606
 */
@SuppressWarnings('PMD.ApexDoc,PMD.LocalVariableNamingConventions')
public with sharing class OMF_CalculateSLADueTime {
    
    @InvocableMethod(label='Get SLADueTime as per Business Hours' description='Returns the SLADueTime for each stage of Managed Fund as per Business Hours' category='Managed Fund Status')
   /**
     * @description Calculate the SLA hours based on business hours and stage.
     * @param managedFundStages A list of strings representing managed fund stages.
     * @return SLA Due Time calculated based on provided business hours and stage.
     */
    public static List<Datetime> getSLADueTime(List<String> managedFundStage) {
        
        List<String> listCurrentStage = managedFundStage;
        Datetime datetimeActualSLADueTime;
        List<Datetime> listSlaDueTime = new List<Datetime>();
        map<String,String>mapStageNameBySearchString = new map<String,String>();
        DateTime currentTime = system.now();
        
        //***Fetch Business Hours assigned for each stage of Managed fund***
        for(String strCurrentStage : listCurrentStage){
            String strSearchString = ((strCurrentStage == 'OSD') ? '%OMF_OSD%' : '%OMF_BusinessHours%');
            mapStageNameBySearchString.put(strSearchString,strCurrentStage);
        }
        
        //***Fetch Business Hours assigned for each stage of Managed fund***
        BusinessHours[] assignedbusinesshour = [SELECT 
                                                Id, 
                                                Name,
                                                TimeZoneSidKey 
                                                FROM 
                                                BusinessHours 
                                                WHERE 
                                                Name LIKE : mapStageNameBySearchString.keySet()];
        
        Map<String, BusinessHours> mapBusinessHoursByStageName = new Map<String, BusinessHours>();
        
        for(BusinessHours objBusinessHours :assignedbusinesshour){
            String strSearchString = (objBusinessHours.Name.contains('OMF_OSD') ? '%OMF_OSD%' : '%OMF_BusinessHours%');
            mapBusinessHoursByStageName.put(mapStageNameBySearchString.get(strSearchString), objBusinessHours);
        }
        
        //***Fetch the SLA hours allocated to each stage of Managed Fund from OMF_ManagedFundRules__c object***
        
        Id slaRecordTypeId = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        
        OMF_ManagedFundRules__c[] managedFundRule = new SEL_OMF_ManagedFundRules().selectedManagedFundRulesWithStatus(listCurrentStage, slaRecordTypeId);
        
        Map<String, OMF_ManagedFundRules__c> mapManagedFundRuleByStageName = new Map<String, OMF_ManagedFundRules__c>();
        
        for (OMF_ManagedFundRules__c rule : managedFundRule) {
            mapManagedFundRuleByStageName.put(rule.Stage__c, rule);
        }
        for(String strManagedFundStage : managedFundStage){
            if(mapManagedFundRuleByStageName.containsKey(strManagedFundStage)){
                Decimal decAllotedSLAHours = mapManagedFundRuleByStageName.get(strManagedFundStage).SLAHours__c;
                if(mapBusinessHoursByStageName.containsKey(strManagedFundStage)){
                    if(BusinessHours.isWithin(mapBusinessHoursByStageName.get(strManagedFundStage).Id, currentTime)) {
                        datetimeActualSLADueTime = BusinessHours.add(mapBusinessHoursByStageName.get(strManagedFundStage).Id, currentTime, (Long)(decAllotedSLAHours * 60 * 60 * 1000L));
                    }
                    else {
                        Datetime nextBusinessHour = BusinessHours.nextStartDate(mapBusinessHoursByStageName.get(strManagedFundStage).Id, currentTime);
                        // Calculate the SLA using the next business hour
                        datetimeActualSLADueTime = BusinessHours.add(mapBusinessHoursByStageName.get(strManagedFundStage).Id, nextBusinessHour, (Long)(decAllotedSLAHours * 60 * 60 * 1000L)); // SLA is 4 hours from next business hour
                        
                    }
                }
            }
            listSlaDueTime.add(datetimeActualSLADueTime);
        }
        return listSlaDueTime;
    }
}