/**
 * This class is used for handling failed actions in aura controllers classes.
 * It should be used, whenever performed logic has failed or exception was thrown
 * and UI should be notified about such event.
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
public with sharing class OSB_SRV_ActionFailureHandler implements IService {

    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    public interface IService {
        /**
         * Is used to handle various errors or unexpected results in aura component controllers classes
         * @param e exception
         */
        void handleError(Exception e);
        /**
         * Is used to handle various errors or unexpected results in aura component controllers classes
         * @param e exception
         * @param source - class where error occurred
         */
        void handleError(Exception e, String source);
        /**
         * Is used to handle various errors or unexpected results in aura component controllers classes
         * @param message error message
         */
        void handleError(String message);
    }

    public void handleError(Object e) {
        Exception caughtException = (Exception) e;
    }

    public void handleError(Object e, String source) {
        Exception caughtException = (Exception) e;
        SRV_Logger.newInstance().log(caughtException, DMN_Log.AREA_ONEHUB, source);
        throw caughtException;
    }

    public void handleError(String message) {
    }
}