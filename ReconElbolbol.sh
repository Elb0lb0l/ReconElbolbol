#!/bin/bash

# Function to check if a command is available
check_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "$1 command not found. Please install $1."
    exit 1
  fi
}

## Adding flags for : ASN , URLS , Subdomains

# Display banner
check_command figlet
figlet "ReconElbolbol"

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  notify-send -u critical -t 5000 "Error" "Usage: $0 <file_with_urls>"
  echo "Usage: $0 <file_with_urls>"
  exit 1
fi

# Function to show help
show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -c            Collaborator link"
  echo "  -u            Urls"
  echo "  -s            Subdomains"
  echo "  -asn          ASN"
  echo "  -o            output Directory"
  echo "  -h            HELP ME :O"
  exit 0
}

while getopts "c:u:s:asn:o:h" opt; do
  case $opt in
  c) collab_link="$OPTARG" ;;
  u) urls="$OPTARG" ;;
  s) subdomains="$OPTARG" ;;
  asn) asn="$OPTARG" ;;
  o) output_dir="$OPTARG" ;;
  h) show_help ;;
  *) show_help ;;
  esac
done

# Subdomains Shit
if [ -f $subdomains ]; then
  check_command bbot
  bbot -t $(cat bbotSbudomains/subdomains.txt | sed 's/\n/ , /g' | sed 's/,.$//g') -f subdomain-enum -n bbotSbudomains -o . --retry-deps
  bbotSub=
  urls=$(cat bbotSbudomains/subdomains.txt $urls | sort -u)
fi

# Create output directories
mkdir -p "$output_dir/crawled" "$output_dir/filtered" "$output_dir/paramx_results" "$output_dir/js_analysis"
notify-send -u normal -t 5000 "Setup" "Output directories created"

# Process URLs with waybackurls and save the output to way_back_all.txt
check_command waybackurls
cat "$urls" | waybackurls | tee "$output_dir/way_back_all.txt"
notify-send -u normal -t 5000 "Waybackurls" "URLs processed with waybackurls"

# Process URLs with waymore and save the output to way_more_all.txt
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
cat "$output_dir/way_all.txt" | gospider -t 50 |  grep -o 'http[^ ]*' | tee "$output_dir/crawled/gospider.txt"
notify-send -u normal -t 5000 "GoSpider" "URLs processed with gospider"

check_command katana
cat "recon_results/way_all.txt" | katana | grep -o 'http[^ ]*' | tee "recon_results/crawled/katana.txt"
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

# Run paramspider on subdomains.txt URLs
check_command paramspider
paramspider -l "bbotSbudomains/subdomains.txt"  | tee "$output_dir/paramspider.txt"
notify-send -u normal -t 5000 "ParamSpider" "ParamSpider analysis completed"

# Run Grep =  on crawled.txt urls
paramspider -l "$output_dir/crawled/crawled.txt"  | grep -o "=" |tee "$output_dir/CrawledParam.txt"
notify-send -u normal -t 5000 "Grepped =" "Greping analysis completed"

# collect into param_all.txt
cat   "$output_dir/paramspider.txt" "$output_dir/CrawledParam.txt" | sort | uniq | tee  "$output_dir/param_all.txt"
notify-send -u normal -t 5000 "recon_results/param_all.txt is collected"



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

# xss testing  
# kxss -> filtering for available characters -> kxss.txt 
cat "$output_dir/paramx_results/xss.txt" | kxss | tee "$output_dir/paramx_results/kxss.txt"
# dalfox [mode] [target] [flags]  -> dalfox.txt : contains pocs for xss 
dalfox file $output_dir/paramx_results/param_all.txt --no-spinner --only-poc=r --ignore-return 302,404,403 --skip-bav -b "$collab_link" -w 100 |  cut -d " " -f 2 > "$output_dir/paramx_results/dalfox.txt"


# Run jsleak and mantra on JavaScript files
check_command jsleak
cat "$output_dir/filtered/javascript_files.txt" | jsleak -s -l -k | tee "$output_dir/js_analysis/jsleak.txt"
notify-send -u normal -t 5000 "JsLeak" "JavaScript analysis with JsLeak completed"

check_command mantra
cat "$output_dir/filtered/javascript_files.txt" | mantra | tee "$output_dir/js_analysis/mantra.txt"
notify-send -u normal -t 5000 "Mantra" "JavaScript analysis with Mantra completed"

notify-send -u normal -t 5000 "ReconElbolbol" "Script execution completed"




# ##############Manuals####################
# arjun
# arjun  -u https://api.example.com/endpoint --include 'api_key=xxxxx'
# arjun -u https://api.example.com/endpoint --headers "Accept-Language: en-US\nCookie: null"
# arjun -> manual revision file 
mkdir -p arjun 
cat crawled.txt | grep -E '\.(php|asp|jsp|aspx|cgi|pl|py|rb|html|htm)$' | tee arjun/extensioned_targets.txt && arjun -i arjun/extensioned_targets.txt -t 50 -oT arjun/arjun.txt | tee arjun/arjun_raw.txt


# Angular js 
# Detection
# https://techbrunch.github.io/patt-mkdocs/XSS%20Injection/XSS%20in%20Angular/
