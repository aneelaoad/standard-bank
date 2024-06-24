/**
* Salesforce NBAC - DCP Integration
* As a NBAC Secretary I want to approve the NBAC In order to automatically trigger a
* DCP (Digital Credit Paper).  This class gets the access token.
* US-4434
*
* @author Wayne Solomon
* @date 2020-01-08
*
* Cleaned up header, indentations and spacings
*
* @modified Wayne Solomon
* @date 2020-06-17
*/
public class RAS_CreateDcp_ApiGetTokenQ implements Queueable, Database.AllowsCallouts {
    List<RAS_CreateDcp_Api.DcpWrapper> dcpWrappers;
    List<Id> nbacIds;
    public RAS_CreateDcp_ApiGetTokenQ(List<RAS_CreateDcp_Api.DcpWrapper> dcpWrappers, List<Id> nbacIds) {
        this.dcpWrappers = dcpWrappers;
        this.nbacIds = nbacIds;
    }
    public void execute(QueueableContext context) {
        String access_token = RAS_CreateDcp_Api.getAccessToken(nbacIds);
        if (String.isBlank(access_token)) return;
        else if (!Test.isRunningTest()) System.enqueueJob(new RAS_CreateDcp_ApiPostNbacQ(access_token, dcpWrappers, nbacIds));
    }
}