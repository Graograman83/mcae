import { LightningElement, wire } from 'lwc';
import getHistoricalExchangeRates from '@salesforce/apex/ExchangeRateController.getHistoricalExchangeRates';
import getLatestExchangeRates from '@salesforce/apex/ExchangeRateController.getLatestExchangeRates';
import getSymbols from '@salesforce/apex/ExchangeRateController.getSymbols';

export default class ExchangeRates extends LightningElement {
    base = 'EUR';
    get baseHistoricalParam() {
        return this.mode === 'historical' ? this.base : undefined;
    }
    get baseLatestParam() {
        return this.mode === 'latest' ? this.base : undefined;
    }
    columns = [
        { label: 'Currency', fieldName: 'currency', type: 'text' },
        { label: 'Rate', fieldName: 'rate', type: 'number' }
    ];
    currencies = {};
    get currencyOptions() {
        return Object.entries(this.currencies).map(([key, value]) => ({ label: key + ' - ' + value, value: key }));
    };
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
        { label: 'Historical', value: 'historical' }
    ];
    mode = 'latest';
    quotes = [];
    ratesData = {};
    get rates() {
        if (this.isHistoricalMode && !this.historicalDate) {
            return [];
        }
        return Object.entries(this.ratesData).filter(([key]) => this.quotes.includes(key)).map(([key, value]) => ({ id: key, currency: key + ' - ' + this.currencies[key], rate: value }));
    };
    timestamp

    @wire(getLatestExchangeRates, { base: '$baseLatestParam' }) 
    wiredLatestExchangeRates({ error, data }) {
        if (data) {
            this.timestamp = new Date(data.timestamp);
            this.ratesData = data.rates;
            console.log('getLatestExchangeRates', this.ratesData, this.timestamp)
        } else if (error) {
            this.error = error;
            console.log('getLatestExchangeRates error', this.error)
        }
    }

    @wire(getHistoricalExchangeRates, { base: '$baseHistoricalParam', historicalDate: '$historicalDate' }) 
    wiredHistoricalExchangeRates({ error, data }) {
        if (data) {
            this.timestamp = new Date(data.timestamp);
            this.ratesData = data.rates;
            console.log('getHistoricalExchangeRates', this.ratesData, this.timestamp)
        } else if (error) {
            this.error = error;
            console.log('getHistoricalExchangeRates error', this.error)
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

    handleModeChange(event) {
        this.mode = event.detail.value;
    }


    handleHistoricalDateChange(event) {
        this.historicalDate = event.detail.value;
    }

    handleQuoteChange(event) {
        this.quotes = event.detail.value;
    }
}