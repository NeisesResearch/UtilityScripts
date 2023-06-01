#!/bin/bash

# set the results directory
if [ -z "results_directory" ]; then
    :
else
    results_directory="/mnt/continteg/SimulationResults"
fi

# create the final log file
datetime=$(date +"%d%b%Y")
logfile="${datetime}-ContinuousIntegrationResults.txt"

declare -A build_results
declare -A introspection_results
error_logs=""

# iterate over files in results directory
for file in "$results_directory"/*; do
    filename=$(basename -- "$file")
    
    # check if file is of the form "result-[version]"
    if [[ $filename =~ ^result-(.*)$ ]]; then
        version=${BASH_REMATCH[1]}
        
        # check if file contains the string "Overall Appraisal Result"
        if grep -q "Overall Appraisal Result" "$file"; then
            introspection_results[$version]="X"
        fi
    fi

    # check if file is of the form "buildlog-[version]"
    if [[ $filename =~ ^buildlog-(.*)$ ]]; then
        version=${BASH_REMATCH[1]}
        
        # check if file contains "ERROR:", "error:", or "FAILED:"
        error_log=$(grep -Ei -m 1 "ERROR:|error:|FAILED:" "$file")
        if [ -n "$error_log" ]; then
            error_logs+="$version: $error_log\n"
        else
            build_results[$version]="X"
        fi
    fi
done

# write headers
printf "%-15s %-15s %-15s\n" "Version" "Build" "Introspection" >> $logfile

# get list of all versions
versions=(${!build_results[@]} ${!introspection_results[@]})
# remove duplicate versions
versions=($(printf "%s\n" "${versions[@]}" | sort -V | uniq))

# write results
for version in "${versions[@]}"; do
    printf "%-15s %-15s %-15s\n" "$version" "${build_results[$version]:-}" "${introspection_results[$version]:-}" >> $logfile
done

# append error logs
if [ -n "$error_logs" ]; then
    echo -e "\nError Logs:\n$error_logs" >> $logfile
fi

# Specify your email address
email="neisesmichael@gmail.com"

if [[ -f $logfile ]]; then
    # If the file exists, send it by email
    echo "Report file has been generated." | mutt -s "Report for today" -a $logfile -- $email
else
    # If the file does not exist, send a notification email
    echo "No report was generated today." | mutt -s "Report for today" -- $email
fi

