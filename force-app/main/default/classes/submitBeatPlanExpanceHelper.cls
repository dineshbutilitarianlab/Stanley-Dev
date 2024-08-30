public class submitBeatPlanExpanceHelper {
    @AuraEnabled
    public static void  submitApproval(string recordId){
        system.debug('recordId==>'+recordId);
        try{
            Id approverId = '0052v00000gOuCEAA0';
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Submitting For Approval.');
            approvalRequest.setObjectId(recordId);
            approvalRequest.setSubmitterId('0052v00000gOuCEAA0');
            approvalRequest.setProcessDefinitionNameOrId('Monthly_Travel_Expense_Approval');
            approvalRequest.setSkipEntryCriteria(true);
            approvalRequest.setNextApproverIds(new List<Id>{ approverId }); 
            Approval.ProcessResult result = Approval.process(approvalRequest);
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }  
    }
}