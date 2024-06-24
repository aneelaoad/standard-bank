/**
 * @description An class to getting service type records
 *
 * @author Raja Kumar
 *
 * @date April 2023 */
public with sharing class CMN_FLOW_ComboboxServiceTypeHelper {
    /**
     * @description Get service types records by team Id and account id
     *
     * @param teamId Team Id and account id
     * 
     * @return service types records which is parent of support service type
     */
    
    @InvocableMethod(Label='Get service types records by team Id and Account Id' Description='Get service types records by team Id and Account Id')
    public static List<DTO_ServiceTypeResponse> getServiceTypesByTeam(List<DTO_ServiceTypeRequest> requests) {
        DTO_ServiceTypeResponse result = new DTO_ServiceTypeResponse();
        Set<Id> teamIds = new Set<Id>();
       	Set<Id> accountIds = new Set<Id>();
        Set<Id> serviceTypeIds = new Set<Id>();
        Map<id,String> mapIdToServiceType_Name=new Map<id,String>();
        Map<id,String> mapIdToServiceType_ServiceType=new Map<id,String>();
        Map<id,id> mapSupportServiceTypeIdToServiceTypeId=new Map<id,id>();
		String clientTier='Standard';
                
        for (DTO_ServiceTypeRequest request : requests) {
            teamIds.add(request.teamId);
            accountIds.add(request.AccountId);
            }
		List<Account> getAccountList=SEL_Accounts.newInstance().selectById(AccountIds);
        if(getAccountList.size()!=0 && getAccountList[0].CIB_Service_Tier__c != null){
            clientTier=getAccountList[0].CIB_Service_Tier__c;
        }
       
        
        List<SVC_SupportServiceTypes__c> steams=SEL_SupportServiceType.newInstance().selectByTeamIdAndServiceTier(teamIds,clientTier);
        if(steams.size()!=0){
            for(SVC_SupportServiceTypes__c sst:steams){
                serviceTypeIds.add(sst.Service_Type__c);
                mapSupportServiceTypeIdToServiceTypeId.put(sst.Id, sst.Service_Type__c);
            }
            
        }
        
        List<Service_Type__c> serviceTypeList=SEL_ServiceTypes.newInstance().selectById(serviceTypeIds);
        if(serviceTypeList.size()!=0){
            for(Service_Type__c stypeRec:serviceTypeList){
                mapIdToServiceType_Name.put(stypeRec.id,stypeRec.Name);
                mapIdToServiceType_ServiceType.put(stypeRec.id,stypeRec.ServiceType__c);
            }
            
        }
        
        
        
        List<Service_Type__c> stypes = new List<Service_Type__c>();
        for (SVC_SupportServiceTypes__c item : steams) {
            stypes.add(
                new Service_Type__c(
                    Description__c = item.Id,
                    Name = mapIdToServiceType_Name.get(mapSupportServiceTypeIdToServiceTypeId.get(item.id)),
                    ServiceType__c = mapIdToServiceType_ServiceType.get(mapSupportServiceTypeIdToServiceTypeId.get(item.id))
                )
            );
        }
        result.serviceTypes = stypes;
        return new List<DTO_ServiceTypeResponse>{result};
    }

    /**
     * @description wrapper class with input parameters
     */
    public class DTO_ServiceTypeRequest {

        @InvocableVariable(Label='Team Id' Description='Team Id' Required=true)
        public String teamId;
        @InvocableVariable(Label='Account Id' Description='Account Id' Required=true)
        public String AccountId;

    }

    /**
     * @description wrapper class with output parameters
     */
    public class DTO_ServiceTypeResponse {

        @InvocableVariable(Label='Service Types' Description='List of Service Types' Required=true)
        public List<Service_Type__c> serviceTypes;
    }
}