/**
 * Service class handling Case creation for OneHub
 * <br/>
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 *
 **/
public with sharing class OSB_SRV_NewCase implements IService {

    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    public interface IService {
        void saveCaseInGuestContext(Case newCase, String identityNumber, String passportNumber, fflib_ISObjectUnitOfWork uow);
        void saveCasesInUserContext(List<Case> newCases, fflib_ISObjectUnitOfWork uow);
        void saveCases(List<Case> newCases, fflib_ISObjectUnitOfWork uow);
    }

    /**
     * Searches for contact related to current user by ContactId and assigns it to case
     * Then it calls saveCase(Case) to insert the case
     *
     * @param newCases with filled fields
     * @param uow - unit of work used to register new cases
     */
    public void saveCasesInUserContext(List<Case> newCases, fflib_ISObjectUnitOfWork uow) {
        Contact contact = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{UserInfo.getUserId()})[0];
        Id userCaseRT = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_USER_CASE);
        Id bankContactRT = UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK);
        for(Case newCase : newCases) {
            newCase.ContactId = contact.Id;
            newCase.SuppliedEmail = contact.Email;
            if (contact.RecordTypeId == bankContactRT) {
                newCase.RecordTypeId = userCaseRT;
            }
        }
        saveCases(newCases, uow);
    }

    /**
     * Searches for existing contact by identity or passport number and assigns it to case.
     * Then it calls saveCase(Case) to insert the case
     *
     * @param newCase with filled fields
     * @param identityNumber - identity number to search contact
     * @param passportNumber - passport number to search contact
     * @param uow - unit of work used to register new cases
     */
    public void saveCaseInGuestContext(Case newCase, String identityNumber, String passportNumber, fflib_ISObjectUnitOfWork uow) {
        List <Contact> contacts = SEL_Contacts.newInstance().selectByEmailIdentityPassport(
                new Set<String>{newCase.SuppliedName},
                new Set<String>{identityNumber},
                new Set<String>{passportNumber}
        );
        if (!contacts.isEmpty()) {
            newCase.ContactId = contacts[0].Id;
            if (contacts[0].RecordTypeId == UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK)) {
                newCase.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_USER_CASE);
            }
        }
        saveCases(new List<Case>{newCase}, uow);
    }

    /**
     * Assigns priority, OneHub queue and client case RT, if there is none assigned. Then inserts the case.
     *
     * @param newCases with filled fields
     * @param uow - unit of work used to register new cases
     */
    public void saveCases(List<Case> newCases, fflib_ISObjectUnitOfWork uow) {
        Id queueId = UTL_Queue.getQueueId(DMN_Group.GROUP_DEVELOPER_NAME_ONE_HUB);
        Id clientCaseRT = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CIB_CLIENT_CASE);
        for(Case newCase : newCases) {
            newCase.Priority = DMN_Case.PRIORITY_LOW;
            newCase.OwnerId = QueueId;
            if(newCase.RecordTypeId == null) {
                newCase.RecordTypeId = clientCaseRT;
            }
            uow.registerNew(newCase);
        }
        uow.commitWork();
    }
}