#!/bin/bash

# Function to check if a command is available
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 command not found. Please install $1."
        exit 1
    fi
}

# Display banner
check_command figlet
figlet "ReconElbolbol"

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    notify-send -u critical -t 5000 "Error" "Usage: $0 <file_with_urls>"
    echo "Usage: $0 <file_with_urls>"
    exit 1
fi

# File containing URLs
file=$1

# Check if the file exists
if [ ! -f "$file" ]; then
    notify-send -u critical -t 5000 "Error" "File not found!"
    echo "File not found!"
    exit 1
fi

# Create output directories
output_dir="recon_results"
mkdir -p "$output_dir/crawled" "$output_dir/filtered" "$output_dir/paramx_results" "$output_dir/js_analysis"
notify-send -u normal -t 5000 "Setup" "Output directories created"

# Process URLs with waybackurls and save the output to way_back_all.txt
check_command waybackurls
cat "$file" | waybackurls | tee "$output_dir/way_back_all.txt"
notify-send -u normal -t 5000 "Waybackurls" "URLs processed with waybackurls"

# Process URLs with waymore and save the output to way_more_all.txt
check_command waymore
cat "$file" | waymore -mode U -oU "$output_dir/way_more_all.txt" -v
notify-send -u normal -t 5000 "Waymore" "URLs processed with waymore"

# Combine and sort unique URLs from waybackurls and waymore
cat "$output_dir/way_back_all.txt" "$output_dir/way_more_all.txt" | sort | uniq > "$output_dir/way_all.txt"

# Process the URLs with cariddi, hakrawler, and katana
check_command cariddi
cat "$output_dir/way_all.txt" | cariddi -s -e -err -info -debug -intensive | tee "$output_dir/crawled/cariddi.txt"
notify-send -u normal -t 5000 "Cariddi" "URLs processed with cariddi"

check_command hakrawler
cat "$output_dir/way_all.txt" | hakrawler | tee "$output_dir/crawled/hakrawler.txt"
notify-send -u normal -t 5000 "Hakrawler" "URLs processed with hakrawler"

check_command katana
cat "$output_dir/way_all.txt" | katana | tee "$output_dir/crawled/katana.txt"
notify-send -u normal -t 5000 "Katana" "URLs processed with katana"

# Combine and sort unique URLs from the crawlers
cat "$output_dir/crawled/cariddi.txt" "$output_dir/crawled/hakrawler.txt" "$output_dir/crawled/katana.txt" | sort | uniq | tee "$output_dir/crawled/crawled.txt"
notify-send -u normal -t 5000 "Crawling" "Unique URLs combined and sorted"

# Filter URLs by file type and save to specific files
declare -A file_types=(
    ["javascript_files.txt"]="\\.js(\\?|$)"
    ["json_files.txt"]="\\.json(\\?|$)"
    ["php_files.txt"]="\\.php(\\?|$)"
    ["aspx_files.txt"]="\\.aspx?(\\?|$)"
    ["jsp_files.txt"]="\\.jsp(\\?|$)"
    ["txt_files.txt"]="\\.txt(\\?|$)"
    ["xml_files.txt"]="\\.xml(\\?|$)"
    ["csv_files.txt"]="\\.csv(\\?|$)"
    ["env_files.txt"]="\\.env(\\?|$)"
    ["config_files.txt"]="\\.config(\\?|$)"
    ["log_files.txt"]="\\.log(\\?|$)"
    ["backup_files.txt"]="\\.bak(\\?|$)"
    ["swap_files.txt"]="\\.swp(\\?|$)"
    ["gzip_files.txt"]="\\.gz(\\?|$)"
    ["zip_files.txt"]="\\.zip(\\?|$)"
    ["tar_files.txt"]="\\.tar(\\?|$)"
    ["sql_files.txt"]="\\.sql(\\?|$)"
    ["mdb_files.txt"]="\\.mdb(\\?|$)"
    ["excel_files.txt"]="\\.xlsx?(\\?|$)"
    ["doc_files.txt"]="\\.docx?(\\?|$)"
    ["pdf_files.txt"]="\\.pdf(\\?|$)"
    ["certificate_files.txt"]="\\.cer(\\?|$)"
    ["certificate_crt_files.txt"]="\\.crt(\\?|$)"
    ["certificate_pem_files.txt"]="\\.pem(\\?|$)"
    ["private_key_files.txt"]="\\.key(\\?|$)"
)

for file in "${!file_types[@]}"; do
    regex=${file_types[$file]}
    cat "$output_dir/crawled/crawled.txt" | grep -E "$regex" > "$output_dir/filtered/$file"
    notify-send -u normal -t 5000 "Filtering" "Filtered URLs saved to $file"
done

# Run paramspider on crawled URLs
check_command paramspider
paramspider -l "$output_dir/crawled/crawled.txt" | tee "$output_dir/paramspider.txt"
notify-send -u normal -t 5000 "ParamSpider" "ParamSpider analysis completed"

# Run paramx for different tags
check_command paramx
declare -A paramx_tags=(
    ["xss.txt"]="-tag xss"
    ["sqli.txt"]="-tag sqli"
    ["lfi.txt"]="-tag lfi"
    ["rce.txt"]="-tag rce"
    ["idor.txt"]="-tag idor"
    ["ssrf.txt"]="-tag ssrf"
    ["ssti.txt"]="-tag ssti"
    ["redirect.txt"]="-tag redirect"
)

for file in "${!paramx_tags[@]}"; do
    tag=${paramx_tags[$file]}
    cat "$output_dir/paramspider.txt" | paramx $tag | tee "$output_dir/paramx_results/$file"
    notify-send -u normal -t 5000 "ParamX" "ParamX analysis for $tag completed"
done

# Run jsleak and mantra on JavaScript files
check_command jsleak
cat "$output_dir/filtered/javascript_files.txt" | jsleak -s -l -k | tee "$output_dir/js_analysis/jsleak.txt"
notify-send -u normal -t 5000 "JsLeak" "JavaScript analysis with JsLeak completed"

check_command mantra
cat "$output_dir/filtered/javascript_files.txt" | mantra | tee "$output_dir/js_analysis/mantra.txt"
notify-send -u normal -t 5000 "Mantra" "JavaScript analysis with Mantra completed"

notify-send -u normal -t 5000 "ReconElbolbol" "Script execution completed"
