/**
 * Provides backend services for the ProceedForOnboardingButton component
 *
 * @Author JP Basson
 * @Date Jul 3, 2020
 */
public with sharing class ProceedButtonController {

    /** this is the account( client ) object we are processing
     */
    private static Account m_client = null;

    /** this is account object wrapper
     */
    private static WRP_Account m_account_wrapper;

    /** this will indicate if we have a commB client
     */
    private static Boolean m_is_commb_client;

    /** this will indicate if we have a CIB client
     */
    private static Boolean m_is_cib_client;

    /** this will indicate if we have SA relationship role
     */
    private static Boolean m_is_sa_relationship;

    /** this will get our request code
     */
    private static String m_gt_request_code = 'SA';

    /** this will hold the KYC location
     */
    private static String m_kyc_location;

    /** this will indicate if we should render CIB SA
     */
    private static Boolean m_should_render_cib_sa = false;

    /** this will indicate if we should render CIB ROA
     */
    private static Boolean m_should_render_cib_roa = false;

    /** this function will submit record for onbaording
     * @param recordP is the record we are submitting for onboarding
     * @return ServerResponse object will be returned
     */
    @AuraEnabled
    public static ServerResponse submitForOnboarding( Account recordP ){

        ServerResponse gt_response;            //this is the server response
        ServerResponse email_response;          //this is the server response following email sending
        ServerResponse response;                //this the response that will be sent back to client

        m_client = recordP;                 //set our client record
        m_account_wrapper = new WRP_Account( m_client );        //create our account wrapper
        m_is_commb_client = m_account_wrapper.isCommB();        //check if we have commB client
        m_is_cib_client = m_account_wrapper.isCIB();            //check if we have CIB client
        m_kyc_location = m_client.KYC_Location__c;              //set the KYC location
        m_is_sa_relationship = m_account_wrapper.isSARelationshipRoles();                   //check if we have a relationship role
        m_gt_request_code = m_account_wrapper.getGTRequestCode();                   //get the gt request code

        //check if we should render CIB SA
        if( m_gt_request_code != null  &&  m_is_sa_relationship )
            m_should_render_cib_sa = true;
        else
            m_should_render_cib_roa = true;

        gt_response = sendToGT();              //send the record to Goldtier

        //check if we have an error
        if( gt_response.is_error )
            return gt_response;                //return the response

        email_response = sendEmail();         //send email

        //check if we have an error message
        if( email_response.is_error )
            return email_response;              //return the error response

        //check if we have a goldtier submit message
        if( gt_response.result_message != '' )
            response = gt_response;                     //we will return a gt response
        else
            response = email_response;                  //we will return email response

        return response;                    //send the server response

    }//end of function definition






    /** this functon will check if the current user requires that approval
     * @param cc_user_idP is the cc user id
     * @return will return true if the user requires approval
     */
    @AuraEnabled
    public static ServerResponse shouldBeApproved( Id cc_user_idP ){

        List< Profile > user_profiles_list;                 //this will hold list of user profiles
        String cc_user_division;                            //this will hold the user division

        ServerResponse response = new ServerResponse();      //this will hold the operation result

        try{

            //retrieve the current user's profile
            user_profiles_list = [ SELECT Name
                                   FROM Profile
                                   WHERE Id =: userinfo.getProfileId()
                                   LIMIT 1 ];

            //get the cc user's division
            cc_user_division = [ SELECT User_Division__c
                                 FROM User
                                 WHERE Id =: cc_user_idP
                                 LIMIT 1 ].User_Division__c;

        }
        catch( QueryException query_exception ){

            System.debug( 'In function ProceeedButtonController.shouldBeApproved --- ' + query_exception.getMessage() );    //print message
            response.result_message = query_exception.getMessage();                                    //set the error message
            response.is_error = true;                              //indicate we have an error

            return response;                               //return the onboarding result

        }//end of try-catch block

        //check if cc is a commB user
        if( cc_user_division == 'Commercial Banking' ){

            response.result_message = 'INVAL';          //set to invalid
            return response;                //return the response

        }

        //determine if user needs approval ---> CHANGE WHEN CIB LAYOUT COMPLETE!!!!!!!
      /*  is_cib_user = !( ( user_profiles_list[0].Name == 'Commercial Banking Communities User' ) ||
                         ( user_profiles_list[0].Name == 'Commercial Banking Custom Std User' ) ||
                         ( user_profiles_list[0].Name == 'Commercial Banking Custom Std User - Mobile' ) );
        is_not_cc = ( cc_user_idP != null ) && ( cc_user_idP != UserInfo.getUserId() );			//this will indicate that user is not cc
        response.result_message = String.valueOf( is_cib_user && is_not_cc );					//set the result message*/

        return response;                       //return the OB result

    }//end of function definition






    /** this function will send record for approval( DISABLED UNTIL CIB IS CONFIRMED
     *  @param record_idP is the ID of the record we are sending for approval
     *  @param cc_user_idP is the ID of the cc user
     *  @return Response object will be returned
     */
 /*   @AuraEnabled
    public static ServerResponse sendForApproval( Id record_idP, Id cc_user_idP ){

        Approval.ProcessSubmitRequest approval_request = new Approval.ProcessSubmitRequest();      //create our approval object
        Approval.ProcessResult approval_result;                     //this will hold our approval result
        ServerResponse response = shouldBeApproved( cc_user_idP );              //this is our result object

        //check if we dont have a true or false value
        if( !( ( response.result_message == 'true' ) || ( response.result_message == 'false' ) ) && response.is_error )
            return response;
        //check if have an error or approval is not required
        else if( response.is_error || !Boolean.valueOf( response.result_message ) ){

            response.result_message = 'NA';
        	return response;

        }//end of if-block

        //setup the approval request object
        approval_request.setObjectId( record_idP );                             //set object we are sending for apporval
        approval_request.setSubmitterId( userinfo.getUserId() );                //submit on behalf of the user ID
        approval_request.setProcessDefinitionNameOrId( 'Onboarding_Client_Hierarchy_Approval' );            //approval process we want to invoke

        try{
            approval_result = Approval.process(approval_request);                  //execute approval request
        }
        catch( DmlException dml_exception ){

            System.debug( dml_exception.getMessage() );                     //print our error message

            response.is_error = true;                                      //indicate we have an error
            response.result_message = dml_exception.getMessage();          //set the result message

            return response;                                               //return the Onboarding result

        }//end of try-catch

        return response;                    //return result

    }//end of function definition*/


    

    /** this function will change record type
    * @param account_idP this is the ID of the account
    * @param record_type_nameP this is the name of the record type
    * @return ServerResponse object will be returned
    */
    @AuraEnabled
    public static ServerResponse changeRecordType( String account_idP, String record_type_nameP ){

        ServerResponse response = new ServerResponse();                 //our response object
        response.result_message = LTN_RecordData.changeAccountRecordType( account_idP, record_type_nameP );

        //check if we dont have OK message
        if( response.result_message != 'OK' )
            response.is_error = true;                       //indicate we have an error

        return response;                        //return the response

    }//end of function definition





    /** this function will check if we have a record that is meant for goldtier
     *  @param accountP is the account we are setting
     * 	@return ServerResponse object will be returned
     */
    @AuraEnabled
    public static ServerResponse isGoldtierRecord( Account recordP ){

        ServerResponse response = new ServerResponse();				//this is our response object

        m_client = recordP;                    //set our client account
        m_account_wrapper = new WRP_Account( m_client );                //set the account object

        //check if we have CIB
        if( m_account_wrapper.isSARelationshipRoles() )
            response.result_message = String.valueOf( true );					//we have a GT record here
        else
            response.result_message = String.valueOf( false );					//this is CIF record 

        return response;

    }//end of function definition


    
    
    
    /** this function will check if user is CIB user
     * @return will return true on success
     */
    @AuraEnabled
    public static ServerResponse isUserCIB(){

        List< Profile > user_profiles_list;                 //this will hold list of user profiles
        Boolean is_cib_user;								//this will indicate if we have CIB user

        ServerResponse response = new ServerResponse();      //this will hold the operation result

        try{

            //retrieve the current user's profile
            user_profiles_list = [ SELECT Name
                                   FROM Profile
                                   WHERE Id =: userinfo.getProfileId()
                                   LIMIT 1 ];

        }
        catch( QueryException query_exception ){

            System.debug( 'In function ProceeedButtonController.isUserCIB --- ' + query_exception.getMessage() );    //print message
            response.result_message = query_exception.getMessage();                                    //set the error message
            response.is_error = true;                              //indicate we have an error

            return response;                               //return the onboarding result

        }//end of try-catch block

        is_cib_user = !( ( user_profiles_list[0].Name == 'Commercial Banking Communities User' ) ||
                         ( user_profiles_list[0].Name == 'Commercial Banking Custom Std User' ) ||
                         ( user_profiles_list[0].Name == 'Commercial Banking Custom Std User - Mobile' ) );

        response.result_message = String.valueOf( is_cib_user );					//set the result message

        return response;                       //return the OB result

    }//end of function definition





    /** this function will create a client team record
     * @param recordP is the record we want to create a client team for
     * @return will return server response object
     */
    @AuraEnabled
    public static ServerResponse createClientTeam( Account recordP ){

        ServerResponse response = new ServerResponse();                 //response object

        //check if we have a different Client COordinator
        if( recordP.Client_Co_ordinator__c != UserInfo.getUserId() )
            return response;                        //no need to create client team

        response = checkClientTeam( recordP );                      //check if the client exists

        //check if we have an error
        if( response.is_error )
            return response;                    //return the response object

        //check if we have non zero return value
        if( Integer.valueOf( response.result_message ) != 0 )
            return response;

        List<Account> accRecList = SEL_Accounts.newInstance().selectById(new Set<Id>{recordP.Id});
        //create a new client team object
        Custom_Client_Team__c new_client_team = DMN_ClientTeam.buildCctRecord( accRecList[0], recordP.Client_Co_ordinator__c, recordP.RecordTypeId,
                                                                               recordP.Client_Coordinator_Division__c );
        new_client_team.Client_Role__c = 'BCC Relationship Manager';

        try{
            insert new_client_team;                 //insert the new client team
        }
        catch( DmlException dml_exception ){

            System.debug( 'In function ProceedButtonController.createClientTeam: ' + dml_exception.getMessage() );

            //setup our error response
            response.is_error = true;
            response.result_message = dml_exception.getMessage();

        }//end of try-catch

        return response;

    }//end of function definition





    /** this will check if CC already exists in the client team
     *  @param recordP is the account record that we are checking
     * @return will return true if the user already exists, false otherwise
     */
    private static ServerResponse checkClientTeam( Account accountP ){

        Integer record_count;                                       //this will hold the record count
        ServerResponse response = new ServerResponse();             //this is our server response object

        try{

            //count client team records
            record_count = [ SELECT Count()
                             FROM Custom_Client_Team__c
                             WHERE ( Account__c =: accountP.Id ) AND ( Team_Member__c =: accountP.Client_Co_ordinator__c ) ];

        }
        catch( QueryException query_exception ){

            System.debug( 'In function ServerResponse.checkClientTeam --- ' + query_exception.getMessage() );               //print message to console

            response.is_error = true;                    //indicate we have an error
            response.result_message = query_exception.getMessage();

            return response;                    //return the response object

        }//end of try-catch block

        response.result_message = String.valueOf( record_count );               //set the count value

        return response;                        //return the response to the caller

    }//end of function definition





    /** this function will generate and send xml to Goldtier
     * @return ServerResponse object will be sent
     */
    private static ServerResponse sendToGT(){

        ServerResponse response = new ServerResponse();              //this will hold our result
        OnboardingService ob_service;                               //this is onbaording service

        //check if we have commb or CIB and
        if( ( m_is_cib_client || m_is_commb_client ) && m_should_render_cib_sa && ( m_gt_request_code != null ) ){

            ob_service = new OnboardingService( m_client.Id, m_gt_request_code );             //this is the onboarding service

            try {
                ob_service.sendClientsData();                   //attempt to send the client data
            } catch (OnboardingService.OnboardingServiceException ex) {

                System.debug('Onboarding Exception: ' + ex.getMessage());              //print error message
                response.result_message = ex.getMessage();                              //set the result mesage
                response.is_error = true;                                               //indicate that we have an error

                return response;

            }//end of try-catch statement

            response.result_message = 'Record Submitted to Goldtier';               //we have submitted record

        }//end of if-block

        return response;                           //return onboarding result

    }//end of function definition





    /** this function will send email to CDG
     * @return ServerResponse will be returned
     */
    private static ServerResponse sendEmail(){

        ServerResponse response;                    //this is server response
        String email_body;                          //this will hold email body
        Messaging.SingleEmailMessage production_support_email;          //this will hold the support email
        Messaging.SingleEmailMessage onboarding_email;                  //this will hold the onbaording email
        Messaging.SingleEmailMessage[] emails_to_send_list;               //this will hold emails we will send

        Messaging.EmailFileAttachment[] prod_email_attachments_list = new Messaging.EmailFileAttachment[]{};       //production support attachment
        Messaging.EmailFileAttachment[] onboarding_email_attachments_list = new Messaging.EmailFileAttachment[]{};      //onbaording email attachments
        Messaging.EmailFileAttachment pdf_attachment = getOnboardingPdfAttachment();                //get the onboarding PDF attachment

        Messaging.EmailFileAttachment xml_attachment = getOnboardingXmlAttachment( new OnboardingService( m_client.Id,
                                                                                                          m_account_wrapper.getGTRequestCode() ) ); //get XML content
        response = getOnboardingEmailBody();               //this is the body of the email

        //check if we have an error
        if( response.is_error )
            return response;                        //exit function will error

        email_body = response.result_message;                   //set the email body

        //check if we have xml attachment
        if( xml_attachment != null )
            prod_email_attachments_list.add( xml_attachment );          //add to support email
        //check if we have onboarding attachment
        if( pdf_attachment != null ) {

            onboarding_email_attachments_list.add(pdf_attachment);        //add onboarding xml to email
            prod_email_attachments_list.add(pdf_attachment);              //add the pdf to support email

        }//end of if-block

        production_support_email = getProductionSupportEmail( email_body, prod_email_attachments_list );        //set our production email
        onboarding_email = getOnboardingEmail( email_body, onboarding_email_attachments_list );                 //set the onboarding email
        emails_to_send_list = new Messaging.SingleEmailMessage[]{ production_support_email, onboarding_email  };            //prepare emails to send

        //check if KYC team should be notified
        if( ( m_client.KYC_Location__c ==  'SBSA - Standard Bank of South Africa Ltd' ) && m_account_wrapper.isCIB() &&
            m_account_wrapper.isSARelationshipRoles() )
            emails_to_send_list.add( getOnboardingNotificationToKYCTeamEmail( onboarding_email_attachments_list ) );    //add to email list

        Messaging.SendEmailResult[] results = Messaging.sendEmail( emails_to_send_list );               //send the email

        response.result_message = 'Record Submitted to CDG';                //email sent to CDG

        return response;

    }//end of function definition





    /** this function will get onbaording email to be sent to CDG
     * @param email_bodyP is the body of the email we are sending
     * @param attachements_listP is list of attachments we are gonna attach to the email
     * @return Messaging.SingleEmailMessage object will be returned
     */
    private static Messaging.SingleEmailMessage getOnboardingEmail( String email_bodyP, Messaging.EmailFileAttachment[] attachments_listP ){

        List< String > to_addresses_list = new List< String >();                //to addresses
        List< String > cc_addresses_list = new List< String >();                //cc addresses

        //check if we have a commB client
        if( m_is_commb_client )
            to_addresses_list.add( SB_Parameters__c.getValues( 'CommB_Inbox' ).Value__c );          //add commB inbox
        //check if we have none CIBSA
        else if( !( m_should_render_cib_sa && ( m_gt_request_code != null ) ) )
            to_addresses_list.add( Label.To_Address_Onboarding_form );

        cc_addresses_list.add( UserInfo.getUserEmail() );               //add user to cc address

        return getEmail( to_addresses_list, cc_addresses_list, new List< String >(), email_bodyP, attachments_listP );      //return email


    }//end of function definition





    /**this function will prepare email to be sent to production
     * @param email_bodyP is the email body we are sending
     * @param attachments_listP is list of attachments
     * @return Messaging.SingleEmailMessage object will be returned
     */
    private static Messaging.SingleEmailMessage getProductionSupportEmail( String email_bodyP, Messaging.EmailFileAttachment[] attachment_listP ){

        List< String > to_addresses = new List< String >();             //list of address we will send to
        to_addresses.add( Label.CIB_CRM_Production_Support_email_for_Onboarding );          //add production email

        return getEmail( to_addresses, new List< String >(), new List< String >(), email_bodyP, attachment_listP );

    }//end of function definition





    /** this function will get the on boarding email body
     *  @param none
     *  @return email body string will be returned
     */
    private static ServerResponse getOnboardingEmailBody(){

        String email_body;                                                                      //this is our email body
        Account client_record;                                                                  //this is the client record
        List< EmailTemplate > email_template_list = new List< EmailTemplate >();                     //this will hold the template
        ServerResponse response = new ServerResponse();

        try{

            //get our email template
            email_template_list = [ SELECT Id, Name, body
                                    FROM EmailTemplate
                                    WHERE Name = 'Onboarding: Submit for Onboarding Template' ];

            client_record = [ SELECT Client_Co_ordinator__r.Name, Client_Co_ordinator__r.Email, Client_Coordinator_Division__c
                              FROM Account
                              WHERE Id =: m_client.Id ];

        }
        catch( Exception  ex ){

            System.debug( 'In Function ProceedButtonController.getOnboardingEmailBody --- ' + ex.getMessage() );

            //setup our response object
            response.is_error = true;
            response.result_message = ex.getMessage();

            return response;                    //return the response

        }//end of try-catch block

        //setup the email body
        email_body = email_template_list[0].body;       //get the template body
        email_body = email_body.replace( '{!$User.FirstName}', UserInfo.getFirstName() );
        email_body = email_body.replace( '{!$User.LastName}', UserInfo.getLastName() );
        email_body = email_body.replace( '{!$User.Email}', UserInfo.getUserEmail() );
        email_body = email_body.replace( '{!Account.Name}', m_client.Name );
        email_body = email_body.replace( '{!Account.Client_Co_ordinator__c}', client_record.Client_Co_ordinator__r.Name );
        email_body = email_body.replace( '{!Account.Client_Coordinator_Division__c}', client_record.Client_Coordinator_Division__c );
        email_body = email_body.replace( '{!Account.Client_Coordinator_Email__c}', client_record.Client_Co_ordinator__r.Email );

        response.result_message = email_body;               //set the email body

        return response;        //return response

    }//end of function definition





    /** this function will get the create an email object
     *  @param to_addresses_listP is list of email addresses we are sending email to
     *  @param cc_addresses_listP is list of CC email addresses we are sending email to
     *  @param bcc_addresses_listP is list of BCC email addresses we are sending to
     *  @param email_bodyP is body of email
     *  @param attachments_listP is list of attachments we are attaching to email
     *  @return SingleEmailMessage object will be returned
     */
    private static Messaging.SingleEmailMessage getEmail( List< String >to_addresses_listP, List< String >cc_addresses_listP,
                                                        List< String >bcc_addresses_listP, String email_bodyP,
                                                        Messaging.EmailFileAttachment[] attachments_listP ){

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                //create email object
        email.setSubject( Label.Subject_Onboarding_form + ' ' + m_client.Name );                //set email subject
        email.setToAddresses( to_addresses_listP );                                             //set our to addresses
        email.setCcAddresses( cc_addresses_listP );                                             //set our cc addresses
        email.setBccAddresses( bcc_addresses_listP );                                           //set our BCC addresses
        email.setPlainTextBody( email_bodyP );                                                  //set the email body

        //check if we have valid attachments
        if( ( attachments_listP != null ) && !attachments_listP.isEmpty() )
            email.setFileAttachments( attachments_listP );                  //set the attachments

        return email;                   //return the email

    }//end of function definition





    /**this function will generate XML attachment for onbaording email
     * @param onboarding_serviceP is the onboarding service object which we will generate XML
     * @return Messaging.EmailFileAttachment object will be returned
     */
    private static Messaging.EmailFileAttachment getOnboardingXmlAttachment( OnboardingService onboarding_serviceP ){

        Messaging.EmailFileAttachment file_attachment = null;                   //file attachement

        //check if we have valid parameter
        if( ( onboarding_serviceP != null ) && ( onboarding_serviceP.getRequestBody() != null ) ) {

            file_attachment = new Messaging.EmailFileAttachment();                //create the email file attachment
            file_attachment.setFileName(Label.Onboarding_XML_Attachment_name);                                //create the xml attachment
            file_attachment.setBody(Blob.valueOf(onboarding_serviceP.getRequestBody()));                    //set the xml document body

        }

        return file_attachment;                 //return the file attachment

    }//end of function definition





    /** this function will create PDF attachment
     * @return Messaging.EmailFileAttachment will be returned
     */
    private static Messaging.EmailFileAttachment getOnboardingPdfAttachment(){

        Messaging.EmailFileAttachment file_attachment = new Messaging.EmailFileAttachment();              //this is our file attachment
        file_attachment.setFileName( Label.Onboarding_Attachment_name );                                //set the file name
        file_attachment.setBody( getOnboardingPdfContent() );                                             //set the PDF body

        return file_attachment;                         //return the file attachment

    }//end of function definition





    /** this function will prepare email for KYC team notification
     * @return Messaging.SingleMessage object will be returned
     */
    private static Messaging.SingleEmailMessage getOnboardingNotificationToKYCTeamEmail( Messaging.EmailFileAttachment[] attachment_listP ){

        Messaging.SingleEmailMessage email = UTL_Email.createEmails( UTL_EmailTemplate.getTemplateId( 'Onboarding_notification_to_KYC_Team' ),
                                                                     m_client.Id, new Set< String >{ SB_Parameters__c.getValues( 'KYC Team Email' ).Value__c },
                                                                     UTL_User.getCachedUser( UserInfo.getUserId() ).Contact_Sync_ID__c );
        email.setCcAddresses( new String[]{ UserInfo.getUserEmail() } );
        email.saveAsActivity = false;

        //check that list is not NULL and attachment list is not empty
        if( ( attachment_listP != null ) && !attachment_listP.isEmpty() )
            email.setFileAttachments( attachment_listP );               //add attachments

        return email;                   //return email

    }//end of function definition





    /** this function will get the onboarding PDF content
     *  @param none
     *  @return Blob will be returned
     */
    private static Blob getOnboardingPdfContent(){

        PageReference pdf = Page.Send_for_Onboarding_pdf;           //get the onbaording pdf
        Blob pdf_body;

        //setup up pdf data
        pdf.getParameters().put( 'id', ( String )m_client.Id );
        //pdf.getParameters().put( 'isicdesc', m_client.ISIC_Code_Description__c );
        pdf.setRedirect( true );

        if(Test.isRunningTest())
            pdf_body = blob.valueOf('Unit.Test');
        else
            pdf_body = pdf.getContentAsPDF();

        return  pdf_body;                 //get the pdf

    }//end of function definition





    /** this class will contain results of operations---> to be sent to
     *  client-side controller
     */
    public class ServerResponse{

        /** this will indicate if we have an error
         */
        @AuraEnabled public Boolean is_error{ get; set; }

        /** this will hold message from server side operations when needed( eg: reporting error to user )
         */
        @AuraEnabled public String result_message{ get; set; }

        /** this is class constructor
         */
        public ServerResponse(){

            //default the class attribute
            this.is_error = false;
            this.result_message = '';

        }//end of constructor definition

    }//end of class definition


}//end of class definition