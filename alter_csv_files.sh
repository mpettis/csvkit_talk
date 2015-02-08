#!/bin/bash

DIR_DAT=dat

    ## Make a mtcars file with missing first column
<$DIR_DAT/mtcars_001.csv sed 's/^[^,]*,//' > $DIR_DAT/mtcars_missing-first-col.csv

    ## Make a file that has double quotes removed and commas added where there are spaces
<$DIR_DAT/mtcars_001.csv sed -e 's/"//g' -e 's/ /,/g' > $DIR_DAT/mtcars_too-many-fields.csv

    ## Make a mtcars file that has same cols but in different column order
<dat/mtcars_001.csv perl -a -F, -nle 'print join(",", @F[(1,0,3,2,11,5,6,7,8,9,10,4)]);' > $DIR_DAT/mtcars_col-order-shuffle.csv

    ## Make file that has some data missing
<$DIR_DAT/mtcars_001.csv sed '5s/[^,]//g' > $DIR_DAT/mtcars_blank-out-row.csv
<$DIR_DAT/mtcars_001.csv sed -e '5s/,[^,],/,,/1' -e '8s/,[^,],/,,/2' -e '2s/,[^,],/,,/3' -e '4s/^[^,]*,/,/' > $DIR_DAT/mtcars_blank-select_cells.csv

    ## Make a file that has pipes for delimiters
<$DIR_DAT/mtcars_001.csv sed 's/,/|/g' > $DIR_DAT/mtcars_pipes.csv

    # Make a file that has tabs for delimiters
<$DIR_DAT/mtcars_001.csv tr ',' '\t' > $DIR_DAT/mtcars_tabs.csv

    # Get a json file
curl https://api.github.com/repos/onyxfish/csvkit/issues?state=open > dat/issues.json

    # Create a sqlite database
sed '1d' $DIR_DAT/mtcars_001.csv > $DIR_DAT/mtcars_noheader.csv
rm $DIR_DAT/mtcars.db
sqlite3 $DIR_DAT/mtcars.db ".read genDb.sql"

