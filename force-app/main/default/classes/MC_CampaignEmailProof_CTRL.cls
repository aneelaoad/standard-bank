/**
 * Controller for Campaign Emails Proofs sending
 *
 * @author		Michal Pesko (mpesko@deloittece.com)
 * @date		December 2020
 */
public with sharing class MC_CampaignEmailProof_CTRL {

    /**
    * Invocable Method to send email proof
    *
    * @param emailProofDetails - campaignId, campaignType, userEmail, UserId
    */
    @InvocableMethod(Label='Send Email Proof' Category='Campaign')
    public static void sendEmailProof(List<EmailProofDetails> emailProofDetails){
        MC_EmailProofData mcEmailProofData = new MC_EmailProofData(emailProofDetails.get(0).campaignId,
                emailProofDetails.get(0).campaignType,
                emailProofDetails.get(0).userEmail,
                emailProofDetails.get(0).userId);

        MC_EmailProof_Connector.postEmailProof(mcEmailProofData);
    }

    /**
     * Details of inputs for the Invocable method
     *
     * @author		Michal Pesko (mpesko@deloittece.com)
     * @date		December 2020
     */
    public class EmailProofDetails {
        @InvocableVariable(Label='CampaignId' Required=true)
        public Id campaignId;

        @InvocableVariable(Label='CampaignType' Required=true)
        public String campaignType;

        @InvocableVariable(Label='UserId' Required=true)
        public Id userId;

        @InvocableVariable(Label='UserEmail' Required=true)
        public String userEmail;

    }

}