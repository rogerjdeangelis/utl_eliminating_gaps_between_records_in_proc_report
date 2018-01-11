SAS Forum: Eliminate gaps between records in proc report

see
https://communities.sas.com/t5/Base-SAS-Programming/PROC-REPORT-gap/m-p/426970

Just output a dataset from the first reort and use a dataset to remove the gap and
then either run another 'proc report' or a 'proc print'.

INPUT (proc report printer output with gaps)

                                             |  RULES                   WANT THIS
  COUNTRY_REGION   IPHONES    POP  MALE_PCT  |
                                             |               COUNTRY_REGION   IPHONES     POP   MALE_PCT
  CANADA           10K        82        26   |
  EAST                                       |  Remove gap   CANADA            10K         82         26
                   20K      19.5        54   |               EAST              20K       19.5         54
                   30k        25      16.5   |                                 30k         25       16.5
  CANADA           10K      35.5        40   |               CANADA            10K       35.5         40
  NORTH                                      |  Remove gap   NORTH             20K         29       46.5
                   20K        29      46.5   |                                 30k         81         18
                   30k        81        18   |
  CANADA           10K        49        17   |
  SOUTH                                      |  Remove gap
                   20K        43      67.5   |
                   30k      36.5        22   |


PROCESS
=======

  * create a dataset usin the proc report problem output, just add 'out=havRpt';
  proc report data=havpre nowd split='/' out=havRpt;
  cols COUNTRY_REGION IPHONES POP male_pct;
  define COUNTRY_REGION / group flow ;
  define IPHONES        / group;
  define POP            / mean;
  define male_pct       / mean;
  run;quit;

  * fix country_region;
  data havFix;
    retain cnt 0;
    set havRpt;
    by country_region;
    cnt=cnt+1;
    select;
      when (first.country_region)  country_region=scan(country_region,1,'/');
      when (cnt=2)                 country_region=scan(country_region,2,'/');
      otherwise country_region="";
    end;
    if last.country_region then cnt=0;
  run;quit;

  * just display it - could use proc print;
  proc report data=havFix nowd out=havRpt;
  cols COUNTRY_REGION IPHONES POP male_pct;
  define COUNTRY_REGION / display;
  define IPHONES        / display;
  define POP            / display;
  define male_pct       / display;
  run;quit;

OUTPUT
======

    COUNTRY_REGION      IPHONES      POP   MALE_PCT

    CANADA               10K         82         26
    EAST                 20K       19.5         54
                         30k         25       16.5
    CANADA               10K       35.5         40
    NORTH                20K         29       46.5
                         30k         81         18
    CANADA               10K         49         17
    SOUTH                20K         43       67.5
                         30k       36.5         22
    CANADA               10K       36.5         67
    WEST                 20K         45       52.5
                         30k       31.5       74.5
    MEXICO               10K       30.5         55
    EAST                 20K         17       33.5
                         30k         84       36.5
    MEXICO               10K       57.5       10.5
    NORTH                20K       75.5         46
                         30k         19         74
    ...

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data havpre;
 length country_region $32;
 call streaminit(5731);
 do country='CANADA','USA','MEXICO';
   do region="NORTH","SOUTH","EAST","WEST";
     do iphones="10K","20K","30k";
         country_region=cats(country,'/',region);
         pop=int(100*(rand("uniform")));
         male_pct=int(100*(rand("uniform")));
         output;
         pop=int(100*(rand("uniform")));
         male_pct=int(100*(rand("uniform")));
         output;
      end;
   end;
 end;
run;quit;

proc report data=havpre nowd split='/' out=havRpt;
cols COUNTRY_REGION IPHONES POP male_pct;
define COUNTRY_REGION / group flow ;
define IPHONES        / group;
define POP            / mean;
define male_pct       / mean;
run;quit;

data havFix;
  retain cnt 0;
  set havRpt;
  by country_region;
  cnt=cnt+1;
  select;
    when (first.country_region)  country_region=scan(country_region,1,'/');
    when (cnt=2)                 country_region=scan(country_region,2,'/');
    otherwise country_region="";
  end;
  if last.country_region then cnt=0;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;
proc report data=havFix nowd out=havRpt;
cols COUNTRY_REGION IPHONES POP male_pct;
define COUNTRY_REGION / display;
define IPHONES        / display;
define POP            / display;
define male_pct       / display;
run;quit;

