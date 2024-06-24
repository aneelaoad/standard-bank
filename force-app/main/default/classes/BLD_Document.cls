/**
 * Builder class for Document SObject
 *
 * @author      Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date        May 2020
 */
@IsTest
public class BLD_Document extends ABS_ObjectBuilderBase{
	
    private static final Blob DEF_BODY = Blob.valueOf('Some Text');
    private static final String DEF_CONTENT_TYPE = 'application/pdf';
    private static final String DEF_DEVELOPER_NAME = 'My_Test_Document';
    private static final Boolean DEF_IS_PUBLIC = true;
    private static final String DEF_NAME = 'My Test Document';
    
	public BLD_Document() {
        this(getNewUnitOfWork());
    }

    public BLD_Document(fflib_SObjectUnitOfWork uow) {
        super(Document.SObjectType, uow);
    }

    public BLD_Document(Document document, fflib_SObjectUnitOfWork uow) {
        super(document, uow);
    }

    protected override void setDefaultData() {
        setField(Document.Body, DEF_BODY)
            .setField(Document.ContentType, DEF_CONTENT_TYPE)
            .setField(Document.DeveloperName, DEF_DEVELOPER_NAME)
            .setField(Document.IsPublic, DEF_IS_PUBLIC)
            .setField(Document.Name, DEF_NAME);
    }

    public BLD_Document folderId(Id folderId) {
        return(BLD_Document)setField(Document.FolderId, folderId);
    }
    public BLD_Document developerName(String developerName) {
        return(BLD_Document)setField(Document.DeveloperName, developerName);
    }
    
}