/**
 * @description Creates test data for Akili testing
 * 
 * @author Khakhu Ramakuela
 * @date October 2021
 */
@isTest
public class AKI_TestData {

    /**
     * This method creates an insight for Akili Unit Testing
     */
    public static void createInsight(){
        Insight__c o = new Insight__c();
        o.Event_Date__c=  Date.today();
        o.OwnerId=userInfo.getUserId();
        o.Client_Coordinator__c=userInfo.getUserId();
        insert o;
    }

    /**
     *  This method creates an account for Akili Unit Testing, adds it to the database and returns it
     * 
     * @return Account
     */
    public static Account createAccount(){
        Account c=new Account();
        c.Name='Test insight with client name';
        insert c;
        return c;
    }

    /**
     *  This method creates insights for Akili Unit Testing, adds them to the database and returns them
     * 
     * @param numInsights the number of Insights to be created
     * 
     * @return List<Insight_c>
     */
    public static List<Insight__c> createInsights(Integer numInsights){
        List<Insight__c> ins=new List<Insight__c>();

        for(Integer i=0;i<numInsights;i++){
            Insight__c o = new Insight__c();
            o.Event_Date__c=  Date.today();
            o.Expiry_Date__c = Date.today().addDays(5);
            o.Is_Snoozed__c=true;
            
            o.Category__c = 'FX TIPS';
            ins.add(o);
        }

        insert ins;
        return ins;
    }

    /**
     *  This method creates snoozed insights for Akili Unit Testing and adds them to the database
     * 
     * @param numIns the number of Insights to be created
     */
    public static void createSnoozedInsights(Integer numIns){
        List<Insight__c> ins = new List<Insight__c>();
        for(Integer i = 0; i < numIns; i++){
            Insight__c o = new Insight__c();
            o.Category__c = 'FX TIPS';
            o.Is_Snoozed__c = TRUE;
            o.Event_Date__c=  Date.today();
            ins.add(o);
        }
        insert ins;
    }

    /**
     *  This method creates insights with clients for Akili Unit Testing and adds them to the database
     * 
     * @param numIns the number of Insights to be created
     */
    public static void createInsightsWithClients(Integer numIns){
        Account c=new Account();
        c.Name='Test insight with client name';
        insert c;
        List<Insight__c> ins = new List<Insight__c>();
        for(Integer i = 0; i < numIns; i++){
            Insight__c o = new Insight__c();
            o.Category__c = 'FX TIPS';
            o.Is_Snoozed__c = TRUE;
            o.Event_Date__c=  Date.today();
            o.Client__c= c.Id;
            ins.add(o);
        }
        insert ins;
    }

    /**
     * @description This method creates insight actions for Akili Unit Testing, adds them to the database and returns them
     * 
     * @param numIns the number of Insights to be created
     * 
     * @return List<Insight_Action_c>
     */
    public static List<Insight_Action__c> createValIns(Integer numIns){
        List<Insight__c> ins = new List<Insight__c>();
        for(Integer i = 0; i < numIns; i++){
            Insight__c o = new Insight__c();
            o.Category__c = 'FX TIPS';
            o.Is_Snoozed__c = TRUE;
            o.status__c = 'Accepted';
            o.Event_Date__c=  Date.today();
            ins.add(o);
        }
        insert ins;
        List<Insight_Action__c> insAct = new List<Insight_Action__c>();
        for(Integer i = 0; i < numIns; i++){
            Insight_Action__c o = new Insight_Action__c();
            o.Action_Type__c = 'Rating';
            o.Insight__c = ins.get(i).Id;
            o.Insight_Status__c=  'Insight Actioned';
            o.Insight_Quality__c= 'Please give me more';
            o.User__c=UserInfo.getUserId();
            insAct.add(o);
        }
        insert insAct;
        return insAct;
    }

    /**
     * @description This method creates an opportunity for Akili Unit Testing and adds it to the database
     * 
     * @param numIns the number of Insights to be created
     */
    public static void createOpp(Integer numIns){
        Opportunity op = new Opportunity();
        op.name = 'Opportunity ';
        op.closeDate = Date.today().addDays(5);
        op.stageName = '1 - Lead';
        insert op;

        List<Insight__c> ins=new List<Insight__c>();

        for(Integer i=0;i<numIns;i++){
            Insight__c o = new Insight__c();
            o.Event_Date__c=  Date.today();
            o.Opportunity__c=op.Id;
            ins.add(o);
        }

        insert ins;
    }

    /**
     * @description This method creates opportunities for Akili Unit Testing and adds them to the database
     * 
     * @param numOpps the number of opportunities to be created
     */
    public static void createOpps(Integer numOpps){
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < numOpps; i++){
          Opportunity o = new Opportunity();
          o.name = 'Opportunity ' + i;
          o.closeDate = Date.today().addDays(5);
          o.stageName = '1 - Lead';
          opps.add(o);
        }
        insert opps;
    }
}