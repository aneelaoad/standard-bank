/**
 *
 * @description Queueable class for statement generating and sending by the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 * 
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class OSB_SRV_BotStatementHandler implements Queueable, Database.AllowsCallouts {
    @TestVisible
    private static Boolean doChainJob = true;
    private String serializedInput;
    private static final Http REQUEST_SENDER = new Http();
    private static final Long TEN_MINUTES = 10 * 60 * 1000;
    private static final String ACTION_TYPE = 'ActionType',
            CASE_ID = 'CaseId',
            CONTACT_ID = 'ContactId',
            ACCOUNT_NO = '{accountNo}',
            LAST_7_DAYS = 'Last 7 days',
            LAST_30_DAYS = 'Last 30 days',
            ERROR_LOG_ID = 'ErrorLogId',
            SERVICE_TYPE = 'ServiceType',
            FILENAME_TIMESTAMP = 'yyyyMMdd.HHmmss',
            FILE_NAME_PATTERN = '{0}{1}.{2}.pdf',
            PDF_CONTENT_TYPE = 'application/pdf',
            STATEMENT_ERROR_ACTION_TYPE = 'Statement error',
    		AWS_TOKEN = 'AWS_Token',
            OCH_TOKEN = 'OCH_TOKEN_',
            ERROR = 'Error',
            INFO = 'Info',
            ONE_HUB = 'OneHub',
            PASSWORD = 'password',
            EMAIL_STATEMENT = 'Email statement',
            SOURCE_CLASS = 'OSB_SRV_BotStatementHandler',
            DCS = 'DCS_',
            PARAMETER_ACCOUNT_NO = 'accountNo',
            PARAMETER_FROM_DATE = 'fromDate',
            PARAMETER_TO_DATE = 'toDate',
            PARAMETER_PASSWORD = 'password',
            PARAMETER_COUNTRY = 'countryName',
            COUNTRY_NAME = 'CountryName';

    public OSB_SRV_BotStatementHandler (String serializedInput){
        this.serializedInput = serializedInput;
    }

    /**
     * @description Method for invoking Create_Case_From_Chat_Bot flow
     *
     * @param input UpdateCaseInput - input params for flow
     */
    public static void updateCase(UpdateCaseInput input) {
        if (Test.isRunningTest()) {
            return;
        }
        Map<String, Object> params = new Map<String, Object>();
        params.put(ACTION_TYPE, input.actionType);
        params.put(CASE_ID, input.caseId);
        params.put(CONTACT_ID, input.contactId);
        params.put(ERROR_LOG_ID, input.errorLogId);
        params.put(SERVICE_TYPE, input.serviceType);
        params.put(COUNTRY_NAME, input.countryName);
        Flow.Interview.Create_Case_From_Chat_Bot caseFlow = new Flow.Interview.Create_Case_From_Chat_Bot(params);
        caseFlow.start();
    }

    /**
     * @description Method for creating and sending request to AWS statement generator and sending email with statement or fault email to the customer
     *
     * @param serializedInput String - serialized OSB_VA_EmailStatement_CTRL.EmailStatementInput
     */
    public void execute (QueueableContext context) {
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = (OSB_VA_EmailStatement_CTRL.EmailStatementInput) JSON.deserialize(serializedInput, OSB_VA_EmailStatement_CTRL.EmailStatementInput.class);
        HttpResponse response;
        AWSStatementResponse responseBody;
        Boolean statementGenerated = false;
        Log__c errorLog;
        List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput> inputsAuth = new List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput>();
        try {         
            DCS_API_Token__c token = authenticateOnAWSStatementGenerator(input.countryName);
            AWSCallResult awsCallResult = triggerStatementGeneration(input, token.Access_Token__c);
            response = awsCallResult.response;
            errorLog = awsCallResult.log;
            if (response.getStatusCode() == 200) {
                statementGenerated = true;
                responseBody = (AWSStatementResponse) JSON.deserialize(response.getBody(), AWSStatementResponse.class);
                String instanceName = OCH_TOKEN + input.countryName.replace(' ', '_');
                DCS_API_Token__c accessToken = DCS_API_Token__c.getInstance(instanceName);
                Long now = Datetime.now().getTime();
                if(accessToken == null){
                    accessToken = new DCS_API_Token__c(Name = instanceName);
                }
                accessToken.Created_Time__c = String.valueOf(now);
            }
        } catch (Exception ex) {
            Log__c errorLog1 = new Log__c(Area__c = ONE_HUB, Source__c = SOURCE_CLASS, Type__c = ERROR, Context_User__c = UserInfo.getUserId());
            errorLog1.Message__c += 'Input: ' + serializedInput + '\n';
            errorLog1.Message__c += ex.getMessage() + '\n';
            errorLog1.Stack_trace__c += ex.getStackTraceString();
            statementGenerated = false;
        } finally {
            handleAWSResponse(responseBody, statementGenerated, input, errorLog);
            List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenOutput> res = new List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenOutput>();
            String instanceName = OCH_TOKEN + input.countryName.replace(' ', '_');
            DCS_API_Token__c accessToken = DCS_API_Token__c.getInstance(instanceName);
            if(accessToken == null){
                accessToken = new DCS_API_Token__c();
                accessToken.Access_Token__c = '12345';
                accessToken.Name = instanceName;
            }
            accessToken.Created_Time__c = null;
            upsert accessToken;
            if(doChainJob) {
                System.enqueueJob(new OSB_VA_OCHBotAuthenticationQueueable(input.countryName, input.contactId, input.serviceType));
            }
        }
    }

    private static void handleAWSResponse(AWSStatementResponse responseBody, Boolean isStatementGenerated, OSB_VA_EmailStatement_CTRL.EmailStatementInput input, Log__c errorLog) {
        Messaging.SendEmailResult sendStatementResult;
        Boolean statementGenerated = isStatementGenerated;
        if (responseBody != null) {
            if (responseBody.hasError == true) {
                statementGenerated = false;
            }
        }
        if (statementGenerated == false) {
            handleStatementNotGenerated(input, errorLog, sendStatementResult);
            return;
        }
        try{
            sendStatementResult = sendEmailWithStatement(input.userId, responseBody.data, createFileName(input, 'Indian/Mauritius'), input.accountNumber, input.countryName);
            if (sendStatementResult.isSuccess()) {
                updateCaseOnSuccess(input);
                return;
            }
        } catch(Exception ex){
            handleStatementGenerated(input, errorLog, null);
            return;
        }
    }

    private static void handleStatementGenerated(OSB_VA_EmailStatement_CTRL.EmailStatementInput input, Log__c errorLog, Messaging.SendEmailResult sendStatementResult) {
        List<Messaging.SendEmailError> sendStatementErrors;
        if(sendStatementResult != null){
            sendStatementErrors = sendStatementResult.getErrors();
        }
        Messaging.SendEmailResult sendFaultEmailResult = sendFaultEmail(input.userId, input.accountNumber, input.countryName);
        errorLog = new Log__c();
        if (sendFaultEmailResult.isSuccess()) {
            errorLog.Message__c = 'System.Label.OSB_VA_Statement_Not_Sent';
            if(sendStatementErrors != null){
                for (Messaging.SendEmailError error : sendStatementErrors) {
                    errorLog.Message__c += '-----------------------------\n';
                    errorLog.Message__c += error.getMessage() + '\n';
                }
            }
        } else {
            List<Messaging.SendEmailError> sendFaultErrors = sendFaultEmailResult.getErrors();
            errorLog.Message__c += 'Send statement errors:\n';
            for (Messaging.SendEmailError error : sendStatementErrors) {
                errorLog.Message__c += '-----------------------------\n';
                errorLog.Message__c += error.getMessage() + '\n';
            }
            errorLog.Message__c += 'Send fault email errors:\n';
            for (Messaging.SendEmailError error : sendFaultErrors) {
                errorLog.Message__c += '-----------------------------\n';
                errorLog.Message__c += error.getMessage() + '\n';
            }
        }
        updateCaseOnError(input, errorLog);
        return;
    }

    private static void handleStatementNotGenerated(OSB_VA_EmailStatement_CTRL.EmailStatementInput input, Log__c errorLog, Messaging.SendEmailResult sendStatementResult) {
        sendStatementResult = sendFaultEmail(input.userId, input.accountNumber, input.countryName);
        if (errorLog == null){
            errorLog = new Log__c();
            errorLog.Message__c = '';
        }
        if (sendStatementResult.isSuccess()) {
            errorLog.Message__c += System.Label.OSB_VA_Statement_Not_Generated;
        } else {
            errorLog.Message__c += System.Label.OSB_VA_Statement_Fault_Email_Not_Sent + '\n';
            List<Messaging.SendEmailError> errors = sendStatementResult.getErrors();
            errorLog.Message__c += 'Email send errors:\n';
            for (Messaging.SendEmailError error : errors) {
                errorLog.Message__c += '-----------------------------\n';
                errorLog.Message__c += error.getMessage() + '\n';
            }
        }
        updateCaseOnError(input, errorLog);
        return;
    }

    private static void updateCaseOnSuccess(OSB_VA_EmailStatement_CTRL.EmailStatementInput input) {
        UpdateCaseInput updateCaseInput = new UpdateCaseInput();
        updateCaseInput.actionType = OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_ON_SUCCESS_ACTION;
        updateCaseInput.serviceType = EMAIL_STATEMENT;
        updateCaseInput.caseId = input.caseId;
        updateCaseInput.contactId = input.contactId;
        updateCaseInput.countryName = input.countryName;
        updateCase(updateCaseInput);
    }

    private static void updateCaseOnError(OSB_VA_EmailStatement_CTRL.EmailStatementInput input, Log__c errorLog) {
        UpdateCaseInput updateCaseInput = new UpdateCaseInput();
        updateCaseInput.actionType = OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION;
        updateCaseInput.serviceType = EMAIL_STATEMENT;
        updateCaseInput.caseId = input.caseId;
        updateCaseInput.contactId = input.contactId;
        updateCaseInput.errorLogId = errorLog.Id;
        updateCaseInput.countryName = input.countryName;
        updateCase(updateCaseInput);
    }

    private static String createFileName(OSB_VA_EmailStatement_CTRL.EmailStatementInput input, String timezone) {
        return String.format(FILE_NAME_PATTERN, new List<String>{
                input.accountNumber.substring(0, 4),
                input.accountNumber.substring(input.accountNumber.length() - 3),
                Datetime.now().format(FILENAME_TIMESTAMP, timezone)
        });
    }

    private static AWSCallResult triggerStatementGeneration(OSB_VA_EmailStatement_CTRL.EmailStatementInput input, String token) {
        AWSCallResult awsCallResult = new AWSCallResult();
        Contact contactRecord = retrieveContactRecord(input.contactId);
        String password = createPassword(contactRecord);
        if (password == null) {
            throw new StringException(String.format('Password could not have been generated for the contact record, contact Id: {0}, contact email: {1}, contact identity number: {2}, contact passport number: {3}. To generate password Email and Identity_Number__c or OSB_Passport_Number__c on contact record have to be filled', new List<String>{
                    contactRecord.Id,
                    contactRecord.Email,
                    contactRecord.Identity_Number__c,
                    contactRecord.OSB_Passport_Number__c
            }));
        }
        setDatesForStatement(input);
        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put(PARAMETER_ACCOUNT_NO, input.accountNumber);
        requestBodyMap.put(PARAMETER_FROM_DATE, formatDate(input.statementStart, false));
        requestBodyMap.put(PARAMETER_TO_DATE, formatDate(input.statementEnd, true));
        requestBodyMap.put('password', password);
        requestBodyMap.put('countryName', input.countryName);

        String requestBody = JSON.serialize(requestBodyMap);
        HttpRequest request = OSB_VA_RequestFactory.createAWSStatementRequest(requestBody, token, input.countryName);

        awsCallResult.response = REQUEST_SENDER.send(request);
        
        return awsCallResult;
    }

    /**
     * @description Method for authenticating on AWS and creating token
     *
     * @param inputCountryName String
     * 
     * @return DCS_API_Token__c
     */
    public static DCS_API_Token__c authenticateOnAWSStatementGenerator(String inputCountryName) {
        DCS_API_Token__c token = DCS_API_Token__c.getInstance(AWS_TOKEN);
        Long now = Datetime.now().getTime();
        if (token == null) {
            token = new DCS_API_Token__c();
            token.Name = AWS_TOKEN;
        }
        if (token.Created_Time__c == null || Long.valueOf(token.Created_Time__c) + TEN_MINUTES < now) {
            HttpRequest request = OSB_VA_RequestFactory.createAWSStatementAuthenticationRequest(inputCountryName);
            AWSTokenResponse parsedResponse;
            HttpResponse response;
            response = REQUEST_SENDER.send(request);       
            parsedResponse = (AWSTokenResponse) JSON.deserialize(response.getBody(), AWSTokenResponse.class);
            now = Datetime.now().getTime();
            token.Created_Time__c = String.valueOf(now);
            token.Access_Token__c = parsedResponse.token;
        }
        return token;
    }

    /**
     * @description formatDate method to format and adopt date for json object for HTTP request
     *
     * @param dateInput input variable type of Date
     * @param endOfDay input variable type of Date
     * 
     * @return String 
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    private static String formatDate(Date dateInput, Boolean endOfDay) {
        if (dateInput == Date.today()) {
            Datetime nowDatetime = Datetime.now();
            return String.format('{0}-{1}-{2}T{3}:{4}:{5}.000', new List<String>{
                    String.valueOf(dateInput.year()),
                    zeroPad(String.valueOf(dateInput.month())),
                    zeroPad(String.valueOf(dateInput.day())),
                    zeroPad(String.valueOf(nowDatetime.hourGmt())),
                    zeroPad(String.valueOf(nowDatetime.minuteGmt())),
                    zeroPad(String.valueOf(nowDatetime.secondGmt()))
            });
        }
        String template = endOfDay ? '{0}-{1}-{2}T23:59:59.000' : '{0}-{1}-{2}T00:00:00.000';
        String returnValue = String.format(template, new List<String>{String.valueOf(dateInput.year()), zeroPad(String.valueOf(dateInput.month())), zeroPad(String.valueOf(dateInput.day()))});
        return returnValue;
    }

    private static Messaging.SendEmailResult sendEmailWithStatement(String recipientId, String base64StatementData, String fileName, String accountNumber, String inputCountryName) {
        DCS_country_setting__mdt connectionDetails = getDCSCountrySetting(inputCountryName);
        Messaging.SingleEmailMessage email = createEmailMessage(recipientId, connectionDetails.Statement_Template__c, inputCountryName);
        email.setHtmlBody(email.getHtmlBody().replace(ACCOUNT_NO, hideAccountNumberBeginning(accountNumber)));
        email.setSubject(email.getSubject().replace(ACCOUNT_NO, hideAccountNumberBeginning(accountNumber)));
        email.setFileAttachments(new List<Messaging.EmailFileAttachment>{
                prepareEmailAttachment(fileName, base64StatementData)
        });
        return Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                email
        }).get(0);
    }

    private static String zeroPad(String monthOrDay) {
        if (monthOrDay.length() == 1) {
            return '0' + monthOrDay;
        }
        return monthOrDay;
    }

    private static String hideAccountNumberBeginning(String accountNumber) {
        return String.format('******{0}', new List<String>{
                accountNumber.substring(accountNumber.length() - 3)
        });
    }

    private static String hideAccountNumberMiddle(String accountNumber) {
        return String.format('{0}******{1}', new List<String>{
                accountNumber.substring(0, 4),
                accountNumber.substring(accountNumber.length() - 3)
        });
    }

    private static Messaging.SendEmailResult sendFaultEmail(String recipientId, String accountNumber, String inputCountryName) {
        DCS_country_setting__mdt connectionDetails = getDCSCountrySetting(inputCountryName);
        Messaging.SingleEmailMessage email = createEmailMessage(recipientId, connectionDetails.Statement_Fault_Template__c, inputCountryName);
        email.setHtmlBody(email.getHtmlBody().replace(ACCOUNT_NO, hideAccountNumberMiddle(accountNumber)));
        email.setSubject(email.getSubject().replace(ACCOUNT_NO, hideAccountNumberBeginning(accountNumber)));
        return Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                email
        }).get(0);
    }

    /**
     * @description Method generates password for protecting statement; password is created from combining Contact record's field values
     *
     * @param contactRecord Contact
     *
     * @return String
     */
    private static String createPassword(Contact contactRecord) {
        String emailAddress = contactRecord.Email;
        String id = contactRecord.Identity_Number__c;
        String passportNumber = contactRecord.OSB_Passport_Number__c;
        String password = '';
        if (emailAddress != null && emailAddress.length() >= 6) {
            password += emailAddress.substring(0, 6);
            if (id != null && id.length() >= 6) {
                password += id.substring(id.length() - 6);
                return password.toLowerCase();
            }
            if (passportNumber != null && passportNumber.length() >= 6) {
                password += passportNumber.substring(passportNumber.length() - 6);
                return password.toLowerCase();
            }
        }
        return null;
    }

    private static void setDatesForStatement(OSB_VA_EmailStatement_CTRL.EmailStatementInput input) {
        if (input.timePeriod == System.Label.OSB_VA_Statement_Period_Last7D) {
            input.statementStart = Date.today().addDays(-7);
            input.statementEnd = Date.today();
            return;
        }
        if (input.timePeriod == System.Label.OSB_VA_Statement_Period_Last30D) {
            input.statementStart = Date.today().addDays(-30);
            input.statementEnd = Date.today();
            return;
        }
        return;
    }

    private static Messaging.SingleEmailMessage createEmailMessage(String recipientId, String templateName, String inputCountryName) {
        DCS_country_setting__mdt connectionDetails = getDCSCountrySetting(inputCountryName);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        EmailTemplate templateRecord = UTL_EmailTemplate.getTemplate(templateName);
        String emailBody = templateRecord.HtmlValue.replace(connectionDetails.Email_Banner_Image__c, SRV_Document.newInstance().getImageLink(connectionDetails.Email_Banner_Image__c));
        emailBody = emailBody.replace(connectionDetails.Email_Footer_Image__c, SRV_Document.newInstance().getImageLink(connectionDetails.Email_Footer_Image__c));
        email.setSaveAsActivity(false);
        email.setOrgWideEmailAddressId(UTL_OrgWideEmailAddress.getAddressId(connectionDetails.Statement_Email_Address__c));
        email.setTargetObjectId(recipientId);
        email.setHtmlBody(emailBody);
        email.setSubject(templateRecord.Subject);
        return email;
    }

    private static Contact retrieveContactRecord(String contactId) {
        SEL_Contacts selector = SEL_Contacts.newInstance();
        return selector.selectById(new Set<Id>{
                Id.valueOf(contactId)
        }).get(0);
    }

    private static Messaging.EmailFileAttachment prepareEmailAttachment(String fileName, String base64FileContent) {
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setContentType(PDF_CONTENT_TYPE);
        emailAttachment.setFileName(fileName);
        emailAttachment.setBody(EncodingUtil.base64Decode(base64FileContent));
        return emailAttachment;
    }

    /**
     * @description getDCSCountrySetting method for selecting data from DCS_country_setting__mdt metadata object
     *
     * @param inputCountryName String - countryName input variable
     * 
     * @return DCS_country_setting__mdt object
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    private static DCS_country_setting__mdt getDCSCountrySetting(String inputCountryName) {
        String countryParameter = DCS + inputCountryName.replace(' ', '_');
        DCS_country_setting__mdt connectionDetails = [
                SELECT
                    Id,
                    Statement_Email_Address__c,
                    Statement_Fault_Template__c,
                    Statement_Formal_name__c,
                    Statement_Full_Email_Address__c,
                    Statement_Template__c,
                    Email_Banner_Image__c,
                    Email_Footer_Image__c
                FROM DCS_country_setting__mdt
                WHERE DeveloperName = :countryParameter
        ];
        return connectionDetails;
    }

    /**
     * @description DTO class with input parameters for Create_Case_From_Chat_Bot flow
     *
     * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
     * @date March 2021
     */
    public class UpdateCaseInput {
        public String actionType;
        public String caseId;
        public String contactId;
        public String errorLogId;
        public String serviceType;
        public String countryName;
    }

    /**
     * @description DTO class with for response from AWS statement generator
     *
     * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
     * @date March 2021
     */
    public class AWSStatementResponse {
        public Boolean hasError;
        public String errorMessage;
        public String data;
    }

    /**
     * @description DTO for response from AWS statement generator authentication endpoint
     *
     * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
     * @date April 2021
     */
    public class AWSTokenResponse {
        public String token;
    }

    /**
     * @description Wrapper for response from statement generation endpoint
     *
     * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
     * @date March 2021
     */
    public class AWSCallResult{
        public Log__c log;
        public HttpResponse response;
    }
}