/**
 *
 * @description Queueable class for calling OCHAuthenticate class to reset token
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date June 2022
 * 
 */
public with sharing class OSB_VA_OCHBotAuthenticationQueueable implements Queueable, Database.AllowsCallouts  {
    private String countryName;
    private String contactId;
    private String serviceType;

    public OSB_VA_OCHBotAuthenticationQueueable(String countryName, String contactId, String serviceType) {
        this.contactId = contactId;
        this.serviceType = serviceType;
        this.countryName = countryName;
    }

    public void execute (QueueableContext context) {
        List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput> inputsAuth = new List<OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput>();
        OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput inputAuth = new OSB_VA_OCHAuthenticate_CTRL.OCHTokenInput();
        inputAuth.contactId = contactId;
        inputAuth.countryName = countryName;
        inputAuth.serviceType = serviceType;
        inputsAuth.add(inputAuth);
        OSB_VA_OCHAuthenticate_CTRL.authenticate(inputsAuth);
    }
}