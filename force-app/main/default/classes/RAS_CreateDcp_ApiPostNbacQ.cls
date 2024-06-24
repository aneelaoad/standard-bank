/**
* Salesforce NBAC - DCP Integration
* As a NBAC Secretary I want to approve the NBAC In order to automatically trigger a
* DCP (Digital Credit Paper).  This class posts the nbac/s.
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
public class RAS_CreateDcp_ApiPostNbacQ implements Queueable, Database.AllowsCallouts {
    String access_token;
    List<RAS_CreateDcp_Api.DcpWrapper> dcpWrappers;
    List<Id> nbacIds;
    public RAS_CreateDcp_ApiPostNbacQ(String access_token, List<RAS_CreateDcp_Api.DcpWrapper> dcpWrappers, List<Id> nbacIds) {
        this.access_token = access_token;
        this.dcpWrappers = dcpWrappers;
        this.nbacIds = nbacIds;
    }
    public void execute(QueueableContext context) {
        List<Object> result = RAS_CreateDcp_Api.postNbac(access_token, dcpWrappers, nbacIds);
        if (result == null) return; else RAS_CreateDcp_Api.writeResponseStatus(result);
    }
}