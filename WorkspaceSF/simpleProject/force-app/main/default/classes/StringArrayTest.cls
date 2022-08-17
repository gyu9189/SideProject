public class StringArrayTest {
    public static List<String> generateStringArray(Integer n){
        List<String> strList = new List<String>();
        for (Integer i=0;i<n;i++){
            strList.add('Test '+i);
        }
        System.debug(strList);
        return strList;
    }
}
