/* Example application for SAP NetWeaver RFC
   Search for and display SAP repository information.
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
    // The function name
    "FUNC",
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
    writefln("RepoTool V%s", VERSION);
    writefln("\nUsage:");
    writefln("    repotool [-h] [-v] (KEY=VALUE)+");
    writefln("\nOptions:");
    writefln("    -h       This help text");
    writefln("    -v       Enable verbose output");
    writefln("    -lang=d  Output D code ");
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
    writefln("    repotool DEST=X01 FUNC=BAPI_BUPA_SEARCH");
    throw new ExitException(rc);
}

void dumpMetadataFields(alias GetCount, alias GetDescriptionByIndex, DESC, T)(T descHandle, int level, bool function(DESC) filter = function(DESC x) { return false; })
    if(is(T == RFC_TYPE_DESC_HANDLE) || is(T == RFC_FUNCTION_DESC_HANDLE))
{
    immutable count = GetCount(descHandle);
    foreach (i; 0..count)
    {
        bool recurse = false;
        DESC desc;
        GetDescriptionByIndex(descHandle, i, desc);
        if (filter(desc))
            continue;
        foreach (j; 0..level)
            write("    ");
        writef("%-24s ", desc.name[0..strlenU16(desc.name.ptr)]);
        final switch (desc.type)
        {
            case RFCTYPE.RFCTYPE_CHAR:
                writef("CHAR     Length %d ", desc.nucLength);
                break;
            case RFCTYPE.RFCTYPE_DATE:
                writef("DATE     Length %d", desc.nucLength);
                break;
            case RFCTYPE.RFCTYPE_BCD:
                writef("BCD      Decimals %d", desc.decimals);
                break;
            case RFCTYPE.RFCTYPE_TIME:
                writef("TIME");
                break;
            case RFCTYPE.RFCTYPE_BYTE:
                writef("BYTE     Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_INT:
                writef("INT      Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_INT2:
                writef("INT2     Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_INT1:
                writef("INT1     Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_INT8:
                writef("INT8     Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_DECF16:
                writef("DEC16    Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_DECF34:
                writef("DEC34    Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_FLOAT:
                writef("FLOAT    Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_NUM:
                writef("NUM      Length %d", desc.nucLength);
                break;
            case RFCTYPE.RFCTYPE_STRING:
                writef("STRING   Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_XSTRING:
                writef("XSTRING");
                break;
            case RFCTYPE.RFCTYPE_XMLDATA:
                writef("XMLDATA  Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_TABLE:
                writef("TABLE");
                RFC_ABAP_NAME tname;
                RfcGetTypeName(desc.typeDescHandle, tname);
                writefln("    %s", tname[0..strlenU16(tname.ptr)]);
                recurse = true;
                dumpMetadataFields!(RfcGetFieldCount, RfcGetFieldDescByIndex, RFC_FIELD_DESC)(desc.typeDescHandle, level+1);
                break;
            case RFCTYPE.RFCTYPE_STRUCTURE:
                writef("STRUCTURE");
                RFC_ABAP_NAME tname;
                RfcGetTypeName(desc.typeDescHandle, tname);
                writefln("    %s", tname[0..strlenU16(tname.ptr)]);
                recurse = true;
                dumpMetadataFields!(RfcGetFieldCount, RfcGetFieldDescByIndex, RFC_FIELD_DESC)(desc.typeDescHandle, level+1);
                break;
            case RFCTYPE.RFCTYPE_NULL:
                writef("NULL");
                break;
            case RFCTYPE.RFCTYPE_ABAPOBJECT:
                writef("ABAPOBJECT");
                break;
            case RFCTYPE.RFCTYPE_UTCLONG:
                writef("UTCLONG");
                break;
            case RFCTYPE.RFCTYPE_UTCSECOND:
                writef("UTCSECOND");
                break;
            case RFCTYPE.RFCTYPE_UTCMINUTE:
                writef("UTCMINUTE");
                break;
            case RFCTYPE.RFCTYPE_DTDAY:
                writef("DTDAY");
                break;
            case RFCTYPE.RFCTYPE_DTWEEK:
                writef("DTWEEK");
                break;
            case RFCTYPE.RFCTYPE_DTMONTH:
                writef("DTMONTH");
                break;
            case RFCTYPE.RFCTYPE_TSECOND:
                writef("TSECOND");
                break;
            case RFCTYPE.RFCTYPE_TMINUTE:
                writef("TMINUTE");
                break;
            case RFCTYPE.RFCTYPE_CDAY:
                writef("CDAY");
                break;
            case RFCTYPE.RFCTYPE_BOX:
                writef("BOX");
                break;
            case RFCTYPE.RFCTYPE_GENERIC_BOX:
                writef("GENERIC_BOX");
                break;
            case RFCTYPE._RFCTYPE_max_value:
                writef("(max value?)");
                break;
        }
        if (!recurse) writeln();
    }
}

void dumpMetadata(RFC_FUNCTION_DESC_HANDLE funcDesc)
{
    RFC_ABAP_NAME name;
    RfcGetFunctionName(funcDesc, name);
    writefln("FUNCTION\n    %s\n", name[0..strlenU16(name.ptr)]);

    immutable paramCount = RfcGetParameterCount(funcDesc);
    alias DIRECTION = TypeTuple!(
        RFC_DIRECTION.RFC_IMPORT,
        RFC_DIRECTION.RFC_EXPORT,
        RFC_DIRECTION.RFC_CHANGING,
        RFC_DIRECTION.RFC_TABLES,
    );
    foreach (direction; DIRECTION)
    {
        static if (direction == RFC_DIRECTION.RFC_IMPORT)
            writeln("IMPORTING");
        else static if (direction == RFC_DIRECTION.RFC_EXPORT)
            writeln("EXPORTING");
        else static if (direction == RFC_DIRECTION.RFC_CHANGING)
            writeln("CHANGING");
        else static if (direction == RFC_DIRECTION.RFC_TABLES)
            writeln("TABLES");

        dumpMetadataFields!(RfcGetParameterCount, RfcGetParameterDescByIndex, RFC_PARAMETER_DESC)(funcDesc, 1, function(RFC_PARAMETER_DESC d){ return d.direction != direction; });
        writeln();
    }
    writeln("EXCEPTIONS");
    immutable excCount = RfcGetExceptionCount(funcDesc);
    foreach (i; 0..excCount)
    {
        RFC_EXCEPTION_DESC excDesc;
        RfcGetExceptionDescByIndex(funcDesc, i, excDesc);
        writefln("    %s", excDesc.key[0..strlenU16(excDesc.key.ptr)]);
    }
}

void dumpMetadataAsD(RFC_FUNCTION_DESC_HANDLE funcDesc)
{
    writeln("Not yet implemented");
}

int run(string[] args)
{
    if  (args.length == 0) usage();

    bool verbose = false;
    bool outputD = false;
    wstring dest = "";
    wstring func = "";

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
            case "-lang":
                if (kv[1] == "d")
                    outputD = true;
                else
                    usage();
                break;
            foreach (key; KEYWORDS)
            {
                case key: mixin(toLower(key)) = toUTF16(kv[1]); break;
            }
        }
    }

    if (dest == "" || func == "")
        usage();

    if (verbose) writeln("Connecting...");
    RfcInit();
    RFC_CONNECTION_PARAMETER[1] conParams = [ { "DEST"w.ptr, cU(dest) } ];
    auto connection = RfcOpenConnection(conParams);
    scope(exit) RfcCloseConnection(connection);

    if (verbose) writeln("Retrieving function description...");
    auto desc = RfcGetFunctionDesc(connection, func);

    if (outputD)
        dumpMetadataAsD(desc);
    else
        dumpMetadata(desc);

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