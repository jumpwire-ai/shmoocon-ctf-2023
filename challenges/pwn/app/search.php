<?php
function blacklist($data)
{
    $data = str_replace("-", "", $data);                            //Strip out –.
    $data = str_replace('/*', '', $data);                       //strip out /*
    $data = str_replace('*/', '', $data);                       //strip out */
    $data = str_replace(';', '', $data);                       //strip out ;
    $data = preg_replace('/ +/s', ' ', $data); // strip multi whitespace
    //$data = preg_replace('/union select/si', '', $data);         // Strip out union select

    return $data;
}

if($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_REQUEST["title"])) {

    $title = $_REQUEST["title"];

    $db = new PDO("sqlite:/db.sqlite");

    $data = blacklist($title);

    $sql = "SELECT Name FROM Track WHERE Name LIKE '%" . $data . "%'";

    $recordset = $db->query($sql);

    if(!$recordset) {
        die("<font color=\"red\">Incorrect syntax detected!</font>");
    }

    $data = $recordset->fetchAll();

    if(count($data) > 0) {
        echo "<h3>Results:</h3><ul>";
        for($i = 0; $i < count($data); ++$i) {
            $name = $data[$i]['Name'];
            echo "<li>$name</li>";
        }
        echo "</ul>";
    } else {
        echo "The song does not exist in our database!";
    }

    $db = null;
}
?>
