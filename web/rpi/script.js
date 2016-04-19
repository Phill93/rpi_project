$(document).ready(function(){
	
	tempsArray = [];
	humsArray = [];

	$.get("functions.php",{ function: "all"	}, function(data){
		$.each(data, function(i){
			var date = new Date(data[i].tstamp);
			tempsArray.push({ x: date, y: parseFloat(data[i].temp), localeTimeString: date.toLocaleTimeString() });
			humsArray.push({ x: date, y: parseFloat(data[i].hum), localeTimeString: date.toLocaleTimeString() });
		});
		getLineChart(tempsArray, humsArray);
		//getLiveData( getLineChart(tempsArray, humsArray) );
	});



});

function getLiveData(chart){

	$.get("functions.php",{ function: "last" }, function(data){
		$.each(data, function(i){
			var date = new Date(data[i].tstamp);
			tempsArray.push({ x: date, y: parseFloat(data[i].temp), localeTimeString: date.toLocaleTimeString() });
			humsArray.push({ x: date, y: parseFloat(data[i].hum), localeTimeString: date.toLocaleTimeString() });
		});
		getLineChart(tempsArray, humsArray);
	});
	if (dps.length >  10 ){
		dps.shift();
	}

	chart.render();
}

function getChart(){
	
}

function getLineChart(tempsArray, humsArray){
	var thickness = 1;
	var chart = new CanvasJS.Chart("chartContainer", {
		
		title:{
			text: "Übersicht",
			fontSize: 30,
			fontFamily: "Verdana,sans-serif",
			fontWeight: "lighter",
			padding: 10
		},
		animationEnabled: false,
		axisX:{
			lineThickness: thickness,
			lineColor: "black",
			titleFontWeight: "lighter",
			titleFontColor: "black",
			tickThickness: thickness,

			valueFormatString: "HH:mm",

			titleFontColor: "black"

		},
		toolTip:{
			shared: false,
			//backgroundColor: "black",
			//fontColor: "white",
			borderThickness: thickness
		},
		axisY: {
			lineColor: "black",
			lineThickness: thickness,
			gridColor: "Black",
			gridThickness: thickness,

			tickColor: "black",
			tickThickness: thickness
		},
		data: [
			{
				type: "line",
				showInLegend: true,
				toolTipContent: "{localeTimeString} Uhr<br><b>{y}°C</b>",
				lineThickness: thickness,
				name: "Temperatur",
				color: "#F08080",
				dataPoints: tempsArray
			},
			{
				type: "line",
				showInLegend: true,
				toolTipContent: "{localeTimeString} Uhr<br><b>{y}%</b>",
				lineThickness: thickness,
				name: "Luftfeuchtigkeit",
				color: "#20B2AA",
				dataPoints: humsArray
			}
		]
	});

	chart.render();
	return chart;
}