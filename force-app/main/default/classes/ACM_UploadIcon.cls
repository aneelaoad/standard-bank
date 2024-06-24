/**
@description Upload API Icon to anypoint API exchange
@className ACM_UploadIcon
@Author - Sherry Afsar
@email 	sherry.afsar@standardbank.co.za
@company  Standardbank    
@date  June 22th, 2023
**/
public class ACM_UploadIcon {
    
    /**
* @description to log the global info/Errors
**/
    private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ACM_UploadIcon');
    
    public virtual class BaseException extends Exception {}
    public class AnypointExchangeException extends BaseException {}
    
    @InvocableMethod(callout=true label='Upload icon to Anypoint Exchange asset') 
    public static void uploadIconToAnypointExchangeAsset(List<uploadIconToAnypointExchangeAssetRequest> assetList){        
        
        for(uploadIconToAnypointExchangeAssetRequest asset : assetList){   
            
            try{
                logger.info('Preparing data from asset list in try block.');
                String staticResourceName = asset.staticResourceName;
                String assetId  = asset.assetId;
                String anypointGroupId  = asset.anypointGroupId;
                
                // Read PNG file contents as a Blob from a Static Resource
                Blob pngBlob = [SELECT Body FROM StaticResource WHERE Name = :staticResourceName].Body;
                
                // Create HttpRequest object
                HttpRequest httpRequest = new HttpRequest();
                HttpRequest.setEndpoint('callout:Anypoint' + '/exchange/api/v2/assets/' + anypointGroupId + '/' + assetId + '/icon');
                httpRequest.setMethod('PUT');
                httpRequest.setHeader('Content-Type', 'image/png');
                httpRequest.setBodyAsBlob(pngBlob);
                
                // Create and send the HTTP request
                HttpResponse httpResponseObj = new HttpResponse();
                Http http = new Http();
                httpResponseObj = http.send(httpRequest);
                
                Integer httpStatusCode = httpResponseObj.getStatusCode();
                if(httpStatusCode != 201)
                {
                    logger.error('Response code not 201!');
                    throw new AnypointExchangeException(httpResponseObj.getBody());
                }
            }
            catch(BaseException e)
            {
                logger.ERROR('No Record in Assetlist'+ e);
                throw new AnypointExchangeException('ANYPOINT-EXCHANGE-ERROR: ' + e);
            } 
        }
        
    }
    
    //This is an inner class defining the input variables to the above method. It's needed so multiple variables can be passed from flow to the APEX class
    public class uploadIconToAnypointExchangeAssetRequest{
        
        @InvocableVariable(required=true)
        public String staticResourceName;
        
        @InvocableVariable(required=true)
        public String assetId;
        
        @InvocableVariable(required=true)
        public String anypointGroupId;
        
    }
    
}