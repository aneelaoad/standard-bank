/**
 * @description TRH_ContentVersion
 */
public class TRH_ContentVersion extends ABS_TriggerHandlerBase {
    private ContentVersion[] records {
        get { return (ContentVersion[])Trigger.new; }
    }
    public override void handleBeforeInsert() {
        DMN_ContentVersion.updateDocumentPrivacy(records);
    }
}