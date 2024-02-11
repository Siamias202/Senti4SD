#!/bin/bash
SCRIPTDIR=$(dirname "$0")
echo $SCRIPTDIR

if [ -z "$1" ]; then
    echo "Usage: classificationTask.sh 'input_folder' ['outputPredictions.csv']"
else
    input_folder="$1"
    output_file="$SCRIPTDIR/${2:-outputPredictions.csv}"

    if [ ! -d "$input_folder" ]; then
        echo "Folder $input_folder not found!"
    else
        # Create an empty output file if it doesn't exist
        touch "$output_file"

        for csv_file in "$input_folder"/output_chunk_*.csv; do
            if [ -f "$csv_file" ]; then
                echo "Processing $csv_file"

                # Extract features and perform classification for each CSV file
                java -jar "$SCRIPTDIR/Senti4SD-fast.jar" -F A -i "$csv_file" -W "$SCRIPTDIR/dsm.bin" -oc "$SCRIPTDIR/extractedFeatures.csv" -vd 600
                Rscript "$SCRIPTDIR/classification.R" "$SCRIPTDIR/extractedFeatures.csv" "$SCRIPTDIR/predictions_temp.csv"
                rm "$SCRIPTDIR/extractedFeatures.csv"
                
                # Append the output to the final output file
                cat "$SCRIPTDIR/predictions_temp.csv" >> "$output_file"
                rm "$SCRIPTDIR/predictions_temp.csv"
            fi
        done

        # Sort the final output file by the "Row" column
        sort -t, -k1,1 -o "$output_file" "$output_file"

        echo "Output appended and sorted in $output_file"
    fi
fi
