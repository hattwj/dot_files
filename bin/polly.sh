#!/bin/bash

# AWS Polly Text-to-Speech Script
# Enhanced version with file input, validation, and cleanup

set -euo pipefail

# Default parameters
DEFAULT_VOICE="Joanna"
DEFAULT_ENGINE="neural"
DEFAULT_FORMAT="mp3"
DEFAULT_LANGUAGE="en-US"
DEFAULT_SAMPLE_RATE="24000"
DEFAULT_PROFILE="${USER}"

# Global variables for cleanup
TEMP_FILES=()
OUTPUT_FILE=""

# Cleanup function
cleanup() {
    local exit_code=$?
    echo "Cleaning up temporary files..." >&2

    # Remove temporary files
    for temp_file in "${TEMP_FILES[@]}"; do
        if [[ -f "$temp_file" ]]; then
            rm -f "$temp_file"
            echo "Removed: $temp_file" >&2
        fi
    done

    # Remove output file if it exists and we created it
    if [[ -n "$OUTPUT_FILE" && -f "$OUTPUT_FILE" ]]; then
        rm -f "$OUTPUT_FILE"
        echo "Removed: $OUTPUT_FILE" >&2
    fi

    exit $exit_code
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Help function
show_help() {
    cat << EOF
AWS Polly Text-to-Speech Script

USAGE:
    $0 [OPTIONS] [TEXT_FILE]

ARGUMENTS:
    TEXT_FILE           Path to text file to synthesize (optional)
                       If not provided, reads from stdin

OPTIONS:
    -h, --help         Show this help message
    -v, --voice VOICE  Voice ID (default: $DEFAULT_VOICE)
    -e, --engine ENGINE Engine type: neural|standard (default: $DEFAULT_ENGINE)
    -f, --format FORMAT Output format: mp3|ogg_vorbis|pcm (default: $DEFAULT_FORMAT)
    -l, --lang LANGUAGE Language code (default: $DEFAULT_LANGUAGE)
    -s, --sample-rate RATE Sample rate in Hz (default: $DEFAULT_SAMPLE_RATE)
    -p, --profile PROFILE AWS profile to use (default: $DEFAULT_PROFILE)
    -o, --output FILE  Output file path (default: temporary file)
    --no-play         Don't automatically play the audio
    --debug           Enable debug output

EXAMPLES:
    $0 textfile.txt                    # Synthesize from file
    echo "Hello world" | $0            # Synthesize from stdin
    $0 -v Matthew -e standard text.txt # Use different voice and engine
    $0 --no-play -o speech.mp3 text.txt # Save without playing

SUPPORTED VOICES:
    Neural: Joanna, Matthew, Ruth, Stephen, Amy, Emma, Brian, Arthur, etc.
    Standard: All neural voices plus additional options

EOF
}

# Input validation functions
validate_voice() {
    local voice="$1"
    # This is a basic check - AWS will validate the actual voice
    if [[ ! "$voice" =~ ^[A-Za-z]+$ ]]; then
        echo "Error: Invalid voice ID format: $voice" >&2
        return 1
    fi
}

validate_engine() {
    local engine="$1"
    case "$engine" in
        neural|standard) return 0 ;;
        *) echo "Error: Invalid engine: $engine. Must be 'neural' or 'standard'" >&2; return 1 ;;
    esac
}

validate_format() {
    local format="$1"
    case "$format" in
        mp3|ogg_vorbis|pcm) return 0 ;;
        *) echo "Error: Invalid format: $format. Must be 'mp3', 'ogg_vorbis', or 'pcm'" >&2; return 1 ;;
    esac
}

validate_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    if [[ ! -r "$file" ]]; then
        echo "Error: File not readable: $file" >&2
        return 1
    fi
    if [[ ! -s "$file" ]]; then
        echo "Error: File is empty: $file" >&2
        return 1
    fi
}

# Parse command line arguments
VOICE="$DEFAULT_VOICE"
ENGINE="$DEFAULT_ENGINE"
FORMAT="$DEFAULT_FORMAT"
LANGUAGE="$DEFAULT_LANGUAGE"
SAMPLE_RATE="$DEFAULT_SAMPLE_RATE"
PROFILE="$DEFAULT_PROFILE"
OUTPUT_FILE=""
INPUT_FILE=""
NO_PLAY=false
DEBUG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--voice)
            VOICE="$2"
            shift 2
            ;;
        -e|--engine)
            ENGINE="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -l|--lang)
            LANGUAGE="$2"
            shift 2
            ;;
        -s|--sample-rate)
            SAMPLE_RATE="$2"
            shift 2
            ;;
        -p|--profile)
            PROFILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --no-play)
            NO_PLAY=true
            shift
            ;;
        --debug)
            DEBUG=true
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
        *)
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
            else
                echo "Error: Multiple input files specified" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Enable debug mode if requested
if [[ "$DEBUG" == "true" ]]; then
    set -x
fi

# Validate parameters
validate_voice "$VOICE" || exit 1
validate_engine "$ENGINE" || exit 1
validate_format "$FORMAT" || exit 1

# Validate sample rate
if [[ ! "$SAMPLE_RATE" =~ ^[0-9]+$ ]] || [[ "$SAMPLE_RATE" -lt 8000 ]] || [[ "$SAMPLE_RATE" -gt 48000 ]]; then
    echo "Error: Invalid sample rate: $SAMPLE_RATE. Must be between 8000 and 48000 Hz" >&2
    exit 1
fi

# Handle input text
TEXT_CONTENT=""
if [[ -n "$INPUT_FILE" ]]; then
    # Validate input file
    validate_file "$INPUT_FILE" || exit 1
    TEXT_CONTENT=$(cat "$INPUT_FILE")
elif [[ ! -t 0 ]]; then
    # Read from stdin if available
    TEXT_CONTENT=$(cat)
else
    echo "Error: No input provided. Specify a file or pipe text to stdin" >&2
    echo "Use --help for usage information" >&2
    exit 1
fi

# Validate text content
if [[ -z "$TEXT_CONTENT" ]]; then
    echo "Error: No text content to synthesize" >&2
    exit 1
fi

# Text length validation (Polly has limits)
TEXT_LENGTH=${#TEXT_CONTENT}
if [[ "$TEXT_LENGTH" -gt 3000 ]]; then
    echo "Warning: Text is $TEXT_LENGTH characters. AWS Polly has a 3000 character limit for synthesize-speech" >&2
fi

# Set up output file
if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE=$(mktemp --suffix=".$FORMAT")
    TEMP_FILES+=("$OUTPUT_FILE")
    echo "Using temporary output file: $OUTPUT_FILE" >&2
fi

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI not found. Please install it first." >&2
    exit 1
fi

# Check if ffplay is available (only if we're going to play)
if [[ "$NO_PLAY" == "false" ]] && ! command -v ffplay &> /dev/null; then
    echo "Warning: ffplay not found. Audio will not be played automatically." >&2
    NO_PLAY=true
fi

# Synthesize speech
echo "Synthesizing speech with voice '$VOICE' using '$ENGINE' engine..." >&2
if ! aws --profile "$PROFILE" polly synthesize-speech \
    --engine "$ENGINE" \
    --text "$TEXT_CONTENT" \
    --output-format "$FORMAT" \
    --voice-id "$VOICE" \
    --language-code "$LANGUAGE" \
    --sample-rate "$SAMPLE_RATE" \
    "$OUTPUT_FILE"; then
    echo "Error: AWS Polly synthesis failed" >&2
    exit 1
fi

# Verify output file was created
if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "Error: Output file was not created: $OUTPUT_FILE" >&2
    exit 1
fi

echo "Speech synthesis completed: $OUTPUT_FILE" >&2

# Play audio if requested and possible
if [[ "$NO_PLAY" == "false" ]]; then
    echo "Playing audio..." >&2
    ffplay -nodisp -autoexit "$OUTPUT_FILE"
fi

# If output file was specified by user, don't clean it up
if [[ "$OUTPUT_FILE" != "${TEMP_FILES[*]}" ]]; then
    OUTPUT_FILE=""
fi

echo "Done!" >&2
