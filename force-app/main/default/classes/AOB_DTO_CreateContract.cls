/**
* @description  Wrapper Class for Creating Contract API request Body
* @author Dayakar
* @date  11-12-2022 
*/
public class AOB_DTO_CreateContract{
    /**
    * @description	used to set information related to the create Contract API
    * @param offerid
    * @return Contract API request Body
    */
    public  static AOB_DTO_Contract contractRequestBody(String offerid){
        AOB_DTO_Contract createContract= new AOB_DTO_Contract();
        AOB_DTO_Contract.createContractRequest contractrquest= new  AOB_DTO_Contract.createContractRequest();
        AOB_DTO_Contract.CreateContractRequest conrquest= new AOB_DTO_Contract.CreateContractRequest();
        AOB_DTO_Contract.HeaderDetails headerdata= new AOB_DTO_Contract.HeaderDetails();
        AOB_DTO_Contract.SecurityDetails securitydata= new AOB_DTO_Contract.SecurityDetails();
        conrquest.offerId=offerid;
        headerdata.requestCorrelation=null;
        headerdata.originatorName=null;
        headerdata.digitalId=null;
        headerdata.respondToAddress=null;
        headerdata.sourcePlatform=null;
        headerdata.processType=null;
        headerdata.isSynchronous=false;
        headerdata.channelId=null;
        headerdata.customerInterface=null;
        headerdata.requestTraceId=null;
        securitydata.generateToken=false;
        securitydata.tokenType=null;
        securitydata.accessToken=null;
        headerdata.securityDetails=securitydata;
        conrquest.headerDetails=headerdata;
        createContract.createContractRequest=conrquest;
        return createContract;
    }
}