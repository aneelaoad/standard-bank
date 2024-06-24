/**
 * @description NBACRealEstateFinanceController class for interfacing with the NbacRealEstateFinance LWC component to display REF fields
 *
 * @author Stane Murhula (stane.murhula@standardbank.co.za)
 * @UserStory 
 * @date March 2024
 *
 */
public with sharing class NBACRealEstateFinanceController {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('NBACRealEstateFinanceController');

   /**
     * @description returns a list if REF fields from a business assessment
     * @param baId String
     * @return List of NBAC_Real_Estate_Finance__c
     */
    @AuraEnabled(cacheable=false)
    public static List<NBAC_Real_Estate_Finance__c> getRefData(String baId) {
        try {
            List<NBAC_Real_Estate_Finance__c> refInfo = SEL_NbacRealEstateFinance.newInstance().selectRefByBaId(new Set<String>{baId});
            return refInfo;
        } catch (Exception e) {
            LOGGER.error('NBACRealEstateFinanceController : getRefData Retriving REF Data Exception logged: ',e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
   /**
     * @description saves and updates ref record returns a list if REF fields from a business assessment
     * @param refDataList List<NBAC_Real_Estate_Finance__c> 
     * @param baRec Business_Assessment__c 
     * @param baId String
     * @return List of NBAC_Real_Estate_Finance__c
     */
    @AuraEnabled(cacheable=false)
    public static List<NBAC_Real_Estate_Finance__c> saveRefData(List<NBAC_Real_Estate_Finance__c> refDataList, Business_Assessment__c baRec, String baId) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try {
            SRV_NBACRealEstateFinance.newInstance().saveRefData(refDataList, baRec, baId, uow);
            return getRefData(baId);
        } catch (Exception e) {
            LOGGER.error('NBACRealEstateFinanceController : saveRefData Exception logged: ',e);
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /**
     * @description delete selected ref metric and returns void
     * @param RefId List<String>
     */
    @AuraEnabled
    public static void deleteRefMetric(List<String> refId) {
          try {
            List<NBAC_Real_Estate_Finance__c> refMetricToDelete = SEL_NbacRealEstateFinance.newInstance().selectRefByRefId(refId);
              if (refMetricToDelete.size() != 0) {
                  delete refMetricToDelete;
              }
        } catch (Exception e) {
            LOGGER.error('NBACRealEstateFinanceController : deleteRefMetric Exception logged: ',e);
            throw new AuraHandledException(e.getMessage());
        }
    }  

    /**
     * @description a list of fieldSet values
     * @param objectName String 
     * @param fieldsetNames List<String> 
     * @return List<List<Map<String, String>>> fieldSetValues
     */
   @AuraEnabled(cacheable=true)
    public static List<List<Map<String, String>>> getFieldSetValues(String objectName, List<String> fieldSetNames) {
            List<List<Map<String, String>>> fieldSetValuesList = new List<List<Map<String, String>>>();
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        
            if (objectType != null) {
                Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
                
                for (String fieldSetName : fieldSetNames) {
                    List<Map<String, String>> fieldSetValues = getFieldSetValuesHelper(describeResult, fieldSetName);
                    fieldSetValuesList.add(fieldSetValues);
                }
            }
            return fieldSetValuesList;
    }

    /**
     * @description helper method which return list of fieldSet values
     * @param describeResult Schema.DescribeSObjectResult 
     * @param fieldSetName String
     * @return List<Map<String, String>> key pair for fieldSet
     */
    private static List<Map<String, String>> getFieldSetValuesHelper(Schema.DescribeSObjectResult describeResult, String fieldSetName) {
        List<Map<String, String>> fieldSetValues = new List<Map<String, String>>();
        Schema.FieldSet fieldSet = describeResult.fieldSets.getMap().get(fieldSetName);
        
        if (fieldSet != null) {
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                Map<String, String> fieldInfo = new Map<String, String>();
                fieldInfo.put('label', field.getLabel());
                fieldInfo.put('type', String.valueOf(field.getType()));
                fieldInfo.put('apiName', field.getFieldPath());
                
                Schema.DescribeFieldResult fieldDescribe = describeResult.fields.getMap().get(field.getFieldPath()).getDescribe();
                
                fieldInfo.put('helperText', fieldDescribe.getInlineHelpText());
                fieldInfo.put('description', fieldDescribe.getLabel());
                
                fieldSetValues.add(fieldInfo);
            }
        }
        return fieldSetValues;
    }
}