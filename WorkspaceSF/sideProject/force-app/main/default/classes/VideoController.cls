public with sharing class VideoController {
    
    // select Video List
    @AuraEnabled(cacheable=true)
    public static List<Video__c> getVideoList(){
            List<Video__C> videoList = [SELECT
                                            Id,
                                            Name,
                                            VideoNo__c,
                                            IsLent__c,
                                            LentDate__c,
                                            Video_Genre__c,
                                            Customer__r.Name
                                        FROM 
                                            Video__c
                                        ORDER BY
                                            VideoNo__c DESC];
            
            System.debug('List ::: ' + videoList);

            return videoList;
    } // gerVideoList()

    @AuraEnabled
    public static List<Video__c> delVideoRecords(List<String> vList) {
        System.debug('vList!!!');
        System.debug(vList);
        List<Video__c> delVideos = new List<Video__c>();
        for(Video__c v : [SELECT Id FROM Video__c where Id in :(vList)]){
            delVideos.add(v);
        } // for
        System.debug('deVideos!!! ::: ');
        System.debug(delVideos);

        if(delVideos.size() > 0) {
            try {
                delete delVideos;
            } catch (Exception e) {
                throw new AuraHandledException('unable to delete'+e.getMessage());
            } // try / catch
        } else {
            System.debug('cntl del ELSE join !!!! ');
            return null;
        }
        return delVideos;
    } //delVideoRecords();

} // class