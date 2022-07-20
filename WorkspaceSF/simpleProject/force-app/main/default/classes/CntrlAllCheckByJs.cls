/**
 * @description javascript로 체크박스 전체 선택/해제 컨트롤러
 */
public with sharing class CntrlAllCheckByJs {

    /**
     * @description 체크 박스를 표시하기 위한 Wrapper 리스트 수정 수정 수정 test
     */
    public List<MemberWrapper> memWrapperList { get; set; }

    /**
     * @description "선택" 링크로 선택된 회원명
     */
    public String selMemberName { get; set; }

    /**
     * @description 체크박스를 표시하기 위한 Wrapper 클래스
     */
    private class MemberWrapper {

        public Boolean isSelected { get; set; }     // 체크 박스에 사용할 Boolean형
        public String memName { get; set; }         // 회원 이름
        // 개체 변수도 사용 가능
        // 예) public Member__c member { get; set; }

        /**
         * @description 생성자
         */
        public MemberWrapper() {

            isSelected = false;
        }
    }

    /**
     * @description 생성자
     */
    public CntrlAllCheckByJs() {
        memWrapperList = new List<MemberWrapper>();
        for (integer i = 0; i < 10; i++) {
            MemberWrapper memWrapper = new MemberWrapper();
            memWrapper.memName = '홍길동' + i;
            memWrapperList.add(memWrapper);
        }
    }

    /**
     * @description 체크 박스로 선택된 회원의 회원명 습득
     */
    public void getSelectedItem() {
        List<String> selMembersNameList = new List<String>();
        for (MemberWrapper memWrap : memWrapperList) {
            if (memWrap.isSelected) {
                // 체크 박스가 선택된 경우
                selMembersNameList.add(memWrap.memName);
            }
        }
        System.debug('선택된 멤버명 ' + selMembersNameList);
    }

    /**
     * @description "선택" 링크로 선택된 회원의 회원명 습득
     */
    public void getMemberNameByLink() {
        // 화면에 메세지 표시
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '선택된 멤버명 : ' + selMemberName));
    }
}