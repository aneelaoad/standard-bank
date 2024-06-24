public class NewCaseComment_Controller {
	@AuraEnabled
    public static void saveCaseComment(Id caseId,string caseCommentString){
        if(String.isNotBlank(caseCommentString)){
        	CaseComment cs = new CaseComment();
            cs.CommentBody = caseCommentString;
            cs.ParentId = caseId;
            insert cs;	      
        }
    }    
}