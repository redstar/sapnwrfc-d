/* Example application for SAP NetWeaver RFC
   Connect to SAP system, call ping and display information from RFC_SYSTEM_INFO.
*/
import std.sap;
import std.conv;
import std.stdio;
import std.string;
import std.typetuple;
import std.utf;

enum VERSION = "0.3";

alias KEYWORDS = TypeTuple!(
    // General Connection parameters
    "DEST",
    "SAPROUTER",
    "SNC_LIB",
    "SNC_MYNAME",
    "SNC_PARTNERNAME",
    "SNC_QOP",
    "TRACE",
    "PCS",
    "CODEPAGE",
    "NO_COMPRESSION",
    "ON_CCE",
    "CFIT",
    
    // Parameters used in client programs
    "USER",
    "PASSWD",
    "CLIENT",
    "LANG",
    "PASSWORD_CHANGE_ENFORCED",
    "SNC_SSO",
    "USE_SYMBOLIC_NAMES",
    "MYSAPSSO2",
    "GETSSO2",
    "X509CERT",
    "EXTIDDATA",
    "EXTIDTYPE",
    "LCHECK",
    "USE_SAPGUI",
    "ABAP_DEBUG",
    "DELTA",
    
    // Parameters for direct application server logon
    "ASHOST",
    "SYSNR",

    // Parameters for load balancing
    "MSHOST",
    "MSSERV",
    "R3NAME",
    "SYSID",
    "GROUP",
    
    // Parameters used in server programs
    "GWHOST",
    "GWSERV",
    "PROGRAM_ID",
    "TPNAME",

    "RFC_TRACE",
    "RFC_TRACE_DIR",
    "RFC_TRACE_TYPE",
    "RFC_TRACE_ENCODING",
    "CPIC_TRACE",
);

class ExitException : Exception
{
    int rc;

    @safe pure nothrow this(int rc, string file = __FILE__, size_t line = __LINE__)
    {
        super(null, file, line);
        this.rc = rc;
    }
}

void usage(int rc = 1)
{
    writefln("SapPing V%s", VERSION);
    writefln("\nUsage:");
    writefln("    sapping [-h] [-v] (KEY=VALUE)+");
    writefln("\nOptions:");
    writefln("    -h    This help text");
    writefln("    -v    Enable verbose output");
    writefln("\nRecognized keys:");
    short col = 0;
    foreach (key; KEYWORDS)
    {
        if (col == 0) write("   ");
        writef(" %-24s", key);
        if (col == 2) writeln();
        col = (col + 1) % 3;
    }
    writeln();
    writefln("\nExamples:");
    writefln("    sapping CLIENT=100 USER=techuser PASSWD=secret MSHOST=10.0.5.42 R3NAME=X07 MSSERV=5801 GROUP=PROD_GROUP");
    writefln("    sapping CLIENT=100 USER=techuser PASSWD=secret ASHOST=10.0.5.42 SYSNR=07");
    throw new ExitException(rc);
}

alias cU = toUTF16z;

struct RFCSI_EXPORT
{
    wchar[/*3*/] RFCPROTO;
    wchar[/*4*/] RFCCHARTYP;
    wchar[/*3*/] RFCINTTYP;
    wchar[/*3*/] RFCFLOTYP;
    wchar[/*32*/] RFCDEST;
    wchar[/*8*/] RFCHOST;
    wchar[/*8*/] RFCSYSID;
    wchar[/*8*/] RFCDATABS;
    wchar[/*32*/] RFCDBHOST;
    wchar[/*10*/] RFCDBSYS;
    wchar[/*4*/] RFCSAPRL;
    wchar[/*5*/] RFCMACH;
    wchar[/*10*/] RFCOPSYS;
    wchar[/*6*/] RFCTZONE;
    wchar[/*1*/] RFCDAYST;
    wchar[/*15*/] RFCIPADDR;
    wchar[/*4*/] RFCKERNRL;
    wchar[/*32*/] RFCHOST2;
    wchar[/*12*/] RFCSI_RESV;
    wchar[/*45*/] RFCIPV6ADDR;
}

int run(string[] args)
{
    if  (args.length == 0) usage();

    bool verbose = false;
    RFC_CONNECTION_PARAMETER[] conParams = new RFC_CONNECTION_PARAMETER[0];

    foreach(arg; args[1..$])
    {
        if (arg == "-v")
        {
            verbose = true;
            continue;
        }
        if (arg == "-h")
            usage(0);
        auto kv = split(arg, "=");
        if (kv.length != 2) usage();

        switch (kv[0])
        {
            default: usage();
            foreach (key; KEYWORDS)
            {
                case key: conParams ~= RFC_CONNECTION_PARAMETER(cU(toLower(key)), cU(kv[1])); break;
            }
        }
    }

    if (conParams.length == 0)
        usage();

    if (verbose) writeln("Connecting...");
    auto connection = RfcOpenConnection(conParams);
    scope(exit) RfcCloseConnection(connection);

    if (verbose) writeln("Calling ping...");
    RfcPing(connection);

    if (verbose) writeln("Calling system info...");
    auto desc = RfcGetFunctionDesc(connection, "RFC_SYSTEM_INFO"w.ptr);
    auto func = RfcCreateFunction(desc);
    scope(exit) RfcDestroyFunction(func);
    RfcInvoke(connection, func);

    if (verbose) writeln("Retrieving result data...");
    auto rfcsiStructureHandle = RfcGetStructure(func, "RFCSI_EXPORT");
    if (verbose) writeln("Copying result data...");
    RFCSI_EXPORT rfcsiExport;
    foreach(wstring memberName; __traits(allMembers, RFCSI_EXPORT))
    {
        size_t len;
        wchar[64] buffer;
        RfcGetString(rfcsiStructureHandle, memberName, buffer, len);
        __traits(getMember, rfcsiExport, memberName) = buffer[0..len].dup;
    }

    auto tzone = to!long(strip(rfcsiExport.RFCTZONE)) / 3600;

    writefln("System ID:            %s", rfcsiExport.RFCSYSID);
    writefln("Host:                 %s", rfcsiExport.RFCHOST);
    writefln("IP v4:                %s", rfcsiExport.RFCIPADDR);
    writefln("IP v6:                %s", rfcsiExport.RFCIPV6ADDR);
    writefln("Destination:          %s", rfcsiExport.RFCDEST);
    writefln("Kernel release:       %s", rfcsiExport.RFCKERNRL);
    writefln("OS:                   %s", rfcsiExport.RFCOPSYS);
    writefln("Timezone:             UTC%s%d", tzone < 0 ? "-" : "+", tzone);
    writefln("Daylight saving time: %s", rfcsiExport.RFCDAYST == "X" ? "yes" : "no");
    writefln("Appl. server:         %s", rfcsiExport.RFCHOST2);
    writefln("Endian type:          %s", rfcsiExport.RFCINTTYP == "BIG" ? "Big" : "Little");
    writefln("Floating point:       %s", rfcsiExport.RFCFLOTYP == "IE3" ? "IEEE" : "IBM/370");
    writefln("DB system:            %s", rfcsiExport.RFCDBSYS);
    writefln("DB host:              %s", rfcsiExport.RFCDBHOST);

    return 0;
}

int main(string[] args)
{
    try
    {
        run(args);
    }
    catch (ExitException e)
    {
        return e.rc;
    }
    catch (SAPException e)
    {
        writefln("Error occured %d %s", e.code, e.codeAsString);
        writefln("'%s'", e.message);
        return 100;
    }
    return 0;
}