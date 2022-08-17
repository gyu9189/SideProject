@isTest
private class LearningSFDevAPI_Test {
    @isTest
    private static void testGetMessages(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ExampleMessagesResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        List<LearningSFDevAPI> messages = LearningSFDevAPI.getMessages();
        System.assertEquals(1, messages.size(), 'Incorrect number of messages returned');
    } // testGetMessages()
}
