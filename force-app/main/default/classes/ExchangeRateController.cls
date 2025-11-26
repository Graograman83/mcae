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
        AuraHandledException exc = new AuraHandledException('Can\'t retrieve exchange rates.');

        try {
            String responsebody = requestAndGetResponseBody(((Datetime) historicalDate).format('yyyy-MM-dd'), urlParams);
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
    public static RatesSeriesResponse getTimeseriesExchangeRates(String base, List<String> symbols, Date startDate, Date endDate) {
        Map<String, String> urlParams = new Map<String, String>(baseUrlParams);
        urlParams.put('base', base);
        urlParams.put('symbols', String.join(symbols, ','));
        urlParams.put('start_date', ((Datetime) startDate).format('yyyy-MM-dd'));
        urlParams.put('end_date', ((Datetime) endDate).format('yyyy-MM-dd'));
        AuraHandledException exc = new AuraHandledException('Can\'t retrieve exchange rates.');

        try {
            String responsebody = requestAndGetResponseBody('timeseries', urlParams);
            RatesSeriesResponse response = (RatesSeriesResponse) JSON.deserialize(responsebody, RatesSeriesResponse.class);
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
        AuraHandledException exc = new AuraHandledException('Can\'t retrieve currencies.');

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
        req.setEndpoint(endpoint + resource + Utils.buildQueryString(urlParams));
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getBody();
    }

    public class RatesResponse  {
        public Boolean success;
        @AuraEnabled
        public Long timestamp;
        @AuraEnabled
        public Map<String, Decimal> rates;
    }

    public class RatesSeriesResponse  {
        public Boolean success;
        @AuraEnabled
        public Map<String, Map<String, Decimal>> rates;
    }

    public class SymbolsResponse  {
        public Boolean success;
        @AuraEnabled
        public Map<String, String> symbols;
    }
}