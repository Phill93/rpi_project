<?php
  $db = mysqli_connect("localhost", "web", "web");

  if(mysqli_connect_errorno()) {
    printf("Verbindung fehlgeschlagen: %s \n", mysqli_connect_errorno());
    exit();
  }

  $query = mysqli_query($db, "SELECT temp, hum, tstamp FROM temp, hum");
  $result = mysqli_fetch_assoc($query);

  echo(json_encode($result));

  mysqli_close($db);
?>
