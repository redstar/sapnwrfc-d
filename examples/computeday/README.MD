computeday sample application
=============================

Summary
-------

The computeday sample application is the most simple example of an RFC call. The application takes a date (in format YYYYMMDD),
calls the DATE_COMPUTE_DAY_ENHANCED function module and displays the weekday as text.

You need to put a sapnwrc.ini file in your path with the necessary configuration for your destination.

Command line usage
------------------

    computedate [-h] [-v] (KEY=VALUE)+
    
    Options:
        -h       This help text
        -v       Enable verbose output

    Recognized keys:
        DEST       SAP system id
        DATE       Date in format YYYMMDD

    Example:
        computeday DEST=X01 DATE=20170907