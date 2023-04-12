<?php

if($_SERVER['REQUEST_METHOD'] === 'POST')
{
    // Get input
    $target = $_REQUEST[ 'text' ];

    // Set blacklist
    $substitutions = array(
        '&&' => '',
        ';'  => '',
    );

    // Remove any of the charactars in the array (blacklist).
    $target = str_replace( array_keys( $substitutions ), $substitutions, $target );

    // execute the ping command.
    $cmd = shell_exec( 'cowsay ' . $target );

    // Feedback for the end user
    echo "<pre>{$cmd}</pre>";
}

?>
