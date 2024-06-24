public class TRH_ContentDocument extends ABS_TriggerHandlerBase {

    public override void handleBeforeDelete() {
        DMN_ContentDocument.updateBAssessmentHasDocumentField(Trigger.oldMap.keySet());
    }

}