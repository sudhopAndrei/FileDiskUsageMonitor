#!/bin/bash

script_dir="$HOME/File&DiskUsageMonitor"
sessions_dir="${script_dir}/sessions"
reports_dir="${script_dir}/reports"

begin() {
    if [ ! -d "$script_dir" ]; then
        mkdir -p "$script_dir"
    fi

    if [ ! -d "$sessions_dir" ]; then
        mkdir -p "$sessions_dir"
    fi

    if [ ! -d "$reports_dir" ]; then
        mkdir -p "$reports_dir"
    fi

    echo "Directoarele necesare au fost create"
}

record_session() {
    read -p "Alege directorul: " folder

    if [ ! -d "$folder" ]; then
        echo "Directorul nu exista"
        return 1
    fi

    folder_name=$(basename "${folder}")
    folder_sesh="${sessions_dir}/${folder_name}_sessions"

    if [ ! -d "$folder_sesh" ]; then
        mkdir -p  "$folder_sesh"
    fi

    cd "$folder_sesh"
    count="$(ls -1 | wc -l)"
    count=$((count+1))
    cd ../
    sesh_file="${folder_sesh}/session_${count}.txt"
    {
        echo "$(date +%d/%m/%Y_%T)"
        echo
        echo "Files":
        ls -l "$folder"
        echo
        echo "Disk":
        df -h
    } > "$sesh_file"

    echo "Sesiunea a fost inregistrata cu succes in ${folder_sesh}"
}

compare_sessions() {
    read -p "Sesiunea 1: " file1_name
    file1="${sessions_dir}/${file1_name}"
    if [ ! -f "$file1" ]; then
        echo "Sesiunea nu exista"
        return 1
    fi

    read -p "Sesiunea 2: " file2_name
    file2="${sessions_dir}/${file2_name}"
    if [ ! -f "$file2" ]; then
        echo "Sesiunea nu exista"
        return 1
    fi

    grep -A 1000 "Files:" "$file1" | grep -B 1000 "Disk:" | grep -v "Disk:" | grep -v "Files:" > /tmp/ls1.txt
    grep -A 1000 "Files:" "$file2" | grep -B 1000 "Disk:" | grep -v "Disk:" | grep -v "Files:" > /tmp/ls2.txt

    diff -u /tmp/ls1.txt /tmp/ls2.txt > /tmp/ls_diff.txt

    grep -A 1000 "Disk:" "$file1" | grep -v "Disk:" > /tmp/df1.txt
    grep -A 1000 "Disk:" "$file2" | grep -v "Disk:" > /tmp/df2.txt

    diff -u /tmp/df1.txt /tmp/df2.txt > /tmp/df_diff.txt

    cd "${reports_dir}"
    count="$(ls -1 | wc -l)"
    count=$((count+1))
    cd ../
    report_file="${reports_dir}/report_${count}.txt"

    {
        echo "Raport intre ${file1_name} si ${file2_name}"
        echo
        echo "Modificari fisiere:"
        if [ -s /tmp/ls_diff.txt ]; then
            cat /tmp/ls_diff.txt
        else
            echo "Nu exista modificari"
        fi
        echo
        echo "Modificari spatiu:"
        if [ -s /tmp/df_diff.txt ]; then
            cat /tmp/df_diff.txt
        else
            echo "Nu exista modificari"
        fi
    } >> "$report_file"

    rm /tmp/ls1.txt /tmp/ls2.txt /tmp/df1.txt /tmp/df2.txt /tmp/ls_diff.txt /tmp/df_diff.txt

    echo "Raportul a fost generat cu succes in ${reports_dir}"
}

menu() {
    read -p "Selecteaza o optiune: " optiune

    case $optiune in
        1)
           record_session
           ;;
        2)
           compare_sessions
           ;;
        3)
           exit 0
           ;;
        *)
           echo "Optiune invalida!"
           ;;
    esac
}

begin

echo "1.) Inregistreaza sesiunea curenta"
echo "2.) Compara 2 sesiuni"
echo "3.) Iesi"

while true; do
    menu
done

exit 0
