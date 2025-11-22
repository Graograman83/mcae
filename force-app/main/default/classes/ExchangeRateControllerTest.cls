@isTest
private class ExchangeRateControllerTest {

    @isTest
    static void getExchangeRates() {
        String body = '{"success":true,"timestamp":1763798647,"base":"EUR","date":"2025-11-22","rates":{"AED":4.229027,"USD":1.151538}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        ExchangeRateController.RatesResponse response = ExchangeRateController.getExchangeRates('EUR', new List<String>{'AED', 'USD'});
        System.assert(response.success);
        System.assertEquals(1763798647, response.timestamp);
        System.assertEquals(2, response.rates.size());
        System.assertEquals(4.229027, response.rates.get('AED'));
        System.assertEquals(1.151538, response.rates.get('USD'));
    }

    @isTest
    static void getSymbols() {
        String body = '{"success":true,"symbols":{"AED":"United Arab Emirates Dirham","USD":"United States Dollar"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        ExchangeRateController.SymbolsResponse response = ExchangeRateController.getSymbols();
        System.assert(response.success);
        System.assertEquals(2, response.symbols.size());
        System.assertEquals('United Arab Emirates Dirham', response.symbols.get('AED'));
        System.assertEquals('United States Dollar', response.symbols.get('USD'));
    }
}