/*************************************************************************
  @ Author     : mkumargupta
  @ Date         : 16-11-2016
  @ Description  : US-1593
****************************************************************************/


@IsTest
public without sharing class wrapperConcessionOpportunityTest {

private final static Map<String, Schema.RecordTypeInfo> mapConcessionRecordTypes = Concession__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public final static Id MerchAccRecTypeId = mapConcessionRecordTypes.get('Merchant Acquiring').getRecordTypeId();
    @TestSetup
    static void prepareData() {
        insert TEST_DataFactory.getUserProfileIds();
        insert TEST_DataFactory.getEnvironmentVariable();
    }
    
        private static Concession__c getConcession(){
        Concession__c con = new Concession__c();
        con.Status__c = 'New';
        con.Sub_Status__c = 'With RM';
        con.RecordTypeId = MerchAccRecTypeId;
        con.Risk_Group_Number__c = 1234;
        con.Risk_Group_Name__c = 'riskgroup';
        con.Latest_Risk_Grade_CRS_MRS__c = 'TestLRG';
        con.Total_Credit_Turnover__c = 1;
        con.Total_Debit_Turnover__c = 2;
        con.Credit_Weighted_Average_Price__c = 3;
        con.Debit_Weighted_Average_Price__c = 4;
        con.Merchant_Number__c = 'abc';
        con.SMT_Deal_Number__c = 'def';
        con.Transaction_Type__c = 'Commission - Hybrid';
        con.Turnover__c = 15;
        con.Commission_Rate__c = 5;
        
        return con;
        
    }
    
    private static Conditions_of_Grant__c getCOG(){
    Conditions_of_Grant__c cog = new Conditions_of_Grant__c();
    cog.Condition_Measure__c = 'Full Transactional Banking';
    cog.Condition_Product__c = 'Cash, BOL, Merchant Acquiring';
    cog.Value__c = 5;
    
    return cog;
    
    }
    
    @IsTest
    static void testAttachmentIsGenerated() {

        User userCC, userCC1;
        System.runAs(new User(id = UserInfo.getUserId())) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            userCC = (User) new BLD_USER(uow).useSysAdmin().getRecord();
            userCC1 = (User) new BLD_USER().useCommB().commitWork().getRecord();
            uow.commitWork();
        }

        Account commBAcc;
        Opportunity commbOpty;
        Concession__c con1;
        Conditions_of_Grant__c cog1;
        
        System.runAs(userCC1) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Account commBAccBuilder = new BLD_Account(uow).useCommB();
            commBAcc = (Account) commBAccBuilder.getRecord();
            
            commbOpty = (Opportunity) new BLD_Opportunity(uow)
                .client(commBAccBuilder)
                .getRecord();

            uow.commitWork();

            con1 = getConcession();
            con1.opportunity__c = commbOpty.Id;
            insert con1;
            
            
            cog1 = getcog();
            cog1.Concession__c = con1.Id;
            insert cog1;
            
        

        }
        
        system.runAs(userCC) {
        Concession__c con2= [select id from Concession__c where id=:con1.Id];
                    con2.Sub_Status__c = 'Pricing Team Approved';
                    update con2;
            
                      PageReference pageRef = Page.concessionletter_pdf;
            pageRef.getParameters().put('id', commBAcc.id);
            Test.setCurrentPage(pageRef);
            
            wrapperConcessionOpportunity gie = new wrapperConcessionOpportunity();
            PageReference selectedrec = gie.ProceedWithSelected();
            gie.wrapperList[0].selected = true;
            PageReference returnPR = gie.generateDoc();
            system.assertNotEquals(null, returnPR, 'Returned PageReference should not be null');
            
            system.assertEquals(1, [SELECT COUNT() FROM Attachment WHERE parentId = :commBAcc.id], 'Exactly one Attachment should exist');
    } 
    }

    @IsTest
    static void shouldCountSelectedWrappers() {
        PageReference pageRef = Page.concessionletter_pdf;
        pageRef.getParameters().put('id', fflib_IDGenerator.generate(Opportunity.SObjectType));
        Test.setCurrentPage(pageRef);

        wrapperConcessionOpportunity wrp = new wrapperConcessionOpportunity();
        wrp.wrapperList = new List<wrapperConcessionOpportunity.myWrapperClass>();
        wrapperConcessionOpportunity.myWrapperClass myWrp1 = new wrapperConcessionOpportunity.myWrapperClass();
        myWrp1.selected = true;
        wrp.wrapperList.add(myWrp1);
        wrapperConcessionOpportunity.myWrapperClass myWrp2 = new wrapperConcessionOpportunity.myWrapperClass();
        myWrp2.selected = false;
        wrp.wrapperList.add(myWrp2);

        System.assertEquals(0, wrp.count);

        Test.startTest();
        wrp.countvalue();
        Test.stopTest();

        System.assertEquals(1, wrp.count);
    }

    @IsTest
    static void shouldAssignWrapperListRecordToProperties() {
        PageReference pageRef = Page.concessionletter_pdf;
        pageRef.getParameters().put('id', fflib_IDGenerator.generate(Opportunity.SObjectType));
        Test.setCurrentPage(pageRef);

        wrapperConcessionOpportunity wrp = new wrapperConcessionOpportunity();
        wrp.wrapperList = new List<wrapperConcessionOpportunity.myWrapperClass>();
        wrapperConcessionOpportunity.myWrapperClass myWrp1 = new wrapperConcessionOpportunity.myWrapperClass();
        myWrp1.selected = true;
        myWrp1.opp = new Concession__c(
            Risk_Group_Number__c = 5
        );
        wrp.wrapperList.add(myWrp1);

        Test.startTest();
        wrp.ProceedWithSelected();
        Test.stopTest();

        System.assertEquals(myWrp1.opp.Risk_Group_Number__c, wrp.Riskgroupnum);
    }

}