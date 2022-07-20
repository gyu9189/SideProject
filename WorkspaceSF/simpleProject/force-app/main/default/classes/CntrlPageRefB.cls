/**
 * @description PageRefA에서 전달받은 데이터를 표시할 페이지의 컨트롤러
 */
public class CntrlPageRefB {

    public String paramStr { get; set; }		// 문자열 
    public Integer paramInt { get; set; }		// 정수형
    public Decimal paramDec { get; set; }		// 실수형
    public Boolean paramBool { get; set; }		// 논리형

    /**
     * @description 생성자
     */
    public CntrlPageRefB() {
        // 현재 페이지의 URL에서 각 파라미터에 저장된 값을 습득, 변수에 저장
        // 문자열 형태로 전달되었기 때문에, 각 변수에 맞는 데이터 타입으로 형변환
        paramStr = ApexPages.currentPage().getParameters().get('inputStr');
        paramInt = Integer.valueOf(ApexPages.currentPage().getParameters().get('inputInt'));
        paramDec = Decimal.valueOf(ApexPages.currentPage().getParameters().get('inputDec'));
        paramBool = Boolean.valueOf(ApexPages.currentPage().getParameters().get('inputBool'));
    }
}