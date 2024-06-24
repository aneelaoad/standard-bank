/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-01-2022
 * @last modified by  : TCK
**/
public without sharing class BLD_ContentVersion extends ABS_ObjectBuilderBase {  
    public static final String DEF_TITLE = 'testTitle';
    public static final Blob DEF_VERSION_DATA = EncodingUtil.base64Decode('testVersionData');
    public static final String DEF_TYPE = '.jpg';

    public static Integer counter = 0;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_ContentVersion(fflib_SObjectUnitOfWork uow) {
        super(ContentVersion.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(ContentVersion.Title, counter + DEF_TITLE + counter)
        .setField(ContentVersion.VersionData, DEF_VERSION_DATA)
        .setField(ContentVersion.PathOnClient, counter + DEF_TITLE + counter + DEF_TYPE)
        .setField(ContentVersion.IsMajorVersion, true);

        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_ContentVersion 
    **/
    public BLD_ContentVersion document(BLD_EAP_Document eventBuilder) {
        return (BLD_ContentVersion) setRelation(ContentVersion.FirstPublishLocationId, eventBuilder);
    }

        /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param title 
    * @return BLD_ContentVersion 
    **/
    public BLD_ContentVersion title(String title) {
        return (BLD_ContentVersion) setField(ContentVersion.Title, title);
    }
}