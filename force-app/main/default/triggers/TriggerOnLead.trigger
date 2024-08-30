/*
* Author : Umesh Dadhaniya
* Create date : 2024-07-22 15:55:00
*/
trigger TriggerOnLead on Lead (before insert,after insert, after update,before update) {
    
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Lead');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        LeadTriggerHandler handlerInstance = LeadTriggerHandler.getInstance();
        
        
        if (Trigger.isBefore && Trigger.isInsert ) {
            LeadTriggerHandler.checkingDuplicatePhoneLead(Trigger.new);
        }
        if (Trigger.isAfter && Trigger.isInsert) {
           LeadTriggerHandler.checkDuplicateLeadForMoreThan30Days(Trigger.new);
        }
        
    }
    
}