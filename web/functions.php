<?php
	header('Content-Type: application/json; charset=utf-8');

	if ( isset( $_GET['function'] ) ){

		require_once("conn.php");

		$function = $_GET['function'];
		$noRows = "Es wurde kein Eintrag in der Datenbank gefunden.";
		$limit = 10;
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

		switch($function){
			case "all":

				$query = mysqli_query($conn, "select * from data order by tstamp desc;");
				getJSONArray($query);
				break;

			default: break;
		}
	}