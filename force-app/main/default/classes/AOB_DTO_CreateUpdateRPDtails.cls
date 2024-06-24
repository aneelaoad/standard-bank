/**
* GET API  Update RP Response Body
* 
* @author DAYAKAR
*
* @date Oct 29th 2021
*/
public class AOB_DTO_CreateUpdateRPDtails{
    
    public static string updateRpConfigBodyFormation(Set<String> totalRelPartys1,String Applicationid,String UUID){
        
        AOB_Application__c Aob=[select id,AOB_InflightDataID__c from AOB_Application__c where id=:Applicationid];
        AOB_DTO_UpadteRPDetails aobupdateWrapper= new AOB_DTO_UpadteRPDetails();
        List<AOB_DTO_UpadteRPDetails.personalDetails> lstPersonalDetails =new List<AOB_DTO_UpadteRPDetails.personalDetails>();
        List<AOB_DTO_UpadteRPDetails.relationships> lstRelationShipDetails =new List<AOB_DTO_UpadteRPDetails.relationships>();
        AOB_DTO_UpadteRPDetails.PersonalDetails personalobj = new AOB_DTO_UpadteRPDetails.PersonalDetails();
        List<AOB_DTO_UpadteRPDetails.PersonalDetails> personalobjlist= new List<AOB_DTO_UpadteRPDetails.PersonalDetails>();
        List<AOB_DTO_UpadteRPDetails.Relationships> Relationlist=new   List<AOB_DTO_UpadteRPDetails.Relationships>();
        aobupdateWrapper.inflightCustomerDataID=Aob.AOB_InflightDataID__c;
        personalobj.customerUUID=UUID;
        personalobjlist.add(personalobj);
        aobupdateWrapper.personalDetails=personalobjlist;
        if(totalRelPartys1.size()>0){
            for(String s:totalRelPartys1){
                AOB_DTO_UpadteRPDetails.Relationships Relation= new  AOB_DTO_UpadteRPDetails.Relationships();
                Relation.relationshipTypeCode=s;
                Relationlist.add(Relation);    
            }  
        }
        personalobj.relationship=Relationlist;
        return Json.serialize(aobupdateWrapper);
        
    }
}