module etc.c.sapuc;

private import std.utf : toUTF16z;

extern(C):
@nogc:

alias SAP_UTF16 = wchar;

alias cU = toUTF16z;

version(Windows)
{
    private import core.stdc.wchar_ : wcslen;
    alias strlenU16 = wcslen;
}
else
{
    size_t strlenU16(in const(SAP_UTF16)* s)
    {
        const(SAP_UTF16)* p = s;
        while (*p) p++;
        return p - s;
    }
}
