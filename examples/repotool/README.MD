repotool
========

Summary
-------

With the repotool application you can display the metadata for a function.
This is the same information the function builder (transaction `se37`) provides.

If the `-lang=d` option is specified then D source code will be generated to call
the remote function.

Command line usage
------------------

    repotool [-h] [-v] [-lang=d] DEST=<sysid> FUNC=<name>
    
    Options:
        -h       This help text
        -v       Enable verbose output
        -lang=d  Output D code

    Recognized keys:
        DEST     SAP system id
        FUNC     The function name for which the meta data is retrieved

    Example:
        repotool DEST=X01 FUNC=BAPI_BUPA_SEARCH

Example
-------

The following information is output for the function DATE_COMPUTE_DAY_ENHANCED:

    FUNCTION
        DATE_COMPUTE_DAY_ENHANCED

    IMPORTING
        DATE                     DATE     Length 8

    EXPORTING
        DAY                      CHAR     Length 1 
        WEEKDAY                  CHAR     Length 15 

    CHANGING

    TABLES

    EXCEPTIONS

The option `-lang=d` returns the following code:

    void DATE_COMPUTE_DAY_ENHANCED(
        RFC_CONNECTION_HANDLE con,
        in RFC_DATE DATE,
        out RFC_CHAR DAY,
        out RFC_CHAR[15] WEEKDAY)
    {
        auto desc = RfcGetFunctionDesc(con, "DATE_COMPUTE_DAY_ENHANCED"w);
        auto func = RfcCreateFunction(desc);
        scope(exit) RfcDestroyFunction(func);

        RfcSetDate(func, "DATE"w.ptr, DATE);

        RfcInvoke(con, func);

        RfcGetChars(func, "DAY"w.ptr, &DAY, 1);

        RfcGetChars(func, "WEEKDAY"w.ptr, WEEKDAY.ptr, 15);
    }
