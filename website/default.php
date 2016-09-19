<html>

<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>Congratulations! Your free website is up and running!</title>
</head>

<body bgcolor="#FCFCFC">

<p align="center">
&nbsp;</p>

<p align="center">
&nbsp;</p>
<p align="center">
&nbsp;</p>
<h1 align="center"><font face="Verdana">Congratulations!</font></h1>

<p align="center"><b><font face="Verdana" size="5">Your free website is up and running!</font></b></p>
<p align="center"><font face="Verdana">Please delete the file &quot;default.php&quot; from public_html folder</font></p>
<p align="center"><font face="Verdana">and upload your website files by using FTP or the Online File Manager.</font></p>
<div align="center">
<table border="1" id="table1" cellpadding="2">
	<tr>
		<td bgcolor="#FFFFFF">
<font face="Verdana">Below you can see your current files in public_html folder.</font>
		</td>
	</tr>
	<tr>
		<td bgcolor="#CCFFCC">
<?php
 if ($handle = opendir('.')) {
   while (false !== ($file = readdir($handle)))
      {
          if ($file != "." && $file != "..")
	  {
          	$thelist .= '- <a href="'.$file.'">'.$file.'</a><br>';
          }
       }
  closedir($handle);
  }
?>
<p><?=$thelist?></p>
</td>
	</tr>
</table>



</div>



<p>&nbsp;</p>
<p>&nbsp;</p>


<p align="center">&nbsp;</p>
<p align="center"><font face="Verdana"><a href="http://freehostingnoads.net/">Free Hosting No Ads</a>&nbsp; 
| <a href="http://t15.org/">Create a Website for Free</a></font></p>



</body>

</html>
<!--DEFAULT_WELCOME_PAGE-->
