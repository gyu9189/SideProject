public with sharing class Calculator {

    public static Integer add(Integer item1, Integer item2) {

        if(item1 == null || item2 == null) {
            throw new CalculatorException('error message');
        }
            return item1 + item2;
        }
    }