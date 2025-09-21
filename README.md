Sure! Here is the README for your script `ReconElbolbol.sh` using ````` for code blocks:

````markdown
# ReconElbolbol

`ReconElbolbol` is a comprehensive reconnaissance script designed to automate the process of gathering and analyzing URLs for various types of files and potential vulnerabilities. It utilizes multiple tools to collect data, filter it, and perform parameter and JavaScript analysis.

## Installation

To install all the necessary tools, run the provided `prepareElbolbol.sh` script. This script will install the tools using `pacman` for Arch-based systems and `go install` for Go-based tools.

### Prerequisites

Ensure you have Go and Python installed on your system:

- **Install Go**:
  ```bash
  sudo pacman -S go
  ```
````

- **Install Python**:
  ```bash
  sudo pacman -S python python-pip
  ```

### Installation Command

1. Save the `prepareElbolbol.sh` script.
2. Make the script executable and run it:

   ```bash
   chmod +x prepareElbolbol.sh
   ./prepareElbolbol.sh
   ```

## Usage

To use the `ReconElbolbol` script, provide it with a file containing URLs. The script will process these URLs, perform various analyses, and save the results into organized directories.

### Running the Script

1. Ensure the script is executable:

   ```bash
   chmod +x ReconElbolbol.sh
   ```

2. Run the script with the input file containing URLs:

   ```bash
   ./ReconElbolbol <file_with_urls> -o .
   ```

### Example

```bash
./ReconElbolbol all_urls.txt
```

## For easy access

```sh
sudo cp ReconElbolbol.sh /usr/bin/ReconElbolbol
```

## Tools Used

The script utilizes the following tools:

1. `figlet` - For displaying a banner.
2. `waybackurls` - For extracting URLs from the Wayback Machine.
3. `cariddi` - For intensive URL crawling.
4. `hakrawler` - For URL crawling and enumeration.
5. `katana` - For URL crawling and enumeration.
6. `paramspider` - For discovering URL parameters.
7. `paramx` - For analyzing parameters for different types of vulnerabilities.
8. `jsleak` - For analyzing JavaScript files for potential leaks.
9. `mantra` - For analyzing JavaScript files for vulnerabilities.

## Directory Structure

The script organizes the output files into the following directories:

- `recon_results`: Main output directory.
  - `crawled`: Contains outputs from the crawlers.
  - `filtered`: Contains filtered URLs by file type.
  - `paramx_results`: Contains results from ParamX analysis.
  - `js_analysis`: Contains results from JavaScript analysis.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request. For major changes, please open an issue first to discuss what you would like to change.

## Acknowledgments

Special thanks to the authors of the tools used in this script for their contributions to the cybersecurity community.

```

```
