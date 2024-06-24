public without sharing class ApprovalUrlController {
    public String recID {get; set;}

    public String urlStr{
        get
        {
            return createApprovalURL(recID);
        }
    }

    @TestVisible
    private static String createApprovalURL(String recordID){
        String url='';

        List<ProcessInstanceWorkitem> workItemLst = [SELECT id
                            FROM ProcessInstanceWorkitem
                            WHERE processInstance.TargetObjectId=:recordID];

        if(workItemLst.size() > 0)
        {
            url='https://'+ System.URL.getSalesforceBaseUrl().getHost() +
                    '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;
        }
        return url;
    }
}