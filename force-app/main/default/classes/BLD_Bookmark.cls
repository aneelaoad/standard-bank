@IsTest
public with sharing class BLD_Bookmark extends ABS_ObjectBuilderBase{
    public BLD_Bookmark() {
        this(getNewUnitOfWork());
    }

    public BLD_Bookmark(fflib_SObjectUnitOfWork workUnit) {
        super(NewsBookmark__c.sObjectType, workUnit);
    }

    private BLD_Bookmark(NewsBookmark__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    public BLD_Bookmark news(BLD_News bNews){
        return (BLD_Bookmark) setRelation(NewsBookmark__c.ArticleNews__c, bNews);
    }
}