@isTest
private class UtilsTest {
    @isTest
    static void buildQueryString() {
        Map<String, String> urlParams = new Map<String, String>{
            'param1' => 'value1',
            'param2' => 'value2'
        };

        String result = Utils.buildQueryString(urlParams);
        System.assertEquals('?param1=value1&param2=value2', result);
    }
}