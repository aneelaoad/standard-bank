/*************************************************************************\
    @ Author        : Petr Roubal
    @ Date          : 18 Jan 2016
    @ Description   : EN-1016 Techn. Story for Automated Tests
 /************************************************************************/
global with sharing class AutomatedTestJobQueuer implements Schedulable{

    global void execute(SchedulableContext SC){
        doExecute();
    }
    @testvisible
    private List<ApexTestResult> apexMockPassTestResults = new List<ApexTestResult>();
    @testvisible
    private List<ApexTestResult> apexMockFailTestResults = new List<ApexTestResult>();

    //@future(callout=true)
    public void doExecute(){
        enqueueTests();
    }

    public void enqueueTests() {

        //ApexClass[] testClasses = [SELECT Id, Name FROM ApexClass];
        ApexTestResult[] atrFail;
        ApexTestResult[] atrPass;

        if(!Test.isRunningTest()) {
            atrFail = [
                    SELECT TestTimestamp, ApexClass.Name, MethodName, Outcome, Message, AsyncApexJobId, QueueItemId
                    FROM ApexTestResult
                    WHERE TestTimestamp = TODAY
                    and AsyncApexJobId = ''
                    and outcome = 'Fail'
                    order by TestTimestamp desc
                            , ApexClass.name asc
                            , MethodName asc
            ];

            atrPass = [
                    SELECT TestTimestamp, ApexClass.Name, MethodName, Outcome, Message, AsyncApexJobId, QueueItemId
                    FROM ApexTestResult
                    WHERE TestTimestamp = TODAY
                    and AsyncApexJobId = ''
                    and outcome = 'Pass'
                    order by TestTimestamp desc
                            , ApexClass.name asc
                            , MethodName asc
            ];
        }else{
            system.debug('isTest true');
            atrPass = apexMockPassTestResults;
            atrFail = apexMockFailTestResults;
        }

        String htmlBody = '';
        String orgName = UserInfo.getUserName().substringAfterLast('.');
        system.debug('##### atrFail = ' + atrFail + ', atrPass = ' + atrPass);
        if(atrFail.size() == 0 &&  atrPass.size() == 0){
            // send email that tests didn't run today
            htmlBody = '<p>The result of test was not found in ' + orgName+ '. Please check the Jenkins if testing job is scheduled.</p>';
            system.debug('##### The result of test was not found');
        }else if(atrFail.size() > 0) {
            // send email about tests faild
            htmlBody = '<p>Following method(s) failed in ' + orgName + ':</p><p>';
            for (ApexTestResult atr : atrFail){
                htmlBody += atr.ApexClass.Name + ' - ' + atr.MethodName + '<br/>';
            }
            htmlBody += '</p>';
            system.debug('##### Method(s) failed');
        }else{
            // send email that everything is ok
            htmlBody = '<p>All testing methods passed in ' + orgName + '.</p>';
            system.debug('##### All testing methods passed');
        }
        String subject = 'Run Apex Test Result ' + Datetime.now();
        
        Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
        singleMail.setSaveAsActivity(false);
        singleMail.setSubject(subject);
        singleMail.setHtmlBody(htmlBody);

        
        List<string>usersTo = new List<string>();
        for (EmailRecipientTestResults__c e: EmailRecipientTestResults__c.getAll().values()) {
            usersTo.add(e.name);
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        singleMail.setToAddresses(usersTo);
        emails.add(singleMail);
        
        Messaging.sendEmail(emails);

    }


}