
public without sharing class TaskTriggerHandler extends TriggerHandler {

    private static final String KEY_PREFIX = Contact.sObjectType.getDescribe().getKeyPrefix;

    private Boolean isContactId(Id recordId) {
        return String.valueOf(recordId).startsWith(KEY_PREFIX);
    } // isContactId()

    private Map<Id,Contact> retrieveContacts(Set<Id> contactIds) {
        return new Map<Id, Contact>([select
                                        Id,
                                        No_of_Open_Tasks__c
                                    from
                                        Contact
                                    where
                                        Id in:contactIds]);
    } // retrieveContacts()

    public override void afterInsert(){
        Set<Id> contactIds = new Set<Id>();
        for(Task t : (List<Task>)Trigger.new) {
            if(t.WhoId != null && isContactId(t.WhoId)) {
                contactIds.add(t.WhoId);
            } // if
        } // for

        Map<Id,Contact> contactMap = retrieveContacts(contactIds);
        for(Task t : (List<Task>)Trigger.new) {
            if(contactMap.containsKey(t.WhoId)) {
                contactMap.get(t.WhoId).No_of_Open_Tasks__c += 1;
            } // if
        } // for
        update contactMap.values();
    } // afterInsert()

    public override void afterUpdate() {
        Set<Id> contactIds = new Set<Id>();

        for (Task t : (List<Task>)Trigger.new) {
            Task oldTask = (Task)(Trigger.oldMap.get(t.Id));
            if(t.IsClosed && !oldTask.IsClosed && t.WhoId != null && isContactId(t.WhoId)) {
                contactIds.add(t.WhoId);
            } // if
        } // for

        Map<Id, Contact> contactMap = retrieveContacts(contactIds);

        for(Contact con : contactMap.values()) {
            con.No_of_Open_Tasks__c = 0;
        } // for

        for(AggregateResult ar : [SELECT
                                        WhoId,
                                        COUNT(Id) total
                                    FROM
                                        Task 
                                    WHERE 
                                        IsClosed = false 
                                    AND 
                                        WhoId in :contactIds 
                                    GROUP BY 
                                        WhoId]) {
                                            
            String who = String.valueOf(ar.get('WhoId'));
            Decimal total = (Decimal)(ar.get('total'));
            contactMap.get(who).No_of_Open_Tasks__c = total;
        } // for

        update contactMap.values();
    }// afterUpdate()
} // main class
