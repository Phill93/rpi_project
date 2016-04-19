
var file = "/weather/php/functions.php";

function getAverages(calendar, month, year){
	
	$.get(file,{ function: "averagesDays", month: month, year: year }, function(data){
		if (!data[0].noEntry){
			var averages = [];
			//alert( data[0][1] );
			$.each(data, function(i){
				averages.push({
					date: moment( data[i][0] ).subtract(1, "days").format("YYYY-MM-DD"),
					temp: data[i][1],
					hum: data[i][2]
				});
			});

			calendar.setEvents(averages);

			$(".event").click(function(){
				var date = moment( parseInt( $(this).attr("id") ) ).format("YYYY-MM-DD");

				for (var i = 0; i<averages.length; i++){
					if(averages[i].date == date){
						$("#averagePopup h2").html( moment(date).format("DD.MM.YYYY") );
						$("#averageTemp h3").html( averages[i].temp +" &deg;C ");
						$("#averageHum h3").html( averages[i].hum + " % ");
						$("#averagePopup").fadeIn(duration);
					}
				}
			});
		}
	});
}
var splineChart;
var gaugeChart;

function requestData(){
	$.get(file,{ function: "showNew"/*, value: "temps"*/ }, function(data){
		$("#liveData .liveTemp h3 span").last().html( data["temp"][1] );
		$("#liveData .liveHum h3 span").last().html( data["hum"][1] );

		//alert (gaugeChart.series[0].data[0].y);
		gaugeChart.series[0].data[0].update( data["temp"][1] );
		gaugeChart.series[1].data[0].update( data["hum"][1] );

		var tempSeries = splineChart.series[0];
		var humSeries = splineChart.series[1];
		// shift if the series is longer than 10
		shiftTemps = tempSeries.data.length > 10;
		shiftHums = humSeries.data.length > 10;
		// add points
		splineChart.series[0].addPoint(data["temp"], true, shiftTemps);
		splineChart.series[1].addPoint(data["hum"], true, shiftHums);
		// call it again after ten seconds
		setTimeout(requestData, 10000);
	});
}

function requestHourAverages(){
	$.get(file,{ function: "averagesHours" }, function(data){

		if( data[0].noEntry ){
			$("ul.averageList").html("<li class='w3-center'>Leider sind noch keine Daten vorhanden...</li>");
		}
		else{
			$("ul.averageList").empty();
			$.each(data, function(i){
				$("ul.averageList").append("<li><div class='w3-row'><div class='w3-third'>"+moment(data[i][0]).subtract(1, "hours").format("HH")+":00 Uhr</div><div class='w3-third'>"+data[i][1]+" °C</div><div class='w3-third'>"+data[i][2]+" %</div></div></li>");
			});
		}
		// call it again after one minute
		setTimeout(requestHourAverages, 60000);
	});
}

Highcharts.setOptions({
	global: { useUTC: false },
	colors: ['tomato', 'lightblue', 'transparent', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
});

function initHighChart(options){

	return new Highcharts.Chart({
		chart: {
			renderTo: options.selector,
			type: "line",
			events: {
				load: requestData
			}
		},
		credits: 'disabled',
		tooltip: { enabled: false },
		title: {
			text: options.title
		},
		xAxis: {
			type: 'datetime',
			title: {
				text: options.xTitle
			}
		},
		yAxis: {
			title: {
				text: options.yTitle
			}
		},
		series: [{
			name: options.seriesNames[0],
			data: [],
			dataLabels: {
				enabled: true,
				padding: 10,
				style: { fontSize: '1em', fontWeight: 'lighter' },
				format: '{y} °C'
			}
		},
		{
			name: options.seriesNames[1],
			data: [],
			dataLabels: {
				enabled: true,
				style: { fontSize: '1em', fontWeight: 'lighter' },
				format: '{y} %'
			}
		}]
	});
}

function initGaugeChart(options){
	return new Highcharts.Chart({
		chart: {
			type: 'solidgauge',
			renderTo: 'gaugeChart'
		},
		credits: 'disabled',
		title: {
			text: options.title,
			style: { fontSize: '24px' }
		},
		tooltip: {
			/*borderWidth: 0,
			backgroundColor: 'none',
			shadow: false,
			style: { fontSize: '16px', left: '10px', right: '10px', top: '10px', bottom: '10px'},
			useHTML: true,
			pointFormat: '<p class="w3-center" style="margin-top: 3em; font-size:2em; color: {point.color}; font-weight: bold">{point.y}</p>'*/
			enabled: false
		},
		pane: {
			startAngle: 0,
			endAngle: 360,
			background: [{
				// Track for temperature
				outerRadius: '112%',
				innerRadius: '108%',
				backgroundColor: Highcharts.getOptions().colors[2],
				borderWidth: 0
			},
			{
				// Track for humidity
				outerRadius: '108%',
				innerRadius: '100%',
				backgroundColor: Highcharts.getOptions().colors[2],
				borderWidth: 0
			}]
		},
		yAxis: {
			min: 0,
			max: 100,
			lineWidth: 0,
			tickPositions: []
		},
		plotOptions: {
			solidgauge: {
				borderWidth: '15px',
				linecap: 'round',
				stickyTracking: false
			}
		},
		series: [
			{ 	name: options.seriesNames[0],
				borderColor: Highcharts.getOptions().colors[0],
				data: [{
					color: Highcharts.getOptions().colors[0],
					radius: '112%',
					innerRadius: '112%',
					y: 0
				}],
				dataLabels: {
					enabled: true,
					borderWidth: 0,
					verticalAlign: 'bottom',
					style: { fontSize: '1.5em', fontWeight: 'lighter', color: Highcharts.getOptions().colors[0] },
					format: 'Temperatur: {y} °C'
				}
			},
			{ 	name: options.seriesNames[1],
				borderColor: Highcharts.getOptions().colors[1],
				data: [{
					color: Highcharts.getOptions().colors[1],
					radius: '100%',
					innerRadius: '100%',
					y: 0
				}],
				dataLabels: {
					enabled: true,
					borderWidth: 0,
					verticalAlign: 'top',
					style: { fontSize: '1.5em', fontWeight: 'lighter', color: Highcharts.getOptions().colors[1] },
					format: 'Luftfeuchtigkeit: {y} %'
				}
			}
		]
	});
}
var duration = 500
function showNav(){
	$(".w3-modal").fadeOut(duration);
	$("nav").fadeIn(duration);
};
function hideNav(){
	$("nav").fadeOut(duration);
}

$(document).ready(function(){

	configureMoment();

	$("div.ui-loader").remove();

	var seriesNames = ["Temperatur", "Luftfeuchtigkeit"];

	var lineOptions = {
		selector: "container",
		title: "Live-Diagramm",
		xTitle: "Datum",
		yTitle: "Wert",
		seriesNames: seriesNames
	};
	var gaugeOptions = {
		selector: "gaugeChart",
		title: "Live Data",
		seriesNames: seriesNames
	}
	splineChart = initHighChart(lineOptions);
	gaugeChart = initGaugeChart(gaugeOptions);
	requestHourAverages();

	var weekdays = moment.weekdaysShort();
	var currentDay = moment().format("DD");
	var currentMonth = moment().format("M");
	var currentYear = moment().format("YYYY");

	var calendar = $('#cal').clndr({
		template: $("#cal-template").html(),
		daysOfTheWeek: weekdays,
		clickEvents: {
			onMonthChange: function(month){

				var parameters = $("div.current-month").text().split(" ");
				getAverages( calendar, moment(month).format("M"), parameters[1] );
			},
			today: function(month){ 

			}
		},
		forceSixRows: true,
		targets: {
			nextButton: 'clndr-next-button',
			previousButton: 'clndr-previous-button',
			todayButton: 'clndr-today-button',
			day: 'day',
			empty: 'empty'
		},
		doneRendering: function() {
			$(".next-month").remove();
		},
		showAdjacentMonths: false,
		adjacentDaysChangeMonth: false,
		forceSixRows: true
	});
	getAverages( calendar, currentMonth, currentYear );

	$("body").on("swiperight", showNav);
	$("nav").on("swipeleft", hideNav);

	$(".averageContainer").click(showNav);
	$(".closeNav").click(hideNav);


	$(".liveTemp").css("background-color", Highcharts.getOptions().colors[0]).css("color", "white");
	$(".liveHum").css("background-color", Highcharts.getOptions().colors[1]);

	$("#cal div.event").click(function(){
		$(".w3-modal").fadeIn(duration);
	});
	$("i.fa-close").click(function(){
		$(this).parents(".w3-modal").fadeOut(duration);
	});
});
