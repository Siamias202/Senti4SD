#!/bin/bash
SCRIPTDIR=$(dirname "$0")
echo $SCRIPTDIR

if [ -z "$1" ]; then
    echo "Usage: classificationTask.sh input_folder [output_folder]"
else
    input_folder="$1"
    output_folder="$SCRIPTDIR/output_folder"

    if [ ! -d "$input_folder" ]; then
        echo "Input folder $input_folder not found!"
    else
        if [ -n "$2" ]; then
            output_folder="$2"
        fi

        # Create the output folder if it doesn't exist
        mkdir -p "$output_folder"

        for input_file in "$input_folder"/*.csv; do
            if [ -f "$input_file" ]; then
                output_file="$output_folder/$(basename "$input_file" .csv)_predictions.csv"

                java -jar "$SCRIPTDIR/Senti4SD-fast.jar" -F A -i "$input_file" -W "$SCRIPTDIR/dsm.bin" -oc "$SCRIPTDIR/extractedFeatures.csv" -vd 600

                Rscript "$SCRIPTDIR/classification.R" "$SCRIPTDIR/extractedFeatures.csv" "$output_file"

                rm "$SCRIPTDIR/extractedFeatures.csv"
            fi
        done
    fi
fi
