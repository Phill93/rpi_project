Chart.defaults.global.pointHitDetectionRadius = 1;
Chart.defaults.global.responsive = true;

function showCharts(limit, month, dataArray, colors, selectors){

	$.get("functions.php",{ function: "show", limit: limit, type:"init", month: month }, function(data){
		if (data[0].noEntry){
			alert("Keine Einträge in der Datenbank!");
			$("#lastChartId").attr("class", 0);
		}
		else{
			drawLineChart(data, dataArray, colors, selectors, false);
		}
		
	});
}

function drawLineChart(data, dataArray, colors, selectors, shiftElements){

	$.each(data, function(i){
		var date = new Date(data[i].tstamp);

		dataArray.dates.push( moment( data[i].tstamp ).format("HH.mm.ss") );
		dataArray.temps.push( parseFloat(data[i].temp) );
		dataArray.hums.push( parseFloat(data[i].hum) );

		if( shiftElements ){
			for (var i = 0; i < 1; i++){
				dataArray.dates.shift();
				dataArray.temps.shift();
				dataArray.hums.shift();
			}
		}
	});
	var test = data[data.length-1].tstamp;

	$("#lastChartId").attr("class", test).html(test);

	var tempContainer = $( selectors[0] ).get(0).getContext("2d");
	var tempChart = new Chart(tempContainer).Line( generateData(dataArray.dates, dataArray.temps, colors.temps),{
		tooltipTemplate: "Temperatur <%=label%>: <%= value %> Grad"
	});

	var humContainer = $( selectors[1] ).get(0).getContext("2d");
	var humChart = new Chart(humContainer).Line( generateData(dataArray.dates, dataArray.hums, colors.hums), {
		tooltipTemplate: "Luftfeuchtigkeit um <%=label%>: <%= value %>%"
	});

	return [tempChart, humChart];
}

function getLiveCharts(limit, month, tstamp, dataArray, colors, selectors){
	

		$.get("functions.php",{ function: "show", limit: limit, tstamp: tstamp, type: "live", month: month }, function(data){
			if (data[0].noEntry){
				$("div#status").html("Keine Einträge in der Datenbank!").removeClass("w3-green").addClass("w3-red");
				$("#lastChartId").attr("class", 0);
			}
			else{
				$("div#status").html("Status OK").addClass("w3-green");
				drawLineChart(data, dataArray, colors, selectors, true);
			}
		});
	
}

function getLiveData(selector){
	$.get("functions.php",{ function: "last" }, function(data){
		if (data[0].noEntry){
			alert("Keine weiteren Einträge in der Datenbank!");
		}
		else{
			$(selector).first().html( data[0].temp );
			$(selector).last().html( data[0].hum );
		}
	});
}
function generateData(dates, values, colors){
	var data = {
		labels: dates,
		datasets: [{
			fillColor: colors[0],
			strokeColor: colors[1],
			pointColor: "rgba(220,220,220,1)",
			pointStrokeColor: "#fff",
			pointHighlightFill: "#fff",
			pointHighlightStroke: "rgba(220,220,220,1)",
			data: values
		}]
	};
	return data;
}
var datesArray = [];
var tempsArray = [];
var humsArray = [];
var selectors = ["#tempChart", "#humChart"];

var limit = 5;

var data = {
	dates: [],
	temps: [],
	hums: []
};

var colors = {
	temps: ["tomato", "white"],
	hums: ["lightblue", "white"]
};

var parametersInit = {
	function: "show",
	limit: limit,
	type: "init"
};

var parametersLive = {
	function: "show",
	limit: limit,
	type: "live"
};
var interval;
var counter = 0;
$("button.start").click(function(){

	interval = setInterval(function(interval){

		getLiveData("#liveData h3 span");
		
		counter++;
		if( counter%3 == 0 ){
			if($("#lastChartId").attr("class") != 0){
				getLiveCharts( limit, currentMonth, $("#lastChartId").attr("class"), data, colors, selectors);
			}
		}
	}, 1000);
});

$("button.stop").click(function(){
	clearInterval(interval);
	
});
showCharts(limit, currentMonth, data, colors, selectors);