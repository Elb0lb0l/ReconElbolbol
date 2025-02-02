#!/usr/bin/env bash

# Function to check if a command is available
check_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "$1 command not found. Please install $1."
    exit 1
  fi
}

# Display banner
check_command figlet
figlet "ReconElbolbol"

# Function to show help
show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -c <collaborator_link>  Collaborator link"
  echo "  -u <urls_file>          File with URLs"
  echo "  -s <subdomains_file>    File with subdomains"
  echo "  -a <asn>                ASN"
  echo "  -o <output_dir>         Output directory"
  echo "  -h                      Display this help message"
  exit 0
}

# Parse options
while getopts "c:u:s:a:o:h" opt; do
  case $opt in
    c) collab_link="$OPTARG" ;;
    u) urls="$OPTARG" ;;
    s) subdomains="$OPTARG" ;;
    a) asn="$OPTARG" ;;
    o) output_dir="$OPTARG" ;;
    h) show_help ;;
    *) show_help ;;
  esac
done

# Check if URLs file is provided
if [ -z "$urls" ]; then
  notify-send -u critical -t 5000 "Error" "Usage: $0 -u <file_with_urls>"
  echo "Usage: $0 -u <file_with_urls>"
  exit 1
fi

# Create output directories
mkdir -p "$output_dir/crawled" "$output_dir/filtered" "$output_dir/paramx_results" "$output_dir/js_analysis"
notify-send -u normal -t 5000 "Setup" "Output directories created"

# Process subdomains if provided
if [ -f "$subdomains" ]; then
  check_command bbot
  bbot -t $(cat "$subdomains" | tr '\n' ',' | sed 's/,$//') -f subdomain-enum -n bbotSbudomains -o . --retry-deps
  urls=$(cat bbotSbudomains/subdomains.txt "$urls" | sort -u)
fi

# Process URLs with waybackurls and save the output
check_command waybackurls
cat "$urls" | waybackurls | tee "$output_dir/way_back_all.txt"
notify-send -u normal -t 5000 "Waybackurls" "URLs processed with waybackurls"

# Process URLs with waymore and save the output
check_command waymore
cat "$urls" | waymore -mode U -oU "$output_dir/way_more_all.txt" -v
notify-send -u normal -t 5000 "Waymore" "URLs processed with waymore"

# Combine and sort unique URLs from waybackurls and waymore
cat "$output_dir/way_back_all.txt" "$output_dir/way_more_all.txt" | sort | uniq >"$output_dir/way_all.txt"

# Process the URLs with cariddi, hakrawler, and katana
check_command cariddi
cat "$output_dir/way_all.txt" | cariddi -s -e -err -info -debug -intensive | tee "$output_dir/crawled/cariddi.txt"
notify-send -u normal -t 5000 "Cariddi" "URLs processed with cariddi"

# Crawling using gospider
check_command gospider
cat "$output_dir/way_all.txt" | gospider -t 50 | grep -o 'http[^ ]*' | tee "$output_dir/crawled/gospider.txt"
notify-send -u normal -t 5000 "GoSpider" "URLs processed with gospider"

# Crawling using katana
check_command katana
cat "$output_dir/way_all.txt" | katana | grep -o 'http[^ ]*' | tee "$output_dir/crawled/katana.txt"
notify-send -u normal -t 5000 "Katana" "URLs processed with katana"

# Combine and sort unique URLs from the crawlers
cat "$output_dir/crawled/cariddi.txt" "$output_dir/crawled/gospider.txt" "$output_dir/crawled/katana.txt" | sort | uniq | tee "$output_dir/crawled/crawled.txt"
notify-send -u normal -t 5000 "Crawled" "Unique URLs combined and sorted"

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

for urls in "${!file_types[@]}"; do
  regex=${file_types[$urls]}
  cat "$output_dir/crawled/crawled.txt" | grep -E "$regex" >"$output_dir/filtered/$urls"
  notify-send -u normal -t 5000 "Filtering" "Filtered URLs saved to $urls"
done

# Run paramspider on URLs
check_command paramspider
cat "$urls" | awk -F[/:] '{print $4}' | sort -u | xargs -I{} paramspider -d {}
paramspider -l "$subdomains" | tee "$output_dir/paramspider.txt"
notify-send -u normal -t 5000 "ParamSpider" "ParamSpider analysis completed"

# Run Grep for '=' on crawled URLs
paramspider -l "$output_dir/crawled/crawled.txt" | grep -o "=" | tee "$output_dir/CrawledParam.txt"
notify-send -u normal -t 5000 "Grepped =" "Greping analysis completed"

# Collect into param_all.txt
cat "$output_dir/paramspider.txt" "$output_dir/CrawledParam.txt" | sort | uniq | tee "$output_dir/param_all.txt"
notify-send -u normal -t 5000 "ReconElbolbol" "param_all.txt is collected"

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

for urls in "${!paramx_tags[@]}"; do
  tag=${paramx_tags[$urls]}
  cat "$output_dir/param_all.txt" | paramx -rw FUZZ -tp patterns -t patterns/$tag | tee "$output_dir/paramx_results/$urls"
  notify-send -u normal -t 5000 "ParamX" "ParamX analysis for $tag completed"
done

# XSS testing
# kxss -> filtering for available characters -> kxss.txt
cat "$output_dir/paramx_results/xss.txt" | kxss | tee "$output_dir/paramx_results/kxss.txt"
# dalfox -> dalfox.txt : contains POCs for XSS
dalfox file "$output_dir/paramx_results/param_all.txt" --no-spinner --only-poc=r --ignore-return 302,404,403 --skip-bav -b "$collab_link" -w 100 | cut -d " " -f 2 > "$output_dir/paramx_results/dalfox.txt"

# Run jsleak and mantra on JavaScript files
check_command jsleak
cat "$output_dir/filtered/javascript_files.txt" | jsleak -s -l -k | tee "$output_dir/js_analysis/jsleak.txt"
notify-send -u normal -t 5000 "JsLeak" "JavaScript analysis with JsLeak completed"

check_command mantra
cat "$output_dir/filtered/javascript_files.txt" | mantra | tee "$output_dir/js_analysis/mantra.txt"
notify-send -u normal -t 5000 "Mantra" "JavaScript analysis with Mantra completed"

notify-send -u normal -t 5000 "ReconElbolbol" "Script execution completed"

# Manual tasks: Arjun for parameter discovery
mkdir -p arjun
cat "$output_dir/crawled/crawled.txt" | grep -E '\.(php|asp|jsp|aspx|cgi|pl|py|rb|html|htm)$' | tee arjun/extensioned_targets.txt
arjun -i arjun/extensioned_targets.txt -t 50 -oT arjun/arjun.txt | tee arjun/arjun_raw.txt 



# ##############Manuals####################
# arjun
# arjun  -u https://api.example.com/endpoint --include 'api_key=xxxxx'
# arjun -u https://api.example.com/endpoint --headers "Accept-Language: en-US\nCookie: null"
# arjun -> manual revision file 
# Angular js 
# Detection
# xss in angular is alot just for old versions use this 
# https://techbrunch.github.io/patt-mkdocs/XSS%20Injection/XSS%20in%20Angular/
# for i in $();do ;done 
# # 
# for i in $(cat subs);
#       do curl $i | grep "elementUrl";
# done
