<?php


// Outputs all the result of shellcommand "ls", and returns

exec('perl ../perl/run.pl 2>&1', $output);

echo $retval;
foreach($output as $line)
    echo $line . "\n";


?>