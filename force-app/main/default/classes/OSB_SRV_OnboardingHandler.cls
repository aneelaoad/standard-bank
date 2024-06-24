/**
 * Is used for omitting sharing for editing Onboarding_Tour_Date__c
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com
 * @date April 2020
 */
public without sharing class OSB_SRV_OnboardingHandler implements IService {

    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    public interface IService {
        void setUserContactOnboardingDate(Set<Id> contactIds, fflib_ISObjectUnitOfWork uow);
    }

    public void setUserContactOnboardingDate(Set<Id> contactIds, fflib_ISObjectUnitOfWork uow) {
        Datetime currentTime = Datetime.now();
        for(Id contactId : contactIds) {
            Contact currentUserContact = new Contact(
                    Id = contactId,
                    Onboarding_Tour_Date__c = currentTime
            );
            uow.registerDirty(currentUserContact);
        }
    }
}