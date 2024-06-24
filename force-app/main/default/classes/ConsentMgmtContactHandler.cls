/**
 * Functional Area: Consent Management
 * Usage: Contact flow to handle consent management events
 * @author Atul Sharma
 * @date 2023-8-20
 */
public without sharing class ConsentMgmtContactHandler {
	public String OPT_OUT = 'OptOut';
    public String DIRECT_MARKETING = 'Direct Marketing'; 
    public String CONTACTPOINT_NAME = 'Email - Direct Marketing';   
    public Id DIRECT_MARKETING_ID;  
    public Id CIB_BUSINESS_BRAND_ID;  
    public String CIB = 'CIB';
    public String CAPTURESOURCE = 'Salesforce UI';
    public String  PRIMARY_RELATIONSHIP_HOLDER =  'Corporate and Investment Banking';   
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ConsentMgmtContactHandler');
    
    public ConsentMgmtContactHandler() {
        DIRECT_MARKETING_ID   = new SEL_DataUsePurposes().selectIdByDataUsePurposeName(DIRECT_MARKETING);
        CIB_BUSINESS_BRAND_ID =[SELECT Id FROM BusinessBrand WHERE  Name =:CIB limit 1].Id;	//Current fflib classes doesn't support BusinessBrand object
    }

    /**
     * @description: Manages Consents Changes
     *
     * @param cons - the list of Contacts for that consents will be managed
     *
     */    
    @InvocableMethod(label='Create and maintain consent records' description='Whenever a contact is created or updated, Individual and ContactPointTypeConsent records are created or updated for opting a contact in or out of direct marketing.' category='Contact')
    public static void manageConsent(List<Contact> cons) {	
        List<Id> conIds = new List<Id>();
        for (Contact con : cons) {
            conIds.add(con.id);
        }
        try{
        	Contact[] contacts = new SEL_Contacts().selectByIdforConsentFlow(conIds);        
			new ConsentMgmtContactHandler().handleContactConsent(contacts);
        } catch (Exception e) {
            // Because these consents are processed as backend processes, the user shouldn't be prevented from creating or updating their contacts' information
            LOGGER.fatal('Failed ConsentMgmtContactHandler.manageConsent(),\n StackTraceString:'+e.getStackTraceString() +'\n getMessage:'+e.getMessage()+'\n scope Ids :'+ conIds );//Print scope Ids
        }      
    }
    /**
     * @description: Checks Consents Changes for contacts
     *
     * @param cons - the list of Contacts for that consents will be managed
     *
     */   
	public void handleContactConsent(Contact[] cons)
	{               
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Contact> indIdsNoInd				= new List<Contact>();	//createAll
        List<Contact> indIdsNoContactPoint    	= new List<Contact>();
        List<Contact> indIdsWithIndContactPoint = new List<Contact>(); 
        Map<Id,Contact> remainingCons = new Map<Id,Contact>();
        Set<Id> indIds = new Set<Id>();
        ContactPointTypeConsent[] contPts;
        
        for (Contact con : cons) {            
            if (con.IndividualId == null) {
                indIdsNoInd.add(con);
            } else {
              	remainingCons.put(con.IndividualId,con);
                indIds.add(con.IndividualId);
            } 
        }        
        if (indIdsNoInd.size()>0) {
        	createIndidualNConPoint(indIdsNoInd,uow); //Create and link both    
        }        
        if (indIds.size()<1) { return; }                      
        
        contPts = new SEL_ContactPointTypeConsents().selectActiveContactPointTypeConsent(indIds,DIRECT_MARKETING);
            
        if (contPts != null && contPts.size() > 0) {
            for (ContactPointTypeConsent cpt : contPts) {               
                Boolean check = remainingCons.get(cpt.PartyId).HasOptedOutOfEmail;
                cpt.PrivacyConsentStatus = check ? 'OptOut' : 'OptIn';
                remainingCons.remove(cpt.PartyId);
            }
            uow.registerDirty(contPts);
            uow.commitWork();
        }
        
        if (remainingCons.size() > 0) {	// With Ind but without ContactPoint
           createContactPointConsentType(remainingCons.values(), uow); 
        }
	}
    /**
     * @description: Creates Indiduals and Contact Point Type Consents for provided contacts
     *
     * @param cons - the list of Contacts for that records will be created
     * @param uow - the Unit of Work
     *
     */
    private void createIndidualNConPoint(Contact[] cons, fflib_ISObjectUnitOfWork uow) {
        Map<Contact,Individual> conPointMap = new Map<Contact,Individual>();
        for (Contact con : cons) {
            Individual i1 = new Individual();
            i1.FirstName  = con.FirstName;
            i1.LastName   = con.LastName;
            
            ContactPointTypeConsent cpt1 = getContactPointConsentType(con);            
            uow.registerNew(i1);
            uow.registerNew(cpt1,ContactPointTypeConsent.PartyId,i1);
            conPointMap.put(con,i1);            
        }

        uow.commitWork();
        for (Contact con : cons) {
            con.IndividualId = conPointMap.get(con).Id;
        }
        uow.registerDirty(cons);
        uow.commitWork();        
    }
    /**
     * @description: Creates Contact Point Type Consents for provided contacts
     *
     * @param cons - the list of Contacts for that records will be created
     * @param uow - the Unit of Work
     *
     */
    private void createContactPointConsentType(Contact[] cons, fflib_ISObjectUnitOfWork uow) {
        for (Contact con : cons) {
            ContactPointTypeConsent cpt1 = getContactPointConsentType(con);            
            uow.registerNew(cpt1);            
        }
        uow.commitWork();
    }
    /**
     * @description: Generates Contact Point Type Consents for a provided contacta
     *
     * @param con - the Contact record for that a new record will be created
     *
	 * @return ContactPointTypeConsent - the newly generated Contact Point Type Consent record
     */
    private ContactPointTypeConsent getContactPointConsentType(Contact con) {
        ContactPointTypeConsent cpt1 = new ContactPointTypeConsent();
        cpt1.Name 					 = CONTACTPOINT_NAME;
        cpt1.PrivacyConsentStatus	 = con.HasOptedOutOfEmail ? 'OptOut' : 'OptIn';        
        cpt1.EffectiveFrom 			 = date.today();
        cpt1.CaptureDate   			 = date.today();
        cpt1.DataUsePurposeId 		 = DIRECT_MARKETING_ID;
        cpt1.PartyId				 = con.IndividualId;            
        cpt1.CaptureContactPointType = 'Web';
        cpt1.ContactPointType		 = 'Email';
        cpt1.AccountId__c 			 = con.AccountId;
        cpt1.CaptureSource 			 = CaptureSource;
        if (con.Account.Primary_Relationship_Holder__c == PRIMARY_RELATIONSHIP_HOLDER) {
            cpt1.BusinessBrandId= CIB_BUSINESS_BRAND_ID;
        }
		return    cpt1;
    }    
}