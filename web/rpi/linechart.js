function formatDate(date){
	if(date){
		var dates = date.split(/[- :]/);
		return dates[2]+"."+dates[1];
		//return dates[2]+"."+dates[1]+"."+dates[0]+" um "+dates[3]+":"+dates[4]+":"+dates[5];
	}
}

$(document).ready(function(){

	var temps = [];
	var hums = [];

	$.get("functions.php",{ function: "all"	}, function(data){
		$.each(data, function(i){
			//$("p").append("<pre>"+data[i].id+" "+formatDate(data[i].tstamp)+" "+data[i].temp+"°C "+data[i].hum+"%</pre>");
			temps.push({ x: formatDate(data[i].tstamp), y: data[i].temp });
			hums.push({ x: formatDate(data[i].tstamp), y: data[i].hum });

			//$("p#temps").append("<pre>"+temps[i].x+", "+temps[i].y+"</pre>");
			//$("p#hums").append("<pre>"+hums[i].x+", "+hums[i].y+"</pre>");
		});
	});

	for (var i = 0; i < temps.length; i++){
		console.log(formatDate(data[i].tstamp)+", "+fdata[i].temp);
	}

	var lineThickness = 1;
	var chart = new CanvasJS.Chart("chartContainer", {

		title:{
			text: "Site Traffic",
			fontSize: 30,
			fontFamily: "Verdana,sans-serif",
			fontWeight: "lighter",
			padding: 10
		},
		animationEnabled: false,
		axisX:{
			lineThickness: 1,
			lineColor: "black",
			titleFontWeight: "lighter",
			titleFontColor: "black",
			tickThickness: 1,

			margin: 0,

			titleFontColor: "black",

			valueFormatString: "DD.MM"

		},
		toolTip:{
			shared:true
		},
		axisY: {
			lineColor: "black",
			lineThickness: 1,
			gridColor: "Black",
			gridThickness: 1,

			tickColor: "black",
			tickThickness: 1
		},
		data: [
			{
				type: "line",
				lineThickness: lineThickness,
				name: "Celsius",
				color: "#F08080",
				dataPoints: temps
				/*dataPoints: [
					{ x: new Date(2010,0,3), y: 650.6 },
					{ x: new Date(2010,0,5), y: 700 },
					{ x: new Date(2010,0,7), y: 710 },
					{ x: new Date(2010,0,9), y: 658 },
					{ x: new Date(2010,0,11), y: 734 },
					{ x: new Date(2010,0,13), y: 963 },
					{ x: new Date(2010,0,15), y: 847 },
					{ x: new Date(2010,0,17), y: 853 },
					{ x: new Date(2010,0,19), y: 869 },
					{ x: new Date(2010,0,21), y: 943 },
					{ x: new Date(2010,0,23), y: 970 }
				]*/
			},
			{
				type: "line",
				lineThickness: lineThickness,
				name: "Luftfeuchtigkeit",
				color: "#20B2AA",
				dataPoints: hums
				/*dataPoints: [
					{ x: new Date(2010,0,3), y: 510 },
					{ x: new Date(2010,0,5), y: 560 },
					{ x: new Date(2010,0,7), y: 540 },
					{ x: new Date(2010,0,9), y: 558 },
					{ x: new Date(2010,0,11), y: 544 },
					{ x: new Date(2010,0,13), y: 693 },
					{ x: new Date(2010,0,15), y: 657 },
					{ x: new Date(2010,0,17), y: 663 },
					{ x: new Date(2010,0,19), y: 639 },
					{ x: new Date(2010,0,21), y: 673 },
					{ x: new Date(2010,0,23), y: 660 }
				]*/
			}
		]
	});

	chart.render();
});