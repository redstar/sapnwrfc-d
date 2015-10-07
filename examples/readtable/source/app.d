/* Example application for SAP NetWeaver RFC
   Execute RFC_READ_TABLE in SAP system and export result.
*/
import std.sap;
import std.conv;
import std.stdio;
import std.string;
import std.typetuple;
import std.utf;

enum VERSION = "0.1";

alias KEYWORDS = TypeTuple!(
    // General Connection parameters
    "DEST",
    "TABLE",
    "DELIMITER",
    "MAXROWS",
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
    writefln("ReadTable V%s", VERSION);
    writefln("\nUsage:");
    writefln("    readtable [-h] [-v] (KEY=VALUE)+");
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
    writefln("\nExample:");
    writefln("    readtable DEST=X01 TABLE=bd90 DELIMITER=| MAXROWS=500");
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
    wstring dest = "";
    wstring table = "";
    wstring delimiter = "";
    wstring maxrows = "";

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
                case key: mixin(toLower(key)) = toUTF16(kv[1]); break;
            }
        }
    }

    if (dest == "" || table == "")
        usage();

    if (verbose) writeln("Connecting...");
    RFC_CONNECTION_PARAMETER[1] conParams = [ { cU("DEST"), cU(dest) } ];
    auto connection = RfcOpenConnection(conParams);
    scope(exit) RfcCloseConnection(connection);

    if (verbose) writeln("Calling read table...");
    auto desc = RfcGetFunctionDesc(connection, cU("RFC_TABLE_READ"));
    auto func = RfcCreateFunction(desc);
    scope(exit) RfcDestroyFunction(func);
    RfcSetString(func, "QUERY_TABLE"w, table);
    if (delimiter != "") RfcSetString(func, "DELIMITER"w, delimiter);
    if (maxrows != "") RfcSetString(func, "ROWCOUNT"w, maxrows);
    
    RfcInvoke(connection, func);

    if (verbose) writeln("Retrieving result data...");
    RFC_STRUCTURE_HANDLE rfcsiStructureHandle;
    RfcGetStructure(func, cU("RFCSI_EXPORT"), rfcsiStructureHandle);
    if (verbose) writeln("Copying result data...");
    RFCSI_EXPORT rfcsiExport;
    foreach(wstring memberName; __traits(allMembers, RFCSI_EXPORT))
    {
        uint len;
        wchar[64] buffer;
        RfcGetString(rfcsiStructureHandle, memberName.ptr, buffer.ptr, cast(uint) buffer.length, len);
        __traits(getMember, rfcsiExport, memberName) = buffer[0..len].dup;
    }

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