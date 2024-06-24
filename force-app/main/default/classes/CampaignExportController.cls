/*****************************************************************************************************\
    @ Func Area     : Campaigns, Campaign Members and Member hosts.
    @ Author        : Rudolf Niehaus
    @ Date          : 02/2011
    @ Test File     : TestCampaignMemberHostController
    @ Description   : Case#1168
                      Controller class for the Visualforce pages CampaignMemberToExcel.page. The controller creates an Excel export file
                      per 2500 campaign members. The reason for this it to overcome the SF limits per visualforce page. 
   
    @ Last Modified By  :   Stephen Moore
    @ Last Modified On  :    25/04/2012
    @ Modification Description : remove preferred_language__c and replace it with sa_preferred_language__c
                             C-00003926 Delete Preferred Language (See line 51)
    
    @ Last Modified By  :   Rudolf niehaus
    @ Last Modified On  :   30/05/2012
    @ Modification Description : Defect for Case#6374. Update the ordering of members from desc to asc when the data are renderd to Excel.

    * @description Added a property for bom
    * SFP-3681
    *
    * @author Wayne Solomon
    * @date Mar 2021


	@ Last Modified By  :   Vipeen Sarode
    @ Last Modified On  :   o6/09/2023
    @ Modification Description : Added dynamic column creation for host members as user can add N number of host for campaign member.
                                : Update direct soql queries to selecter layer remove unnecessary debugs
*/
public inherited sharing class CampaignExportController {
    public String bom {
        get {
            return '\uFEFF';
        }
        private set;
    }
    public Transient List<CampaigHostsWrapper> memberResultsExl {get;set;}
    public Transient List<Campaign_Member_Host__c> memhostList;
    public String currentId {get;set;}
    public Integer limitSize {get;set;}
    public Integer exportSize {get;set;}
    public String fileNo {get;set;}
    public String camName {get;set;}
    public Map<Id,Set<String>> hostMap = new Map<Id,Set<String>>();
    public Map<Id,List<Campaign_Hosts__c>> hostsMap = new Map<Id,List<Campaign_Hosts__c>>();
    private String memIds = '';
    private List<String> members = new List<String>();
    
    public List<String> hostColumnHeaders { get; set; }    
    public Integer maxHostCount = 0;
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CampaignExportController');

    /**
   * Class constructor
   */
    public CampaignExportController(){
        currentId = ApexPages.currentPage().getParameters().get('campId');
        memIds = ApexPages.currentPage().getParameters().get(CampaignMemberHostController.PARAM_NAME_MEMBERS_IDS);
        fileNo = ApexPages.currentPage().getParameters().get('fileno');
        if(memIds.length() > 0){
            members = memIds.split('-');
        }
        exportSize = members.size();
    }

    /**
   * Export to Excel method.
   * @return null
   */
    public PageReference loadExl(){		        
       
        List<Campaign> camp = SEL_Campaign.newInstance().selectById(currentId);
        camName = camp[0].Name;
        //Current readonly VF limit
        limitSize = 10000;        
        List<Campaign_Member_Host__c> memhostList = SEL_CampaignMemberHosts.newInstance().selectByIdandCampaignId(members, currentId, limitSize);	         
        Set<Id> memIds = new Set<Id>();		
        for(Campaign_Member_Host__c mh : memhostList){            
            memIds.add(mh.Id);        
        }
				
        List<Campaign_Hosts__c> hostList = SEL_CampaignHosts.newInstance().getMemhostList(memIds);
        
        Id memID = null;
        Set<String> hostNames = new Set<String>();
        List<Campaign_Hosts__c> hostsPerMem = new List<Campaign_Hosts__c>();        
       
        for(Campaign_Hosts__c h : hostList){			
            if(memID == h.Campaign_Member_Host__c || memID == null){            	
                hostNames.add(h.Bank_Contact__r.Name);               
                hostsPerMem.add(h);                
                if(hostList.size() == 1){                	
                    memID = h.Campaign_Member_Host__c;                    
                    hostMap.put(memID, hostNames);                   
                    hostsMap.put(memID,hostsPerMem);
                }
            }else{                
                hostMap.put(memID, hostNames);               
                hostsMap.put(memID,hostsPerMem);                
                hostNames = new Set<String>();                
                hostsPerMem = new List<Campaign_Hosts__c>();              	
                hostNames.add(h.Bank_Contact__r.Name);                
                hostsPerMem.add(h);
            }                        
            memID = h.Campaign_Member_Host__c;           
        }        		
        hostMap.put(memID, hostNames);
        hostsMap.put(memID,hostsPerMem);		
        memberResultsExl = new List<CampaigHostsWrapper>();	
		 
        for(Campaign_Member_Host__c h : memhostList){        	           
            Set<String> contactNames = new Set<String>();             
            List<Campaign_Hosts__c> linkedHosts = new List<Campaign_Hosts__c>();             
            if(hostMap.containsKey(h.Id)){                 
                contactNames = hostMap.get(h.Id);               
                linkedHosts = hostsMap.get(h.Id);
            }else{                 
                contactNames.add('None');
            }

            h.Member__r.Phone = getPhoneNumberWithLeadingZeros(h.Member__r.Phone);
            h.Member__r.MobilePhone = getPhoneNumberWithLeadingZeros(h.Member__r.MobilePhone);
            if(linkedHosts.size()>maxHostCount){
                maxHostCount = linkedHosts.size();
            }
            List<String> hostColumnHeaderLists = new List<String>();
            for (Integer i = 0; i < maxHostCount; i++) {
                Integer idx = i+1;               
                hostColumnHeaderLists.add('HOST NAME '+idx);                  
                hostColumnHeaderLists.add('HOST SURNAME '+idx);               
                hostColumnHeaderLists.add('HOST EMAIL '+idx);
                hostColumnHeaderLists.add('HOST DIVISION');
                hostColumnHeaderLists.add('BUSINESS UNIT');               
            }            
            hostColumnHeaders = hostColumnHeaderLists;            
            CampaigHostsWrapper cw = new CampaigHostsWrapper(h,contactNames,linkedHosts);
            memberResultsExl.add(cw);
        }
        for(CampaigHostsWrapper cwInst :memberResultsExl){
            cwInst.hostsPerMember = emptyDataTableCell(cwInst.hostsPerMember, maxHostCount);
        }
        hostMap.clear();
        hostsMap.clear();
        hostNames.clear();
        hostsPerMem.clear();
        
        return null;
    }
	/**
    * @description Returns list of hostsPerMember
    *
    * @param hostsPerMember list and maxHostCountVal number
	 *
    * @return list of hostsPerMember
    */
    public static List<String> emptyDataTableCell(List<String> hostsPerMember, Integer maxHostCountVal){
        if(hostsPerMember.size() != maxHostCountVal){
            for (Integer i = hostsPerMember.size(); i < maxHostCountVal; i++) {
                hostsPerMember.add('<td></td><td></td><td></td><td></td><td></td>');
            }
        }

        return hostsPerMember;
    }

    private String getPhoneNumberWithLeadingZeros(String phoneNumber) {
        return String.isNotBlank(phoneNumber) ? '="' + phoneNumber + '"' : '';
    }
}