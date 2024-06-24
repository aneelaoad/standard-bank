/**************************************************************************************
Apex Class Name     : StdBank_Ltn_BackendResult
Version             : 1.0
Created Date        : 20 JUL 2016
Function            : Backend Response object containing result and message (optional)
Modification Log    :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------
* Daniel Horky                  20/07/2016              Original Version
*************************************************************************************/

public class StdBank_Ltn_BackendResult {

    // Success status indicator
    public Boolean success {get; set;}

    // Message containing detailed instructions
    public String message {
        get {
            return (message == null) ? '' : message;
        }

        set;
    }

    /*
     * Description  : Default constructor
     */
    public StdBank_Ltn_BackendResult() {}

    /*
     * Description  : Constructor with success indicator
     * Parameter    : Boolean success
     */
    public StdBank_Ltn_BackendResult(Boolean success) {
        this.success = success;
    }

    /*
     * Description  : Constructor with success indicator and message
     * Parameter    : Boolean success, String message
     */
    public StdBank_Ltn_BackendResult(Boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public String toJSON() {
        return JSON.serialize(this);
    }
}