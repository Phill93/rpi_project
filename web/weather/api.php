<?php
  $db = mysqli_connect("localhost", "web", "web", "rpi_project");

  if(mysqli_connect_errno()) {
    printf("Verbindung fehlgeschlagen: %s \n", mysqli_connect_errno());
    exit();
  }

  $query = mysqli_query($db, "select temps.temperature as temp, hums.humidity as hum from temps, hums where temps.tstamp < current_timestamp and temps.tstamp = hums.tstamp order by temps.tstamp desc limit 1");
  $result = mysqli_fetch_assoc($query);

  echo(json_encode($result));

  mysqli_close($db);
?>
