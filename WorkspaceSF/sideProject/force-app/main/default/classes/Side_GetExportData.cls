public with sharing class Side_GetExportData {
    


    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDefaultData(){

        List<Video__c> vList = [SELECT Id, Name, Video_Genre__c, VideoNo__c FROM Video__c];

        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('size', vList.size());
        returnMap.put('dataList', vList);

        return returnMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAllObjectList(){
        List<String> sObjectList = new List<String>();

        for(Schema.SObjectType objType : Schema.getGlobalDescribe().values()){
            String name = objType.getDescribe().getName();

            if(!name.containsIgnoreCase('history') && !name.containsIgnoreCase('tag') &&
               !name.containsIgnoreCase('share') && !name.containsIgnoreCase('feed') || 
                name.toLowerCase().right(3) == '__c') {
                    sObjectList.add(name);
                    System.debug(name);
            }
        }        
        return sObjectList;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getFieldToObject(String objectName){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();

        List<String> strList = new List<String>();
        
        for(String mapKey : fieldMap.keySet()) {
            String name = string.valueOf(fieldMap.get(mapKey));
            if(!name.containsIgnoreCase('id')) {
                strList.add(name);
            }
            
            // add(fieldMap.get(mapKey));
        }
        System.debug('srtList ::: ' + strList);

        return strList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getChoiceData(String objectName, List<String> fields){
        String query = 'SELECT ';
        String lastField = fields[fields.size()-1];

        for(String field : fields) {
            if(field.equalsIgnoreCase(lastField)) {
                query += field + ' ';
            } else {
                query += field + ',';
            }
        }
        query += 'FROM ' + objectName;
        System.debug('query ::: ' + query);

        List<SObject> objList = new List<SObject>();
        objList = Database.query(query);
        List<String> strList = new List<String>();

        for(SObject temp : objList) {
            String name = string.valueOf(temp);
            if(!name.containsIgnoreCase('id')) {
                strList.add(name);
            }
        }
        
        System.debug('strList ::: ' + strList);
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('fieldList', strList);
        returnMap.put('size', strList.size());

        return returnMap;
    }


}
