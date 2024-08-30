trigger TriggerOnMBP on Monthly_Beat_Plan__c (before insert,after insert) {
    if(trigger.isInsert && trigger.isBefore){
        BeatPlannerHelper.updateMonthname(trigger.new);
    }
    if(trigger.isInsert && trigger.IsAfter){
        BeatPlannerHelper.docCategories(trigger.new);
         BeatPlannerHelper.CreateDocumentCategories(trigger.new);
    }
}