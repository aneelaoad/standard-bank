/**
* @ModifiedBy Emmanuel Mulea Nocks(BlueSky)
* @date Aug 2021
* @description Test class
*/
@isTest
private class SHR_CreditLine_TEST {
	
	public static final String 
    TEST_USER_NAME       = 'test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_2     = '2test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_3     = '3test.StdBank_Ltn_Ecosystem_Test@test.com',
    DEF_ACC_NAME         = 'Def Name for Acc',
    DEF_ACC_NAME_IMM     = 'Def Name for Immm',
    DEF_ACC_NAME_CHILD   = 'Def Name for Child',
    GROUP_NUMBER         = '123456';

    private static ABS_ObjectBuilderBase accBld;
    private static ABS_ObjectBuilderBase conBld;
    private static ABS_ObjectBuilderBase creditLineBld;
    private static ABS_ObjectBuilderBase teamBld;

    private static Account acc;
    private static Account child;
    private static Account grandChild;
    private static User usr;
    private static User otherUsr;
    private static User otherUsr2;
    private static void getData(){
        for(User u : [  SELECT Username 
                        FROM User
                        WHERE UserName =: TEST_USER_NAME_2 
                        OR UserName =: TEST_USER_NAME
                      OR UserName =: TEST_USER_NAME_3
                        LIMIT 3]){
            if(u.UserName == TEST_USER_NAME){
                usr = u;
            }
            if(u.UserName == TEST_USER_NAME_2){
                otherUsr = u;
            }
            if(u.UserName == TEST_USER_NAME_3){
                otherUsr2 = u;
            }
        }

        for(Account accRec : [  SELECT Name
                                FROM Account
                                WHERE Name  =: DEF_ACC_NAME
                                    OR Name =: DEF_ACC_NAME_IMM
                                    OR Name =: DEF_ACC_NAME_CHILD
                                LIMIT 3]){
            if(accRec.Name == DEF_ACC_NAME){
                acc = accRec;
            }
            if(accRec.Name == DEF_ACC_NAME_IMM){
                child = accRec;
            }
            if(accRec.Name == DEF_ACC_NAME_CHILD){
                grandChild = accRec;
            }
        }
    }

    @testSetup
    static void prepareData() { 

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            User sysAdmin = (User)new BLD_USER().useSysAdmin().syncContact().getRecord();
            otherUsr = (User)new BLD_USER(uow).userName(TEST_USER_NAME_2).useCommB().syncContact().getRecord();
            otherUsr2 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_3).useCommB().syncContact().getRecord();
            usr = (User)new BLD_USER(uow).userName(TEST_USER_NAME).useCommB().syncContact().getRecord();
            uow.commitWork();
        }
        
        System.runAs(usr){
            ABS_ObjectBuilderBase accBld = new BLD_Account(uow).name(DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER); 
            ABS_ObjectBuilderBase conBld = new BLD_Contact(uow).useClientContact().accountId(accBld.getRecordId());
            //creditLineBld   = new BLD_CreditLine(uow).product('').account((BLD_Account)accBld);
            //teamBld         = new BLD_ClientTeam(uow).account(accBld).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id);
            uow.commitWork();
            
            ABS_ObjectBuilderBase childAcc = new BLD_Account(uow).name(DEF_ACC_NAME_IMM).useCommB().useImmediateParent(accBld.getRecordId()).groupNumber(GROUP_NUMBER);
            uow.commitWork();
            ABS_ObjectBuilderBase grandchildAcc = new BLD_Account(uow).name(DEF_ACC_NAME_CHILD).useCommB().useChild(childAcc.getRecordId(), childAcc.getRecordId()).groupNumber(GROUP_NUMBER);
            uow.commitWork();
        }
    }  
    
    private static testmethod void defaultDataCheck() {

        getData();

        System.runAs(usr){
            Test.startTest();
                fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
                creditLineBld = new BLD_CreditLine(uow).product('').account(acc.Id);
                teamBld = new BLD_ClientTeam(uow).account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id);
                uow.commitWork();
            Test.stopTest();

            System.assertEquals(4, [SELECT Id FROM Account].size());
            System.assertEquals(2, [SELECT Id FROM Contact].size());
            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(2, [SELECT Id FROM Credit_Line__share].size());
        }
    }
    
    private static testmethod void createTeamMemberExistingCreditLine() {

        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];

        System.runAs(usr){
            Test.startTest();
                fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();////
                creditLineBld = new BLD_CreditLine(uow).product('').account(acc.Id);////
                teamBld = new BLD_ClientTeam(uow).account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id);
                uow.commitWork();////
            Test.stopTest();
        }

        Credit_Line__c creditLine = [   SELECT OwnerId 
                                        FROM Credit_Line__c
                                        LIMIT 1];

        Credit_Line__share[] shares = [SELECT ParentId, UserOrGroupId
                                        FROM Credit_Line__share];

        System.assertEquals(2, shares.size());
        Map<Id, Credit_Line__share> ownerId2Share = new Map<Id, Credit_Line__share>{
                                                                shares[0].UserOrGroupId => shares[0],
                                                                shares[1].UserOrGroupId => shares[1]
                                                            };

        
        System.assert(ownerId2Share.containsKey(usr.Id));
        System.assert(ownerId2Share.containsKey(otherUsr.Id));
        System.assert(ownerId2Share.containsKey(creditLine.OwnerId));

        System.assertEquals(creditLine.Id, ownerId2Share.get(usr.Id).ParentId);
        System.assertEquals(creditLine.Id, ownerId2Share.get(otherUsr.Id).ParentId);
    }
    
    private static testmethod void createTeamMemberNoCreditLine() {

        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){
            Test.startTest();
                teamBld = new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).commitWork();
            Test.stopTest();
        }

        Credit_Line__share[] shares = [SELECT ParentId, UserOrGroupId
                                        FROM Credit_Line__share];

        System.assertEquals(0, shares.size());
    }
    
    private static testmethod void createCreditLineExistingTeamMember() {

        getData();
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){
            Test.startTest();
                fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();////
                creditLineBld = new BLD_CreditLine(uow).product('').account(acc.Id);////
                teamBld = new BLD_ClientTeam(uow).account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id);////
                uow.commitWork();////
                //creditLineBld   = new BLD_CreditLine().account(acc.Id).product('').commitWork();
            Test.stopTest();
        }

        Credit_Line__c creditLine = [   SELECT OwnerId 
                                        FROM Credit_Line__c
                                        WHERE Id =: creditLineBld.getRecordId()];

        Custom_Client_Team__c member = [SELECT Team_Member__c 
                                        FROM Custom_Client_Team__c
                                        LIMIT 1];

        Credit_Line__share[] shares = [SELECT ParentId, UserOrGroupId
                                        FROM Credit_Line__share];

        System.assertEquals(2, shares.size());
        Map<Id, Credit_Line__share> ownerId2Share = new Map<Id, Credit_Line__share>{
                                                                shares[0].UserOrGroupId => shares[0],
                                                                shares[1].UserOrGroupId => shares[1]
                                                            };

        
        System.assert(ownerId2Share.containsKey(usr.Id));
        System.assert(ownerId2Share.containsKey(otherUsr.Id));
        System.assert(ownerId2Share.containsKey(creditLine.OwnerId));
        System.assert(ownerId2Share.containsKey(member.Team_Member__c));

        System.assertEquals(creditLine.Id, ownerId2Share.get(usr.Id).ParentId);
        System.assertEquals(creditLine.Id, ownerId2Share.get(otherUsr.Id).ParentId);
    }

    private static testmethod void createCreditLineNoTeamMember() {

        getData();
        //delete [SELECT Id FROM Credit_Line__c];
        //delete [SELECT Id FROM Custom_Client_Team__c];

        System.runAs(usr){
            Test.startTest();
                creditLineBld   = new BLD_CreditLine().account(acc.Id).product('').commitWork();
            Test.stopTest();
        }

        Credit_Line__c creditLine = [   SELECT OwnerId 
                                        FROM Credit_Line__c
                                        WHERE Id =: creditLineBld.getRecordId()];

        Credit_Line__share[] shares = [SELECT ParentId, UserOrGroupId
                                        FROM Credit_Line__share];

        System.assertEquals(1, shares.size());
        System.assertEquals(creditLine.OwnerId, shares[0].UserOrGroupId);
    } 
    
    private static testmethod void createCreditLineRemoveTeamMember() {

        getData();
        System.runAs(usr){
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();////
            creditLineBld = new BLD_CreditLine(uow).product('').account(acc.Id);////
            teamBld = new BLD_ClientTeam(uow).account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id);////
            uow.commitWork();////
        }

        /*Custom_Client_Team__c[] ctts = [SELECT Account__r.Name, Team_Member__r.UserName FROM Custom_Client_Team__c];
        Credit_Line__c[] crs = [SELECT Client_Name__r.Name FROM Credit_Line__c];

        System.assertEquals(1, ctts.size());
        System.assertEquals(1, crs.size());
        System.assertEquals(1, [SELECT Id FROM Credit_Line__share].size());*/

        System.runAs(usr){ 

            /*System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(2, [SELECT Id FROM Credit_Line__share].size());*/

            Test.startTest();

                delete [SELECT Id FROM Custom_Client_Team__c];
            Test.stopTest();
        }

        Credit_Line__c creditLine = [   SELECT OwnerId 
                                        FROM Credit_Line__c];

        Credit_Line__share[] shares = [SELECT ParentId, UserOrGroupId
                                        FROM Credit_Line__share];

        System.assertEquals(0, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
        System.assertEquals(1, shares.size());
        System.assertEquals(creditLine.OwnerId, shares[0].UserOrGroupId);
    } 
 
    private static testmethod void createCreditLineRemoveCreditLine() {

        getData();
        System.runAs(usr){
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();////
            creditLineBld = new BLD_CreditLine(uow).product('').account(acc.Id);////
            teamBld = new BLD_ClientTeam(uow).account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id);////
            uow.commitWork();////
        }

        /*System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
        System.assertEquals(2, [SELECT Id FROM Credit_Line__share].size());*/

        System.runAs(usr){
            Test.startTest();
                delete [SELECT Id FROM Credit_Line__c];
            Test.stopTest();
        }

        Credit_Line__c[] creditLines = [    SELECT OwnerId 
                                        FROM Credit_Line__c];

        Credit_Line__share[] shares = [SELECT ParentId, UserOrGroupId
                                        FROM Credit_Line__share];

        System.assertEquals(0, shares.size());
        System.assertEquals(0, creditLines.size());
    } 
    
    private static testmethod void hierarchyCreation(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){
            creditLineBld   = new BLD_CreditLine().account(acc.Id).product('').commitWork();

            Test.startTest();
                teamBld         = new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).commitWork();
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(2, [SELECT Id FROM Credit_Line__share].size());
        }
    }

    private static testmethod void hierarchyClOnParentTeamOnChild(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            creditLineBld   = new BLD_CreditLine().account(acc.Id).product('').commitWork();

            Test.startTest();
                teamBld         = new BLD_ClientTeam().account(child.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).commitWork();
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__share].size());
        }
    }

    private static testmethod void hierarchyClOnParentTeamOnGrandchild(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            creditLineBld   = new BLD_CreditLine().account(acc.Id).product('').commitWork();

            Test.startTest();
                teamBld         = new BLD_ClientTeam().account(grandChild.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).commitWork();
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__share].size());
        }
    }

    private static testmethod void hierarchyTmOnParentClOnChild(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            Test.startTest();
                teamBld         = new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).commitWork();
                creditLineBld   = new BLD_CreditLine().account(child.Id).product('').commitWork();
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(2, [SELECT Id FROM Credit_Line__share].size());
        }
    }
    
    private static testmethod void hierarchyTmOnParentClOnGrandchild(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            Test.startTest();
                teamBld         = new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).commitWork();
                creditLineBld   = new BLD_CreditLine().account(grandChild.Id).product('').commitWork();
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(2, [SELECT Id FROM Credit_Line__share].size());
        }
    }
    
    private static testmethod void hierarchyTmOnParentAndChildClOnGrandchild(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            Test.startTest();
                insert new Custom_Client_Team__c[]{ (Custom_Client_Team__c)new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).getRecord(),
                                                    (Custom_Client_Team__c)new BLD_ClientTeam().account(child.Id).role(DMN_ClientTeam.ROLE_COMMB_PRODUCT_SPEC).user(otherUsr2.Id).getRecord()};
                creditLineBld   = new BLD_CreditLine().account(grandChild.Id).product('').commitWork();
            Test.stopTest();

            System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(3, [SELECT Id FROM Credit_Line__share].size());
        }
    }

    private static testmethod void hierarchyTmOnParentMultipleClOnGrandchild(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            Test.startTest();
                insert new Custom_Client_Team__c[]{ (Custom_Client_Team__c)new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).getRecord(),
                                                    (Custom_Client_Team__c)new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_PRODUCT_SPEC).user(otherUsr2.Id).getRecord()};
                creditLineBld   = new BLD_CreditLine().account(grandChild.Id).product('').commitWork();
            Test.stopTest();

            System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(3, [SELECT Id FROM Credit_Line__share].size());
        }
    }

    private static testmethod void hierarchyTmOnChildMultipleClOnGrandchild(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            Test.startTest();
                insert new Custom_Client_Team__c[]{ (Custom_Client_Team__c)new BLD_ClientTeam().account(child.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).getRecord(),
                                                    (Custom_Client_Team__c)new BLD_ClientTeam().account(child.Id).role(DMN_ClientTeam.ROLE_COMMB_PRODUCT_SPEC).user(otherUsr2.Id).getRecord()};
                creditLineBld   = new BLD_CreditLine().account(grandChild.Id).product('').commitWork();
            Test.stopTest();

            System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(3, [SELECT Id FROM Credit_Line__share].size());
        }
    }

    private static testmethod void hierarchyTmOnChildMultipleClOnGrandchildReverseOrder(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            Test.startTest();
                creditLineBld   = new BLD_CreditLine().account(grandChild.Id).product('').commitWork();
                insert new Custom_Client_Team__c[]{ (Custom_Client_Team__c)new BLD_ClientTeam().account(child.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).getRecord(),
                                                    (Custom_Client_Team__c)new BLD_ClientTeam().account(child.Id).role(DMN_ClientTeam.ROLE_COMMB_PRODUCT_SPEC).user(otherUsr2.Id).getRecord()};
                
            Test.stopTest();

            System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(3, [SELECT Id FROM Credit_Line__share].size());
        }
    }
    
    private static testmethod void hierarchyCLOnChildMultipleTMOnGrandchild(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            Test.startTest();
                insert new Custom_Client_Team__c[]{ (Custom_Client_Team__c)new BLD_ClientTeam().account(child.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).getRecord(),
                                                    (Custom_Client_Team__c)new BLD_ClientTeam().account(child.Id).role(DMN_ClientTeam.ROLE_COMMB_PRODUCT_SPEC).user(otherUsr2.Id).getRecord()};
                insert new Credit_Line__c[]{(Credit_Line__c)new BLD_CreditLine().account(grandChild.Id).product('a').getRecord(),
                                            (Credit_Line__c)new BLD_CreditLine().account(grandChild.Id).product('b').getRecord()};
            Test.stopTest();

            System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(2, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(4, [SELECT Id FROM Credit_Line__share WHERE RowCause =: SHR_CreditLine.DEF_SHARING].size()); 
        }
    }
    
    private static testmethod void hierarchyClean(){
        getData();
        System.runAs(usr){
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();////
            creditLineBld = new BLD_CreditLine(uow).product('').account(acc.Id);////
            teamBld = new BLD_ClientTeam(uow).account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id);////
            uow.commitWork();////

            Test.startTest();
                SRV_AccountSharing shr = new SRV_AccountSharing();
                shr.remove(acc.Id, [SELECT Id FROM Credit_Line__c]);
                shr.run();
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            // NO Sharing was removed - CL sharing is deleted when record is removed from recycle bin. 
            System.assertEquals(1, [SELECT Id FROM Credit_Line__share].size());  
        }
    }

    private static testmethod void teamMemberRole(){
        getData();
        ABS_ObjectBuilderBase teamBld;

        System.runAs(usr){
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();////
            creditLineBld = new BLD_CreditLine(uow).product('').account(acc.Id);////
            teamBld = new BLD_ClientTeam(uow).account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id);////
            uow.commitWork();////

            Test.startTest();
                teamBld = new BLD_ClientTeam().account(acc.Id)
                                                .role(DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER)
                                                .user(otherUsr2.Id).commitwork();
            Test.stopTest();

            System.assertEquals(DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER, 
                                [   SELECT Client_Role__c 
                                    FROM Custom_Client_Team__c
                                    WHERE Id =: teamBld.getRecordId()].Client_Role__c);
        } 
    } 

    private static testmethod void hierarchyTmOnParentClOnChild2(){
        getData();
        //delete [SELECT Id FROM Custom_Client_Team__c];
        //delete [SELECT Id FROM Credit_Line__c];

        System.runAs(usr){

            Test.startTest();
                creditLineBld   = new BLD_CreditLine().account(child.Id).product('').commitWork();
                teamBld         = new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUsr.Id).commitWork();
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Credit_Line__c].size());
            System.assertEquals(2, [SELECT Id FROM Credit_Line__share].size());
        }
    } 
}