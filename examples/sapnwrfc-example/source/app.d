/* Example application for SAP NetWeaver RFC
   Compute week day of date.
*/
import std.stdio;
import sapnwrfc;

int main(string[] args)
{
    if  (args.length != 3)
    {
        writeln("\nUsage:");
        writeln("    computedate <DEST> <DATE>");
        writeln("\n    <DEST>:    SAP destination");
        writeln("    <DATE>:    date in format YYYYMMDD");
        writeln("\nExample:");
        writeln("    computeday X01 DATE=20170907");
        return 1;
    }
    try
    {
    	auto dest = cU(args[1]);
    	auto date = cU(args[2]);
        RfcInit();
        RFC_CONNECTION_PARAMETER[1] conParams = [ { "DEST"w.ptr, dest } ];
        auto connection = RfcOpenConnection(conParams);
        scope(exit) RfcCloseConnection(connection);

        auto desc = RfcGetFunctionDesc(connection, "DATE_COMPUTE_DAY"w);
        auto func = RfcCreateFunction(desc);
        scope(exit) RfcDestroyFunction(func);

        RfcSetDate(func, "DATE", date[0..8]);
        RfcInvoke(connection, func);

        wchar[1] day;
        RfcGetChars(func, "DAY", day);
        
        writefln("Date %s is weekday %s", date[0..8], day);
    }
    catch (SAPException e)
    {
        writefln("Error occured %d %s", e.code, e.codeAsString);
        writefln("'%s'", e.message);
        return 100;
    }
    return 0;
}