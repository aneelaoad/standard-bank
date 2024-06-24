/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description holds REST API status codes
 */
public with sharing class RequestConsentErrorCode {

    /**
    * @description Gets the definition of a code
    * @param  code Integer
    * @return String
    */
    public static String getDefinition(Integer code){
        switch on code {
            when 400 {	
                return 'Bad Request';
            }	
            when 401 {
                return 'Unauthorized';
            }
            when 403 {	
                return 'Forbidden';
            }
            when 408 {	
                return 'Request Timeout';
            }
            when 500 {	
                return 'Internal Server Error';
            }
            when 503 {	
                return 'Service Unavailable';
            }
            when 204 {	
                return 'No Content';
            }
            when else {	
                return 'No Definition';
            }
        }
    }

    /**
    * @description gets the Description of te code
    * @param  code Integer
    * @return String
    */
    public static String getDescription(Integer code){
        switch on code {
            when 400 {	
                return 'response status code indicates that the server cannot or will not process the request due to something that is perceived to be a client error'+
                    '(e.g., malformed request syntax, invalid request message framing, or deceptive request routing) , SF might be the problem in this case or the remote server has updated their endpoints';
            }	
            when 401 {
                return 'client error status response code indicates that the request has not been applied because it lacks valid authentication credentials for the target resource, =>SF or the ESB Gateway has changed creds'
					+'This status is similar to 403, but in this case, authentication is possible';
            }
            when 403 {	
                return 'client error status response code indicates that the server understood the request but refuses to authorize it.'+
                    ' so the most possible issue is the ESB gateway , probably the request does not have rights to the actual resource ';
            }
            when 408 {	
                return 'response status code means that the server would like to shut down this unused connection. '+
                    'but it might happen that the ESB gateway holds SF request beyond SF timeout limit then SF might just close the connection ';
            }
            when 500 {	
                return 'server error response code indicates that the server encountered an unexpected condition'+
                    ' that prevented it from fulfilling the request. the most possible issue is BPM';
            }
            when 503 {	
                return 'server error response code indicates that the server is not ready to handle the request, he most possible issue is BPM';
            }
            when 204 {	
                return 'success status response code indicates that the request has succeeded, but that the client doesn\'t need to go away from its current page';
            }
            when else {	
                return 'No Description';
            }
        }
    }
    /**
    * @description Gets the full status code message
    * @param  res CallOutErrorWrapper
    * @return string
    */
    public static string getcalloutError(CallOutErrorWrapper res){
        
        Integer errorCode = Integer.valueOf(res.httpCode);
        String definition = RequestConsentErrorCode.getDefinition(errorCode);
        String description = RequestConsentErrorCode.getDescription(errorCode);
        String fullMsg = 'Error Message: '+res.httpMessage+'Error Code: '+errorCode+'Code Definition :'+definition+'Code Descriotion:'+
            description;   
        return fullMsg;
    }
    /**
    * @description Gets the full status code message
    * @param  e CalloutException
    * @param  res HttpResponse
    * @return string
    */
    public static String getcalloutError(CalloutException e,HttpResponse res){
        String msg = e.getMessage();
        Integer errorCode = res.getStatusCode();
        String definition = RequestConsentErrorCode.getDefinition(errorCode);
        String description = RequestConsentErrorCode.getDescription(errorCode);
        String fullMsg = 'Error Message: '+msg+' Error Code: '+errorCode+' Code Definition :'+definition+' Code Descriotion:'+
            description;
        
        return fullMsg;
    }

    /**
    * @description Inner class to wrap CallOutErrorWrapper Object
    */
    public class CallOutErrorWrapper{
        public String httpCode;
        public String httpMessage;
        public String moreInformation;
    }
}