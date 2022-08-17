public class LearningSFDevAPI {

    public static List<Message> getMessages(){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://api.learnsf-devwithapex.com/messages');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            List<Message> messages =(List<Message>)(JSON.deserialize(res.getBody(), List<Message>.class));
            return messages;
        } else {
            throw new LearningSFDevAPIException('API callout returned with a status of ' + res.getStatus());
        } // else 
    
    } // getMessages()

    public static void sendMessage(Message msg) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.learnsfdevwithapex.com.messages');
        req.setBody(JSON.serialize(msg));

        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() != 200) {
            throw new LearningSFDevAPIException('API callout returned with a status of ' + res.getStatus());
        }
        System.debug(res);
    } // sendMessage(msg)

public class Message {
    public String id;
    public String body;
    public Date posted;
    public String sender;
    public String location;
    public String email;
    public Boolean test;
} // Message class
} // main class
