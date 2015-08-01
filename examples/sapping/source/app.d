/* Example application for SAP NetWeaver RFC
   Connect to SAP system, call ping and display information from RFC_SYSTEM_INFO.
*/
import etc.c.sapnwrfc;
import std.conv;
import std.stdio;
import std.string;
import std.utf;

version(Windows)
{
    import core.stdc.wchar_ : wcslen;
}
else
{
    size_t wcslen(in const(wchar)* s)
    {
        const(wchar)* p = s;
        while (*p) p++;
        return p - s;
    }
}

enum VERSION = "0.1";

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
    writefln("    GATEWAY");
    writefln("    ASHOST");
    writefln("    SYSNR");
    writefln("    MSHOST");
    writefln("    MSSERV");
    writefln("    R3NAME");
    writefln("    GROUP");
    writefln("    CLIENT");
    writefln("    USER");
    writefln("    PASSWD");
    writefln("    LANG");
    writefln("    DEST");
    writefln("    TRACE");
    writefln("    ABAP_DEBUG");
    writefln("    NO_COMPRESSION");
    writefln("\nExamples:");
    writefln("    sapping CLIENT=100 USER=techuser PASSWD=secret MSHOST=10.0.5.42 R3NAME=X07 MSSERV=5801 GROUP=PROD_GROUP");
    writefln("    sapping CLIENT=100 USER=techuser PASSWD=secret ASHOST=10.0.5.42 SYSNR=07");
    throw new ExitException(rc);
}

alias cU = toUTF16z;

void rfcError(in RFC_ERROR_INFO errorInfo)
{
    auto rcmsg = RfcGetRcAsString(errorInfo.code);
    writefln("Error occured %d %s", errorInfo.code, rcmsg[0 .. wcslen(rcmsg)]);
    writefln("'%s'", errorInfo.message);
    throw new ExitException(2);
}

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
            case "GATEWAY": conParams ~= RFC_CONNECTION_PARAMETER(cU("gateway"), cU(kv[1])); break;
            case "ASHOST": conParams ~= RFC_CONNECTION_PARAMETER(cU("ashost"), cU(kv[1])); break;
            case "MSHOST": conParams ~= RFC_CONNECTION_PARAMETER(cU("mshost"), cU(kv[1])); break;
            case "MSSERV": conParams ~= RFC_CONNECTION_PARAMETER(cU("msserv"), cU(kv[1])); break;
            case "R3NAME": conParams ~= RFC_CONNECTION_PARAMETER(cU("r3name"), cU(kv[1])); break;
            case "GROUP": conParams ~= RFC_CONNECTION_PARAMETER(cU("group"), cU(kv[1])); break;
            case "SYSNR": conParams ~= RFC_CONNECTION_PARAMETER(cU("sysnr"), cU(kv[1])); break;
            case "CLIENT": conParams ~= RFC_CONNECTION_PARAMETER(cU("client"), cU(kv[1])); break;
            case "USER": conParams ~= RFC_CONNECTION_PARAMETER(cU("user"), cU(kv[1])); break;
            case "PASSWD": conParams ~= RFC_CONNECTION_PARAMETER(cU("passwd"), cU(kv[1])); break;
            case "LANG": conParams ~= RFC_CONNECTION_PARAMETER(cU("lang"), cU(kv[1])); break;
            case "DEST": conParams ~= RFC_CONNECTION_PARAMETER(cU("dest"), cU(kv[1])); break;
            case "TRACE": conParams ~= RFC_CONNECTION_PARAMETER(cU("trace"), cU(kv[1])); break;
            case "ABAP_DEBUG": conParams ~= RFC_CONNECTION_PARAMETER(cU("abap_debug"), cU(kv[1])); break;
            case "NO_COMPRESSION": conParams ~= RFC_CONNECTION_PARAMETER(cU("no_compression"), cU(kv[1])); break;
            default: usage();
        }
    }

    if (conParams.length == 0)
        usage();

    if (verbose) writeln("Connecting...");
    RFC_ERROR_INFO errorInfo;
    auto connection = RfcOpenConnection(conParams.ptr, cast(uint)conParams.length, errorInfo);
    if (!connection) rfcError(errorInfo);
    scope(exit) RfcCloseConnection(connection, errorInfo);

    if (verbose) writeln("Calling ping...");
    if (RfcPing(connection, errorInfo) != RFC_RC.RFC_OK) rfcError(errorInfo);

    if (verbose) writeln("Calling system info...");
    auto desc = RfcGetFunctionDesc(connection, cU("RFC_SYSTEM_INFO"), errorInfo);
    if (!desc) rfcError(errorInfo);
    auto func = RfcCreateFunction(desc, errorInfo);
    if (!func) rfcError(errorInfo);
    scope(exit) RfcDestroyFunction(func, errorInfo);
    if (RfcInvoke(connection, func, errorInfo) != RFC_RC.RFC_OK) rfcError(errorInfo);

    if (verbose) writeln("Retrieving result data...");
    RFC_STRUCTURE_HANDLE rfcsiStructureHandle;
    if (RfcGetStructure(func, cU("RFCSI_EXPORT"), rfcsiStructureHandle, errorInfo) != RFC_RC.RFC_OK) rfcError(errorInfo);
    if (verbose) writeln("Copying result data...");
    RFCSI_EXPORT rfcsiExport;
    foreach(wstring memberName; __traits(allMembers, RFCSI_EXPORT))
    {
        uint len;
        wchar[64] buffer;
        if (RfcGetString(rfcsiStructureHandle, memberName.ptr, buffer.ptr, cast(uint) buffer.length, len, errorInfo) != RFC_RC.RFC_OK)
            rfcError(errorInfo);
        __traits(getMember, rfcsiExport, memberName) = buffer[0..len].dup;
        //writefln("%s = %s", memberName, __traits(getMember, rfcsiExport, memberName));
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
    return 0;
}