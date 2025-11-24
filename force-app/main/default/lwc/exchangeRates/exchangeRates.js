import { LightningElement, wire } from 'lwc';
import getExchangeRates from '@salesforce/apex/ExchangeRateController.getExchangeRates';
import getSymbols from '@salesforce/apex/ExchangeRateController.getSymbols';

export default class ExchangeRates extends LightningElement {
    base = 'EUR';
    columns = [
        { label: 'Currency', fieldName: 'currency', type: 'text' },
        { label: 'Rate', fieldName: 'rate', type: 'number' }
    ];
    currencies = {};
    get currencyOptions() {
        return Object.entries(this.currencies).map(([key, value]) => ({ label: key + ' - ' + value, value: key }));
    };
    error;
    modeOptions = [
        { label: 'Latest', value: 'latest' },
        { label: 'Historical', value: 'historical' }
    ];
    mode = 'latest';
    quotes = [];
    ratesData = {};
    get rates() {
        return Object.entries(this.ratesData).filter(([key]) => this.quotes.includes(key)).map(([key, value]) => ({ id: key, currency: key + ' - ' + this.currencies[key], rate: value }));
    };
    timestamp

    @wire(getExchangeRates, { base: '$base' }) 
    wiredExchangeRates({ error, data }) {
        if (data) {
            this.timestamp = new Date(data.timestamp);
            this.ratesData = data.rates;
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

    handleModeChange(event) {
        this.mode = event.detail.value;
    }

    handleQuoteChange(event) {
        this.quotes = event.detail.value;
    }
}