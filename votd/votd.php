<?php
# This script could be a lot better, but it gets the job done.
# The $message will be the 2nd CLI argument, which should be the file.
# For example:
#
#    php votd.php tip479.html
#
# Note that the file is written to the same dir!
$file = $argv[1];

if (file_exists($file)) {
    $message = file_get_contents($file);
    $subject = "Vim of the Day";
    $mail_to = "benjam72@yahoo.com";

    # Make sure the headers are HTML compliant.
    $headers = "MIME-Version:  1.0\r\n";
    $headers .= "Content-type: text/html; charset=UTF-8\r\n";
    $headers .= "From: VOTD <votd@benjamintoll.com>\r\n";

    mail($mail_to, $subject, $message, $headers);
}
?>
