/*****************************************************************************************************\
    @ Func Area     : Campaigns, Campaign Members and Member hosts.
    @ Author        : Rudolf Niehaus
    @ Date          : 02/2011
    @ Test File     : TestCampaignMemberHostController
    @ Description   : Case#1168
                      Controller class for the Visualforce pages CampaignMemberToExcel.page. The controller creates an Excel export file
                      per 2500 campaign members. The reason for this it to overcome the SF limits per visualforce page. 
                                     
******************************************************************************************************/
public class CampaignExportDownloader {

    public CampaignExportDownloader(){}
    
    public PageReference DownloadData(){
        
        String currentId = ApexPages.currentPage().getParameters().get('campId');
        Integer block = Integer.valueOf(ApexPages.currentPage().getParameters().get('datablock'));
        
        String ids = getDataBlock(block, currentId);
        
        Pagereference download = Page.CampaignMembersToExcel;
        download.getParameters().put('ids',ids);
        download.getParameters().put('campId',currentId);
        download.getParameters().put('fileno',String.valueOf(block));
        return download;
    }

    public String getDataBlock(Integer x, String cid){
        
        Integer recs = 0;
        String ids = '';
        Integer max = 0;
        Integer resultCount = 0;
        
        List<Campaign_Member_Host__c> memberCount = new List<Campaign_Member_Host__c>([Select Id, Name From Campaign_Member_Host__c Where Campaign__c =: cid order By Name asc limit 10000]);
        resultCount = memberCount.size(); 
         
        if(x == 1){
            recs=0;
            if(resultCount>=2500){
                max=2500;
            }else{
                max = resultCount;
            }
        }else if(x == 2){
            recs=2500;
            if(resultCount>=5000){
                max=5000;
            }else{
                max = resultCount;
            }
        }else if(x == 3){
            recs=5000;
            if(resultCount>=7500){
                max=7500;
            }else{
                max = resultCount;
            }
        }else if(x == 4){
            recs=7500;
            if(resultCount>=10000){
                max=10000;//Max limit for readOnly records in a VF page
            } 
        }
         
        for(Integer i=recs;i<=max-1;i++){
             ids = ids + memberCount[i].Id + '-';
        }
         
         if(ids.length() > 0){
            ids = ids.substring(0,ids.length()-1);
         }

        return ids;

    }
}