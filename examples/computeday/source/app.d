/* Example application for SAP NetWeaver RFC
   Compute week day of date.
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
    // The date parameter
    "DATE",
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

string[] firstSplitOf(string s, char delim)
{
    auto idx = s.indexOf(delim);
    if (idx < 0)
    {
        auto res = new string[1];
        res[0] = s;
        return res;
    }
    auto res = new string[2];
    res[0] = s[0..idx];
    res[1] = s[idx+1..$];
    return res;
}

void usage(int rc = 1)
{
    writefln("ComputeDay V%s", VERSION);
    writefln("\nUsage:");
    writefln("    computedate [-h] [-v] (KEY=VALUE)+");
    writefln("\nOptions:");
    writefln("    -h       This help text");
    writefln("    -v       Enable verbose output");
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
    writefln("    computeday DEST=X01 DATE=20170907");
    throw new ExitException(rc);
}

int run(string[] args)
{
    if  (args.length == 0) usage();

    bool verbose = false;
    wstring dest = "";
    wstring date = "";

    foreach(arg; args[1..$])
    {
        if (arg == "-v")
        {
            verbose = true;
            continue;
        }
        if (arg == "-h")
            usage(0);
        auto kv = firstSplitOf(arg, '=');
        if (kv.length != 2) usage();

        switch (kv[0])
        {
            default:
                usage();
                break;
            foreach (key; KEYWORDS)
            {
                case key: mixin(toLower(key)) = toUTF16(kv[1]); break;
            }
        }
    }

    if (dest == "" || date == "" || date.length != 8)
        usage();

    if (verbose) writeln("Connecting...");
    RfcInit();
    RFC_CONNECTION_PARAMETER[1] conParams = [ { "DEST"w.ptr, cU(dest) } ];
    auto connection = RfcOpenConnection(conParams);
    scope(exit) RfcCloseConnection(connection);

    if (verbose) writeln("Retrieving function description...");
    auto desc = RfcGetFunctionDesc(connection, "DATE_COMPUTE_DAY_ENHANCED"w.ptr);
    auto func = RfcCreateFunction(desc);
    scope(exit) RfcDestroyFunction(func);

    RfcSetDate(func, "DATE"w.ptr, date[0..8]);
    RfcInvoke(connection, func);

    wchar[1] day;
    wchar[15] weekday;
    RfcGetChars(func, "DAY"w, day);
    RfcGetChars(func, "WEEKDAY"w, weekday);
    
    writefln("Day: %s\nWeekday: %s", day, weekday);

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