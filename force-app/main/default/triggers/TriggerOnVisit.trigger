trigger TriggerOnVisit on Visit__c (before insert, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        if (Trigger.oldMap != null) {
            TriggerOnVisitHelper.updateDistanceOnRelatedDatVisit(Trigger.new, Trigger.oldMap);
            TriggerOnVisitHelper.updateAchivedCountOnKPI(Trigger.new, Trigger.oldMap);
        }
    }
}