<?php
	header('Content-Type: application/json; charset=utf-8');

	if ( isset( $_GET['function'] ) ){

		require_once("conn2.php");

		$function = $_GET['function'];
		$noRows = "Es wurde kein Eintrag in der Datenbank gefunden.";

		if( !isset( $_GET['id'] ) ){
			$id = 1;
		}
		else{
			$id = $_GET['id'];
		}

		if (!$conn->set_charset('utf8')) {
			printf("Error loading character set utf8: %s\n", $conn->error);
			exit;
		}

		function getJSONArray($query, $mode){

			if( mysqli_num_rows($query) ){
				
				switch($mode){
					case "show":
						while ($fetched = mysqli_fetch_assoc($query)) {

							$data['temp'][] = array(
								strtotime( $fetched['tstamp'] ) * 1000,
								round( floatval( $fetched['temp'] ), 2, PHP_ROUND_HALF_UP )
							);
							$data['hum'][] = array(
								strtotime( $fetched['tstamp'] ) * 1000,
								round( floatval( $fetched['hum'] ), 2, PHP_ROUND_HALF_UP )
							);

						}
						break;
					case "averages":
						while ($fetched = mysqli_fetch_assoc($query)) {
							
							$data[] = array(
								strtotime( $fetched['tstamp'] ) * 1000,
								round( floatval( $fetched['tempAverage'] ), 2, PHP_ROUND_HALF_UP ),
								round( floatval( $fetched['humAverage'] ), 2, PHP_ROUND_HALF_UP )
							);
						}
						break;
					case "sensors":
						while ($fetched = mysqli_fetch_assoc($query)) {
							
							$data[] = array(
								"id" => $fetched['id'],
								"name" => $fetched['name'],
								"description" => $fetched['description']
							);
						}
						break;
					default: break;
				}
				//$data['rows'] = array('entries' => mysqli_num_rows($query));
			}
			else{
				$data['rows'] = array('entries' => 0);
			}
			echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
		}

		function prepareStatement($conn, $query, $params, $values, $getResult){
			$stmt = $conn->prepare($query);
			$paramString = "";

			if( is_array($params) && is_array($values) ){
				foreach ($params as $param) {
					$paramString .= $param;
				}
				switch ( count($values) ) {
					case 2:
						$stmt->bind_param( $paramString, $values[0], $values[1] );
						break;
					case 3:
						$stmt->bind_param( $paramString, $values[0], $values[1], $value[2] );
						break;
					case 4:
						$stmt->bind_param( $paramString, $values[0], $values[1], $value[2], $values[3] );
						break;
					case 5:
						$stmt->bind_param( $paramString, $values[0], $values[1], $value[2], $values[3], $value[4] );
						break;
					case 6:
						$stmt->bind_param( $paramString, $values[0], $values[1], $value[2], $values[3], $value[4], $values[5] );
						break;
					default:
						break;
				}
			}
			else{
				$stmt->bind_param( $params, $values );
			}

			if( $stmt->execute() ){

				if( $getResult ){
					return $stmt->get_result();
				}
			}
			else{
				return false;
			}
			$stmt->close();
		}

		switch($function){

			case "showNew":
				$query = mysqli_query($conn, "select temps.id, temps.tstamp, temps.temperature as temp, hums.humidity as hum from temps, hums where temps.tstamp < current_timestamp and temps.tstamp = hums.tstamp order by temps.tstamp desc limit 1;");
				getJSONArray( $query, "show" );
				break;
			case "showInit":

				$query = mysqli_query($conn, "select temps.id, temps.tstamp, temps.temperature as temp, hums.humidity as hum from temps, hums where temps.tstamp = hums.tstamp order by temps.tstamp desc limit 5;");
				getJSONArray( $query, "show" );
				break;
			case "averagesDays":
				if( isset( $_GET['month'] ) && isset( $_GET['year'] ) ){

					$sql = "select * from archive_days where year(tstamp) = ? and month(tstamp) = ?;";
					$param[0] = "i";
					$param[1] = "i";

					$value[0] = $_GET['year'];
					$value[1] = $_GET['month'];

					getJSONArray( prepareStatement($conn, $sql, $param, $value, true), "averages" );
				}
				break;
			case "averagesHours":
				$date = date("Y-m-d", time());

				$query = mysqli_query($conn, "select * from archive_hours where tstamp like '$date%' order by tstamp desc;");
				getJSONArray( $query, "averages" );
				break;
			case "showSensors":
				$query = mysqli_query($conn, "select * from sensors;");
				getJSONArray( $query, "sensors" );
				break;
			case "showSpace":
				$dir =  $_SERVER['DOCUMENT_ROOT'];
				$giga = 1073741824;

				$space = [
					'dir' => $dir,
					'total' => round( floatval( disk_total_space( $dir ) / $giga ), 2, PHP_ROUND_HALF_UP ),
					'free' => round( floatval( disk_free_space( $dir ) / $giga ), 2, PHP_ROUND_HALF_UP )
				];
				$space['used'] = round( floatval( $space['total'] - $space['free'] ), 2, PHP_ROUND_HALF_UP );
				echo json_encode($space, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
				break;

			default: break;
		}
	}