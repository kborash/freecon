var echarts = require('echarts');

let chart_container = document.getElementById('expected_values_and_transactions_graph');
if (chart_container != null) {
  var myChart = echarts.init(chart_container);

  myChart.setOption({
    legend: {
      data: ['Expected Values', 'Transactions']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: Array(window.game_review_chart.rounds).fill(0).map( (ele, index) => 'Round ' + (index + 1))
    },
    yAxis: {
      type: 'value',
      name: 'Price',
      position: 'middle'
    },
    series: [
      {
        name: 'Expected Values',
        data: window.game_review_chart.expected_values,
        type: 'line',
        emphasis: {
          label: {
            show: true,
            fontWeight: 'bolder',
            backgroundColor: 'white',
            formatter: function (param) {
              return param.data;
            },
            position: 'top'
          }
        }
      },
      {
        name: 'Transactions',
        type: 'scatter',
        data: window.game_review_chart.transactions,
        symbolSize: function(data) {
          return 10 + data[2] * 5
        },
        emphasis: {
          label: {
            show: true,
            fontWeight: 'bolder',
            backgroundColor: 'white',
            formatter: function (param) {
              return param.data[2] + ' at ' + param.data[1];
            },
            position: 'top'
          }
        }
      }
    ]
  });
}