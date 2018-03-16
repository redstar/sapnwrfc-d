repotool
========

Summary
-------

With the repotool application you can display the metadata for a function.
This is the same information the function builder (transaction `se37`) provides.

Command line usage
------------------

    repotool [-h] [-v] DEST=<sysid> FUNC=<name>
    
    Options:
        -h       This help text
        -v       Enable verbose output

    Recognized keys:
        DEST     SAP system id
        FUNC     The function name for which the meta data is retrieved

    Example:
        repotool DEST=X01 FUNC=BAPI_BUPA_SEARCH