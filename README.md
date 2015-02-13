# csvkit_talk

Big set of examples (with data!) on how to use [csvkit](https://csvkit.readthedocs.org/en/0.9.0/index.html).


# Introduction
[csvkit](https://csvkit.readthedocs.org/en/0.9.0/index.html) is a great toolkit to help people deal with CSV files.  In particular:

* How to format CSV files into nice table-looking output without leaving the comfort of the command line.
* How to check columns in your files for missing values and mins/maxes/means/modes in a CSV file.
* How to get files from other formats into CSV, and how to project CSV files into other formats.
* How to stack CSV files into one single file.
* How to select certain columns of the file, or certain rows based on filtering critera.
* How to treat a CSV file as a database table and issue SQL against it.

I made this repository to be a self-contained set of csvkit examples that you
can test csvkit tools against.  It assumes you have the following:

* csvkit tools installed.
* A bash command prompt with common tools, like `ls`, `cat`, `less`, `head`, and others.

You can run the examples below from a command prompt rooted in this repository's top-level directory, which will contain `dat`.



# On why this is important

If you deal with data long enough, you will come to find that more time than
you anticipated gets spent in wraingling data, rather than actually analyzing
the data for the meaningful things you want out of it.  Careless, or at least
undocumented, data cleaning can come back to bite you.  Did you see a bad value
and change it?  Or remove the value?  Or remove the line?  If you did any of
these things, did you record exactly how you changed the data somewhere?  You
will find that these questions will inconveniently pop up, and by
inconveniently, I mean usually many weeks after you have done any such cleaning
and way past when you remember exactly what you did.

This is why programmatic processing of data, versus changing data in files by
hand with no way of auditing the change, is a bad practice.  In the best of
worlds, you get perfect data and unicorns and rainbows.  Second best is to be
able to figure out what is wrong with the data and push back on your providers
of said data to fix it to the unicorn and rainbows state.

The most common reality is that you get the data that you get, and you need to
use it immediately, but will have to go back sometime in the future and argue
with the data provider about the data problems.  If you hand-edit data, and
don't keep originals, it will be very hard to trace what happened.  Sure, if
you keep originals, and only edit copies, it can still have problems.  Can you
recall why you editied a value?  Or why you changed it to the value you did?
Or, if you are on a team, exactly who made the edit even?

Programmatic changes, when done right, can be better.  You make cleaned copies
of files, but all cleaning changes are documented as code, and you need to
document your code as to why it is making the change it is.  That way, you
should have collected in one spot all of the things that take the data from
original to clean in one place, and documented explanations along side the
cleaning code.

To that end, command-line tools, which can be run in batch, that aid you in
transporting, viewing, analyzing, and converting in a programmatic way help you
to actually execute this best practice.  csvkit is a set of tools in that process.



# Data sets
The `dat/` directory contains a number of datasets.  I'll try to describe most of them.

* `mtcars_0<nn>.csv` set of identical csv files that all have information about
  cars.  I'll refer to all of these identical copies as `mtcars` below, as
  there will be varitions on this one main dataset for illustrative purposes.
* `mtcars_blank-out-row.csv` Same as `mtcars`, but with one row having all of
  its values removed.
* `mtcars_blank-select_cells.csv`.  Same as `mtcars`, but with a few select
  cells blanked out.
* `mtcars_col-order-shuffle.csv` Same as `mtcars`, but the column order is not
  the same.
* `mtcars_missing-first-col.csv` Same as `mtcars`, but the first column is
  removed.
* `mtcars_noheader.csv` Same as `mtcars`, but the header is removed.
* `mtcars_pipes.csv` Same as `mtcars`, but not a CSV, as I've replaced the
  comma separators with the `|` character.
* `mtcars_tabs.csv` Same as `mtcars`, but not a CSV, as I've replaced the
  comma separators with the tab character.
* `mtcars_too-many-fields.csv`.  Gotten by taking `mtcars`, removing all of the
  double-quotes, and replacing all spaces with commas.  Effectively makes the
  CSV file look like it has more columns in most of the rows than what the
  header would indicate.
* `transposed_mtcars.csv` `mtcars`, but rows and columns transposed.
* `wide_flights_dest_month.csv`  A subset of the `flights` dataset, built for
  `R` testing.  Used as an example of a wide dataset.  Found here: https://github.com/hadley/nycflights13
* `wide_mtcars.csv` Redundant with `transposed_mtcars.csv`.  Didn't realize
  I had this twice.  One of these will be removed in the future.
* `xlsx_mtcars.xlsx` An Excel file which contains `mtcars` data.  Used to
  illustrate extracting CSV info from an Excel file.
* `issues.json` A json file.  Very wide.  Likely find a better one.
* `join_<n>.csv` A simple set of files with same columns and somewhat
  intersecting rows.  Used to illustrate `csvjoin`.
* `long_flights.csv` A long dataset for illustrative purposes.
* `mtcars.db` A sqlite database to illustrate interactions of these tools with
  a simple database.


# Examples

The most common way to look at CSV files is to open them with Excel.  This is
perfectly acceptable if you have Excel (or equivalent app), and you have to
look at one or just a few files, and you ultimately want to save that CSV into
a spreadsheet program and make other columns or information derived off of the
original data.

But sometimes opening in Excel is just too heavyweight of a solution, or doing
so might not help you anwer some other questions about the file that are easier
done with csvkit and other command line tools.  We'll look at what some of
those questions might be.

## Inspection

First, an easy one.  Let's say you want to just look at one of the CSV files.
You could open the file in Excel.  Or you could look at the raw data:

The convention here is that `$` is the terminal prompt, followed by the
command, followed by an empty line, followed by the command output, or at least
the first few lines of the output.

```
$ cat dat/mtcars_001.csv

"name","mpg","cyl","disp","hp","drat","wt","qsec","vs","am","gear","carb"
"Mazda RX4",21,6,160,110,3.9,2.62,16.46,0,1,4,4
"Mazda RX4 Wag",21,6,160,110,3.9,2.875,17.02,0,1,4,4
"Datsun 710",22.8,4,108,93,3.85,2.32,18.61,1,1,4,1
...
```

That's not really an improvement over Excel.  But you do get to see the raw,
underlying data.  We can do a bit better with `csvlook`:

```
$ csvlook dat/mtcars_001.csv

|----------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  name                | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|----------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4           | 21   | 6   | 160   | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  Mazda RX4 Wag       | 21   | 6   | 160   | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|  Datsun 710          | 22.8 | 4   | 108   | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
...
```


That is an improvement over the raw output, but it may just seem minimalistic.
Why not just do Excel?  Well, a few pros to this way:

* You don't have to open Excel at all, which can take time, or you might not
  have the app handily installed where you are (like, say at a terminal with no
  GUI).
* You can quickly copy and paste this into an email, format with a monospace
  font, and show in a minimalistic but decent way, what was in the file.

Do you miss having the numbers on the left in Excel?  You can get that back
too, with the `-l` switch:

```
$ csvlook -l dat/mtcars_001.csv

|--------------+---------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  line_number | name                | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|--------------+---------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  1           | Mazda RX4           | 21   | 6   | 160   | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  2           | Mazda RX4 Wag       | 21   | 6   | 160   | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|  3           | Datsun 710          | 22.8 | 4   | 108   | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
...
```

Still, it seems I'm trying to sell you on a scooter when you have a racecar
like Excel handy....

## Combining files

So, now say you don't just have one file, but a bunch of files that should have
identical columns.  You'd like to look at them too.  But opening each file
individually in Excel seems like real drudgery.  `csvstack` with `csvlook` can
fix that (with the `less` tool thrown in there to help page through rows):

```
$ csvstack dat/mtcars_0*.csv | csvlook | less

|----------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  name                | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|----------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4           | 21   | 6   | 160   | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  Mazda RX4 Wag       | 21   | 6   | 160   | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|  Datsun 710          | 22.8 | 4   | 108   | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
|  Hornet 4 Drive      | 21.4 | 6   | 258   | 110 | 3.08 | 3.215 | 19.44 | 1  | 0  | 3    | 1     |
|  Hornet Sportabout   | 18.7 | 8   | 360   | 175 | 3.15 | 3.44  | 17.02 | 0  | 0  | 3    | 2     |
|  Valiant             | 18.1 | 6   | 225   | 105 | 2.76 | 3.46  | 20.22 | 1  | 0  | 3    | 1     |
|  Duster 360          | 14.3 | 8   | 360   | 245 | 3.21 | 3.57  | 15.84 | 0  | 0  | 3    | 4     |
...
```

The way `csvstack` works is that it just concatenates all of the rows from all
of the files provided into one big output file.  But it keeps only one header,
not copying each header in the middle of the output.  So it works the way you
want it to.  In this example, I specified `dat/mtcars*0*.csv`, which is file
wildcard globbing.  It will get all files in the `dat/` directory that start
with `mtcars`, has a `0` in the name, and ends with `.csv`.  I could make
a simpler one that replaces the first star with an underscore, but it is
messing up my editor's intellisense stuff.  So I'm using this formulation.  But
you can make your own.

You can pipe the `csvstack` output right to file if you want.  In this case,
I pipe it into `csvlook` because I just want to see it.

And you say, "Well, that's nice, but now I don't know where each row came
from!"  Well, you can fix that too with the `--filenames` switch:

```
$ csvstack --filenames dat/mtcars_0*.csv | csvlook | less

|-----------------+---------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  group          | name                | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|-----------------+---------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  mtcars_001.csv | Mazda RX4           | 21   | 6   | 160   | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  mtcars_001.csv | Mazda RX4 Wag       | 21   | 6   | 160   | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|  mtcars_001.csv | Datsun 710          | 22.8 | 4   | 108   | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
|  mtcars_001.csv | Hornet 4 Drive      | 21.4 | 6   | 258   | 110 | 3.08 | 3.215 | 19.44 | 1  | 0  | 3    | 1     |
|  mtcars_001.csv | Hornet Sportabout   | 18.7 | 8   | 360   | 175 | 3.15 | 3.44  | 17.02 | 0  | 0  | 3    | 2     |
|  mtcars_001.csv | Valiant             | 18.1 | 6   | 225   | 105 | 2.76 | 3.46  | 20.22 | 1  | 0  | 3    | 1     |
|  mtcars_001.csv | Duster 360          | 14.3 | 8   | 360   | 245 | 3.21 | 3.57  | 15.84 | 0  | 0  | 3    | 4     |
...
```

So the output will prepend the filename that the row came from.

## Validation

This all helps with checking data by looking at it (and, to boot, we have a way
of putting a bunch of files together that have identical column structure).
But much of the time what we'd like to do is have some way to inspect the data
for bad conditions that we'd like to detect, because the data is too big to
eyeball such a check.

This is where `csvstat` can come in handy.  It can check for some very common
conditions about the columns of data you'd like to know about.  For example,
perhaps you know that none of the columns should have missing data.  You can
check that as:

```
$ csvstat --nulls dat/mtcars_001.csv

  1. name: False
  2. mpg: False
  3. cyl: False
  4. disp: False
  5. hp: False
  6. drat: False
  7. wt: False
  8. qsec: False
  9. vs: False
 10. am: False
 11. gear: False
 12. carb: False
```

The `--nulls` switch tells `csvstat` to check to see if each column has any
null values.  If a column has one or more empty values, the column will return
`True`, otherwise, if all rows in a column have values, it returns `False`.  In
this case, no columns have missing data.

Here's an example that does:

```
$ csvstat --nulls dat/mtcars_blank-select_cells.csv

  1. name: True
  2. mpg: False
  3. cyl: True
  4. disp: False
  5. hp: False
  6. drat: False
  7. wt: False
  8. qsec: False
  9. vs: True
 10. am: False
 11. gear: True
 12. carb: False
```


Let's take a peek:

```
$ csvlook dat/mtcars_blank-select_cells.csv

|----------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  name                | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|----------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4           | 21   | 6   | 160   | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  |      | 4     |
|  Mazda RX4 Wag       | 21   | 6   | 160   | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|                      | 22.8 | 4   | 108   | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
|  Hornet 4 Drive      | 21.4 |     | 258   | 110 | 3.08 | 3.215 | 19.44 | 1  | 0  | 3    | 1     |
|  Hornet Sportabout   | 18.7 | 8   | 360   | 175 | 3.15 | 3.44  | 17.02 | 0  | 0  | 3    | 2     |
|  Valiant             | 18.1 | 6   | 225   | 105 | 2.76 | 3.46  | 20.22 | 1  | 0  | 3    | 1     |
|  Duster 360          | 14.3 | 8   | 360   | 245 | 3.21 | 3.57  | 15.84 |    | 0  | 3    | 4     |
...
```

Sure enough, you can pick out some blank cells.  You, as a user, have to know
if a column having missing values is acceptable or not.

Other stat include `--min` and `--max`.  I like to use these when I know the
range of values I should get.  For `--min`, I usually use that if I know there
should be no `0` values.  I use `--max` when I know what the largest thing
should be, and any errors that are a misplaced decimal will give me an
order-of-magnigude error that I can quickly spot.

```
$ csvstat --max dat/mtcars_001.csv

  1. name: Volvo 142E
  2. mpg: 33.9
  3. cyl: 8
  4. disp: 472.0
  5. hp: 335
  6. drat: 4.93
  7. wt: 5.424
  8. qsec: 22.9
  9. vs: 1
 10. am: 1
 11. gear: 5
 12. carb: 8
```

If `mpg` was, say, `339`, I'd guess we are dealing with super-efficient cars,
or someone made a decimal error.

Other common errors is that a row can have a different number of columns than
what the header would indicate.  This can often happen with incorrect quoting
of column values that have commas (if your field has commas, you need to
surround that whole field in double-quotes), or fields that have double-quotes
as actual strings in the field didn't have them properly escaped.  What happens
then is that the thing that reads the file will shove fields to incorrect
columns in those problem rows.

We can detect when a row doesn't match up with the number of columns the file's
header dictates with the `csvclean` utility.  Let's try this utility on a file
that has problems:

```
$ csvclean -n dat/mtcars_too-many-fields.csv

Line 1: Expected 12 columns, found 13 columns
Line 2: Expected 12 columns, found 14 columns
Line 3: Expected 12 columns, found 13 columns
Line 4: Expected 12 columns, found 14 columns
```

Here, the `-n` switch tells `csvclean` to output it's informatin back to the
terminal.

For this file, the `mtcars` file had all of it's double-quotes stripped out and
spaces replaced with commas.  So names that had 2 or more space-separated words
in them had those spaces turned into commas and, with no double-quotes to quote
the whole thing, the CSV interpretation is that those two or more words turned
into two or more columns.  Which doesn't macth the number of colums based on
the comma-separated headers.

The nice thing about this utility is that, without the `-n` switch, what it
will do to a file is to process the file, put all of the good lines into a file
with the same basename, but the `.csv` part turned into `_out.csv` The
errors will be written to a `_err.csv` file.  So this way you can easily
inspect the errors, and also get an output file that is in good shape, but with
the bad rows removed.

```
$ csvclean dat/mtcars_too-many-fields.csv
31 errors logged to dat/mtcars_too-many-fields_err.csv

$ head dat/mtcars_too-many-fields_out.csv
name,mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb
Valiant,18.1,6,225,105,2.76,3.46,20.22,1,0,3,1

$ head dat/mtcars_too-many-fields_err.csv
line_number,msg,name,mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb
1,"Expected 12 columns, found 13 columns",Mazda,RX4,21,6,160,110,3.9,2.62,16.46,0,1,4,4
2,"Expected 12 columns, found 14 columns",Mazda,RX4,Wag,21,6,160,110,3.9,2.875,17.02,0,1,4,4
3,"Expected 12 columns, found 13 columns",Datsun,710,22.8,4,108,93,3.85,2.32,18.61,1,1,4,1
...
```

Here, just one row made it through.  That's because the `Valiant` name only had
one name, and the others had 2 or three space-separated names, and those names
looked like columns to the parser.

## Importing and Exporting

Not all data comes to you in CSV form, and not all people want CSV files
returned to them.  Here are some examples of getting and producing non-CSV
files.

### Excel to CSV conversion

Getting data out of an Excel file is very easy.  It is really easy if the data
in the sheet you want is rectangular and starts in the A1 column.  Here's an
example:

```
$ in2csv --sheet "mtcars-s1" dat/xlsx_mtcars.xlsx

name,mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb
Mazda RX4,21,6,160,110,3.9,2.62,16.46,0,1,4,4
Mazda RX4 Wag,21,6,160,110,3.9,2.875,17.02,0,1,4,4
Datsun 710,22.8,4,108,93,3.85,2.32,18.61,1,1,4,1
...
```

Here I knew the sheet name, and am showing the raw output.  Obviously, you
could pipe this through `csvlook` for a nicer formatting.

Be careful if the data doesn't start in cell A1.  In the same file, the
following sheet has data starting in cell B2:

```
$ in2csv --sheet "mtcars-s2" dat/xlsx_mtcars.xlsx

,,,,,,,,,,,,
,name,mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb
,Mazda RX4,21,6,160,110,3.9,2.62,16.46,0,1,4,4
,Mazda RX4 Wag,21,6,160,110,3.9,2.875,17.02,0,1,4,4
,Datsun 710,22.8,4,108,93,3.85,2.32,18.61,1,1,4,1
...
```

Note the first column that is just a row of commas, and the first line of each
row starts with a comma.  This is what happens when your data doesn't start in
A1.  But those problems can be fixed with other command line tools.



### Alternate delimiters

There are files that are close kin of CSV files.  They difference is that they
don't use commas as field separators, but other characters.  Common ones are
semi-colons, pipes (`|`), and tab characters.  With the `-d` switch, you can
specify what that seperator character is:

Pipes:

```
$ head dat/mtcars_pipes.csv

"name"|"mpg"|"cyl"|"disp"|"hp"|"drat"|"wt"|"qsec"|"vs"|"am"|"gear"|"carb"
"Mazda RX4"|21|6|160|110|3.9|2.62|16.46|0|1|4|4
"Mazda RX4 Wag"|21|6|160|110|3.9|2.875|17.02|0|1|4|4
"Datsun 710"|22.8|4|108|93|3.85|2.32|18.61|1|1|4|1
"Hornet 4 Drive"|21.4|6|258|110|3.08|3.215|19.44|1|0|3|1
"Hornet Sportabout"|18.7|8|360|175|3.15|3.44|17.02|0|0|3|2
"Valiant"|18.1|6|225|105|2.76|3.46|20.22|1|0|3|1
"Duster 360"|14.3|8|360|245|3.21|3.57|15.84|0|0|3|4
"Merc 240D"|24.4|4|146.7|62|3.69|3.19|20|1|0|4|2
"Merc 230"|22.8|4|140.8|95|3.92|3.15|22.9|1|0|4|2



$ in2csv -d\| dat/mtcars_pipes.csv | head

name,mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb
Mazda RX4,21.0,6,160.0,110,3.9,2.62,16.46,0,1,4,4
Mazda RX4 Wag,21.0,6,160.0,110,3.9,2.875,17.02,0,1,4,4
Datsun 710,22.8,4,108.0,93,3.85,2.32,18.61,1,1,4,1
Hornet 4 Drive,21.4,6,258.0,110,3.08,3.215,19.44,1,0,3,1
Hornet Sportabout,18.7,8,360.0,175,3.15,3.44,17.02,0,0,3,2
Valiant,18.1,6,225.0,105,2.76,3.46,20.22,1,0,3,1
Duster 360,14.3,8,360.0,245,3.21,3.57,15.84,0,0,3,4
Merc 240D,24.4,4,146.7,62,3.69,3.19,20.0,1,0,4,2
Merc 230,22.8,4,140.8,95,3.92,3.15,22.9,1,0,4,2
```


Tabs (weird white spacing is tabs):

```
$ head dat/mtcars_tabs.csv

"name"	"mpg"	"cyl"	"disp"	"hp"	"drat"	"wt"	"qsec"	"vs"	"am"	"gear"	"carb"
"Mazda RX4"	21	6	160	110	3.9	2.62	16.46	0	1	4	4
"Mazda RX4 Wag"	21	6	160	110	3.9	2.875	17.02	0	1	4	4
"Datsun 710"	22.8	4	108	93	3.85	2.32	18.61	1	1	4	1
"Hornet 4 Drive"	21.4	6	258	110	3.08	3.215	19.44	1	0	3	1
"Hornet Sportabout"	18.7	8	360	175	3.15	3.44	17.02	0	0	3	2
"Valiant"	18.1	6	225	105	2.76	3.46	20.22	1	0	3	1
"Duster 360"	14.3	8	360	245	3.21	3.57	15.84	0	0	3	4
"Merc 240D"	24.4	4	146.7	62	3.69	3.19	20	1	0	4	2
"Merc 230"	22.8	4	140.8	95	3.92	3.15	22.9	1	0	4	2



$ in2csv -t dat/mtcars_tabs.csv | head

name,mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb
Mazda RX4,21.0,6,160.0,110,3.9,2.62,16.46,0,1,4,4
Mazda RX4 Wag,21.0,6,160.0,110,3.9,2.875,17.02,0,1,4,4
Datsun 710,22.8,4,108.0,93,3.85,2.32,18.61,1,1,4,1
Hornet 4 Drive,21.4,6,258.0,110,3.08,3.215,19.44,1,0,3,1
Hornet Sportabout,18.7,8,360.0,175,3.15,3.44,17.02,0,0,3,2
Valiant,18.1,6,225.0,105,2.76,3.46,20.22,1,0,3,1
Duster 360,14.3,8,360.0,245,3.21,3.57,15.84,0,0,3,4
Merc 240D,24.4,4,146.7,62,3.69,3.19,20.0,1,0,4,2
Merc 230,22.8,4,140.8,95,3.92,3.15,22.9,1,0,4,2
```

You can output CSV files to these formats in a similar way, with `csvformat`:

```
$ csvformat -D\| dat/mtcars_001.csv | head

name|mpg|cyl|disp|hp|drat|wt|qsec|vs|am|gear|carb
Mazda RX4|21|6|160|110|3.9|2.62|16.46|0|1|4|4
Mazda RX4 Wag|21|6|160|110|3.9|2.875|17.02|0|1|4|4
Datsun 710|22.8|4|108|93|3.85|2.32|18.61|1|1|4|1
Hornet 4 Drive|21.4|6|258|110|3.08|3.215|19.44|1|0|3|1
Hornet Sportabout|18.7|8|360|175|3.15|3.44|17.02|0|0|3|2
Valiant|18.1|6|225|105|2.76|3.46|20.22|1|0|3|1
Duster 360|14.3|8|360|245|3.21|3.57|15.84|0|0|3|4
Merc 240D|24.4|4|146.7|62|3.69|3.19|20|1|0|4|2
Merc 230|22.8|4|140.8|95|3.92|3.15|22.9|1|0|4|2



$ csvformat -T dat/mtcars_001.csv | head

name	mpg	cyl	disp	hp	drat	wt	qsec	vs	am	gear	carb
Mazda RX4	21	6	160	110	3.9	2.62	16.46	0	1	4	4
Mazda RX4 Wag	21	6	160	110	3.9	2.875	17.02	0	1	4	4
Datsun 710	22.8	4	108	93	3.85	2.32	18.61	1	1	4	1
Hornet 4 Drive	21.4	6	258	110	3.08	3.215	19.44	1	0	3	1
Hornet Sportabout	18.7	8	360	175	3.15	3.44	17.02	0	0	3	2
Valiant	18.1	6	225	105	2.76	3.46	20.22	1	0	3	1
Duster 360	14.3	8	360	245	3.21	3.57	15.84	0	0	3	4
Merc 240D	24.4	4	146.7	62	3.69	3.19	20	1	0	4	2
Merc 230	22.8	4	140.8	95	3.92	3.15	22.9	1	0	4	2
```

You can output CSV to json with `csvjson`:

```
$ csvjson -i 4 dat/mtcars_001.csv | head
[
    {
        "name": "Mazda RX4",
        "mpg": "21",
        "cyl": "6",
        "disp": "160",
        "hp": "110",
        "drat": "3.9",
        "wt": "2.62",
        "qsec": "16.46",
```

## Bash analogs: csvcut, csvgrep, csvsort

These 3 utilities have analogs in the bash utilities `cut`, `grep`, and `sort`.
The original utilites aren't quite what is wanted, because these bash utilites
don't natively have the concept of a header row, and so treat the header row as
if it was just another data row.  So these utilities come in...  We'll do some
abbreviated examples.

```
    # csvcut: show the column name to index map
$ csvcut -n dat/mtcars_001.csv

  1: name
  2: mpg
  3: cyl
  4: disp
  5: hp
  6: drat
  7: wt
  8: qsec
  9: vs
 10: am
 11: gear
 12: carb


    # cut by index number
$ csvcut -c1,11 dat/mtcars_001.csv | head -4 | csvlook

|----------------+-------|
|  name          | gear  |
|----------------+-------|
|  Mazda RX4     | 4     |
|  Mazda RX4 Wag | 4     |
|  Datsun 710    | 4     |
|----------------+-------|

    # cut by name
$ csvcut -c "name,gear" dat/mtcars_001.csv | head -4 | csvlook

|----------------+-------|
|  name          | gear  |
|----------------+-------|
|  Mazda RX4     | 4     |
|  Mazda RX4 Wag | 4     |
|  Datsun 710    | 4     |
|----------------+-------|


    # grep by pure substring
$ csvgrep -c name -m "azd" dat/mtcars_001.csv | csvlook

|----------------+-----+-----+------+-----+------+-------+-------+----+----+------+-------|
|  name          | mpg | cyl | disp | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|----------------+-----+-----+------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4     | 21  | 6   | 160  | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  Mazda RX4 Wag | 21  | 6   | 160  | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|----------------+-----+-----+------+-----+------+-------+-------+----+----+------+-------|



    # grep by pattern
    # This pattern says "all rows where 'a' is the second letter in the name column
$ csvgrep -c name -r "^.a" dat/mtcars_001.csv | csvlook

|---------------------+------+-----+------+-----+------+-------+-------+----+----+------+-------|
|  name               | mpg  | cyl | disp | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|---------------------+------+-----+------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4          | 21   | 6   | 160  | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  Mazda RX4 Wag      | 21   | 6   | 160  | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|  Datsun 710         | 22.8 | 4   | 108  | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
|  Valiant            | 18.1 | 6   | 225  | 105 | 2.76 | 3.46  | 20.22 | 1  | 0  | 3    | 1     |
|  Cadillac Fleetwood | 10.4 | 8   | 472  | 205 | 2.93 | 5.25  | 17.98 | 0  | 0  | 3    | 4     |
|  Camaro Z28         | 13.3 | 8   | 350  | 245 | 3.73 | 3.84  | 15.41 | 0  | 0  | 3    | 4     |
|  Maserati Bora      | 15   | 8   | 301  | 335 | 3.54 | 3.57  | 14.6  | 0  | 1  | 5    | 8     |
|---------------------+------+-----+------+-----+------+-------+-------+----+----+------+-------|

    # sort
    # original order
$ head -4 dat/mtcars_001.csv | csvlook

|----------------+------+-----+------+-----+------+-------+-------+----+----+------+-------|
|  name          | mpg  | cyl | disp | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|----------------+------+-----+------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4     | 21   | 6   | 160  | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  Mazda RX4 Wag | 21   | 6   | 160  | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|  Datsun 710    | 22.8 | 4   | 108  | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
|----------------+------+-----+------+-----+------+-------+-------+----+----+------+-------|

    # after sorting by name
$ csvsort -c name dat/mtcars_001.csv | head -4 | csvlook

|---------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  name               | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|---------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  AMC Javelin        | 15.2 | 8   | 304.0 | 150 | 3.15 | 3.435 | 17.3  | 0  | 0  | 3    | 2     |
|  Cadillac Fleetwood | 10.4 | 8   | 472.0 | 205 | 2.93 | 5.25  | 17.98 | 0  | 0  | 3    | 4     |
|  Camaro Z28         | 13.3 | 8   | 350.0 | 245 | 3.73 | 3.84  | 15.41 | 0  | 0  | 3    | 4     |
|---------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
```



## Chaining together in a pipeline

These tools read from stdin and write to stdout by design, so that they may
work and play with some of the other command-line tools.  You can start to
piece together some really powerful checks by using other bash tools:

Note: the '>' are not part of the command -- those come from bash knowing that
the command hasn't been ended, so waits for you to enter a complete command.
Like the `$` sign, you need to remove them before copy and pasting them into
a shell.

Here is an easy way to just look at a set of first lines of files.  If you
expect them to all have the same header, then all of these columns should have
identical values.

```
$ for f in $(ls dat/mtcars_00*.csv); do
>     head -1 $f
> done | csvlook -H

|----------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
|  column1 | column2 | column3 | column4 | column5 | column6 | column7 | column8 | column9 | column10 | column11 | column12  |
|----------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|----------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
```

Throw in a known file that lacks a header.

`gshuf` is the GNU shuffle (`shuf`) utility.  Used here so that the rows are
shuffled, and the one bad line probably doesn't show up at the bottom always.

```
$ for f in $(ls dat/mtcars_00*.csv dat/mtcars_noheader.csv | gshuf); do
>     head -1 $f
> done | csvlook -H
|------------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
|  column1   | column2 | column3 | column4 | column5 | column6 | column7 | column8 | column9 | column10 | column11 | column12  |
|------------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  Mazda RX4 | 21      | 6       | 160     | 110     | 3.9     | 2.62    | 16.46   | 0       | 1        | 4        | 4         |
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name      | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|------------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
```



Scan for headers that might be out of order:

```
$ for f in $(ls dat/mtcars_00*.csv dat/mtcars_col-order-shuffle.csv | gshuf); do
>     head -1 $f
> done | csvlook -H

|----------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
|  column1 | column2 | column3 | column4 | column5 | column6 | column7 | column8 | column9 | column10 | column11 | column12  |
|----------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|  mpg     | name    | disp    | cyl     | carb    | drat    | wt      | qsec    | vs      | am       | gear     | hp        |
|  name    | mpg     | cyl     | disp    | hp      | drat    | wt      | qsec    | vs      | am       | gear     | carb      |
|----------+---------+---------+---------+---------+---------+---------+---------+---------+----------+----------+-----------|
```


An alternate way that doesn't use csvkit.  This will grab all of the headers,
and then count up the number of times that particular header (as an ordered
string) occurrs in the files.  If all of the headers are the same, there will
be one line with just that count of headers.  If there is more than one header,
the unique header strings and counts will be shown:

```
$ for f in $(ls dat/mtcars_00*.csv dat/mtcars_col-order-shuffle.csv | gshuf); do
>     head -1 $f
> done | sort | uniq -c
   1 "mpg","name","disp","cyl","carb","drat","wt","qsec","vs","am","gear","hp"
   9 "name","mpg","cyl","disp","hp","drat","wt","qsec","vs","am","gear","carb"
```

Note here that one header sequence occurred 9 times, and one time the top line
header string occurred.


This is a nice command that loops over files, and then echos the filename and
then a quick peek at the top rows of each named file.  This is a nice skeleton
if you want multiple operations on the same file, with outputs, all grouped
together.

```
$ for f in $(ls dat/mtcars_00*.csv dat/mtcars_blank-select_cells.csv dat/mtcars_blank-out-row.csv dat/mtcars_noheader.csv | gshuf); do
>     echo
>     echo
>     echo "-----"
>     echo "file: " $f
>     echo
>     head $f | csvlook
> done | less


-----
file:  dat/mtcars_009.csv

|--------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  name              | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|--------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4         | 21   | 6   | 160   | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  Mazda RX4 Wag     | 21   | 6   | 160   | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
...
```


## SQL utilities

SQL is a major other way of getting at and storing data.  csvkit allows you to
do some nice things with SQL, such as:

* Issue a `select` statement against a database and return the result set as
  CSV format
* Treat a CSV file *as if* it were a table in a database, and issue SQL against
  it.
* Insert CSV file data into a table in a database.
* Generate `CREATE` statements for a CSV table base on inferred information
  about the CSV column names and types.


### Issue selects against a database
You will need to have this installed on your system to perform these
commands.

csvkit supports multiple databases to query against.  We'll use sqlite as an
example.

In `dat/mtcars.db` there is a table called `mtcarstbl`.  This is just the
`mtcars` CSV file already loaded into that table on this database.

Issuing a select statement is easy, once you have the connection string to the
database:

```
$ sql2csv --db "sqlite:///dat/mtcars.db" --query "select * from mtcarstbl" | head | csvlook

|--------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  name              | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|--------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4         | 21   | 6   | 160   | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  Mazda RX4 Wag     | 21   | 6   | 160   | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|  Datsun 710        | 22.8 | 4   | 108   | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
|  Hornet 4 Drive    | 21.4 | 6   | 258   | 110 | 3.08 | 3.215 | 19.44 | 1  | 0  | 3    | 1     |
|  Hornet Sportabout | 18.7 | 8   | 360   | 175 | 3.15 | 3.44  | 17.02 | 0  | 0  | 3    | 2     |
|  Valiant           | 18.1 | 6   | 225   | 105 | 2.76 | 3.46  | 20.22 | 1  | 0  | 3    | 1     |
|  Duster 360        | 14.3 | 8   | 360   | 245 | 3.21 | 3.57  | 15.84 | 0  | 0  | 3    | 4     |
|  Merc 240D         | 24.4 | 4   | 146.7 | 62  | 3.69 | 3.19  | 20    | 1  | 0  | 4    | 2     |
|  Merc 230          | 22.8 | 4   | 140.8 | 95  | 3.92 | 3.15  | 22.9  | 1  | 0  | 4    | 2     |
|--------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
```

### Treat a CSV file as if it were a database table
csvkit can make an in-memory database on the fly, and you can use this to treat
a CSV file as if it were a table in that database.  Which means you can issue
SQL against it, and all of the power that that entails.  Here we just compute
the mean of the `mpg` column for illustration.

```
$ csvsql --query "select avg(mpg) as mean_mpg from mtcars_001" dat/mtcars_001.csv

mean_mpg
20.090625
```


### Insert into a database

The `test` table doesn't exist in this database prior to issuing the `--insert`
statement.  After that, the data is inserted, and you can query it.

```
$ csvsql --db "sqlite:///dat/mtcars.db" --table "test" --insert dat/mtcars_001.csv

$ sql2csv --db "sqlite:///dat/mtcars.db" --query "select * from test" | head | csvlook

|--------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  name              | mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs | am | gear | carb  |
|--------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
|  Mazda RX4         | 21.0 | 6   | 160.0 | 110 | 3.9  | 2.62  | 16.46 | 0  | 1  | 4    | 4     |
|  Mazda RX4 Wag     | 21.0 | 6   | 160.0 | 110 | 3.9  | 2.875 | 17.02 | 0  | 1  | 4    | 4     |
|  Datsun 710        | 22.8 | 4   | 108.0 | 93  | 3.85 | 2.32  | 18.61 | 1  | 1  | 4    | 1     |
|  Hornet 4 Drive    | 21.4 | 6   | 258.0 | 110 | 3.08 | 3.215 | 19.44 | 1  | 0  | 3    | 1     |
|  Hornet Sportabout | 18.7 | 8   | 360.0 | 175 | 3.15 | 3.44  | 17.02 | 0  | 0  | 3    | 2     |
|  Valiant           | 18.1 | 6   | 225.0 | 105 | 2.76 | 3.46  | 20.22 | 1  | 0  | 3    | 1     |
|  Duster 360        | 14.3 | 8   | 360.0 | 245 | 3.21 | 3.57  | 15.84 | 0  | 0  | 3    | 4     |
|  Merc 240D         | 24.4 | 4   | 146.7 | 62  | 3.69 | 3.19  | 20.0  | 1  | 0  | 4    | 2     |
|  Merc 230          | 22.8 | 4   | 140.8 | 95  | 3.92 | 3.15  | 22.9  | 1  | 0  | 4    | 2     |
|--------------------+------+-----+-------+-----+------+-------+-------+----+----+------+-------|
```



### Generate CREATE statements
csvkit can make a really good stab at `CREATE` statement for your database of
choice based on column names and values.  Here's an example:

```
$ csvsql -i oracle --table mtcars dat/mtcars_001.csv

CREATE TABLE mtcars (
	name VARCHAR2(19 CHAR) NOT NULL,
	mpg FLOAT NOT NULL,
	cyl INTEGER NOT NULL,
	disp FLOAT NOT NULL,
	hp INTEGER NOT NULL,
	drat FLOAT NOT NULL,
	wt FLOAT NOT NULL,
	qsec FLOAT NOT NULL,
	vs INTEGER NOT NULL,
	am INTEGER NOT NULL,
	gear INTEGER NOT NULL,
	carb INTEGER NOT NULL
);
```






# Summary

Using csvkit, along with other command-line tools, can help you efficiently
deal with a lot of questions and problems with data, especially CSV-centric
data.  Many function you might run to Excel (or open-source software) for can
be done more efficiently with these tools.




