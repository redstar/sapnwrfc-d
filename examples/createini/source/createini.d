// Written in the D programming language.

/* Example application for SAP NetWeaver RFC
   Reads a saplogon.ini file and creates a sapnwrfc.ini from the data.
*/
module createini;

private import std.string;
private import std.stdio;
private import std.traits : isSomeString;

public import etc.c.sapnwrfc : RFC_CONNECTION_PARAMETER, cU;
import etc.c.sapuc : strlenU16;

enum VERSION = "0.1";
    
/*
 * Function to read the saplogon.ini file.
 *
 * For a description of the file format, please see https://service.sap.com/sap/support/notes/99435.
 */

// Parses the lines of the ini file
string[string][string] parse(string[] lines)
{
    string[string][string] res;
    auto section = "";

    foreach(line; lines)
    {
        line = line.strip;

        // Ignore empty or comment lines
        if (line.length == 0 || line.startsWith(";"))
            continue;
        
        // Start of new section?
        if (line.startsWith("[") && line.endsWith("]"))
        {
            section = line[1..line.length-1];
        }
        else
        {
            auto idx = line.indexOf('=');
            if (idx < 1)
                continue; // Ignore bad lines
            
            auto key = line[0..idx].strip;
            auto value = line[idx+1..line.length].strip;
            res[section][key] = value;
        }
    }

    return res;
}

// Maps the parsed values of the ini file to RFC_CONNECTION_PARAMETER values
RFC_CONNECTION_PARAMETER[][string] map(string[string][string] raw)
{
    RFC_CONNECTION_PARAMETER[][string] res;

    foreach (item, sysname; raw["MSSysName"])
    {
        // Ignore systems without a "MSSysName"
        if (sysname == "")
            continue;

        RFC_CONNECTION_PARAMETER[10] params;
        int nextParam = 0;

        void set(wstring param, string key)
        {
            auto val = raw[key][item];
            if (val.length)
            {
                params[nextParam++] = RFC_CONNECTION_PARAMETER(param.ptr, cU(val));
            }
        }

        params[nextParam++] = RFC_CONNECTION_PARAMETER("DEST"w.ptr, cU(sysname));
        auto origin = raw["Origin"][item];
        auto server = raw["Server"][item];
        if (origin == "MS_SEL_GROUPS")
        {
            set("GROUP", "Server");
            //set("MSHOST", "MSSrvName");
            // Assuming that "MSSysName" is always present
            // set(Parameter.SYSID, "MSSysName");
        }
        else //origin == "MS_SEL_SERVER" || origin == "USEREDIT"
        {
            set("ASHOST", "Server");
            // Assuming that "Database" is always present
            // set(Parameter.SYSNR, "Database");
        }
        set("SYSNR", "Database");
        set("MSHOST", "MSSrvName");
        set("MSSERV", "MSSrvPort");
        set("SAPROUTER", "Router");
        auto cpi = raw["CodepageIndex"][item];
        if (cpi.length > 0 && cpi != "-1")
            set("CODEPAGE", "Codepage");
        auto sncChoice = raw["SncChoice"][item];
        if (sncChoice.length > 0 && sncChoice != "-1")
        {
            set("SNC_QOP", "SncChoice");
            set("SNC_PARTNERNAME", "SncName");
            set("SNC_SSO", raw["SncNoSSO"][item] == "0" ? "1" : "0");
        }

        res[sysname] = params[0..nextParam].dup;
    }
    return res;
}

unittest
{
    string[] lines = [
        "[Origin]",
        "Item1=USEREDIT",
        "; This is a comment!"
    ];
    auto res = parse(lines);
    assert("Origin" in res);
    assert("Item1" in res["Origin"]);
    assert(res["Origin"]["Item1"] == "USEREDIT");
    writeln("Success.");
}

void usage()
{
    writefln("CreateIni V%s", VERSION);
    writeln("\nUsage:");
    writeln("    createinit <SAPLOGONINI>");
    writeln("\nParameter:");
    writeln("    <SAPLOGONINI>    Path to saplogon.ini");
    writeln("\nExample:");
    writeln("    createini C:\\Windows\\saplogon.ini");
}

int main(string[] args)
{
    if (args.length != 2)
    {
        usage();
        return 1;       
    }
    
    import std.file : read;
    auto rawcontent = read(args[1]);
    version (Windows)
    {
        import core.sys.windows.windows;
        import std.windows.syserror;
        static import std.utf;
        
        wchar[] result;
        int readLen;
        result.length = MultiByteToWideChar(CP_ACP, 0, cast(const(char)*)rawcontent.ptr, cast(int)rawcontent.length, null, 0);
        if (result.length)
        {
            readLen = MultiByteToWideChar(CP_ACP, 0, cast(const(char)*)rawcontent.ptr, cast(int)rawcontent.length, result.ptr, cast(int)result.length);
        }
        if (!readLen || readLen != result.length)
        {
            throw new Exception("Couldn't convert string: " ~ sysErrorString(GetLastError()));
        }
        auto content = std.utf.toUTF8(result).split("\n");
    }
    else
        auto content = rawcontent.split("\n");

    auto config = map(parse(content));
    foreach (name, params; config)
    {
        foreach (param; params)
        {
            writefln("%s=%s", param.name[0..strlenU16(param.name)], param.value[0..strlenU16(param.value)]);
        }
        writeln();
    }
    
    return 0;
}