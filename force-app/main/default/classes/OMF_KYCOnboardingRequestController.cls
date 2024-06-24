/****************************************************************
* @author Khushmeet Kaur
* @Test class OMF_KYCOnboardingRequestController_Test
* @description Controller for the vf page for the data retrieval
* @date Jan 2024
*/

public without sharing class OMF_KYCOnboardingRequestController {
    /**
*@description id of managed fund record
*/
    public static Id managedFundId { get; set; }
    /**
* @description fundtion used to get all the merge fields used in the visual force email template
* @return objKycDetails
* */
    public KycDetails getobjKycDetails(){
        KycDetails objKycDetails = new KycDetails();
        if(String.isNotBlank(managedFundId)){
            List<OMF_ManagedFund__c> lstManagedFunds = new SEL_OMF_ManagedFunds().selectManagedFundRecordWithAssetManagerAndFundDetails(managedFundId);
            
            List<Contact> lstCustContacts = [SELECT Id, Name, FirstName, Contact_Category__c, Email, Phone_Country__c,
                                             Phone, Initials__c, LastName FROM Contact WHERE 
                                             AccountId =: lstManagedFunds[0].AssetManager__c AND CreatedById IN (SELECT Id FROM User WHERE Division = 'Operational Manager')];
            
            objKycDetails.objMangedFund = lstManagedFunds[0];
            objKycDetails.objContact = new Contact();
            if(!lstCustContacts.isEmpty()){
                objKycDetails.objContact = lstCustContacts[0];
            }
        }
        return objKycDetails;
    }
    /**
@description wrapper class to store the objects*/
    public class KycDetails{
        /**
@description  objMangedFund record*/
        public OMF_ManagedFund__c objMangedFund{get;set;}
        /**
@description contact record*/
        public Contact objContact{get;set;}
    }
}