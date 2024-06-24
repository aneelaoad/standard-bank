/**
 *  @description Controller class for OSBRegistrationRedirect component
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 *
 **/
public without sharing class OSB_RegistrationRequest_Ctrl {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OSB_RegistrationRequest_Ctrl');
        /**
         *  @description Creates a case to allow the marketplace manager to register a new user 
         *
         * @param Case for registration request
         *    
         * @return Case
         **/
        @AuraEnabled
        public static Case saveCase(Case regCase) {
            Id queueId = UTL_Queue.getQueueId(DMN_Group.GROUP_DEVELOPER_NAME_ONE_HUB);
            Case newCase = regCase;
            try{
                newCase.Priority = DMN_Case.PRIORITY_LOW;
                newCase.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CROSS_BORDER);
                newCase.OwnerId = queueId;
                insert newCase;
                return newCase;
            }catch(Exception e){
                LOGGER.error('OSB_RegistrationRequest_Ctrl : saveCase with  Exception logged: ',e);
                return null;
            }
        }
        
        /**
         *  @description decodes base64 string 
         *
         * @param base64 String
         *      
         * @return Case
         **/
        @AuraEnabled
        public static String decodeBase64String(String base64String){
            try{
                Blob base64Blob = EncodingUtil.base64Decode(base64String);
                base64String = base64Blob.toString();
                return base64String;
            }
            catch(Exception e){
                LOGGER.error('OSB_RegistrationRequest_Ctrl : decodeBase64String with  Exception logged: ',e);
                return null;
            }
    
        }
    
        /**
         *  @description Checks if a case exists in the org with the same email and subject
         *
         * @param Case for registration request
         * param email Set<String> set of emails
         * param subject Set<String> set of emails 
         * @return Boolean value
         **/
        
        @AuraEnabled(Cacheable=false)
        public static Boolean caseCheck(String email,String subject) {
            Integer countCases = [SELECT COUNT() 
                                    FROM Case 
                                    WHERE Subject =: subject 
                                    AND SuppliedEmail =: email
                                    ];
            
            return countCases > 0;
        }
    
        /**
         *  @description Checks if a contact exists in the org with the same status and email
         *
         * @param Contact for registration request
         * @param emailSet Set<String> set of emails
         * @param statusSet Set<String> set of status    
         * @return Contact
         **/
        @AuraEnabled(cacheable=false)
        public static Boolean checkDuplicate(Contact cont) {
            try{
                List<Contact> contactsFoundList = new List<Contact>();
                Set<String> emailSet = new Set<String>();
                Set<String> statusSet = new Set<String>(); 
                emailSet.add(cont.Email);
                statusSet.add(cont.OSB_Community_Access_Status__c);
                contactsFoundList = SEL_Contacts.newInstance().selectByEmailAccessStatus(emailSet,statusSet);           
                return (contactsFoundList.size() > 0);
    
            }catch(Exception e){
                LOGGER.error('OSB_RegistrationRequest_Ctrl : checkDuplicate with  Exception logged: ',e);
                return null;
        }
       }
    }