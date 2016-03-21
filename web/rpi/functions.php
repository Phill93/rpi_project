<?php
	header('Content-Type: application/json; charset=utf-8');

	if ( isset( $_GET['function'] ) ){

		require_once("conn.php");

		$function = $_GET['function'];
		$noRows = "Es wurde kein Eintrag in der Datenbank gefunden.";
		$limit = 2;

		if (!$conn->set_charset('utf8')) {
			printf("Error loading character set utf8: %s\n", $conn->error);
			exit;
		}

		function getJSONArray($query){

			if( mysqli_num_rows($query) ){

				while ($fetched = mysqli_fetch_assoc($query)) {
					$data[] = array(
						'id' => $fetched['id'],
						'tstamp' => $fetched['tstamp'],
						'temp' => $fetched['temp'],
						'hum' => $fetched['hum']
					);
				}
			}
			else{
				$data[] = array('noEntry' => "true");
			}
			echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
		}

		function prepareStatement($conn, $query, $params, $values, $getResult, $array){
			$stmt = $conn->prepare($query);
			$paramString = "";
			$valueString = "";

			//echo "bind_param(".$paramString.");";

			if($array == true){
				for($i = 0; $i < count($params); $i++){
					$paramString .= $params[$i];
				}
				switch ( count($values) ) {
					case 1:
						$stmt->bind_param( $paramString, $values[0] );
						break;
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
		}

		switch($function){
			case "all":

				$query = mysqli_query($conn, "select * from data;");
				getJSONArray($query);
				break;
			case "show":

				if ( isset( $_GET['limit'] ) && $_GET['limit']>=2 && isset( $_GET['type'] ) ){
					$limit = $_GET['limit'];
					$type = $_GET['type'];

					switch($type){
						case "init":
							if( isset( $_GET['month'] ) ){
								$month = $_GET['month'];
								$query = "select * from data where month(tstamp) = ? order by tstamp limit ?;";
								$params[] = "i";
								$params[] = "i";

								$values[] = $month;
								$values[] = $limit;
							}
							break;
						case "live":
							if( isset( $_GET['tstamp'] ) ){
								$tstamp = $_GET['tstamp'];
								$query = "select * from data where tstamp > ? limit ?;";

								$params[] = "s";
								//$params[] = "i";
								$params[] = "i";

								$values[] = $tstamp;
								//$values[] = $month;
								$values[] = $limit;
							}
					}

					//var_dump( prepareStatement($conn, $query, $params, $values, true, true) );
					
					getJSONArray( prepareStatement($conn, $query, $params, $values, true, true) );
				}
				break;
			case "getAverages":
				if( isset( $_GET['month'] ) ){
					$months = array();
					$month = $_GET['month'];

					$distinctDays = mysqli_query($conn, "select distinct day(tstamp) as tstamp from data order by day(tstamp) asc;");
					$distinctMonths = mysqli_query($conn, "select distinct month(tstamp) as tstamp from data order by month(tstamp) asc;");

					if( mysqli_num_rows($distinctMonths) ){
						while ($fetched = mysqli_fetch_assoc($distinctMonths)) {
							array_push($months, $fetched['tstamp'] );
						}
					}
					
					if ( in_array($month, $months) ){
						if( mysqli_num_rows($distinctDays) ){

							$tstamps = array();

							while ($fetched = mysqli_fetch_assoc($distinctDays)) {
								array_push($tstamps, $fetched['tstamp'] );
							}
							
							foreach ($tstamps as $tstamp) {

								$sql = "select id, tstamp, avg(temp) as temp, avg(hum) as hum from data where day(tstamp) = ? and month(tstamp) = ?;";
								$params[0] = "i";
								$params[1] = "i";

								$values[0] = $tstamp;
								$values[1] = $month;

								$query = prepareStatement($conn, $sql, $params, $values, true, true);

								if( mysqli_num_rows($query) ){

									while ($fetched = mysqli_fetch_assoc($query)) {
										if( $fetched['id'] !== null ){
											$data[] = array(
												'id' => $fetched['id'],
												'tstamp' => $fetched['tstamp'],
												'temp' => $fetched['temp'],
												'hum' => $fetched['hum']
											);
										}
									}
								}
								else{
									$data[] = array('noEntry' => "true");
								}
							}
							echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
						}
					}
					else{
						echo "Monat nicht vorhanden";
					}
				}

				/*if( mysqli_num_rows($distinctDays) ){

					$tstamps = array();

					while ($fetched = mysqli_fetch_assoc($distinctDays)) {
						array_push($tstamps, $fetched['tstamp'] );
					}
					
					foreach ($tstamps as $tstamp) {
						$sql = "select id, tstamp, avg(temp) as temp, avg(hum) as hum from data where day(tstamp) = ? and month(tstamp) = ?;";
						$params[] = "i";
						$params[] = "i";

						$values[] = $tstamp;
						$values[] = $month;


						$query = prepareStatement($conn, $sql, $params, $tstamp, true, true);

						if( mysqli_num_rows($query) ){

							while ($fetched = mysqli_fetch_assoc($query)) {
								$data[] = array(
									'id' => $fetched['id'],
									'tstamp' => $fetched['tstamp'],
									'temp' => $fetched['temp'],
									'hum' => $fetched['hum']
								);
							}
						}
						else{
							$data[] = array('noEntry' => "true");
						}
					}
					echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
				}*/
				
				break;
			case "last":
				$query = mysqli_query($conn, "select * from data order by tstamp desc limit 1;");
				getJSONArray($query);
				break;

			case "insert":
				$tempValue = rand(0, 38);
				$humValue = rand(20, 80);
				$query = mysqli_query($conn, "insert into data(temp, hum) values($tempValue, $humValue);");
				//getJSONArray($query);
				break;

			default: break;
		}
	}