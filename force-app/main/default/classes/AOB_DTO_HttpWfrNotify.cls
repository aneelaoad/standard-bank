/**
 * @description The REST Web Service DTO with Wrappers to update the WFR Status on Application record
 *
 * @author Narendra Teja
 *
 * @date January 2023
 */
/**
 * @description class to format API Request structure
*/
public with sharing class AOB_DTO_HttpWfrNotify {
    /**
     * @description class to format API Request structure
     */
	public class WfrNotify {
        /** @description wfrStatus */
		public String wfrStatus { get; set; }
        /** @description wfrMessage */
		public String wfrMessage { get; set; }
        /** @description wfrErrorCode */
		public String wfrErrorCode { get; set; }
	}
	/*
     * @description parse 
     * @param json
     * @return AOB_DTO_HttpWfrNotify
    */
    public static AOB_DTO_HttpWfrNotify parse(String json) {
        return (AOB_DTO_HttpWfrNotify) System.JSON.deserialize(json, AOB_DTO_HttpWfrNotify.class);
    }
}