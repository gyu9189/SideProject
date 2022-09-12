public with sharing class MemberController {
    
    @AuraEnabled(cacheable=true)
    public static List<Customer__c> getCustomerList(){
        return [SELECT
                    Customer_Number__c,
                    Name,
                    Phone_Number__c,
                    IsLental__c,
                    LentalVideo__r.Name,
                    LentalCount__c
                FROM 
                    Customer__c
                ORDER BY Customer_Number__c ASC];
    } // getCustomerList()

    @AuraEnabled
    public static List<Customer__c> delCustomerRecords(List<String> cList) {
        System.debug('cList!!!');
        System.debug(cList);
        List<Customer__c> delCustomers = new List<Customer__C>();
        for(Customer__c c : [SELECT Id FROM Customer__C where Id in :(cList)]){
            delCustomers.add(c);
        } // for
        System.debug('delCustomers!!! ::: ');
        System.debug(delCustomers);

        if(delCustomers.size() > 0) {
            try {
                delete delCustomers;
            } catch (Exception e) {
                throw new AuraHandledException('unable to delete'+e.getMessage());
            } // try / catch
        }else {
            return null;
        }
        return delCustomers;
    } //delVideoRecords();
}
