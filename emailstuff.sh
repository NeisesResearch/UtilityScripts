
# Specify your email address
email="neisesmichael@gmail.com"

if [[ -f $logfile ]]; then
    # If the file exists, send it by email
    echo "Report file has been generated." | mutt -s "Report for today" -a $logfile -- $email
else
    # If the file does not exist, send a notification email
    echo "No report was generated today." | mutt -s "Report for today" -- $email
fi

