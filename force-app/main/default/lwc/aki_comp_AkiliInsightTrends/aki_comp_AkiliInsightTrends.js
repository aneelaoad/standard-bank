import { LightningElement, api, wire, track } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSnoozedInsights from '@salesforce/apex/AKI_COMP_InsightTrends.getSnoozedInsights';
import getOpportunityState from '@salesforce/apex/AKI_COMP_InsightTrends.getOpportunityState';
import getInsightsPerClient from '@salesforce/apex/AKI_COMP_InsightTrends.getInsightsPerClient';
import getValuableInsights from '@salesforce/apex/AKI_COMP_InsightTrends.getValuableInsights';
import CLIENT_URL from '@salesforce/label/c.AKI_CLIENT_URL';
import OPP_URL from '@salesforce/label/c.AKI_OPP_URL';
import VAL_URL from '@salesforce/label/c.AKI_VAL_URL';
import SNOOZE_URL from '@salesforce/label/c.AKI_SNOOZE_URL';
 
export default class aki_comp_AkiliInsightTrends extends LightningElement {
    @api oppChartConfig;
    @api snoozedChartConfig;
    @api insChartConfig;
    @api ValunvChartConfig;
    @track colours=['rgba(8,51, 151,0.95)','rgba(0, 101, 213, 0.95)','rgba(0, 151, 244, 0.95)','rgba(173, 33, 250, 0.95)','rgba(12, 13, 101, 0.95)'];
    clientURL="/lightning/r/Report/"+CLIENT_URL+"/view";
    oppURL="/lightning/r/Report/"+OPP_URL+"/view";
    valURL="/lightning/r/Report/"+VAL_URL+"/view";
    snoozeURL="/lightning/r/Report/"+SNOOZE_URL+"/view";

    dateChange()
    {
        if(this.insChart)
        {
            this.insChart.destroy();
        }
        if(this.snoozeChart)
        {
            this.snoozeChart.destroy();
        }
        if(this.oppChart)
        {
            this.oppChart.destroy();
        }
        if(this.valChart)
        {
            this.valChart.destroy();
        }
        if(this.template.querySelector('input.day_7').checked){
            this.getInsightsPerClientJS(7);
            this.getOpportunityStateJS(7);
            this.getSnoozedInsightsJS(7);
            this.getValuableInsightsJS(7);
        }
        else if(this.template.querySelector('input.day_14').checked){
            this.getInsightsPerClientJS(14);
            this.getOpportunityStateJS(14);
            this.getSnoozedInsightsJS(14);
            this.getValuableInsightsJS(14);
        }
        else{
            this.getInsightsPerClientJS(30);
            this.getOpportunityStateJS(30);
            this.getSnoozedInsightsJS(30);
            this.getValuableInsightsJS(30);
        }
    }

    getInsightsPerClientJS(dR)
    {
        getInsightsPerClient({dateRange:dR})
        .then((result)=>{
            this.error = undefined;
            this.drawInsightBar(result);
        })
        .catch((error)=>{
            this.error = error;
            this.chartConfiguration = undefined;
        })
    }

    getOpportunityStateJS(dR)
    {
        getOpportunityState({dateRange:dR})
        .then((result)=>{
            this.error = undefined;
            this.drawoppDonut(result);
        })
        .catch((error)=>{
            this.error = error;
            this.chartConfiguration = undefined;
        })
    }

    getSnoozedInsightsJS(dR)
    {
        getSnoozedInsights({dateRange:dR})
        .then((result)=>{
            this.error = undefined;
            this.drawSnoozeBar(result);
        })
        .catch((error)=>{
            this.error = error;
            this.chartConfiguration = undefined;
        })
    }

    getValuableInsightsJS(dR)
    {
        getValuableInsights({dateRange:dR})
        .then((result)=>{
            this.error = undefined;
            this.drawValUnv(result);
        })
        .catch((error)=>{
            this.error = error;
            this.chartConfiguration = undefined;
        })
    }

    drawoppDonut(oppData)
    {
        let oppStageName = [];
        let oppCount = [];
        oppData.forEach(opp => {
            oppStageName.push(opp.StageName);
            oppCount.push(opp.Total);
        });
        this.oppChartConfig = {
            type: 'bar',
            data: {
                datasets: [
                {
                    label: 'Total number of opportunities',
                    backgroundColor: this.colours,
                    data: oppCount,
                },
                ],
                labels: oppStageName,
            },
            options: { 
                scales:{
                    title:{
                        display: true,
                    },
                    yAxes:[{
                        ticks: {
                            precision:0,
                            beginAtZero: true,
                        },
                        gridLines: {
                            // zeroLineColor: '#000000',
                            // color: '#000000',
                        },
                    }],
                    xAxes:[{
                        gridLines: {
                            // zeroLineColor: '#000000',
                            // color: '#000000',
                        },
                    }],
                },
                cutoutPercentage: 70,
                // legend: {
                //     display: false,
                // },
            },
        };
        this.isChartJsInitialized = true;
        const oppctx = this.template.querySelector('canvas.oppSt').getContext('2d');
        this.oppChart = new window.Chart(oppctx, JSON.parse(JSON.stringify(this.oppChartConfig)));
    }

    drawSnoozeBar(snoozedIns)
    {
        let snCat = [];
        let snSnooze = [];
        snoozedIns.forEach(sn => {
            snCat.push(sn.Category__c);
            snSnooze.push(sn.Snoozed);
        });
        this.snoozedChartConfig = {
            type: 'doughnut',
            data: {
                datasets: [
                {
                    label: 'Snoozed',
                    backgroundColor: this.colours,
                    data: snSnooze,
                    fill: false,
                },
                ],
                labels: snCat,
            },
            options: {
                cutoutPercentage: 70,
                legend: {
                    position: 'right',
                    labels:{
                        usePointStyle: true,
                        pointStyle: 'circle',
                    }
                }
            },
        };
        this.isChartJsInitialized = true;
        const snctx = this.template.querySelector('canvas.snIns').getContext('2d');
        this.snoozeChart = new window.Chart(snctx, JSON.parse(JSON.stringify(this.snoozedChartConfig)));
    }

    drawInsightBar(Ins)
    {  
        this.insChartConfig=null;
        let insClient = [];
        let insCount = [];
        Ins.forEach(insi => {
            insClient.push(insi.Name);
            insCount.push(insi.InsightPerClient);
        });
        this.insChartConfig = {
            type: 'horizontalBar',
            data: {
                datasets: [
                {
                    label: 'Insights',
                    backgroundColor: this.colours,
                    data: insCount,
                },       
            ],
            labels: insClient,
            },
            options: {
                legend: {
                    display: false,
                },
                scales:{
                    xAxes:[{
                        ticks: {
                            precision:0,
                            beginAtZero: true,
                        },
                        gridLines: {
                            // zeroLineColor: '#000000',
                            // color: '#000000',
                        },
                    }],
                    yAxes:[{
                        stacked: false,
                        gridLines: {
                            // zeroLineColor: '#000000',
                            // color: '#000000',
                        }
                    }],
                },
            }
        };
        this.isChartJsInitialized = true;
        const insctx = this.template.querySelector('canvas.inspercli').getContext('2d');
        this.insChart = new window.Chart(insctx, JSON.parse(JSON.stringify(this.insChartConfig)));
    }

    drawValUnv(Val)
    {
        var percent;
        let insQuality = [];
        let insInsight = [];
        let insCount = [];

        Val.forEach(valins => {
            insQuality.push(valins.Status__c);
            insInsight.push(valins.id);
            insCount.push(valins.CountValue);
        });

        this.ValunvChartConfig = {
            type: 'doughnut',
            data: {
                datasets: [
                {
                    label: 'Insight',
                    backgroundColor: this.colours,
                    data: insInsight,
                    fill: false,
                },     
                ],
                labels: insQuality,
            },
            fill: false,
            options: {
                cutoutPercentage: 70,
                responsive: true,
                legend: {
                    position: 'right',
                    maxWidth: 20,
                    labels:{
                        usePointStyle: true,
                        pointStyle: 'circle',
                    }
                }
            }
        };
        this.isChartJsInitialized = true;
        const valctx = this.template.querySelector('canvas.valunv').getContext('2d');
        this.valChart = new window.Chart(valctx, JSON.parse(JSON.stringify(this.ValunvChartConfig)));
    }
 
    isChartJsInitialized;
    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }
        // load chartjs from the static resource
        Promise.all([loadScript(this, chartjs)])
            .then(() => {
                this.dateChange();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Chart',
                        message: error.message,
                        variant: 'error',
                    })
                );
            });
    }
}