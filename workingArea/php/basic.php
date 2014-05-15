<?php

$directive = $_GET["command"];

$config = $_GET["config"];

$state = $_GET["state"];

$command = 'perl ../../scripts/' . $directive . '.pl ' . $config . ' ' . $state . ' 2>&1';

exec($command, $output);

echo $retval;
foreach($output as $line)
    echo $line . "\n";


?>