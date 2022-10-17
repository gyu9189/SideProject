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
            
            if(!name.containsIgnoreCase('history') && !name.containsIgnoreCase('tag') && !name.containsIgnoreCase('share') && 
               !name.containsIgnoreCase('feed') && !name.containsIgnoreCase('date') && !name.containsIgnoreCase('ChangeEvent') ||
                name.toLowerCase().right(3) == '__c') {
                    sObjectList.add(name);
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
            if(!name.containsIgnoreCase('id') && !name.containsIgnoreCase('LastViewedDate') && !name.containsIgnoreCase('LastReferencedDate') &&
               !name.containsIgnoreCase('LastReferencedDate')) {
                strList.add(name);
            }            
        }

        return strList;
    }


    // https://propicsignifi.github.io/
    @AuraEnabled(cacheable=true)
    public static Map<String, object> getChoiceData(String objectName, List<String> fields, List<String> whereList) {                

        String query = 'SELECT ';
        String lastField = string.valueOf(fields[fields.size() - 1]);

        for(String field : fields) {
            if(field.equalsIgnoreCase(lastField)) query += field + ' ';
            else query += field + ',';
        }
        
        query += 'FROM ' + objectName;
        if(whereList != null) {
            query = addQuery(query, whereList);
        }

        List<SObject> selectResult = new List<SObject>();
        selectResult = Database.query(query);

        
        Map<String, object> returnMap = new Map<String, object>();
        returnMap.put('fieldList', selectResult);

        return returnMap;
    }

    @AuraEnabled
    public static String getFieldType(String objectName, String fieldName) {
        System.debug('fieldName   ' + fieldName);

        if(fieldName.equalsIgnoreCase('none')) return 'null';
        
        SObjectType r = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        String result = string.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
        
        return result;
    }


    // 해당 메서드의 pick List 를 동적으로 가져오는 Schema Class Notion에 정리 해야함
    @AuraEnabled
    public static List<String> getPickList(String objectName, String fieldName){       
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();

        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(fieldName).getDescribe().getPickListValues();        
        
        List<String> prickList = new List<String>();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
            prickList.add(objPickList.getLabel());
        }

        // type이 pickList 인 field의 pickList를 가져오는?
        /* List<String> returnList = new List<String>();

        for(Schema.PicklistEntry pickListVal : ple) {
            returnList.add(pickListVal.getLabel());
        } */

        /* System.debug('returnList ::: ' + returnList); */
        return prickList;
    }


    private static String addQuery(String query, List<String> whereList){ // lastValue가 필요 없을거 같은데 ...
            query += ' where ';
            String lastVlaue = whereList.get(whereList.size() - 2);
            String operator = '';
            for(Integer i = 0; i < whereList.size(); i++) {
                if(i == 0 || Math.Mod(i, 3) == 0){
                    operator = operatorProcessing(whereList.get(i),whereList.get(i+1), whereList.get(i+2));
                    if(operator.containsIgnoreCase('LIKE')) {
                        if(!lastVlaue.equalsIgnoreCase(whereList.get(i+2))){
                            query += operator;
                        } else {
                            query += operator;
                        }
                    }
                } else if (i == 1 ||Math.Mod(i, 3) == 1) {
                    if(!operator.containsIgnoreCase('LIKE')) {
                        query += whereList.get(i) + operator;
                    }
                } else if (i == 2 ||Math.Mod(i, 3) == 2) {
                    if(!operator.containsIgnoreCase('LIKE')){
                        if(!lastVlaue.equalsIgnoreCase(whereList.get(i))){
                            query +=  '\''+ whereList.get(i) + '\' ';
                        } else {
                            query +=  '\''+ whereList.get(i) + '\' ';
                        }
                    }
                } else if(i == 3 ||Math.Mod(i, 3) == 3) {
                    if(whereList.get(i).equalsIgnoreCase('none')){
                        if(whereList.get(i).equalsIgnoreCase('and')){
                            query += ' AND ';
                        } else if(whereList.get(i).equalsIgnoreCase('or')){
                            query += ' OR ';
                        }
                    }
                }
            }


        return query;
    }

    private static String operatorProcessing(String oper,String field, String value) {
        if(oper.equalsIgnoreCase('equals')){
            oper = '=';
        } else if(oper.equalsIgnoreCase('not equal to')) {
            oper = '!=';
        } else if(oper.equalsIgnoreCase('starts with')) {
            oper = ' ' + field + ' LIKE \'' + value + '%\'';
        } else if(oper.equalsIgnoreCase('contains')) {
            oper = ' ' + field + ' LIKE \'%' + value + '%\'';
        } else if(oper.equalsIgnoreCase('dose not contain')) {
            oper = '(NOT ' + field + ' LIKE \'%' + value + '%\')'; //  (NOT fieldName like '%Test%').
        } else if(oper.equalsIgnoreCase('less than')) {
            oper = '<';
        } else if(oper.equalsIgnoreCase('greater than')) {
            oper = '>';
        } else if(oper.equalsIgnoreCase('less or equal')) {
            oper = '<=';
        } else if(oper.equalsIgnoreCase('greater or equal')) {
            oper = '>=';
        }
        return oper;
    }

    
}
