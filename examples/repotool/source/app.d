/* Example application for SAP NetWeaver RFC
   Search for and display SAP repository information.
*/
import sapnwrfc;
import std.conv;
import std.stdio;
import std.string;
import std.typetuple;
import std.utf;

enum VERSION = "0.2";

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
    writefln("    repotool [-h] [-v] [-lang=d] (KEY=VALUE)+");
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
        DESC desc = GetDescriptionByIndex(descHandle, i);
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
                writef("DECF16   Length %d", desc.ucLength);
                break;
            case RFCTYPE.RFCTYPE_DECF34:
                writef("DECF34   Length %d", desc.ucLength);
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
                writefln("    %s", RfcGetTypeName(desc.typeDescHandle));
                recurse = true;
                dumpMetadataFields!(RfcGetFieldCount, RfcGetFieldDescByIndex, RFC_FIELD_DESC)(desc.typeDescHandle, level+1);
                break;
            case RFCTYPE.RFCTYPE_STRUCTURE:
                writef("STRUCTURE");
                writefln("    %s", RfcGetTypeName(desc.typeDescHandle));
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
    writefln("FUNCTION\n    %s\n", RfcGetFunctionName(funcDesc));

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
        auto excDesc = RfcGetExceptionDescByIndex(funcDesc, i);
        writefln("    %s", excDesc.key[0..strlenU16(excDesc.key.ptr)]);
    }
}

/* Generation of D code */

enum INDENT = "    ";

bool hasLength(T)(T desc) if (is(T == RFC_PARAMETER_DESC) || is(T == RFC_FIELD_DESC))
{
    return desc.type == RFCTYPE.RFCTYPE_CHAR || desc.type == RFCTYPE.RFCTYPE_BCD
           || desc.type == RFCTYPE.RFCTYPE_BYTE || desc.type == RFCTYPE.RFCTYPE_NUM;
}

uint getLength(T)(T desc) if (is(T == RFC_PARAMETER_DESC) || is(T == RFC_FIELD_DESC))
{
    switch (desc.type)
    {
        case RFCTYPE.RFCTYPE_CHAR:
            return desc.nucLength;
        case RFCTYPE.RFCTYPE_BCD:
            return desc.decimals;
        case RFCTYPE.RFCTYPE_BYTE:
        case RFCTYPE.RFCTYPE_NUM:
            return desc.ucLength;
        default:
            return 0;
    }
}

wstring mapTypeToD(T)(T desc) if (is(T == RFC_PARAMETER_DESC) || is(T == RFC_FIELD_DESC))
{
    wstring t;
    final switch (desc.type)
    {
        case RFCTYPE.RFCTYPE_CHAR:
            t = "RFC_CHAR";
            break;
        case RFCTYPE.RFCTYPE_DATE:
            assert(desc.nucLength == RFC_DATE.length);
            t = "RFC_DATE";
            break;
        case RFCTYPE.RFCTYPE_BCD:
            t = "RFC_BCD";
            break;
        case RFCTYPE.RFCTYPE_TIME:
            assert(desc.nucLength == RFC_TIME.length);
            t = "RFC_TIME";
            break;
        case RFCTYPE.RFCTYPE_BYTE:
            t = "RFC_BYTE";
            break;
        case RFCTYPE.RFCTYPE_INT:
            t = "RFC_INT";
            break;
        case RFCTYPE.RFCTYPE_INT2:
            t = "RFC_INT2";
            break;
        case RFCTYPE.RFCTYPE_INT1:
            t = "RFC_INT1";
            break;
        case RFCTYPE.RFCTYPE_INT8:
            t = "RFC_INT8";
            break;
        case RFCTYPE.RFCTYPE_DECF16:
            t = "RFC_DECF16";
            break;
        case RFCTYPE.RFCTYPE_DECF34:
            t = "RFC_DECF34";
            break;
        case RFCTYPE.RFCTYPE_FLOAT:
            t = "RFC_FLOAT";
            break;
        case RFCTYPE.RFCTYPE_NUM:
            t = "RFC_NUM";
            break;
        case RFCTYPE.RFCTYPE_STRING:
            t = "RFC_CHAR[]";
            break;
        case RFCTYPE.RFCTYPE_XSTRING:
            t = "RFC_CHAR[]";
            break;
        case RFCTYPE.RFCTYPE_XMLDATA:
            t = "RFC_CHAR[]";
            break;
        case RFCTYPE.RFCTYPE_TABLE:
            assert(false, "Table is not a basic type");
        case RFCTYPE.RFCTYPE_STRUCTURE:
            assert(false, "Structure is not a basic type");
        case RFCTYPE.RFCTYPE_NULL:
            t = "void";
            break;
        case RFCTYPE.RFCTYPE_ABAPOBJECT:
            assert(false, "AbapObject is not a basic type");
        case RFCTYPE.RFCTYPE_UTCLONG:
            t = "RFC_UTCLONG";
            break;
        case RFCTYPE.RFCTYPE_UTCSECOND:
            t = "RFC_UTCSECOND";
            break;
        case RFCTYPE.RFCTYPE_UTCMINUTE:
            t = "RFC_UTCMINUTE";
            break;
        case RFCTYPE.RFCTYPE_DTDAY:
            t = "RFC_DTDAY";
            break;
        case RFCTYPE.RFCTYPE_DTWEEK:
            t = "RFC_DTWEEK";
            break;
        case RFCTYPE.RFCTYPE_DTMONTH:
            t = "RFC_DTMONTH";
            break;
        case RFCTYPE.RFCTYPE_TSECOND:
            t = "RFC_TSECOND";
            break;
        case RFCTYPE.RFCTYPE_TMINUTE:
            t = "RFC_TMINUTE";
            break;
        case RFCTYPE.RFCTYPE_CDAY:
            t = "RFC_CDAY";
            break;
        case RFCTYPE.RFCTYPE_BOX:
            assert(false, "Box is not a basic type");
        case RFCTYPE.RFCTYPE_GENERIC_BOX:
            assert(false, "GenericBox is not a basic type");
        case RFCTYPE._RFCTYPE_max_value:
            assert(false, "max(RFCTYPE) is not a basic type");
    }
    if (desc.hasLength)
    {
        auto l = desc.getLength;
        if (l > 1)
            t ~= "[" ~ to!wstring(l) ~ "]";
    }
    return t;
}

wstring typename(wstring s)
{
    import std.string;
    if (s.startsWith('/'))
        s = s[1..$];
    return s.replace("/"w, "_"w);
}

bool dumpStructureAsD(RFC_TYPE_DESC_HANDLE handle, bool[wstring] done, RFC_TYPE_DESC_HANDLE[wstring] work)
{
    auto name = RfcGetTypeName(handle);
    if (name in done) // Struct is already generated.
        return false;
    writefln("struct %s", typename(name));
    writeln("{");
    auto fields = RfcGetFieldCount(handle);
    foreach (i; 0..fields)
    {
        write(INDENT);
        auto fieldDesc = RfcGetFieldDescByIndex(handle, i);
        if (fieldDesc.type != RFCTYPE.RFCTYPE_STRUCTURE && fieldDesc.type != RFCTYPE.RFCTYPE_TABLE)
        {
            write(mapTypeToD(fieldDesc));
        }
        else
        {
            auto structName = RfcGetTypeName(fieldDesc.typeDescHandle);
            write(typename(structName));
            if (fieldDesc.type == RFCTYPE.RFCTYPE_TABLE)
                write("[]");
            if (!(structName in done))
                work[structName] = fieldDesc.typeDescHandle;
        }
        writefln(" %s;", fieldDesc.name[0..strlenU16(fieldDesc.name.ptr)]);
    }
    writefln("}");
    work.remove(name);
    done[name] = true;
    return true;
}

bool dumpParameterTypesAsD(RFC_FUNCTION_DESC_HANDLE funcDesc)
{
    bool[wstring] done;
    RFC_TYPE_DESC_HANDLE[wstring] work;

    // First loop over all parameters and collect work
    foreach (i; 0..RfcGetParameterCount(funcDesc))
    {
        auto paramDesc = RfcGetParameterDescByIndex(funcDesc, i);
        if (paramDesc.type == RFCTYPE.RFCTYPE_STRUCTURE || paramDesc.type == RFCTYPE.RFCTYPE_TABLE)
        {
            work[RfcGetTypeName(paramDesc.typeDescHandle)] = paramDesc.typeDescHandle;
        }
    }

    // Then do the work
    bool newline = false;
    while (work.length > 0)
    {
        foreach (desc; work.values)
        {
            if (newline)
                writeln();
            newline = dumpStructureAsD(desc, done, work);
        }
    }

    return newline;
}

RFC_PARAMETER_DESC[] sortParams(RFC_FUNCTION_DESC_HANDLE funcDesc)
{
    RFC_PARAMETER_DESC[] params;
    size_t next = 0;
    alias DIRECTION = TypeTuple!(
        RFC_DIRECTION.RFC_IMPORT,
        RFC_DIRECTION.RFC_EXPORT,
        RFC_DIRECTION.RFC_CHANGING,
        RFC_DIRECTION.RFC_TABLES,
    );
    foreach (direction; DIRECTION)
    {
        immutable paramCount = RfcGetParameterCount(funcDesc);
        if (params.length == 0)
            params.length = paramCount;
        foreach (i; 0..paramCount)
        {
            auto paramDesc = RfcGetParameterDescByIndex(funcDesc, i);
            if (paramDesc.direction == direction)
                params[next++] = paramDesc;
        }
    }
    return params;
}

wstring modifier(RFC_PARAMETER_DESC desc)
{
    final switch (desc.direction)
    {
        case RFC_DIRECTION.RFC_IMPORT:
            return "in";
        case RFC_DIRECTION.RFC_EXPORT:
            return "out";
        case RFC_DIRECTION.RFC_CHANGING:
            return "inout";
        case RFC_DIRECTION.RFC_TABLES:
            return "";
    }
}

wstring paramType(RFC_PARAMETER_DESC desc, bool base = false)
{
    if (desc.type != RFCTYPE.RFCTYPE_STRUCTURE && desc.type != RFCTYPE.RFCTYPE_TABLE)
    {
        return mapTypeToD(desc);
    }
    else
    {
        auto type = typename(RfcGetTypeName(desc.typeDescHandle));
        if (desc.type == RFCTYPE.RFCTYPE_TABLE && !base)
            type ~= "[]";
        return type;
    }
}

bool generateMixins(RFC_PARAMETER_DESC[] params)
{
    bool[wstring] seen;
    bool first = true;

    foreach (param; params)
    {
        if (param.type == RFCTYPE.RFCTYPE_STRUCTURE || param.type == RFCTYPE.RFCTYPE_TABLE)
        {
            auto type = paramType(param);
            if (!(type in seen))
            {
                if (first)
                {
                    writeln(INDENT ~ "import sapnwrfc.data;");
                    first = false;
                }
                writefln(INDENT ~ "mixin Rfc%sHelper!%s;", param.type == RFCTYPE.RFCTYPE_STRUCTURE ? "Struct" : "Table", paramType(param, true));
                seen[type] = true;
            }
        }
    }
    return seen.length > 0;
}

void generateSetter(RFC_PARAMETER_DESC param, wstring funcvar)
{
    auto abapname = param.name[0..strlenU16(param.name.ptr)];
    auto dname = abapname;
    final switch (param.type)
    {
        case RFCTYPE.RFCTYPE_CHAR:
            auto len = param.getLength;
            if (len > 1)
                writefln(INDENT ~ "RfcSetChars(%s, \"%s\"w.ptr, %s.ptr, %d);", funcvar, abapname, dname, len);
            else
                writefln(INDENT ~ "RfcSetChars(%s, \"%s\"w.ptr, &%s, 1);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_DATE:
            writefln(INDENT ~ "RfcSetDate(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_BCD:
            writefln(INDENT ~ "RfcSetNum(%s, \"%s\"w.ptr, %s.ptr, %d);", funcvar, abapname, dname, param.getLength);
            break;
        case RFCTYPE.RFCTYPE_TIME:
            writefln(INDENT ~ "RfcSetTime(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_BYTE:
            writefln(INDENT ~ "RfcSetBytes(%s, \"%s\"w.ptr, %s.ptr, %d);", funcvar, abapname, dname, param.getLength);
            break;
        case RFCTYPE.RFCTYPE_INT:
            writefln(INDENT ~ "RfcSetInt(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_INT2:
            writefln(INDENT ~ "RfcSetInt2(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_INT1:
            writefln(INDENT ~ "RfcSetInt1(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_INT8:
            writefln(INDENT ~ "RfcSetInt8(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_DECF16:
            writefln(INDENT ~ "RfcSetDecF16(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_DECF34:
            writefln(INDENT ~ "RfcSetDecF34(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_FLOAT:
            writefln(INDENT ~ "RfcSetFloat(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_NUM:
            writefln(INDENT ~ "RfcSetNum(%s, \"%s\"w.ptr, %s.ptr, %d);", funcvar, abapname, dname, param.getLength);
            break;
        case RFCTYPE.RFCTYPE_STRING:
            writefln(INDENT ~ "RfcSetString(%s, \"%s\"w.ptr, %s.ptr, %s.length);", funcvar, abapname, dname, dname);
            break;
        case RFCTYPE.RFCTYPE_XSTRING:
            writefln(INDENT ~ "RfcXSetString(%s, \"%s\"w.ptr, %s.ptr, %s.length);", funcvar, abapname, dname, dname);
            break;
        case RFCTYPE.RFCTYPE_XMLDATA:
            writefln(INDENT ~ "RfcSetString(%s, \"%s\"w.ptr, %s.ptr, %s.length);", funcvar, abapname, dname, dname);
            break;
        case RFCTYPE.RFCTYPE_TABLE:
            writefln(INDENT ~ "auto %s__tbl = RfcCreateTable(RfcGetTypeDesc(con, \"%s\"w.ptr));", dname, RfcGetTypeName(param.typeDescHandle));
            writefln(INDENT ~ "copyFrom(%s__tbl, %s);", dname, dname);
            writefln(INDENT ~ "RfcSetTable(%s, \"%s\"w, %s__tbl);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_STRUCTURE:
            writefln(INDENT ~ "auto %s__strk = RfcCreateStructure(RfcGetTypeDesc(con, \"%s\"w.ptr));", dname, RfcGetTypeName(param.typeDescHandle));
            writefln(INDENT ~ "copyFrom(%s__strk, %s);", dname, dname);
            writefln(INDENT ~ "RfcSetStructure(%s, \"%s\"w, %s__strk);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_NULL:
        case RFCTYPE.RFCTYPE_UTCLONG:
        case RFCTYPE.RFCTYPE_UTCSECOND:
        case RFCTYPE.RFCTYPE_UTCMINUTE:
        case RFCTYPE.RFCTYPE_DTDAY:
        case RFCTYPE.RFCTYPE_DTWEEK:
        case RFCTYPE.RFCTYPE_DTMONTH:
        case RFCTYPE.RFCTYPE_TSECOND:
        case RFCTYPE.RFCTYPE_TMINUTE:
        case RFCTYPE.RFCTYPE_CDAY:
            writefln(INDENT ~ "/* Type %s not yet implemented */", RfcGetTypeAsString(param.type));
            break;
        case RFCTYPE.RFCTYPE_ABAPOBJECT:
        case RFCTYPE.RFCTYPE_BOX:
        case RFCTYPE.RFCTYPE_GENERIC_BOX:
        case RFCTYPE._RFCTYPE_max_value:
            writefln(INDENT ~ "/* Type %s not supported */", RfcGetTypeAsString(param.type));
            break;
    }
}

void generateGetter(RFC_PARAMETER_DESC param, wstring funcvar)
{
    auto abapname = param.name[0..strlenU16(param.name.ptr)];
    auto dname = abapname;
    final switch (param.type)
    {
        case RFCTYPE.RFCTYPE_CHAR:
            auto len = param.getLength;
            if (len > 1)
                writefln(INDENT ~ "RfcGetChars(%s, \"%s\"w.ptr, %s.ptr, %d);", funcvar, abapname, dname, len);
            else
                writefln(INDENT ~ "RfcGetChars(%s, \"%s\"w.ptr, &%s, 1);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_DATE:
            writefln(INDENT ~ "RfcGetDate(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_BCD:
            writefln(INDENT ~ "RfcGetNum(%s, \"%s\"w.ptr, %s.ptr, %d);", funcvar, abapname, dname, param.getLength);
            break;
        case RFCTYPE.RFCTYPE_TIME:
            writefln(INDENT ~ "RfcGetTime(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_BYTE:
            writefln(INDENT ~ "RfcGetBytes(%s, \"%s\"w.ptr, %s.ptr, %d);", funcvar, abapname, dname, param.getLength);
            break;
        case RFCTYPE.RFCTYPE_INT:
            writefln(INDENT ~ "RfcGetInt(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_INT2:
            writefln(INDENT ~ "RfcGetInt2(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_INT1:
            writefln(INDENT ~ "RfcGetInt1(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_INT8:
            writefln(INDENT ~ "RfcGetInt8(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_DECF16:
            writefln(INDENT ~ "RfcGetDecF16(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_DECF34:
            writefln(INDENT ~ "RfcGetDecF34(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_FLOAT:
            writefln(INDENT ~ "RfcGetFloat(%s, \"%s\"w.ptr, %s);", funcvar, abapname, dname);
            break;
        case RFCTYPE.RFCTYPE_NUM:
            writefln(INDENT ~ "RfcGetNum(%s, \"%s\"w.ptr, %s.ptr, %d);", funcvar, abapname, dname, param.getLength);
            break;
        case RFCTYPE.RFCTYPE_STRING:
            writefln(INDENT ~ "RfcGetString(%s, \"%s\"w.ptr, %s.ptr, cast(uint)%s.length);", funcvar, abapname, dname, dname);
            break;
        case RFCTYPE.RFCTYPE_XSTRING:
            writefln(INDENT ~ "RfcXGetString(%s, \"%s\"w.ptr, %s.ptr, cast(uint)%s.length);", funcvar, abapname, dname, dname);
            break;
        case RFCTYPE.RFCTYPE_XMLDATA:
            writefln(INDENT ~ "RfcGetString(%s, \"%s\"w.ptr, %s.ptr, cast(uint)%s.length);", funcvar, abapname, dname, dname);
            break;
        case RFCTYPE.RFCTYPE_TABLE:
            writefln(INDENT ~ "auto %s__tbl = RfcGetTable(%s, \"%s\"w.ptr);", dname, funcvar, abapname);
            writefln(INDENT ~ "copyTo(%s__tbl, %s);", dname, dname);
            break;
        case RFCTYPE.RFCTYPE_STRUCTURE:
            writefln(INDENT ~ "auto %s__strk = RfcSetStructure(%s, \"%s\"w.ptr);", dname, funcvar, abapname);
            writefln(INDENT ~ "copyTo(%s__strk, %s);", dname, dname);
            break;
        case RFCTYPE.RFCTYPE_NULL:
        case RFCTYPE.RFCTYPE_UTCLONG:
        case RFCTYPE.RFCTYPE_UTCSECOND:
        case RFCTYPE.RFCTYPE_UTCMINUTE:
        case RFCTYPE.RFCTYPE_DTDAY:
        case RFCTYPE.RFCTYPE_DTWEEK:
        case RFCTYPE.RFCTYPE_DTMONTH:
        case RFCTYPE.RFCTYPE_TSECOND:
        case RFCTYPE.RFCTYPE_TMINUTE:
        case RFCTYPE.RFCTYPE_CDAY:
            writefln(INDENT ~ "/* Type %s not yet implemented */", RfcGetTypeAsString(param.type));
            break;
        case RFCTYPE.RFCTYPE_ABAPOBJECT:
        case RFCTYPE.RFCTYPE_BOX:
        case RFCTYPE.RFCTYPE_GENERIC_BOX:
        case RFCTYPE._RFCTYPE_max_value:
            writefln(INDENT ~ "/* Type %s not supported */", RfcGetTypeAsString(param.type));
            break;
    }
}

bool generateSetter(RFC_PARAMETER_DESC[] params, wstring funcvar)
{
    bool newline = false;
    foreach (param; params)
    {
        if (param.direction != RFC_DIRECTION.RFC_IMPORT && param.direction != RFC_DIRECTION.RFC_CHANGING)
            continue;
        if (newline)
            writeln();
        newline = true;
        generateSetter(param, funcvar);
    }
    return newline;
}

bool generateGetter(RFC_PARAMETER_DESC[] params, wstring funcvar)
{
    bool newline = false;
    foreach (param; params)
    {
        if (param.direction != RFC_DIRECTION.RFC_EXPORT && param.direction != RFC_DIRECTION.RFC_CHANGING)
            continue;
        if (newline)
            writeln();
        newline = true;
        generateGetter(param, funcvar);
    }
    return newline;
}

void dumpMetadataAsD(RFC_FUNCTION_DESC_HANDLE funcDesc)
{
    // Dump metadata as comment
    writeln("// Written in the D programming language.");
    writeln("\n// EXPERIMENTAL\n");
    writeln("/*");
    dumpMetadata(funcDesc);
    writeln("*/");
    writeln();

    if (dumpParameterTypesAsD(funcDesc))
        writeln();

    auto params = sortParams(funcDesc);

    auto funcName = RfcGetFunctionName(funcDesc);

    writefln("void %s(", typename(funcName));
    write("    RFC_CONNECTION_HANDLE con");
    foreach (param; params)
    {
        write(",\n    ");
        auto pmod = modifier(param);
        auto ptyp = paramType(param);
        auto pnam = param.name[0..strlenU16(param.name.ptr)];
        if (pmod.length)
            writef("%s %s %s", pmod, ptyp, pnam);
        else
            writef("%s %s", ptyp, pnam);
    }

    writeln(")\n{");
    if (generateMixins(params))
        writeln();

    auto funcvar = "func"w;
    writefln(INDENT ~ "auto desc = RfcGetFunctionDesc(con, \"%s\"w);", funcName);
    writeln(INDENT ~ "auto func = RfcCreateFunction(desc);");
    writefln(INDENT ~ "scope(exit) RfcDestroyFunction(%s);", funcvar);
    writeln();

    if (generateSetter(params, funcvar))
        writeln();

    writefln(INDENT ~ "RfcInvoke(con, %s);", funcvar);
    writeln();

    generateGetter(params, funcvar);

    writeln("}");
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