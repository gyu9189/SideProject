trigger Video_SideProject_Trigger on Video__c (before delete
                                             , before insert
                                             , before update
                                             , after delete
                                             , after insert
                                             , after update
                                             , after undelete) {
    

    switch on Trigger.OperationType  {
        when BEFORE_INSERT
        {

        }
        when BEFORE_UPDATE
        {
            videoLentCheck();
        }
        when BEFORE_DELETE
        {

        }
        when AFTER_INSERT
        {

        }
        when AFTER_UPDATE
        {

        }
        when AFTER_DELETE
        {

        }
        when AFTER_UNDELETE
        {
            
        }
    }
    
    // Video__c
    // 번호 : VideoNo__c
    // 비디오이름 : Name
    // 장르 : Video_Genre__c
    // 대여유무 : IsLent__c
    // 대여자 : Customer__c
    // 대여날짜 : LentDate__c

    // Customer__c
    // 번호 : Custiomer_Number__c
    // 회원이름 : Name
    // 전화번호 : Phone_Number__c
    // 대여상태 : IsLental__c
    // 대여비디오 : LentalVideo__c
    // 대여수 : LentalCount__c

    // Update Trigger Start //

    // 2. 비디오 대여시 해당 비디오 대여상태, 대여자 이름 표시 대여중일시 '이미 대여중인 비디오' error 문구 출력
    private static void videoLentCheck(){
        
        for(Video__c v : Trigger.old) {
            if(v.IsLent__c == true) {
                v.addError('이미 대여중인 비디오 입니다.'); // ******09-11******* 왜 해당Error가 출력이 안될까 ? 
                return;
            } // if
        } // for

        Customer__c customer = new Customer__c();
        for(Video__c v : Trigger.new) {
            System.debug(v);
            System.debug(v.Id);
            v.IsLent__c = true;
            v.LentDate__c = Date.Today();

            for(Customer__c c : [SELECT LentalCount__c FROM Customer__c WHERE Id = :v.Customer__c]){

                customer.IsLental__c = true;
                customer.Id = v.Customer__c;
                customer.LentalVideo__c = v.Id;
                if(c.LentalCount__c == null) {
                    customer.LentalCount__c = 1;
                } else {
                    customer.LentalCount__c = c.LentalCount__c++;
                } // else 
            } // inner for
        } // outter for
        update customer;

    } // videoLentCheck()

}
