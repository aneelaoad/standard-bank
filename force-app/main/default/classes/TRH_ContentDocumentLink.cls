public class TRH_ContentDocumentLink extends ABS_TriggerHandlerBase {
    public override void handleAfterInsert() {
        DMN_ContentDocumentLink.updateBAssessmentHasDocumentField((List<ContentDocumentLink>) Trigger.new);
    }
}