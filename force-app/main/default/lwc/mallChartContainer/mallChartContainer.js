import { LightningElement } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartjs from "@salesforce/resourceUrl/ChartJS";

const generateRandomNumber = () => {
  return Math.round(Math.random() * 100);
};

export default class MallChartContainer extends LightningElement {
  error;
  chart;
  chartjsInitialized = false;

  config = {
    type: "doughnut",
    data: {
      datasets: [
        {
          data: [
            generateRandomNumber(),
            generateRandomNumber(),
            generateRandomNumber(),
            generateRandomNumber()
          ],
          backgroundColor: [
            "rgb(0, 52, 167)",
            "rgb(0, 114, 206)",
            "rgb(0, 161, 224)",
            "rgb(39, 56, 81)"
          ],
          label: "Dataset 1"
        }
      ],
      labels: ["Savings", "Current", "Credit", "Other"]
    },
    options: {
      responsive: false,
      plugins: {
        legend: {
          position: "right"
        }
      },
      legend: {
        position: "right",
        align: "end",
        labels: {
          usePointStyle: true
        }
      },
      animation: {
        animateScale: true,
        animateRotate: true
      }
    }
  };

  renderedCallback() {
    if (this.chartjsInitialized) {
      return;
    }
    this.chartjsInitialized = true;

    loadScript(this, chartjs)
      .then(() => {
        const canvas = document.createElement("canvas");
        this.template.querySelector("div.chart").appendChild(canvas);
        const ctx = canvas.getContext("2d");
        this.chart = new window.Chart(ctx, this.config);
      })
      .catch((error) => {
        this.error = error;
      });
  }
}