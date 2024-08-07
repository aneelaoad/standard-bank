/**
* @description Get User Information in a Chat Bot
* @author Ankit Kumar
* @date Jan 5th 2023
* @Last Modified By  : Ankit Kumar 
* @Last Modified On  : 27 May 2024
* @Modification Description : SFP-12233
*/
public with sharing class MallChatBot_GetUserInfo {
    /**
     * 
     * @description Chat Output 
     */
    public class PrechatOutput{
        @InvocableVariable
        public String sFirstName;
        @InvocableVariable
        public String sLastName;
        @InvocableVariable
        public String sEmail;
        @InvocableVariable
        public String sPhone;
        @InvocableVariable
        public String sContactID;
        @InvocableVariable
        public String sLoggedUser;
    }

    /**
     * 
     * @description Chat Input
     */
    public class PrechatInput{
        @InvocableVariable
        public String sChatKey;
    }

    /**
     * 
     * @description get User Data through chat key
     * @param inputParameters List of Chat Inputs
     * @return  `List<PrechatOutput>`
     */
    @InvocableMethod(label='Get SnapIns Prechat Data')
    public static List<PrechatOutput> getSnapInsPrechatData(List<PrechatInput> inputParameters)
    {
        List<prechatoutput> outputParameters = new List<prechatoutput>();
        try{
            String sChatKey = inputParameters[0].sChatKey;
            String sContactId = null;
            
            PrechatOutput outputParameter = new PrechatOutput();
            if (sChatKey != null && sChatKey != '') {
                List<LiveChatTranscript> transcripts = SEL_LiveChatTranscripts.newInstance().selectByChatKeys(new Set<String>{sChatKey});
                if (transcripts.size()>0) {
                    sContactId = transcripts[0].ContactId;
                }
            }
            
            if (sContactId != null && sContactId != '') {
                List<Contact> contacts = SEL_Contacts.newInstance().selectById(new Set<Id>{(Id)sContactId});
                if (contacts.size()>0) {
                    outputParameter.sFirstName = contacts.get(0).FirstName;
                    outputParameter.sLastName = contacts.get(0).LastName;
                    outputParameter.sEmail = contacts.get(0).Email;
                    outputParameter.sContactId = contacts.get(0).Id;
                    outputParameter.sPhone = contacts.get(0).Phone;
                }
            }
            outputParameters.add(outputParameter);
            
        }catch(Exception e){
            MallExceptionUtil.LOGGER.error('MallChatBot_GetUserInfo.getSnapInsPrechatData', e);
            throw MallExceptionUtil.throwAuraException('MallChatBot_GetUserInfo.getSnapInsPrechatData', e);
        }
        
        return outputParameters;
    }
}