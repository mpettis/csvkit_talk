-- =====================================================================
-- Table: mtcarstbl
-- =====================================================================
create table mtcarstbl (
    name text,
    mpg text,
    cyl text,
    disp text,
    hp text,
    drat text,
    wt text,
    qsec text,
    vs text,
    am text,
    gear text,
    carb text
);

--.separator ,
.mode csv
.import dat/mtcars_noheader.csv mtcarstbl

