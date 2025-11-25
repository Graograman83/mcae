import { LightningElement, api, track } from 'lwc';
import ChartJs from '@salesforce/resourceUrl/ChartJs';
import { loadScript } from 'lightning/platformResourceLoader';

export default class Timeseries extends LightningElement {
    chart;

    @api
    get data() {
        return this._data;
    }
    set data(value) {
        this._data = value;
        if (this.chart) {
            this.chart.data = this.getChartData();
            this.chart.update();
        }
    }
    _data;

    colours = [
        'rgb(255,99,132)',
        'rgb(54,162,235)',
        'rgb(75,192,192)',
        'rgb(255,159,64)',
        'rgb(153,102,255)',
        'rgb(0,0,0)',
        'rgb(255,205,86)',
    ]
    
    renderedCallback() {
        if (this.chart) {
            return; // Chart already initialized
        }
        // Load the Chart.js library
        loadScript(this, ChartJs)
            .then(() => {
                this.initializeChart();
            })
            .catch(error => {
                console.error('Error loading Chart.js:', error);
            });
    }
    initializeChart() {
        const ctx = this.template.querySelector('canvas').getContext('2d');
        this.chart = new Chart(ctx, {
            type: 'line',
            data: this.getChartData(),
            options: {
                responsive: false
            }
        });
    }

    getChartData() {
        const chartData = {
            labels: this._data?.labels,
            datasets: this._data.rows && Object.entries(this._data.rows).map(([key, value], index) => ({
                label: key,
                data: value,
                backgroundColor: this.getTransparentColour(this.colours[index % this.colours.length], 0.5),
                borderColor: this.colours[index % this.colours.length]
            }))
        };
        return chartData;
    }

    getTransparentColour(rgbString, alpha) {
        const [_, r, g, b] = rgbString.match(/rgb\((\d+),(\d+),(\d+)\)/i);
        return `rgba(${r}, ${g}, ${b}, ${alpha})`;
    }
}