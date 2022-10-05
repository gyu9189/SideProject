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

    @AuraEnabled(cacheable=true)
    public static List<Video__c> getSearchList(Map<Object, object> strMap){
        System.debug('strMap');
        System.debug(strMap);
        String searchTitle = String.valueOf(strMap.get('searchTitle'));
        String searchStr = String.valueOf(strMap.get('searchStr'));
        
        System.debug('search Title ::: ');
        System.debug(searchTitle);
        System.debug('searchStr ::: ');
        System.debug(searchStr); 
        try{
            if(searchStr == null) {
                System.debug('searchStr == null !!!');
                return getVideoList();
            }
            String selectQuery = 'SELECT'
                                          +' Id,'
                                          +' Name,'
                                          +' VideoNo__c,'
                                          +' IsLent__c,'
                                          +' LentDate__c,'
                                          +' Video_Genre__c,'
                                          +' Customer__r.Name'
                                      +' FROM'
                                          +' Video__c'
                                      +' WHERE ';
            String finalQuery = selectQuery + searchTitle + ' LIKE \'%' + searchStr + '%\'' + ' LIMIT 5';
            System.debug(finalQuery);
            List<Video__c> temp = Database.query(finalQuery);
            
            System.debug(temp);
            return temp;
        }catch(Exception e) {
            System.debug('ERRORRRR');
            System.debug(e);
        } // try / catch
        
        return null;
    } // getSearchList()

    @AuraEnabled(cacheable=true)
    public static List<Video__c> getDataExportToExcel(){
        List<Video__c> exDataList = [SELECT
                                            Id,
                                            Name,
                                            VideoNo__c,
                                            IsLent__c,
                                            // LentDate__c,
                                            Video_Genre__c,
                                            Customer__r.Name
                                        FROM 
                                            Video__c
                                        ORDER BY
                                            VideoNo__c ASC];
        
            return exDataList;
    } // getDataExportToExcel()

    @AuraEnabled(cacheable=true)
    public static List<Contact> getAccountDataToExport(){
        List<Contact> lstContacts = [SELECT Id, FirstName, LastName, Email 
                                                    FROM Contact WHERE Email != null LIMIT 10];
        return lstContacts;
    }
    
} // class