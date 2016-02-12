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
    "FIELDS",
    "OPTIONS",
    "DELIMITER",
    "NODATA",
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
    writefln("    -a    Use BBP_RFC_READ_TABLE instead of RFC_READ_TABLE");
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

int run(string[] args)
{
    if  (args.length == 0) usage();

    bool verbose = false;
    wstring rfcfunc = "RFC_READ_TABLE";
    wstring dest = "";
    wstring table = "";
    wstring fields = "";
    wstring options = "";
    wstring delimiter = "";
    wstring nodata = "";
    wstring maxrows = "";

    foreach(arg; args[1..$])
    {
        if (arg == "-a")
        {
            rfcfunc = "BBP_RFC_READ_TABLE";
            continue;
        }
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
    RfcInit();
    RFC_CONNECTION_PARAMETER[1] conParams = [ { cU("DEST"), cU(dest) } ];
    auto connection = RfcOpenConnection(conParams);
    scope(exit) RfcCloseConnection(connection);

    if (verbose) writeln("Calling read table...");
    auto desc = RfcGetFunctionDesc(connection, cU(rfcfunc));
    auto func = RfcCreateFunction(desc);
    scope(exit) RfcDestroyFunction(func);
    RfcSetString(func, "QUERY_TABLE"w, table);
    RfcSetString(func, "NO_DATA"w, nodata != "" ? nodata : " "w);
    RfcSetString(func, "DELIMITER"w, delimiter != "" ? delimiter : " "w);
    if (maxrows != "") RfcSetString(func, "ROWCOUNT"w, maxrows);
    if (fields != "")
    {
        auto allFields = std.string.split(fields, ",");
        RFC_TABLE_HANDLE fieldsTableHandle;
        RfcGetTable(func, cU("FIELDS"), fieldsTableHandle);
        foreach (f; allFields)
        {
            RfcAppendNewRow(fieldsTableHandle);
            RfcSetString(fieldsTableHandle, "FIELDNAME"w, f);
        }
    }
    if (options != "")
    {
        RFC_TABLE_HANDLE optionsTableHandle;
        RfcGetTable(func, cU("FIELDS"), optionsTableHandle);
        RfcAppendNewRow(optionsTableHandle);
        RfcSetString(optionsTableHandle, "TEXT"w, options);
    }

    RfcInvoke(connection, func);

    if (verbose) writeln("Retrieving result data...");
    RFC_TABLE_HANDLE dataTableHandle;
    RfcGetTable(func, cU("DATA"), dataTableHandle);
    if (verbose) writeln("Copying result data...");
    uint rows;
    RfcGetRowCount(dataTableHandle, rows);
    if (verbose) writefln("Got %d result rows", rows);
    RfcMoveToFirstRow(dataTableHandle);
    while (rows > 0)
    {
        size_t len;
        wchar[512] buffer;
        RfcGetStringByIndex(dataTableHandle, 0, buffer, len);
				writeln(buffer[0..len]);
				if (--rows > 0)
            RfcMoveToNextRow(dataTableHandle);
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