public with sharing class ExchangeRateController {
    static final String apiKey = Api_Key__mdt.getInstance('Fixer_io').Key__c;
    static final String endpoint = 'http://data.fixer.io/api/';
    static Map<String, String> baseUrlParams = new Map<String, String> {
        'access_key' => apiKey
    };

    @AuraEnabled(cacheable=false)
    public static void getExchangeRates(String base, List<String> symbols) {
        Map<String, String> urlParams = new Map<String, String>(baseUrlParams);
        urlParams.put('base', base);
        urlParams.put('symbols', String.join(symbols, ','));

        String responsebody = requestAndGetResponseBody('latest', urlParams);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSymbols(String base) {
        Map<String, String> urlParams = new Map<String, String>(baseUrlParams);

        String responsebody = requestAndGetResponseBody('symbols', urlParams);

        return new Map<String, String>();
    }  

    private static String requestAndGetResponseBody(String resource, Map<String, String> urlParams) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint + resource + buildQueryString(urlParams));
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getBody();
    }

    private static String buildQueryString(Map<String, String> urlParams) {
        String queryString = '?';
        List<String> expressions = new List<String>();
        for (String key : urlParams.keySet()) {
            expressions.add(key + '=' + urlParams.get(key));
        }
        queryString += String.join(expressions, '&');
        return queryString;
    }    

    public class Output  {
        @AuraEnabled
        public String timestamp;
        @AuraEnabled
        public Map<String, Decimal> rates;
    }
}