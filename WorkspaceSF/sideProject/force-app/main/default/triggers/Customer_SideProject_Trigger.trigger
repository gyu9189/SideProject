trigger Customer_SideProject_Trigger on Customer__c (before delete
                                                    , before insert
                                                    , before update
                                                    , after delete
                                                    , after insert
                                                    , after update
                                                    , after undelete) {
    switch on Trigger.OperationType  {
        when BEFORE_INSERT
        {
            phoneOverlapCheck();
        }
        when BEFORE_UPDATE
        {
            // CustomerLentCheck();
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
    } // switch

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

    // 3. 회원에서 비디오 대여시에도 비디오에 대여자, 대여일자, 대여상태 회원에 비디오 이름, 대여상태, 대여비디오 수 Update
    //    & 이미 대여중인 비디오일시 "이미 대여중인 비디오 입니다." 출력
    /* private static void CustomerLentCheck(){
       
       Video__c updateVideo = new Video__c();

        for(Customer__c customer : Trigger.new) {
            for(Video__c video : [SELECT Id, IsLent__c FROM Video__c WHERE Id = :customer.LentalVideo__c]){
                if(video.IsLent__c == true) {
                    customer.addError('이미 대여중인 비디오 입니다.');
                    return;
                } // if

                customer.IsLental__c = true;
                if(customer.LentalCount__c == null) {
                    customer.LentalCount__c = 1;
                } else {
                    customer.LentalCount__c++;
                } // else
                updateVideo.Id = customer.LentalVideo__c;
                updateVideo.IsLent__c = true;
                updateVideo.LentDate__c = Date.Today();
            } // inner for (SELECT IsLent__c)
        } // outter for (Trigger.new)
        System.debug('updateVideo.Id ::: ');
        System.debug(updateVideo.Id);

        update updateVideo;

    } // CustomerLentCheck() */

    private static void phoneOverlapCheck(){
        for(Customer__c customer : Trigger.new) {
            List<Customer__c> c = [SELECT Phone_Number__c FROM Customer__c WHERE Phone_Number__c = :customer.Phone_Number__c];
            if(c.size() > 0) {
                customer.addError('중복되는 휴대폰 번호 입니다.');
            } // if
        } // for
    } // phoneOverlapCheck()

} 