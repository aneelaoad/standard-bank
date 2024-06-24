/**
* @description  : Security Utility Class
* User Story : SFP-4874
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date Aug 2021
*/

public without sharing class UTL_Security {

    public static final String PDF_FILE_TYPE_HEX = '255044462D';
    public static final String DOC_AND_PPT_FILE_TYPE_HEX = 'D0CF11E0A1B11AE1';
    public static final String DOCX_AND_PPTX_FILE_TYPE_HEX = '504B0304';
    
    /**
    * Sanitize field
    *
    * @param inputObject Type: SObject
    * @param fieldsToSanitize Type: List<String>
    * @return Type: SObject
    */
    public static SObject xssSanitize(SObject inputObject, List<String> fieldsToSanitize) {
        
        SObject tempObject = inputObject;
        
        for(String fieldName : fieldsToSanitize) {
            if(tempObject.get(fieldName) != null) {
                String tempValue = (String)tempObject.get(fieldName);
                tempObject.put(fieldName, tempValue.unescapeHtml4().escapeHtml4());
            }
        }
        
        return tempObject;
    }
    
    /**
    * Validates the file header
    *
    * @param fileExtension Type: String
    * @param fileContent Type: Blob
    * @return Boolean
    */	
    public static Boolean isValidFile(String fileExtension, Blob fileContent){
        Boolean isValid = false;
        String fileTypeHexCode;
        String hexBody = EncodingUtil.convertToHex(fileContent);
        
        if(fileExtension == 'pdf'){
           fileTypeHexCode =  PDF_FILE_TYPE_HEX;
        }else if(fileExtension == 'doc' || fileExtension == 'ppt'){
           fileTypeHexCode =  DOC_AND_PPT_FILE_TYPE_HEX;
        }else if(fileExtension == 'pptx' || fileExtension == 'docx'){
           fileTypeHexCode =  DOCX_AND_PPTX_FILE_TYPE_HEX;
        }
        
        if(hexBody.tolowerCase().startsWith(fileTypeHexCode.tolowerCase())) {
            isValid = true;                 
        } 
        return isValid;
    }
}