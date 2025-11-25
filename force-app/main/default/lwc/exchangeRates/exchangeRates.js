import { LightningElement, wire } from 'lwc';
import getHistoricalExchangeRates from '@salesforce/apex/ExchangeRateController.getHistoricalExchangeRates';
import getLatestExchangeRates from '@salesforce/apex/ExchangeRateController.getLatestExchangeRates';
import getTimeseriesExchangeRates from '@salesforce/apex/ExchangeRateController.getTimeseriesExchangeRates';
import getSymbols from '@salesforce/apex/ExchangeRateController.getSymbols';

export default class ExchangeRates extends LightningElement {
    base = 'EUR';
    get baseHistoricalParam() {
        return this.mode === 'historical' ? this.base : undefined;
    }
    get baseLatestParam() {
        return this.mode === 'latest' ? this.base : undefined;
    }
    get baseTimeseriesParam() {
        return this.mode === 'timeseries' && this.quotes.length > 0 ? this.base : undefined;
    }
    columns = [
        { label: 'Currency', fieldName: 'currency', type: 'text' },
        { label: 'Rate', fieldName: 'rate', type: 'number' }
    ];
    currencies = {};
    get currencyOptions() {
        return Object.entries(this.currencies).map(([key, value]) => ({ label: key + ' - ' + value, value: key }));
    };
    endDate;
    error;
    historicalDate;
    get isHistoricalMode() {
        return this.mode === 'historical';
    }
    get isTimeseriesMode() {
        return this.mode === 'timeseries';
    }
    get maxDate() {
        let date = new Date();
        date.setDate(date.getDate() - 1);
        return date = date.toISOString().split('T')[0];
    }
    minDate = '2000-01-01';
    modeOptions = [
        { label: 'Latest', value: 'latest' },
        { label: 'Historical', value: 'historical' },
        { label: 'Timeseries', value: 'timeseries' }
    ];
    mode = 'latest';
    quotes = [];
    startDate;
    ratesData = {};
    get rates() {
        if (this.isHistoricalMode && !this.historicalDate) {
            return [];
        }
        return Object.entries(this.ratesData).filter(([key]) => this.quotes.includes(key)).map(([key, value]) => ({ id: key, currency: key + ' - ' + this.currencies[key], rate: value }));
    };
    timeseriesData = {};
    timestamp;

    @wire(getLatestExchangeRates, { base: '$baseLatestParam' }) 
    wiredLatestExchangeRates({ error, data }) {
        if (data) {
            this.timestamp = new Date(data.timestamp);
            this.ratesData = data.rates;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getHistoricalExchangeRates, { base: '$baseHistoricalParam', historicalDate: '$historicalDate' }) 
    wiredHistoricalExchangeRates({ error, data }) {
        if (data) {
            this.timestamp = new Date(data.timestamp);
            this.ratesData = data.rates;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getTimeseriesExchangeRates, { base: '$baseTimeseriesParam', symbols: '$quotes', startDate: '$startDate', endDate: '$endDate'}) 
    wiredTimeseriesExchangeRates({ error, data }) {
        if (data) {
            this.timeseriesData = data.rates;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getSymbols) 
    wiredSymbols({ error, data }) {
        if (data) {
            this.currencies = data.symbols;
        } else if (error) {
            this.error = error;
        }
    }

    handleBaseChange(event) {
        this.base = event.detail.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.detail.value;
    }

    handleModeChange(event) {
        this.mode = event.detail.value;
    }

    handleHistoricalDateChange(event) {
        this.historicalDate = event.detail.value;
    }

    handleQuoteChange(event) {
        this.quotes = event.detail.value;
    }

    handleStartDateChange(event) {
        this.startDate = event.detail.value;
    }
}