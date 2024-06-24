/*************************************************************************
    @ Author        : Abhishek
    @ Date          : 8. 7. 2016
    @ File          : MeetingConsole_AttachmentController_Test
    @ Description   : US-1389 - Test class for MeetingConsole_AttachmentController
    
    @ Update        : Jarred
    @ Date          : 27. 5. 2016
    @ File          : MeetingConsole_AttachmentController_Test
    @ Description   : C00002602 - Updated test class to remove PCC references
    
****************************************************************************/

@isTest
public class MeetingConsole_AttachmentController_Test{

    public static Map < String, Schema.RecordTypeInfo > mapBARecordTypes = Business_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Id nbacRecordtypeID = mapBARecordTypes.get('NBAC').getRecordTypeId();
    public static String submissionForNoting = 'Type 1: For noting purposes';
    
    static void setuptestdata(){

        insert TEST_DataFactory.getEnvironmentVariable();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
            .addContact(
                new BLD_Contact(uow).useClientContact()
                    .inactive(true)
                    .reasonForInactive(DMN_Contact.REASON_INACTIVE_DECEASED)
            );

        BLD_Contact bankConBld1 = new BLD_Contact(uow).useBankContact().account(accBld);
        BLD_Contact bankConBld2 = new BLD_Contact(uow).useBankContact().account(accBld);
        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact().account(accBld);

        uow.commitWork();

        User custStandardUser = (User) new BLD_USER(uow).useCib().contactSyncId(bankConBld1.getRecordId()).getRecord();
        User committeeUser = (User) new BLD_USER(uow).useCib().contactSyncId(bankConBld2.getRecordId()).getRecord();
        User sysAdminUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
          uow.commitWork();
        }

        new BLD_Opportunity(uow)
            .client(accBld)
            .addTeamMember(
                new BLD_OpportunityTeamMember(uow)
                    .userId(sysAdminUser.Id)
                    .role('Product Specialist')
            )
                .addTeamMember(
                new BLD_OpportunityTeamMember(uow)
                    .userId(custStandardUser.Id)
                    .role('Client Analyst')
            )
                .addTeamMember(
                new BLD_OpportunityTeamMember(uow)
                    .userId(committeeUser.Id)
                    .role('Client Analyst')
            );

        uow.commitWork();

        Business_Assessment__c assessment = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(accBld.getRecordId()).getRecord();

        assessment.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04');
        assessment.Submission_Type__c = submissionForNoting;
        assessment.RecordTypeId = nbacRecordtypeID;
        assessment.Milestone__c = 'Supported';
        assessment.NBAC_Committee__c = 'Global NBAC';
        insert assessment;

        // Create Event Report
        Call_Report__c defaultEventReport = new Call_Report__c();
        defaultEventReport.Relate_to_Client__c = accBld.getRecordId() ;
        defaultEventReport.Subject__c = 'Test Subject';
        defaultEventReport.Meeting_Audience__c = 'External';
        defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
        defaultEventReport.Start__c = System.now();
        defaultEventReport.End__c = System.now();
        defaultEventReport.Description__c = 'Test Description';
        defaultEventReport.Report_Client_Contact__c = clientConBld.getRecordId();
        insert defaultEventReport;

        Agenda__c agenda = new Agenda__c();
        agenda.Event_Report__c = defaultEventReport.id;
        agenda.Related_NBAC__c = assessment.id;
        
        insert agenda; 
    }
    
    static testMethod void testAttachment(){
        setuptestData();
        
        Test.startTest();
        MeetingConsole_AttachmentController ctrl = new MeetingConsole_AttachmentController();
        System.assertEquals(ctrl.atts.size(), 0);
        ctrl.nbacIDval = [SELECT Id FROM Business_Assessment__c limit 1].ID;
        System.assertEquals(ctrl.atts.size(), 0);
        ctrl.displayattfilepop();
        ctrl.hidepopupWindow();
        ctrl.upload();
        System.assertEquals(ctrl.atts.size(), 0);
        ctrl.attachmentrec.Body = Blob.valueOf('Unit Test 3');
        ctrl.attachmentrec.Name = 'Unit Test 3';
        ctrl.upload();
        System.assertEquals(ctrl.atts.size(), 1);
        Test.stopTest();    
    }
    static testMethod void testGetListOfAttachments() {
        setuptestData();
        string nbacIDval = [SELECT Id FROM Business_Assessment__c limit 1].ID;
        Contentversion cv = new Contentversion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;
        Attachment attachmentrec = new Attachment();
        attachmentrec.OwnerId = UserInfo.getUserId();
        attachmentrec.ParentId = nbacIDval; // the record the file is attached to
        attachmentrec.IsPrivate = false;
        attachmentrec.body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(cv.VersionData));
        attachmentrec.name = cv.Title;
        insert attachmentrec;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Test.startTest();
        String uploadRes = MeetingConsole_AttachmentController.uploadAura(nbacIDval,contentVersion_2.ContentDocumentId);
        UploadResponse res = (UploadResponse) JSON.deserialize(uploadRes,UploadResponse.class);
        system.assertEquals(res.isError,false);

        // pass wrong ContentDocumentId for throwing exception
        uploadRes = MeetingConsole_AttachmentController.uploadAura(nbacIDval,'0019E000014bxRsQAI');
        res = (UploadResponse) JSON.deserialize(uploadRes,UploadResponse.class);
        system.assertEquals(res.isError,true);

        Map<string,List<Object>> files= MeetingConsole_AttachmentController.getListOfAttachments(nbacIDval);
        System.assertNotEquals(files.get('attachList').size(),0);
        System.assertEquals(files.get('conVersion').size(),0);
        Test.stopTest();
    }

    public class UploadResponse{

        boolean isError;
        String msg;
    }

}