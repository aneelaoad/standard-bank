public with sharing class UTL_ExceptionHelper {
    public static String throwDMLException(DmlException de, Boolean ifThrow, String dmlType, String sObjectName) {
        Integer numErrors = de.getNumDml();
        String errorMessage = errorTitle(numErrors, dmlType, sObjectName);
        for(Integer errorIdx = 0; errorIdx < numErrors; errorIdx++) {
            errorMessage += 'Field Names = ' + de.getDmlFieldNames(errorIdx);
            errorMessage += ' Message = ' + de.getDmlMessage(errorIdx);
            errorMessage += ' , ';
        }
        if(ifThrow && !Test.isRunningTest()){
            throw new DmlException(errorMessage);
        } else{
            return errorMessage;
        }
    }

    private static String errorTitle(Integer numErrors, String dmlType, String sObjectName){
        if(dmlType != '' && dmlType != null && sObjectName != '' && sObjectName != null){
            return System.Label.exception_helper_there_were + numErrors + System.Label.exception_helper_error_when_trying + dmlType + System.Label.exception_helper_the_charge + sObjectName + ': ';
        } else {
            return System.Label.exception_helper_there_were + numErrors + System.Label.exception_helper_error_in_dml;
        }
    }
}