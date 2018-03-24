// Written in the D programming language.

module sapnwrfc.data;

import sapnwrfc.binding;
import etc.c.sapnwrfc : RFCTYPE;

struct FieldType
{
    RFCTYPE type;
    size_t length;
}

mixin template RfcStructHelper(T)
{
    void copyTo(RFC_STRUCTURE_HANDLE handle, out T value)
    {
        foreach(wstring memberName; __traits(allMembers, T))
        {
            size_t len;
            wchar[64] buffer;
            RfcGetString(handle, memberName, buffer, len);
            __traits(getMember, value, memberName) = buffer[0..len].dup;
        }
    }

    void copyFrom(RFC_STRUCTURE_HANDLE handle, in T value)
    {
        foreach(wstring memberName; __traits(allMembers, T))
        {
            RfcSetString(handle, memberName.ptr, __traits(getMember, value, memberName).ptr, __traits(getMember, value, memberName).length);
        }
    }
}

mixin template RfcTableHelper(T)
{
    void copyTo(RFC_TABLE_HANDLE handle, out T[] value)
    {
    	mixin RfcStructHelper!T structHelper;

        value.length = RfcGetRowCount(handle);
        foreach (i; 0..value.length)
        {
            RfcMoveTo(handle, i);
            auto line = RfcGetCurrentRow(handle);
            structHelper.copyTo(line, value[i]);
        }
    }

    void copyFrom(RFC_TABLE_HANDLE handle, in T[] value)
    {
    	mixin RfcStructHelper!T structHelper;

    	foreach (v; value)
    	{
    		RfcAppendNewRow(handle);
    		structHelper.copyFrom(handle, v);
        }
    }
}
