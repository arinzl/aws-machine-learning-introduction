#!/bin/bash

# Specify the output file name
output_file="ml_data.csv"

# Print the header to the CSV file
echo "x,y" > "$output_file"


for ((x = 1; x <= 15; x++)); do
    y_original=37

    random_number=$((0 + RANDOM % 100))
    
    random_variation=$(awk -v min=-5 -v max=5 -v randomvalue="$random_number" 'BEGIN{print min+randomvalue*(max-min)/100}')
    y_with_variation=$(awk -v y="$y_original" -v random="$random_variation" 'BEGIN{printf "%.1f\n", y + random}')

    echo "$x,$y_with_variation" >> "$output_file"
done




# Loop through x values from 15 to 115
for ((x = 15; x <= 115; x++)); do
    y_original=$((2 * x + 7))

    random_number=$((0 + RANDOM % 100))
    
    random_variation=$(awk -v min=-5 -v max=5 -v randomvalue="$random_number" 'BEGIN{print min+randomvalue*(max-min)/100}')
    y_with_variation=$(awk -v y="$y_original" -v random="$random_variation" 'BEGIN{printf "%.1f\n", y + random}')

    echo "$x,$y_with_variation" >> "$output_file"
done

echo "CSV file generated: $output_file"

