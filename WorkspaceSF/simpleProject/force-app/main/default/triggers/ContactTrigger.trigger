// trigger 의 표준 형식은 아래와 같다
// trigger TriggerName on sObject (list of applicable contexts) {
//   }

trigger ContactTrigger on Contact (before insert) { // befor insert 는 database 에 insert 하기전 유효성 검사를 하기위해 보통 사용된다.
    for(Contact con : Trigger.new) {
        if (con.Phone == null && con.MobilePhone == null) {
            con.addError('전화번호 혹은 휴대전화 번호를 입력해주세요.');
        } // if
    } // Contact for
} // main












