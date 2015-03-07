csvkit
========================================================
transition: rotate
author: Matt Pettis
date: 2015-03-07

<h1>Data^3 Conference</h1>
<br/>

email: matthew.pettis@gmail.com

github: https://github.com/mpettis/csvkit_talk




How I feel about new tools...
========================================================

<br/>
![xkcd](img/regular_expressions.png)


Problems with CSV
========================================================
incremental: true

<br/>
- Reading them at all.
- Dealing with lots of them, same format, many files.
- Blank cells when I was told that all cells would have values.
    - So, people lying to me.
- Missing header line when expected, or a header line when not expected.
- Not the same number of cells in a row as there are in the header.
- Improperly escaped commas or double-quotes
- Wrong kind of line ending for my OS



Why Not Excel?
========================================================
incremental: true

- Because it makes me feel like this:
![zoolander](img/zoolander-computer-de.jpg)



Why Not Excel?
========================================================
incremental: true

- Well, you can; most people do.
- It is the right tool for some jobs.
- But some things can be done better...
    - Automation
    - Reproducible Research -- not manually changing raw data.
- Let's look at some examples...



Tools to use in conjunction
========================================================
incremental: true

- `python`: This toolkit is written in it, and can drop you into the interactive shell.
- `cat`, `echo`, `head`, `tail`, `less` : Dump contents of files and variables to your screen
- `grep`, `sed`, `awk`, `perl` : filtering/munging on a line-by-line basis.  Are their own programming language in their own right.
- Control structures (`for`, `while`) : Allow you to apply your commands one at a time to each CSV file.
- ... and many more.



Summary
========================================================
incremental: true

- csvkit and other command-line tools can make inspecting CSV files stay lightweight.
- Works well with the Unix utility piping philosophy.
- Some validation checks can be automated.
- Treating a csv as a SQL table and applying SQL against it if you are into that sort of thing.
- Transforming input and output formats can be made easier.  More examples at the github page.
- Munging data with tools rather than by hand makes for easier auditing and reproducible research.



Questions and Thank You!
========================================================
<br/>

Matt Pettis matthew.pettis@gmail.com

This presentation, examples, and data: https://github.com/mpettis/csvkit_talk

Resources:
- csvkit : csvkit.readthedocs.org
- _Data Science at the Command Line_, Jeroen Janssens

![qrcode](img/qr-code-github.png)
