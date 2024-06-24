/**
 * test class for DigiSignService
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 */
@isTest(isParallel=true)
public class DigiSignService_Test {

        private static final String 
        TEST_USER_NAME          = 'stdBank@nbac.com',
        GEN_ACC_NAME			= 'General PTY',
        CIF_NUMBER            = '654321';
    public static final String DEF_FIRST_NAME = 'testFirstName';
    public static final String DEF_LAST_NAME = 'testContact';
    public static final String DEF_EMAIL = 'test@Contact.testcom';
    private static final List<String> CLIENT_ROLES = new List<String>{'KYC Contact','Authorised Person','Direct Shareholder','Indirect Shareholder'};
    private static final String REQUEST_TYPE = 'Request Consent';
    private static final String RT_COMMB_REQUEST_CONSENT = DMN_OnboardingApplications.RT_COMMB_REQUEST_CONSENT;
    private static User usrOwner;
    private static User apiUser;
    private static final String APPROVED = 'Approved';
    @TestSetup
    private static void prepareData() {
        TEST_DataFactory.generateConfiguration();
        Application_Document__c appDoc;
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            
            usrOwner = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'1').useCommB().email(TEST_USER_NAME).syncContact().getRecord();
            apiUser = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'2').useAPIUser().email(TEST_USER_NAME).syncContact().getRecord();
               
            uow.commitWork();
        }
        Test.startTest();
        Test.stopTest();
        
        
        System.runAs(usrOwner){
            
            BLD_Account ugpClientBld	= new BLD_Account(uow)
                .name(GEN_ACC_NAME)
                .CIF(CIF_NUMBER)
                .useCommB()
                .riskRating(DMN_Account.RISK_RATING_D1)
                .useGroupParent();
            
            uow.commitwork();
            
            BLD_Contact con = new BLD_Contact(uow)
                .useClientContact()
                .email(DEF_EMAIL)
                .name(DEF_FIRST_NAME,DEF_LAST_NAME)
                .account(ugpClientBld)
                .ownerId(usrOwner.id)
                .roleAtClient(CLIENT_ROLES[0]);
            uow.commitwork();
            
            BLD_Onboarding_Application onboardRec = new BLD_Onboarding_Application(uow)
                .requestType(REQUEST_TYPE)
                .requestedBy(DEF_FIRST_NAME)
                .status(DMN_OnboardingApplications.STATUS_PENDING)
                .client(ugpClientBld)
                .useRequestConsentRT(RT_COMMB_REQUEST_CONSENT);
            uow.commitWork();
            
            appDoc = (Application_Document__c) new BLD_Application_Document(uow)
                .authorisedPerson(con)
                .onboardingApplication(onboardRec).getRecord();
            uow.commitWork();
        }
    }
      @isTest
    static void testUpdateOnboardRecords() {
        
        String requestBody = getCallBackRequestJSON(true);
        DigiSignResource.RequestWrapper objResponseBody = (DigiSignResource.RequestWrapper) JSON.deserialize(requestBody, DigiSignResource.RequestWrapper.class);
        Test.startTest();
        System.runAs(getAPIUser()){
            DigiSignService.updateOnboardRecords(objResponseBody);
        }
        Test.stopTest();
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{GEN_ACC_NAME})[0];
        list<Onboarding_Application__c> onboardAppList = SEL_OnboardingApplications.newInstance().selectByRequestType(REQUEST_TYPE);
        System.assertEquals(APPROVED,onboardAppList[0].Status__c);
        
    }
    
        private static string getCallBackRequestJSON(Boolean validData){
        Account account = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{GEN_ACC_NAME})[0];
        list<Onboarding_Application__c> onboardAppList = SEL_OnboardingApplications.newInstance().selectByRequestType(REQUEST_TYPE);
        list<Application_Document__c> appDocList = SEL_ApplicationDocuments.newInstance().selectByOnboardApplicationId(new Set<Id>{onboardAppList[0].Id});
        DigiSignResource.RequestWrapper req = new DigiSignResource.RequestWrapper();
        req.callBackRequest = new DigiSignResource.CallBackRequest();
        req.callBackRequest.headerDetails = new DigiSignResource.HeaderDetails();
        req.callBackRequest.documentDetails = new List<DigiSignResource.DocumentDetails>();
        req.callBackRequest.signatoryApprovalDetails = new List<DigiSignResource.SignatoryApprovalDetails>();
        req.callBackRequest.digiSignStatus = new DigiSignResource.DigiSignStatus();
        req.callBackRequest.headerDetails.requestCorrelation = onboardAppList[0].Id;
        req.callBackRequest.headerDetails.applicationContent = '|a1g1x000005SwzFAAS${"isPublicOfficial":false,"null":null,"isConnectedToOfficial":true,"name":"Sibonelo","surname":"Ngcobo","relationship":"Son / Daughter","hasConfirmed":true}|a1g1x000005SwzGAAS$null';
        req.callBackRequest.digiSignStatus.statusDescription = APPROVED;
        
        DigiSignResource.SignatoryApprovalDetails signatory = new DigiSignResource.SignatoryApprovalDetails();
        signatory.bpId = validData ?appDocList[0].Id:null;
        signatory.approvalStatus = validData ? APPROVED:null;
        signatory.firstName = appDocList[0].Authorised_Person__r.FirstName;
        signatory.lastName = appDocList[0].Authorised_Person__r.LastName;
        signatory.emailAddress = appDocList[0].Authorised_Person__r.Email;
        signatory.mobileNumber = appDocList[0].Authorised_Person__r.Phone;
        req.callBackRequest.signatoryApprovalDetails.add(signatory);
        
        return JSON.serialize(req);
    }
  private static USER getAPIUser(){
      return SEL_Users.newInstance().selectByUserName(new Set<String>{TEST_USER_NAME+'2'})[0];
    }
}