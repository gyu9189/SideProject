// Visualforce Javascript 연동 페이지의 컨트롤러

public class CntrlVfCallJs {
    // javascript 에서 호출할 변수
    
    public String myVariable { get; set; }
    
    // 생성자
    public CntrlVfCallJs() {
        myVariable = 'Hello World'; // 변수 초기화
    } // 생성자
    
    // javascript 에서 호출할 변수
    public void myMethod() {
        // 화면에 메세지 표시
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Apex method called'));
    } // myMetho
}