/**
 * @description csv 출력 컨트롤러
 */
public with sharing class CntrlCsvDownload {

    // 개행 코드
    final String CSV_LINEFEED = '\r\n';

    /**
     * @description csv 출력 관련 변수
     */
    public String csvFileName { get ; set; }    // csv파일명
    public String csvHeader { get; set; }       // csv헤더
    public List<String> csvBodyList { get; set; }  // csv본문

    /**
     * @description 생성자
     */
    public CntrlCsvDownload() {

        csvBodyList = new List<String>();
    }

    /**
     * @description 게임 정보 추가(insert)
     */
    public void createMemberForTest() {

        // Insert Test Member Size
        Integer size = 111; // 테스트할때 변경해서 해보자... 커밋되지 않고 Insert하므로 많이하면 Too Many DML... 에러가 발생한다 나의 경우는 148까지만 가능...
        
        // String.format의 출력부분은 JAVA와 다르다. 인수의 Index를 중괄호({})로 지정해줘야 한다.
        System.debug(String.format('=================== INSERT Member SIZE[{0}]_START ==================', new Integer[]{size}));
        for (Integer i=1; i<=size; ++i) { // 일련번호가 있으므로 1부터 카운트하게 한다.
            Member__c newMember = new Member__c();
            newMember.MemberNo__c = formatFill(String.valueOf(i), 10, '0');
            newMember.Name = String.format('홍길동_{0}번', new String[]{formatFill(String.valueOf(i), 3, '0')});
            newMember.RegistDate__c = Date.newInstance(2020, 11, i);
            newMember.Phone__c = String.format('010-2217-{0}', new String[]{formatFill(String.valueOf(i), 4, '0')});
            newMember.Email__c = String.format('TestMember.{0}@dkbmc.com', new String[]{formatFill(String.valueOf(i), 2, '0')});
            // 회원정보 등록(INSERT)
            insert newMember;
            System.debug('===================== INSERT Member : ' + newMember);
        }
        System.debug('===================== INSERT Member_END ==================');
    }

    /**
     * @description csv 출력
     */
    public PageReference exportToCsv() {

        // 파일명 : Member[년월일].csv
        csvFileName = 'Member' + Datetime.now().format('yyyyMMdd') + '.csv';

        // csv헤더 설정
        csvHeader = 'Id,회원번호,회원명,회원등록일,전화번호,이메일주소' + CSV_LINEFEED;

        // 데이터베이스(개체)를 롤백할 지점 설정 Debuger for 
        Savepoint sp = Database.setSavepoint();
        // 테스트를 위한 임시Member 등록.
        createMemberForTest();

        // 회원 레코드 습득
        List<Member__c> memberList = [SELECT Id, Name, MemberNo__c, RegistDate__c, Phone__c, Email__c FROM Member__c ORDER BY MemberNo__c];

        // 데이터베이스 롤백 : 데이터 조작 테스트 후 모두 롤백합니다. 테스트는 테스트이닌깐...
        Database.rollback(sp);

        for (Member__c member : memberList) {

            // csv 본문 생성
            String body = member.id 
                            + ',' + convertNullToBlank(member.MemberNo__c)
                            + ',' + convertNullToBlank(member.Name)
                            + ',' + convertNullToBlank(member.RegistDate__c)
                            + ',' + convertNullToBlank(member.Phone__c)
                            + ',' + convertNullToBlank(member.Email__c);

            // csv 본문에서 행의 마지막에 개행코드를 추가(행 구분)
            body += CSV_LINEFEED;

            // csv 출력에 사용할 본문 리스트에 추가
            csvBodyList.add(body);
        }

        // csv 출력 템플릿 페이지 호출
        return Page.ExportToCsvTemplate.setRedirect(false);
    }

    /**
     * @description csv본문 출력시, null을 공백문자로 표시하기 위해 치환
     * @param str 확인할 문자열
     * @return 공백 또는 문자열
     */
    private String convertNullToBlank(String str) {

        return (String.isBlank(str)) ? '' : str;
    }

    /**
     * @description csv본문 출력시, null을 공백문자로 표시하기 위해 치환
     * @param dt 확인할 날짜 변수
     * @return 공백 또는 날짜
     */
    private String convertNullToBlank(Date dt) {

        // 날짜(년월일) 또는 공백
        // String.leftPad(prm1: 문자수, prm2: 남은 문자수가 빈칸인 경우, 채워 넣을 지정 문자)
        return (dt == null) ? '' : String.valueOf(dt.year()) + String.valueOf(dt.month()).leftPad(2, '0') + String.valueOf(dt.day()).leftPad(2, '0');
    }

    /**
     * @description JAVA의 String.format의 %d, %s가 지원되지 않아 임시로 만든 Util. data를 기준으로 size만큼 앞자리를 defChar로 체운다. defChar이 없으면 공백으로 채운다. 지정한 자릿수 이하이면 자릿수까지 맞추며, 넘치면 넘치는대로 반환한다.
     */
    private String formatFill(String data, Integer size, String defChar) {
        String fillChar = ' ';
        if(data.length()>=size){
            return data;
        } else if(defChar != null || !String.isEmpty(defChar)) {
            fillChar = defChar;
        }
        String result = data;
        for(Integer i = result.length(); i<size; i = result.length()) {
            result = fillChar + result;
        }
        return result;
    }
}