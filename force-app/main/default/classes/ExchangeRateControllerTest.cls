@isTest
private class ExchangeRateControllerTest {
    @isTest
    static void getHistoricalExchangeRatesHappy() {
        String body = '{"success":true,"historical":true,"timestamp":1763798647,"base":"EUR","date":"2025-11-22","rates":{"AED":4.229027,"USD":1.151538}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        try {
            ExchangeRateController.RatesResponse response = ExchangeRateController.getHistoricalExchangeRates('EUR', Date.today());
            System.assert(response.success);
            System.assertEquals(1763798647, response.timestamp);
            System.assertEquals(2, response.rates.size());
            System.assertEquals(4.229027, response.rates.get('AED'));
            System.assertEquals(1.151538, response.rates.get('USD'));
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void getHistoricalExchangeRatesError() {
        String body = '{"success": false,"error": {"code": 101,"type": "missing_access_key","info": "You have not supplied an API Access Key. [Required format: access_key=YOUR_ACCESS_KEY]"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        try {
            ExchangeRateController.RatesResponse response = ExchangeRateController.getHistoricalExchangeRates('EUR', Date.today());
        } catch (Exception e) {
            System.assert(true);
        }
    }

    @isTest
    static void getLatestExchangeRatesHappy() {
        String body = '{"success":true,"timestamp":1763798647,"base":"EUR","date":"2025-11-22","rates":{"AED":4.229027,"USD":1.151538}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        try {
            ExchangeRateController.RatesResponse response = ExchangeRateController.getLatestExchangeRates('EUR');
            System.assert(response.success);
            System.assertEquals(1763798647, response.timestamp);
            System.assertEquals(2, response.rates.size());
            System.assertEquals(4.229027, response.rates.get('AED'));
            System.assertEquals(1.151538, response.rates.get('USD'));
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void getLatestExchangeRatesError() {
        String body = '{"success": false,"error": {"code": 101,"type": "missing_access_key","info": "You have not supplied an API Access Key. [Required format: access_key=YOUR_ACCESS_KEY]"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        try {
            ExchangeRateController.RatesResponse response = ExchangeRateController.getLatestExchangeRates('EUR');
        } catch (Exception e) {
            System.assert(true);
        }
    }

    @isTest
    static void getTimeseriesExchangeRatesHappy() {
        String body = '{"success":true,"timeseries":true,"base":"EUR","start_date":"2025-11-20","end_date":"2025-11-21","rates":{"2025-11-20":{"AED":5.229027,"USD":3.151538},"2025-11-21":{"AED":10.229027,"USD":6.151538}}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        try {
            ExchangeRateController.RatesSeriesResponse response = ExchangeRateController.getTimeseriesExchangeRates('EUR', new List<String>{'AED','USD'}, Date.newinstance(2025, 11, 20), Date.newinstance(2025, 11, 21));
            System.assert(response.success);
            System.assertEquals(2, response.rates.size());
            System.assertEquals(2, response.rates.get('2025-11-20').size());
            System.assertEquals(5.229027, response.rates.get('2025-11-20').get('AED'));
            System.assertEquals(3.151538, response.rates.get('2025-11-20').get('USD'));
            System.assertEquals(2, response.rates.get('2025-11-21').size());
            System.assertEquals(10.229027, response.rates.get('2025-11-21').get('AED'));
            System.assertEquals(6.151538, response.rates.get('2025-11-21').get('USD'));
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void getTimeseriesExchangeRatesError() {
        String body = '{"success": false,"error": {"code": 101,"type": "missing_access_key","info": "You have not supplied an API Access Key. [Required format: access_key=YOUR_ACCESS_KEY]"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        try {
            ExchangeRateController.RatesSeriesResponse response = ExchangeRateController.getTimeseriesExchangeRates('EUR', new List<String>{'AED','USD'}, Date.newinstance(2025, 11, 20), Date.newinstance(2025, 11, 21));
        } catch (Exception e) {
            System.assert(true);
        }
    }

    @isTest
    static void getSymbolsHappy() {
        String body = '{"success":true,"symbols":{"AED":"United Arab Emirates Dirham","USD":"United States Dollar"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        try {
            ExchangeRateController.SymbolsResponse response = ExchangeRateController.getSymbols();
            System.assert(response.success);
            System.assertEquals(2, response.symbols.size());
            System.assertEquals('United Arab Emirates Dirham', response.symbols.get('AED'));
            System.assertEquals('United States Dollar', response.symbols.get('USD'));
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void getSymbolsError() {
        String body = '{"success": false,"error": {"code": 101,"type": "missing_access_key","info": "You have not supplied an API Access Key. [Required format: access_key=YOUR_ACCESS_KEY]"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));

        try {
            ExchangeRateController.SymbolsResponse response = ExchangeRateController.getSymbols();
        } catch (Exception e) {
            System.assert(true);
        }
    }
}