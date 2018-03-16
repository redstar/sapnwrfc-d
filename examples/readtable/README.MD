readtable
=========

Summary
-------

With the readtable application you can retreive data from a table using the 
function `RFC_READ_TABLE` or a function with the same interface. The data is
is printed to the screen.

There are several limitations with `RFC_READ_TABLE`. The use for large tables
is not recommended.

Command line usage
------------------

    readtable [-h] [-v] [-a[=name]] (KEY=VALUE)+
    
    Options:
        -h       This help text
        -v       Enable verbose output
        -a       Use BBP_RFC_READ_TABLE instead of RFC_READ_TABLE
        -a=name  Use RFC name instead of RFC_READ_TABLE

    Recognized keys:
        DEST       SAP system id
        TABLE      Name of table
        FIELDS     Retrieve only these fields
        OPTIONS    Condition to filter result (like SQL where clause)
        DELIMITER  Delimiter used for output
        NODATA     Only retrieve field names
        MAXROWS    Maximum number of rows to retrieve

    Example:
        readtable DEST=X01 TABLE=TSTC DELIMITER=| MAXROWS=500 OPTIONS="TCODE LIKE 'SE%%'"