/**
* Trigger handler class for Knowledge_kav
* <br/> US-4320
*
* @Author Wayde Fagan(wayde.fagan@tetrad.co.za)
* @Date March 2021
*/
public class TRH_Knowledge extends ABS_TriggerHandlerBase {
    
    private List<Knowledge__kav> knowledgeList {
        get {
            return (List<Knowledge__kav>) Trigger.new;
        }
    }   
    
    public override void handleAfterInsert(){    
        DMN_Knowledge.updateSubSolutions(knowledgeList);
        DMN_Knowledge.updateChildrenApi(knowledgeList);
    } 
}