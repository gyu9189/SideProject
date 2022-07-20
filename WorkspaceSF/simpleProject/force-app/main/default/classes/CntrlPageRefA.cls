/**
 * @description 변수 데이터타입 사용법 및 화면 전환 테스트용 클래스
 */
public class CntrlPageRefA {
	
    /**
     * @description 화면 표시용 변수 정의 
     */
    public String dspStr { get; set;}		// 문자열 변수
    public Integer dspInt { get; set; }		// 정수형 변수
    public Decimal dspDec { get; set; }		// 실수형 변수
    public Boolean dspBool { get; set; }		// 논리형 변수

    /**
     * @description 화면 입력용 변수 정의 
     */
    public String inputStr { get; set;}		    // 문자열 변수
    public Integer inputInt { get; set; }		// 정수형 변수
    public Decimal inputDec { get; set; }		// 실수형 변수
    public Boolean inputBool { get; set; }		// 논리형 변수

    /**
     * @description 생성자
     */
    public CntrlPageRefA() {

        dspStr = '화면 표시용 문자열 변수 입니다.';
        dspInt = 10;
        dspDec = 10.00;
        dspBool = true;
    }

    /**
     * @description 화면 입력 변수 표시용 버튼 처리 메서드
     */
    public void dspInputData() {

        // 입력 데이터 화면 표시
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '[inputStr] : ' + inputStr));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '[inputInt] : ' + inputInt));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '[inputDec] : ' + inputDec));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '[inputBool] : ' + inputBool));
    } // dspInputData
    
    // @description 화면 전환 버튼 처리 메서드
    public PageReference moveToPageRefB(){
        
        // 전환 대상 화면(Page) 를 지정
        PageReference nextPage = Page.PageRefB;
        
        // 화면에서 입력한 값을 URL 파라미터에 저장
        // 문자열 형식으로 전달 해야만 하기 때문에, String.valueOf 로 형변환
        nextPage.getParameters().put('inputStr', inputStr);
        nextPage.getParameters().put('inputInt', String.valueOf(inputInt));
        nextPage.getParameters().put('inputDec', String.valueOf(inputDec));
        nextPage.getParameters().put('inputBool', String.valueOf(inputBool));
        
        // 지정된 화면으로 전환
        return nextPage;
    } // moveToPageRefB
}