public with sharing class MallChatBot_GetCaseInfo {
    public class CaseInfoOutput {
        @InvocableVariable
        public Case caseRecord;
    }

    public class CaseInfoInput {
        @InvocableVariable
        public String caseNumber;
    }

    @InvocableMethod(label='Get Case Information')
    public static List<CaseInfoOutput> getSnapInsPrechatData(List<CaseInfoInput> inputParameters) {
        List<Case> cases = new List<Case>();
        cases = [Select Id, Subject, Status from Case where CaseNumber =: inputParameters.get(0).caseNumber];
        List<CaseInfoOutput> outputParameters = new List<CaseInfoOutput>();
        if (cases.size() > 0) {
            CaseInfoOutput outputParameter = new CaseInfoOutput();
            outputParameter.caseRecord = cases.get(0);
            outputParameters.add(outputParameter);
        }
        return outputParameters;
    }
}