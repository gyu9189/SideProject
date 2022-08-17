@isTest
private with sharing class Calculator_Test {

    @isTest
    private static void testTwoPositiveIntegers() {
        // Setup out test data
        Integer x = 5;
        Integer y = 9;

        // Execute the method we wish to test
        Integer result = Calculator.add(x, y);

        // Assert we get the correct result
        // assertion 은 3가지 메서드가 있다
        // 1. System.Assert(Boolean testValue, String failureMEssage)
        //      ㄴ Boolean 값을 사용하며 해당 Boolean 이 false 일시 failureMessage 를 반환합니다.
        // 2. System.AssertEquals(expectedValue, actualValue, String faulureMessage) 
        //      ㄴ expectedValue 와 actualValue 를 비교하고 동일하지 않다면 failureMessage 를 반환합니다.
        // 3. System.assertNotEquals(expectedValue, actualValue, String failureMessage)
        //      ㄴ expectedValue 와 actualValue 를 비교하고 failureMessage 를 반환한다.
        //          failureMessage 를 반환할때 처리 불가능한 예외를 throw 하고 테스트 실행자를 통해
        //          해당 메시지를 표시하는 것을 의미한다.
        System.assertEquals(14, result, 'Incorrect result returned from add method');
    } // testTwoPositiveIntegers()

    @isTest
    private static void testNullItemException() {
        Integer x = null;
        Integer y = 9;

        try {
            Integer result = Calculator.add(x, y);
            System.assert(true, 'try');
        } catch (Exception ex) {
            
        } // catch
    } // testNullItemException()
}