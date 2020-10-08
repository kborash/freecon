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
      data: ['Round 1', 'Round 2', 'Round 3', 'Round 4', 'Round 5', 'Round 6', 'Round 7', 'Round 8', 'Round 9', 'Round 10']
    },
    yAxis: {
      type: 'value',
      name: 'Price',
      position: 'middle'
    },
    series: [
      {
        name: 'Expected Values',
        type: 'line',
        step: 'end',
        data: window.game_review_chart.expected_values
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