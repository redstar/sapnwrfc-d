/* Example application for SAP NetWeaver RFC
   Search for and display SAP repository information.
*/
import std.sap;
import std.conv;
import std.stdio;
import std.string;
import std.typetuple;
import std.utf;

version(Windows)
{
    import core.stdc.wchar_ : wcslen;
}
else
{
    private size_t wcslen(in const(wchar)* s)
    {
        const(wchar)* p = s;
        while (*p) p++;
        return p - s;
    }
}

enum VERSION = "0.1";

alias KEYWORDS = TypeTuple!(
    // General Connection parameters
    "DEST",
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

alias cU = toUTF16z;

void dumpStructureOrTable(RFC_TYPE_DESC_HANDLE typeDescHandle)
{
    immutable fieldCount = RfcGetFieldCount(typeDescHandle);
    foreach (i; 0..fieldCount)
    {
        RFC_FIELD_DESC fieldDesc;
        RfcGetFieldDescByIndex(typeDescHandle, i, fieldDesc);
        writef("    %s ", fieldDesc.name[0..wcslen(fieldDesc.name.ptr)]);
        switch (fieldDesc.type)
        {
            case RFCTYPE.RFCTYPE_CHAR:
                writef("CHAR[%d] ", fieldDesc.nucLength);
                break;
            case RFCTYPE.RFCTYPE_DATE:
                writef("DATE ");
                break;
            case RFCTYPE.RFCTYPE_BCD:
                writef("BCD ");
                break;
            case RFCTYPE.RFCTYPE_TIME:
                writef("TIME ");
                break;
            case RFCTYPE.RFCTYPE_BYTE:
                writef("BYTE[%d] ", fieldDesc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_INT:
                writef("INT[%d] ", fieldDesc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_INT2:
                writef("SHORT[%d] ", fieldDesc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_INT1:
                writef("BYTE[%d] ", fieldDesc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_TABLE:
                writef("TABLE ");
                break;
            case RFCTYPE.RFCTYPE_STRUCTURE:
                writef("STRUCTURE ");
                break;
            default:
                writef("%d ", fieldDesc.type);
        }
        writeln();
    }
}

void dumpMetadata(RFC_FUNCTION_DESC_HANDLE funcDesc)
{
    RFC_ABAP_NAME name;
    RfcGetFunctionName(funcDesc, name);
    writefln("FUNCTION\n    %s\n", name[0..wcslen(name.ptr)]);

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

        foreach (i; 0..paramCount)
        {
            RFC_PARAMETER_DESC paramDesc;
            RfcGetParameterDescByIndex(funcDesc, i, paramDesc);
            if (paramDesc.direction != direction)
                continue;
            writef("    %-30s ", paramDesc.name[0..wcslen(paramDesc.name.ptr)]);
            auto typestr = RfcGetTypeAsString(paramDesc.type);
            writef("%-10s ", typestr[0..wcslen(typestr)]);
            switch (paramDesc.type)
            {
                case RFCTYPE.RFCTYPE_CHAR:
                case RFCTYPE.RFCTYPE_NUM:
                    if (paramDesc.nucLength != 1)
                        writef("Length %d ", paramDesc.nucLength);
                    break;
                case RFCTYPE.RFCTYPE_BYTE:
                case RFCTYPE.RFCTYPE_INT:
                case RFCTYPE.RFCTYPE_INT2:
                case RFCTYPE.RFCTYPE_INT1:
                    if (paramDesc.ucLength != 1)
                        writef("Length %d ", paramDesc.ucLength);
                    break;
                default:
                    break;
            }
            writeln();
        }
        writeln("\n");
    }
    writeln("EXCEPTIONS");
    immutable excCount = RfcGetExceptionCount(funcDesc);
    foreach (i; 0..excCount)
    {
        RFC_EXCEPTION_DESC excDesc;
        RfcGetExceptionDescByIndex(funcDesc, i, excDesc);
        writeln("    %s", excDesc.key[0..wcslen(excDesc.key.ptr)]);
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
    RFC_CONNECTION_PARAMETER[1] conParams = [ { cU("DEST"), cU(dest) } ];
    auto connection = RfcOpenConnection(conParams);
    scope(exit) RfcCloseConnection(connection);

    if (verbose) writeln("Retrieving function description...");
    auto desc = RfcGetFunctionDesc(connection, cU(func));

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