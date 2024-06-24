@IsTest
public without sharing class BLD_News extends ABS_ObjectBuilderBase {

    private static final String DEF_HIGH_CLIENT = 'highClient';
    private static final String DEF_MEDIUM_CLIENT = 'mediumClient';
    private static final String DEF_LOW_CLIENT = 'lowClient';

    public BLD_News() {
        this(getNewUnitOfWork());
    }
 
    public BLD_News(fflib_SObjectUnitOfWork workUnit) {
        super(ArticleNews__c.SObjectType, workUnit);
    }

    private BLD_News(ArticleNews__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    protected override void setDefaultData() {
        setField(ArticleNews__c.High_Prob_Clients__c, DEF_HIGH_CLIENT)
            .setField(ArticleNews__c.Medium_Prob_Clients__c, DEF_MEDIUM_CLIENT)
            .setField(ArticleNews__c.Low_Prob_Clients__c, DEF_LOW_CLIENT);
    }

    public BLD_News an(String an){
        return (BLD_News) setField(ArticleNews__c.An__c, an);
    }

    public BLD_News pred(Boolean pred){
        return (BLD_News) setField(ArticleNews__c.Pred__c, pred);
    }

    public BLD_News publicationDate(String publicationDate) {
        return (BLD_News) setField(ArticleNews__c.Publication_Date__c, publicationDate);
    }

    public BLD_News title(String title){
        return (BLD_News) setField(ArticleNews__c.Title__c, title);
    }
}