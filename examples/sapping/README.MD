sapping
=======

Summary
-------

The sapping application connects to the specified SAP system and displays system information.
All connection parameters can be specified on the command line. The provided user and password
must be valid and have sufficient rights because an RFC is called. This makes this an ideal tool
to check connectivity to an SAP system with a technical user.

Command line usage
------------------

    repotool [-h] [-v] DEST=<sysid> FUNC=<name>
    
    Options:
        -h       This help text
        -v       Enable verbose output

    Recognized keys:
        DEST               SAP system id
        SAPROUTER
        SNC_LIB
        SNC_MYNAME
        SNC_PARTNERNAME
        SNC_QOP
        TRACE
        PCS
        CODEPAGE
        NO_COMPRESSION
        ON_CCE
        CFIT
        USER
        PASSWD
        CLIENT
        LANG
        PASSWORD_CHANGE_ENFORCED
        SNC_SSO
        USE_SYMBOLIC_NAMES
        MYSAPSSO2
        GETSSO2
        X509CERT
        EXTIDDATA
        EXTIDTYPE
        LCHECK
        USE_SAPGUI
        ABAP_DEBUG
        DELTA
        ASHOST
        SYSNR
        MSHOST
        MSSERV
        R3NAME
        SYSID
        GROUP
        GWHOST
        GWSERV
        PROGRAM_ID
        TPNAME
        RFC_TRACE
        RFC_TRACE_DIR
        RFC_TRACE_TYPE
        RFC_TRACE_ENCODING
        CPIC_TRACE

    Example:
        sapping CLIENT=100 USER=techuser PASSWD=secret MSHOST=10.0.5.42 R3NAME=X07 MSSERV=5801 GROUP=PROD_GROUP
        sapping CLIENT=100 USER=techuser PASSWD=secret ASHOST=10.0.5.42 SYSNR=07