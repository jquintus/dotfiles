#!/usr/bin/env bash

#############################################################################
# LaunchDarkly Parse Variations
#
# Description:
#   Parses LaunchDarkly feature flag JSON files to extract and format
#   targeting rules. Outputs unique conditions showing context kinds,
#   attributes, and their values in a human-readable format.
#
# Usage:
#   launch_darkly_parse_variations.sh <json_file>
#
# Arguments:
#   json_file - Path to a LaunchDarkly feature flag JSON file
#
# Output:
#   Sorted unique list of rule conditions in the format:
#   "contextKind.attribute in (value1, value2, ...)"
#
# Example:
#   launch_darkly_parse_variations.sh feature_flags.json
#
# Author: jq
#############################################################################

set -euo pipefail

# Display usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <json_file>

Parses LaunchDarkly feature flag JSON files to extract and format targeting rules.

Arguments:
  json_file    Path to a LaunchDarkly feature flag JSON file

Options:
  -h, --help   Display this help message

Example:
  $(basename "$0") feature_flags.json

Output format:
  contextKind.attribute in (value1, value2, ...)

EOF
    exit 0
}

# Check for help flag
if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
fi

# Validate arguments
if [[ $# -eq 0 ]]; then
    echo "Error: No input file specified" >&2
    echo "" >&2
    usage
fi

if [[ $# -gt 1 ]]; then
    echo "Error: Too many arguments" >&2
    echo "" >&2
    usage
fi

JSON_FILE="$1"

# Validate input file exists and is readable
if [[ ! -f "$JSON_FILE" ]]; then
    echo "Error: File '$JSON_FILE' does not exist" >&2
    exit 1
fi

if [[ ! -r "$JSON_FILE" ]]; then
    echo "Error: File '$JSON_FILE' is not readable" >&2
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is required but not installed" >&2
    echo "Install it with: brew install jq (macOS) or apt-get install jq (Linux)" >&2
    exit 1
fi

# Parse the JSON file and extract rule variations
jq -r '
.rules[]
| [.clauses[] 
  | "\(.contextKind).\(.attribute) in (\(.values | join(", ")))"]
| join(" and ")
' "$JSON_FILE" \
| sort -u
