/*
* Author : Umesh Dadhaniya
* Create date : 2024-07-22 15:55:00
*/
public without sharing class LeadTriggerHandler {
    
    static LeadTriggerHandler handlerInstance;
    public static LeadTriggerHandler getInstance() {
        try {
            if (handlerInstance == null) {
                handlerInstance = new LeadTriggerHandler();
            }
        } 
        catch (Exception e) {
            System.debug('An error occurred while instantiating LeadTriggerHandler: ' + e.getMessage());
        }
        return handlerInstance;
    }
    
    public static void checkingDuplicatePhoneLead(List<Lead> newLeads) {
        system.debug('newLeads === >'+newLeads);
        try {
            Set<String> setPhone = new Set<String>();
            
            for (Lead led : newLeads) {
                if (led.Phone != null) {
                    setPhone.add(led.Phone);
                }
            }
            List<Lead> existingLeads = new List<Lead>();
            if (!setPhone.isEmpty()) {
                existingLeads = [SELECT Id, Phone, CreatedDate FROM Lead WHERE Phone IN :setPhone AND CreatedDate >= LAST_N_DAYS:30];
                system.debug('existingLeads == >'+existingLeads);
            }
            if (!existingLeads.isEmpty()) {
                Set<String> existingPhoneSet = new Set<String>();
                for (Lead led : existingLeads) {
                    existingPhoneSet.add(led.Phone);
                }
                for (Lead led : newLeads) {
                    if (led.Phone != null && existingPhoneSet.contains(led.Phone)) {
                        led.addError('Duplicate phone number found: ' + led.Phone);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
    public static void checkDuplicateLeadForMoreThan30Days(List<Lead> leadList){
        system.debug('leadList === >'+leadList);
        try {
            Set<String> setPhone = new Set<String>();
            
            for (Lead led : leadList) {
                if (led.Phone != null) {
                    setPhone.add(led.Phone);
                }
            }
            
            List<Lead> existingLeads = new List<Lead>();
            if (!setPhone.isEmpty()) {
                existingLeads = [SELECT Id, Phone, CreatedDate,LastModifiedDate,Parent_lead__c FROM Lead WHERE Phone IN :setPhone AND LastModifiedDate <= LAST_N_DAYS:30];
                system.debug('existingLeads == >'+existingLeads);
            }
            
            if (!existingLeads.isEmpty()) {
                Set<String> existingPhoneSet = new Set<String>();
                for (Lead led : existingLeads) {
                    existingPhoneSet.add(led.Phone);
                }
                List<Lead> leadsToBeUpdated = new List<Lead>();
                for (Lead led : leadList) {
                    if (led.Phone != null && existingPhoneSet.contains(led.Phone)) {
                        Task tsk = new Task();
                        tsk.WhoId = existingLeads[0].id;
                        tsk.Status = 'Open';
                        tsk.Subject = 'Test '+led.LeadSource;
                        Insert tsk;
                        
                        Lead ldRec = new Lead();
                        ldRec.Parent_lead__c = existingLeads[0].id;
                        ldRec.Id  = led.Id;
                        leadsToBeUpdated.add(ldRec);
                    }
                }
                update leadsToBeUpdated;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
}