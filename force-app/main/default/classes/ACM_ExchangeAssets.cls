/**
@description Handles Anypoint assets exhange queries
@className ACM_LeadOrSubscribe
@Author - Sherry Afsar
@email 	sherry.afsar@standardbank.co.za
@company  Standardbank    
@date  June 22th, 2023
**/
public class ACM_ExchangeAssets{
        private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ACM_LeadOrSubscribe');

    public virtual class BaseException extends Exception {}
    public class AnypointExchangeException extends BaseException {}
    
    @InvocableMethod(callout=true label='Publish asset to Anypoint Exchange') 
    public static void publishAssetToAnypointExchange(List<publishAssetToAnypointExchangeRequest> assetList){        
        logger.info('Preparing data from asset list to be looped one by one');
      for(publishAssetToAnypointExchangeRequest asset : assetList){   
          
        try{
          
          Blob fileBody = Blob.valueOf(asset.fileBody);
          String fileName = asset.fileName;
          String assetName = asset.assetName;
          String description = asset.description;
          String assetId = asset.assetId;
          String assetype = asset.assetType;
          String fileUploadType = asset.fileUploadType;
          String contentType = asset.contentType;
          String apiVersion = asset.apiVersion;
          String apiVersionGroup = asset.ApiVersionGroup;
          String requestEndpoint = asset.requestEndpoint;
          String authToken = asset.authToken;
          String anypointOrgId = asset.anypointOrgId;
          String anypointGroupId = asset.anypointGroupId;
          String contactName = asset.contactName;
          String contactEmail = asset.contactEmail;
          List<String> categories = asset.categories;
          List<String> customFields = asset.customFields;
          String keywords = asset.keywords;
          String tags = asset.tags;
          String status = asset.status;
        
        //Map array of categories to JSON array
        String categoriesJsonString;    
        Map<String, String> categoriesNameValueMap = new Map<String, String>();
        
        JSONGenerator jsGenCategories = JSON.createGenerator(true);
        jsGenCategories.writeStartArray();
    
        for(String pair : categories) 
          {
            String[] parts = pair.split('=');
            jsGenCategories.writeStartObject();
            jsGenCategories.writeStringField('key', parts[0]);
            jsGenCategories.writeStringField('value', parts[1]);
            jsGenCategories.writeEndObject();
          }
    
        categoriesJsonString = jsGenCategories.getAsString();
    
        //Map array of custom fields to JSON array
        String customFieldsJsonString;    
        Map<String, String> customFieldsNameValueMap = new Map<String, String>();
        
        JSONGenerator jsGenCustomFields = JSON.createGenerator(true);
        jsGenCustomFields.writeStartArray();
    
        for(String pair : customFields) 
          {
            String[] parts = pair.split('=');
            jsGenCustomFields.writeStartObject();
            jsGenCustomFields.writeStringField('key', parts[0]);
            jsGenCustomFields.writeStringField('value', parts[1]);
            jsGenCustomFields.writeEndObject();
          }
    
        customFieldsJsonString = jsGenCustomFields.getAsString();
        
        //Prepare the header
        String boundary = '------------------------------741e90d31eff';
        String formName = '--' + boundary + '\r\nContent-Disposition: form-data; name="name";\r\n\r\n' + assetName +'\r\n';
        String formApiVersionGroup = '--' + boundary + '\r\nContent-Disposition: form-data; name="properties.apiVersion";\r\n\r\n' + apiVersionGroup + '\r\n';
        String formType = '--' + boundary + '\r\nContent-Disposition: form-data; name="type";\r\n\r\n' + assetype + '\r\n';
        String formMainFile = '--' + boundary + '\r\nContent-Disposition: form-data; name="properties.mainFile";\r\n\r\n' + fileName + '\r\n';
        String formDescription = '--' + boundary + '\r\nContent-Disposition: form-data; name="description";\r\n\r\n' + description + '\r\n'; 
        String formContactName = '--' + boundary + '\r\nContent-Disposition: form-data; name="contactName";\r\n\r\n' + contactName + '\r\n';
        String formContactEmail = '--' + boundary + '\r\nContent-Disposition: form-data; name="contactEmail";\r\n\r\n' + contactEmail + '\r\n';
        String formKeywords = '--' + boundary + '\r\nContent-Disposition: form-data; name="keywords";\r\n\r\n' + keywords + '\r\n';
        String formTags = '--' + boundary + '\r\nContent-Disposition: form-data; name="tags";\r\n\r\n' + tags + '\r\n';
        String formCategories = '--' + boundary + '\r\nContent-Disposition: form-data; name="categories";\r\n\r\n' + categoriesJsonString + '\r\n';
        String formCustomFields = '--' + boundary + '\r\nContent-Disposition: form-data; name="fields";\r\n\r\n' + customFieldsJsonString + '\r\n';
        String formStatus = '--' + boundary + '\r\nContent-Disposition: form-data; name="status";\r\n\r\n' + status + '\r\n';
        String header = '--' + boundary + '\r\nContent-Disposition: form-data; name="' + fileUploadType + '"; filename="'+fileName +'"\r\nContent-Type: ' + contentType;
        
        header = formName +  formApiVersionGroup + formType + formMainFile + formDescription + formContactName + formContactEmail + formKeywords + formTags + formCategories + formCustomFields + formStatus + header;
        
        //Prepare the footer
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
         header+=' ';
         headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
    
        //Prepare the body
        String bodyEncoded = EncodingUtil.base64Encode(fileBody);
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
      
       // Process encoding of file
       if(last4Bytes.endsWith('==')) {
          // Note: if using \n\n instead of \r\n replace == with 'oK'
          last4Bytes = last4Bytes.substring(0,2) + '0K';
          bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
          // We have appended the \r\n to the Blob, so leave footer as it is.
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
          // Note: if using \n instead of \r replace = with 'K'
          last4Bytes = last4Bytes.substring(0,3) + 'N';
          bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
          // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
          footer = '\n' + footer;
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
          // Prepend the CR LF to the footer
          footer = '\r\n' + footer;
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
       logger.info('Body has been prepared');
        //Prepare the HTTP request
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; charset="UTF-8"; boundary='+boundary);
        req.setHeader('Accept', '*/*');
        //req.setHeader('Authorization', 'bearer ' + authToken);
        req.setHeader('x-sync-publication', 'true');
        req.setMethod('POST');
        req.setEndpoint('callout:Anypoint' + '/exchange/api/v2/organizations/' + anypointOrgId + '/assets/' + anypointGroupId + '/' + assetId + '/' + apiVersion);
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);
      
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        Integer httpStatusCode = res.getStatusCode();
        if(httpStatusCode != 201)
          {
            logger.info('Error - Status code is ' + res.getStatusCode());
			throw new AnypointExchangeException(res.getBody());
          }
      }
      	catch(BaseException e)
         {
             logger.info('Error in the transaction' + e.getMessage());
             throw new AnypointExchangeException('ANYPOINT-EXCHANGE-ERROR: ' + e);
         } 
     }
     
    }
    
    //This is an inner class defining the input variables to publishAssetToAnypointExchange. It's needed so multiple variables can be passed from flow to the APEX class
    public class publishAssetToAnypointExchangeRequest{
                
        @InvocableVariable(required=true)
        public String fileBody;
        
        @InvocableVariable(required=true)
        public String fileName;
        
        @InvocableVariable(required=true)
        public String assetName;
        
        @InvocableVariable(required=true)
        public String description;
        
        @InvocableVariable(required=true)
        public String assetId;
        
        @InvocableVariable(required=true)
        public String assetType;
        
        @InvocableVariable(required=true)
        public String fileUploadType;
        
        @InvocableVariable(required=true)
        public String contentType;
        
        @InvocableVariable(required=true)
        public String apiVersion;
        
        @InvocableVariable(required=true)
        public String apiVersionGroup;
        
        @InvocableVariable(required=true)
        public String requestEndpoint;
        
        @InvocableVariable(required=true)
        public String authToken;
        
        @InvocableVariable(required=true)
        public String anypointOrgId;
        
        @InvocableVariable(required=true)
        public String anypointGroupId;
        
        @InvocableVariable(required=true)
        public String contactName;
        
        @InvocableVariable(required=true)
        public String contactEmail;
        
        @InvocableVariable(required=true)
        public List<String> categories;
        
        @InvocableVariable(required=true)
        public List<String> customFields;
        
        @InvocableVariable(required=true)
        public String keywords;
        
        @InvocableVariable(required=true)
        public String tags;
        
        @InvocableVariable(required=true)
        public String status;
    }
}