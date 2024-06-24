/**
 * Created by akepczynski on 12.04.2018.
 */

public without sharing class RedirectFromRelatedListToLex {
    private SObject record;
    
    public String componentName{get; set;}
    
    public RedirectFromRelatedListToLex(ApexPages.StandardController ctrl){
        record = ctrl.getRecord();
    }
    
    public PageReference redirect(){
        String parentId = ApexPages.currentPage().getParameters().get('parentId');
        String componentName = ApexPages.currentPage().getParameters().get('componentName');
        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        generator.writeStringField('componentDef', 'c:Modal');
        generator.writeFieldName('attributes');
        generator.writeStartObject();
        generator.writeStringField('component', 'c:' + componentName);
        generator.writeFieldName('attributes');
        generator.writeStartObject();
        generator.writeStringField('recordId', String.isBlank(parentId) ? '' : parentId);
        generator.writeStringField('sObjectName', record.getSObjectType().getDescribe().getName());
        generator.writeBooleanField('isQuickAction', false);
        generator.close();
        System.debug(generator.getAsString());
        Blob base64Component = Blob.valueOf(generator.getAsString());
        String urlStrSF1 = '/one/one.app?source=aloha#' + EncodingUtil.base64Encode(base64Component);
    
        return new PageReference(urlStrSF1);
    }

    public PageReference redirectLightning(){
        String parentId = ApexPages.currentPage().getParameters().get('parentId');
        String componentName = ApexPages.currentPage().getParameters().get('componentName');
        PageReference pageReference = new PageReference('/lightning/cmp/c__'+componentName+'?c__id=' + parentId);
        pageReference.setRedirect(true);
        return pageReference;
    }
    
}