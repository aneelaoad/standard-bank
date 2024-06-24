/**
  @description It will send emails to user with template 
  @className ACM_SendApprovalRejectionEmailToUser  
  @Author - Purna Unnagiri
  @email 	purna.unnagiri@standardbank.co.za
  @company  Standardbank    
  @date  Feb 9th, 2023
**/
public class ACM_SendEmailToUser {
    
	/**
    * @description - global instance of rf lib logger 
    **/
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ACM_SendEmailToUser');
    
    /**
    * @description - It will send user with template
    * @param inputParamsList  - We need to pass wrapper class which holds emailTemplateId, userId and WhatId
    **/	    
	@InvocableMethod(label='ACM_SendEmailToUser' 
                     description='Accepts emailTemplateId, userId, WhatId and orgWideEmailAddressId')
	public static void sendEmailToUser(List<InputParameters> inputParamsList)
	{
        LOGGER.info('Inside sendEmailToUser method');
		if( !inputParamsList.isEmpty() )
		{
            LOGGER.info('inputParamsList is not empty');
			List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

			for(InputParameters inputParams : inputParamsList)
			{				               
				if(inputParams.emailTemplateId !=null && inputParams.userId !=null && inputParams.whatId !=null ){
					LOGGER.info('emailTemplateId, userId and whatId are not null');
					Messaging.SingleEmailMessage email = 
					Messaging.renderStoredEmailTemplate(inputParams.emailTemplateId, 
					inputParams.userId, inputParams.whatId);
					
					email.setSubject(email.getSubject());
					email.setPlainTextBody(email.getPlainTextBody());				
					email.setSaveAsActivity(false);
					if ( inputParams.orgWideEmailAddressId != null )
					{
                        LOGGER.info('orgWideEmailAddressId not null');
						email.setOrgWideEmailAddressId(inputParams.orgWideEmailAddressId);
					}
					email.setTargetObjectId(inputParams.userId);
					emailList.add(email);
				}
			}		
			if(!emailList.isEmpty())
			{                
                LOGGER.info('emailList is not empty so good to send email');
                try{
                    if( Limits.getEmailInvocations() <= Limits.getLimitEmailInvocations()){                        
						Messaging.sendEmail(emailList);
                    }else{
                        LOGGER.error('You have made ' + Limits.getEmailInvocations() + ' email calls out of ' + Limits.getLimitEmailInvocations() + ' allowed');
                    }
                }catch(Exception ex){                   
                    LOGGER.error('sendEmail field and exception logged : ', ex);
                }
			}
		}
	}
	
    /**
    * @description - It will capture emailTemplateId , userId, whatId and orgWideEmailAddressId from flow
    **/	
    public class InputParameters {
        @InvocableVariable(label='Email Template Id' required=true)
        public Id emailTemplateId;
        @InvocableVariable(label='User Id' required=true)
        public Id userId;
        @InvocableVariable(label='What Id' required=true)
        public Id whatId;
		@InvocableVariable(label='orgWideEmailAddressId' required=false)
		public Id orgWideEmailAddressId;
    }	
}