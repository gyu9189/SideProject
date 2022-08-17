@isTest
private with sharing class MessageTest {
    
    @isTest
    private static void messageTest(){
        LearningSFDevAPI.Message msg = new LearningSFDevAPI.Message();
        msg.body = 'TEST MESSAGE';
        msg.sender = 'Paul Battisson';
        msg.email = 'paul@cloudbites.tv';
        msg.location = 'Harrogate, UK';
        msg.test = true;

        System.debug(msg);
    } // messageTest();
}
