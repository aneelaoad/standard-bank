/**
* @description       : API class for internal get document call out
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 07-13-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification Description: SFP-25088
* 1.0   03-17-2023   Tukelo Moseamo   Initial Version
**/
public class AOB_Internal_DTO_GetDocument {


    /*
    *@description getDocument transformation request
    */
    public class DTO_Request {
        public String contentId;
        public String documentId;
        public String filename;
        public String businessFlag;
        public String guId;
    }   

}