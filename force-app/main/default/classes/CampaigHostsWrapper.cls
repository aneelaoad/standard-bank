/*************************************************************************\
    @ Func Area     : Campaign Members and Campaign Hosts 
    @ Author        : Rudolf Niehaus
    @ Date          : 11/2011
    @ Test File     : Test Method in this class : testMe()
    @ Description   : Case#1168
                      Campaign memeber host wrapper class to keep track of check box 
                      selection on members  
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 25/05/2012
    @ Modified Reason   : Case#6374 - Fix campaign member host info not showing correctly in excel file  
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Move test methods into external class  
                               Case #6521- Change contact to use TestFatcory    
                               API Version moved from 24 to 25
****************************************************************************/

public class CampaigHostsWrapper {
    
    public Boolean checked{ get; set; }
    public List<String> hostsPerMember{ get; set; }
    public Campaign_Member_Host__c memhost { get; set;}
    public Campaign_Hosts__c host { get; set;}
    public String hostNames { get; set;}
    
    public CampaigHostsWrapper(){
       
        memhost = new Campaign_Member_Host__c();
       
        checked = false;
    }
    public CampaigHostsWrapper(Campaign_Member_Host__c c, Set<String> hList, List<Campaign_Hosts__c> hostList){
        
        memhost = c;
        
        hostsPerMember = new List<String>();
        String hostFirstName = '';
        String hostLastName = '';
        String hostEmail = '';
        String hostDivision = '';
        String hostBusinessUnit = '';
        
        for(Campaign_Hosts__c ch : hostList){
             
             if(ch.Bank_Contact__r.FirstName!=null){
                    hostFirstName = ch.Bank_Contact__r.FirstName;
             }else{
                hostFirstName = '&nbsp;';
             }
             if(ch.Bank_Contact__r.LastName!=null){
                hostLastName = ch.Bank_Contact__r.LastName;
             }else{
                hostLastName = '&nbsp;';
             }
             if(ch.Bank_Contact__r.Email!=null){
                hostEmail = ch.Bank_Contact__r.Email;
             }else{
                hostEmail = '&nbsp;';
             }
             if(ch.Bank_Contact__r.User_Division_Sync__c!=null){
                hostDivision = ch.Bank_Contact__r.User_Division_Sync__c;
             }else{
                hostDivision = '&nbsp;';
             }
             if(ch.Bank_Contact__r.User_Business_Unit_Sync__c!=null){
                hostBusinessUnit = ch.Bank_Contact__r.User_Business_Unit_Sync__c;
             }else{
                hostBusinessUnit = '&nbsp;';
             }
             
             hostsPerMember.add('<td>' + hostFirstName + '</td><td>' + hostLastName + '</td><td>' + hostEmail + '</td><td>' + hostDivision + '</td><td>' + hostBusinessUnit + '</td>');
        }
       
       
        hostNames = '';
        
        //Sort host list
       
        List<String> toSort = new List<String>();
        
        toSort.addAll(hList);
        toSort.sort(); 
        
        for(String s : toSort){
            hostNames = hostNames + s + ' , ';
            
        }
        
        hostNames = hostNames.substring(0,hostNames.length()-3);
        
        checked = false;
    }
    public CampaigHostsWrapper(Campaign_Hosts__c h){
        host = h;
        checked = false;
    }
}