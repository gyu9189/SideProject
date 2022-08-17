/**
 * @description 메일 송신 화면 컨트롤러
 */
public with sharing class CntrlSendMail {

    public String mailSubject { get; set; }     // 메일 제목
    public String mailToAddress { get; set; }   // To Address(콤마(,)구분)
    public String mailCcAddress { get; set; }   // cc Address(콤마(,)구분)
    public String mailBccAddress { get; set; }  // Bcc Address(콤마(,)구분)
    public String mailBody { get; set; }        // 메일 본문

    /**
     * @description 생성자
     */
    private class MailException extends Exception {
    }

    /**
     * @description 생성자
     */
    public CntrlSendMail() {
        // nothing
    }

    /**
     * @description 메일 송신
     */
    public void sendMail(){

        // 메일 송신 성공 여부 확인용 플래그
        Boolean isSucceed = true;

        // 메일 송신 실패시 표시할 에러 메시지
        String sendErrMsg = '';

        // 콤마(,)로 구분되어 있는 메일 주소를 분할 습득
        List<String> toAddrs = getAddrList(mailToAddress);
        List<String> ccAddrs = getAddrList(mailCcAddress);
        List<String> bccAddrs = getAddrList(mailBccAddress);

        // mail 인스턴스 생성
        Messaging.SingleEmailMessage mail = createMail(toAddrs, ccAddrs, bccAddrs);
    
        try {

            // 메일발송
            send(new List<Messaging.SingleEmailMessage>{ mail });

        } catch (MailException me) {

            System.debug(me.getStackTraceString());
            sendErrMsg = '메일 송신 실패 (이유 : ' + me.getMessage() + ')';
            isSucceed = false;
        }

        if (!isSucceed) {
            // 메일 송신 실패

            // 화면에 에러메시지 표시
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, sendErrMsg));
            return;
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, '메일 송신 완료'));
    }

    /**
     * @description 메일 생성
     * @param toAddrs to Address
     * @param ccAddrs cc Address
     * @param bccAddrs bcc Address
     * @return 메일 인스턴스
     */
    private Messaging.SingleEmailMessage createMail(List<String> toAddrs, List<String> ccAddrs, List<String> bccAddrs) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        if ( (toAddrs == null || toAddrs.isEmpty()) && 
                (ccAddrs == null || ccAddrs.isEmpty()) && 
                (bccAddrs == null || bccAddrs.isEmpty()) ) {
            // 받는 사람 주소가 설정되지 않은 경우

            return null;
        }

        // ToAddress 설정
        if (! (toAddrs == null || toAddrs.isEmpty()) ) {

            mail.setToAddresses(toAddrs);
        }

        // CcAddress 설정
        if (! (ccAddrs == null || ccAddrs.isEmpty()) ) {

            mail.setCcAddresses(ccAddrs);
        }

        // BccAddress 설정
        if (! (bccAddrs == null || bccAddrs.isEmpty()) ) {

            mail.setBccAddresses(bccAddrs);
        }

        // 보내는 사람 이름 설정 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'ilgyu.jeon@dkbmc.com'];
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        } else {
           mail.setSenderDisplayName('Salesforce 개발테스터 - 조직메일을 등록하세요.'); 
        }

        // 메일 제목 설정
        if (String.isNotBlank(mailSubject)) {

            mail.setSubject(mailSubject);
        }

        // 메일 본문 설정
        if (String.isNotBlank(mailBody)) {

            mail.setPlainTextBody(mailBody);
        }

        return mail;
    }

    /**
     * @description 메일 송신(복수)
     * @param mails 메일 리스트
     */
    public static void send(List<Messaging.SingleEmailMessage> mails) {

        if (mails == null || mails.isEmpty()) {

            return;
        }

        try {

            // 메일 송신
            Messaging.sendEmail(mails);

        } catch (Exception e) {

            System.debug(e.getStackTraceString());
            throw new MailException(e.getMessage());
        }
    }

    /**
     * @description 화면에서 입력한 메일주소(콤마(,)구분)를 분할하여 리스트에 저장
     * @param addrStr 화면에 입력한 주소 (문자열、콤마(,)구분)
     * @return 메일 주소 리스트
     */
    private List<String> getAddrList(String addrStr) {

        if (String.isBlank(addrStr)) {

            return null;
        }

        // 콤마(,)를 기준으로 각 메일주소를 분할, 리스트에 저장
        List<String> addrs = addrStr.split(',');

        for (String str : addrs) {

            // 공백 삭제
            str = trimEmSpace(str);
        }

        return addrs;
    }

    /**
     * @description 문자열에서 선두, 말미의 공백문자를 삭제
     * @param str 문자열
     * @return 문자열의 양 끝의 공백문자 삭제
     */
    public static String trimEmSpace(String str) {

        String ret = str;

        if (str == null) {
            return null;
        }

        ret = str.trim();
        if (ret.equals('')) {
            return '';
        }

        // 선두의 공백 문자열 삭제
        ret = ret.replaceAll('^(\\s|　)+', '');

        if (ret.equals('')) {
            return '';
        }

        // 말미의 공백 문자열 삭제
        ret = ret.replaceAll('(\\s|　)+$', '');

        return ret;
    }
}