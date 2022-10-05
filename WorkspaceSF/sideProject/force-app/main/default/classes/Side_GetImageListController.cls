public with sharing class Side_GetImageListController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDefaultImageList(String type){

        Map<String, Schema.SObjectField> schemaOppFieldMap = Images__c.sObjectType.getDescribe().fields.getMap();

        System.debug('schemaOppFieldMap ::: ' + schemaOppFieldMap);
        
        if(type.equals('')){
            type = 'chihiro';
        } // if

        List<Images__c> dImages = [SELECT Id
                                         ,Name
                                         ,ImageType__c
                                         ,ImageURL__c
                                    FROM 
                                        Images__c
                                    WHERE ImageType__c = :type
                                    ORDER BY Image_NO__c DESC];
        

        Map<String, Object> returnMap = new Map<String, Object>();

        Map<String, Object> idMap = new Map<String, Object>();
        for(Integer i = 0; i < dImages.size(); i++) {
            idMap.put(dImages[i].Id, 'unchecked');
        }

        System.debug('idMap ::: ' + idMap);
        
        returnMap.put('imageList', dImages);
        returnMap.put('imageSize', dImages.size());
        returnMap.put('imageId', idMap);


        return returnMap;
    } // getImageList()

}
