<?php
# For example:
#
#    php votd.php tip479.html
#
$file = $argv[1];
$handle = @fopen("subscribers", "r");

if (file_exists($file) && $handle) {
    $subject = "Vim of the Day";
    $message = file_get_contents($file);
    # Make sure the headers are HTML compliant.
    $headers = "MIME-Version:  1.0\r\n";
    $headers .= "Content-type: text/html; charset=UTF-8\r\n";
    $headers .= "From: VOTD <benjam72@yahoo.com>\r\n";

    while (($subscriber = fgets($handle)) !== false) {
        mail($subscriber, $subject, $message, $headers);
    }

    if (!feof($handle)) {
        echo "Error: unexpected fgets() fail\n";
    }

    fclose($handle);
}
?>
