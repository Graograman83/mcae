public with sharing class ExchangeRateController {
    static final String apiKey = Api_Key__mdt.getInstance('Fixer_io').Key__c;
    static final String endpoint = 'http://data.fixer.io/api/';
    static Map<String, String> baseUrlParams = new Map<String, String> {
        'access_key' => apiKey
    };

    @AuraEnabled(cacheable=true)
    public static RatesResponse getHistoricalExchangeRates(String base, Date historicalDate) {
        Map<String, String> urlParams = new Map<String, String>(baseUrlParams);
        urlParams.put('base', base);
        urlParams.put('date', ((Datetime) historicalDate).format('yyyy-MM-dd'));
        AuraHandledException exc = new AuraHandledException('Can\'t retrieve exchange rates.');

        try {
            String responsebody = requestAndGetResponseBody('latest', urlParams);
            RatesResponse response = (RatesResponse) JSON.deserialize(responsebody, RatesResponse.class);
            if (response.success) {
                return response;
            } else {
                throw exc;
            }
        } catch (Exception e) {
            throw exc;
        }
    }

    @AuraEnabled(cacheable=true)
    public static RatesResponse getLatestExchangeRates(String base) {
        Map<String, String> urlParams = new Map<String, String>(baseUrlParams);
        urlParams.put('base', base);
        AuraHandledException exc = new AuraHandledException('Can\'t retrieve exchange rates.');

        try {
            String responsebody = requestAndGetResponseBody('latest', urlParams);
            RatesResponse response = (RatesResponse) JSON.deserialize(responsebody, RatesResponse.class);
            if (response.success) {
                return response;
            } else {
                throw exc;
            }
        } catch (Exception e) {
            throw exc;
        }
    }

    @AuraEnabled(cacheable=true)
    public static SymbolsResponse getSymbols() {
        Map<String, String> urlParams = new Map<String, String>(baseUrlParams);
        AuraHandledException exc = new AuraHandledException('Can\'t retrieve symbols.');

        try {
            String responsebody = requestAndGetResponseBody('symbols', urlParams);
            SymbolsResponse response = (SymbolsResponse) JSON.deserialize(responsebody, SymbolsResponse.class);
            if (response.success) {
                return response;
            } else {
                throw exc;
            }
        } catch (Exception e) {
            throw exc;
        }
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

    public class RatesResponse  {
        public Boolean success;
        @AuraEnabled
        public Long timestamp;
        @AuraEnabled
        public Map<String, Decimal> rates;
    }

    public class SymbolsResponse  {
        public Boolean success;
        @AuraEnabled
        public Map<String, String> symbols;
    }
}