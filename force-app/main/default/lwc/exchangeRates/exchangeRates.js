import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getHistoricalExchangeRates from '@salesforce/apex/ExchangeRateController.getHistoricalExchangeRates';
import getLatestExchangeRates from '@salesforce/apex/ExchangeRateController.getLatestExchangeRates';
import getTimeseriesExchangeRates from '@salesforce/apex/ExchangeRateController.getTimeseriesExchangeRates';
import getSymbols from '@salesforce/apex/ExchangeRateController.getSymbols';
import LightningToast from "lightning/toast";

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
    currenciesError;
    ratesError;
    historicalDate;
    get isTimeseriesHidden() {
        return !this.isTimeseriesMode ? 'slds-hidden' : '';
    }
    get isHistoricalMode() {
        return this.mode === 'historical';
    }
    get isLatestMode() {
        return this.mode === 'latest';
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
    get refreshRatesHidden() {
        return ( this.ratesError || (this.isLatestMode && this.rates.length > 0)) ? '' : 'slds-hidden';
    }
    get timestampHidden() {
        return this.isLatestMode && this.rates.length > 0 ? '' : 'slds-hidden';
    }
    _timeseriesData = {};
    get timeseriesData() {
        if (this.quotes.length === 0 || !this.startDate || !this.endDate) {
            return [];
        }
        return this._timeseriesData;
    }
    set timeseriesData(value) {
        this._timeseriesData = value;
    }
    timestamp;
    wiredCurrencies;
    wiredRates;

    @wire(getLatestExchangeRates, { base: '$baseLatestParam' }) 
    wiredLatestExchangeRates(value) {
        this.wiredRates = value;
        const { error, data } = value;
        console.log('lateststart');
        if (data) {
            this.timestamp = new Date(data.timestamp).toLocaleString();
            this.ratesData = data.rates;
            this.ratesError = undefined;
            console.log('latesthappy');
        } else if (error && !this.currenciesError) {
            console.log('latesterror');
            this.showError(error);
            this.ratesError = error;
        }
    }

    @wire(getHistoricalExchangeRates, { base: '$baseHistoricalParam', historicalDate: '$historicalDate' }) 
    wiredHistoricalExchangeRates(value) {
        this.wiredRates = value;
        const { error, data } = value;
        if (data) {
            this.timestamp = new Date(data.timestamp);
            this.ratesData = data.rates;
            this.ratesError = undefined;
        } else if (error && !this.currenciesError) {
            this.showError(error);
            this.ratesError = error;
        }
    }

    @wire(getTimeseriesExchangeRates, { base: '$baseTimeseriesParam', symbols: '$quotes', startDate: '$startDate', endDate: '$endDate'}) 
    wiredTimeseriesExchangeRates(value) {
        this.wiredRates = value;
        const { error, data } = value;
        if (data) {
            this.timeseriesData = this.mapRatesToTimeseriesData(data.rates);
            this.ratesError = undefined;
        } else if (error && !this.currenciesError) {
            this.showError(error);
            this.ratesError = error;
        }
    }

    @wire(getSymbols) 
    wiredSymbols(value) {
        this.wiredCurrencies = value;
        const { error, data } = value;
        if (data) {
            this.currencies = data.symbols;
            this.currenciesError = undefined;
        } else if (error) {
            this.showError(error);
            this.currenciesError = error;
        }
    }

    mapRatesToTimeseriesData(rates) {
        const timeseriesData = {
            labels: [],
            rows: {}
        };
        Object.entries(rates).forEach(([key, value]) => {
            timeseriesData.labels.push(key);
            Object.entries(value).forEach(([key, value]) => {
                if (!timeseriesData.rows[key]) {
                    timeseriesData.rows[key] = [];
                }
                timeseriesData.rows[key].push(value);
            });
        })
        return timeseriesData;
    }
    
    handleBaseChange = this.handleChange('base');
    handleEndDateChange = this.handleChange('endDate');
    handleHistoricalDateChange = this.handleChange('historicalDate');
    handleModeChange = this.handleChange('mode');
    handleQuoteChange = this.handleChange('quotes');
    handleStartDateChange = this.handleChange('startDate');

    handleChange(propName) {
        return function(event) {
            this[propName] = event.detail.value;
        }
    }

    async handleRatesRefresh() {
        try {
            await refreshApex(this.wiredRates);
        } catch (error) {
            this.showError(error);
        }
    }

    async handleCurrenciesRefresh() {
        try {
            await refreshApex(this.wiredCurrencies);
            await refreshApex(this.wiredRates);
        } catch (error) {
            this.showError(error);
        }
    }

    showError(error) {
        LightningToast.show(
            {
                label: error.body.message,
                message: "Press refresh button to try again",
                mode: "sticky",
                variant: "error",
            }, this
        );
    }
}