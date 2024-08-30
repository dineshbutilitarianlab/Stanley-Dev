public class ApprovalDetailsHelper {
    
    public static ApprovalUserDetails getActualApprovalDetails(Id recordId) {
        ApprovalUserDetails approvalDetails = new ApprovalUserDetails();

        try {
            // Query for the Process Instance associated with the record
            List<ProcessInstance> processInstances = [SELECT Id, Status 
                                                      FROM ProcessInstance 
                                                      WHERE TargetObjectId = :recordId
                                                      ORDER BY CreatedDate DESC LIMIT 1];

            if (!processInstances.isEmpty()) {
                // Retrieve the latest Process Instance Id
                Id latestProcessInstanceId = processInstances[0].Id;

                // Query for the Process Instance Steps
                List<ProcessInstanceStep> approvalSteps = [SELECT Id, StepStatus, ActorId, Comments, CreatedDate
                                                           FROM ProcessInstanceStep 
                                                           WHERE ProcessInstanceId = :latestProcessInstanceId
                                                           ORDER BY CreatedDate DESC LIMIT 1];

                // Check if any approval steps are found
                if (!approvalSteps.isEmpty()) {
                    ProcessInstanceStep step = approvalSteps[0];

                    // Retrieve user information for the actor
                    User actorUser = [SELECT Id, Name, CreatedDate 
                                      FROM User 
                                      WHERE Id = :step.ActorId LIMIT 1];

                    // Populate approval details
                    approvalDetails.name = actorUser.Name;
                    approvalDetails.stepStatus = step.StepStatus;
                    approvalDetails.comments = step.Comments;
                    approvalDetails.created = actorUser.CreatedDate;
                }
			system.debug('approvalDetails---'+approvalDetails);
                return approvalDetails;
            } else {
                approvalDetails.message = 'No approval process found for the record';
                return approvalDetails;
            }
        } catch (Exception e) {
            // Handle exceptions here
            approvalDetails.message = 'Exception occurred: ' + e.getMessage();
            return approvalDetails;
        }
    }

    public class ApprovalUserDetails {
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public DateTime created;
        @AuraEnabled
        public String comments;
        @AuraEnabled
        public String stepStatus;
    }
}