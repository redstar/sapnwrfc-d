// Written in the D programming language.

module sapnwrfc.data;

import sapnwrfc.binding;
import etc.c.sapnwrfc : RFCTYPE;

struct FieldType
{
    RFCTYPE type;
    size_t length;
}

private alias helper(alias T) = T;

mixin template RfcStructHelper(T)
{
    // Copy RFC structure to D structure
    void copyTo(RFC_STRUCTURE_HANDLE handle, out T value)
    {
        import std.traits : Unqual, isStaticArray;

        foreach(wstring memberName; __traits(allMembers, T))
        {
            alias member = helper!(__traits(getMember, value, memberName));

            static if (is(typeof(member) == RFC_CHAR))
            {
                RfcGetChars(handle, memberName.ptr, &__traits(getMember, value, memberName), 1);
            }
            else static if (is(Unqual!(typeof(member)) == RFC_CHAR[]))
            {
                __traits(getMember, value, memberName).length = RfcGetStringLength(handle, memberName.ptr);
                RfcGetChars(handle, memberName.ptr, __traits(getMember, value, memberName).ptr, cast(uint)__traits(getMember, value, memberName).length);
            }
            else static if ((isStaticArray!(typeof(member)) && is(Unqual!(typeof(member[0])) == RFC_CHAR)))
            {
                RfcGetChars(handle, memberName.ptr, __traits(getMember, value, memberName).ptr, cast(uint)__traits(getMember, value, memberName).length);
            }
            else static if (is(typeof(member) == RFC_BYTE))
            {
                RfcGetBytes(handle, memberName.ptr, &__traits(getMember, value, memberName), 1);
            }
            else static if (is(typeof(member) == RFC_BYTE[]) || (isStaticArray!(typeof(member)) && is(typeof(member[0]) == RFC_BYTE)))
            {
                RfcGetBytes(handle, memberName.ptr, __traits(getMember, value, memberName).ptr, cast(uint)member.length);
            }
            else static if (is(typeof(member) == RFC_INT))
            {
                RfcGetInt(handle, memberName.ptr, __traits(getMember, value, memberName));
            }
            else static if (is(typeof(member) == RFC_INT1))
            {
                RfcGetInt1(handle, memberName.ptr, __traits(getMember, value, memberName));
            }
            else static if (is(typeof(member) == RFC_INT2))
            {
                RfcGetInt2(handle, memberName.ptr, __traits(getMember, value, memberName));
            }
            else static if (is(typeof(member) == RFC_INT8))
            {
                version (sapnwrfc_sdk_750)
                    RfcGetInt8(handle, memberName.ptr, __traits(getMember, value, memberName));
                else
                    static assert(false, "RFC_INT8 not supported");
            }
            else static if (is(typeof(member) == RFC_FLOAT))
            {
                RfcGetFloat(handle, memberName.ptr, __traits(getMember, value, memberName));
            }
            else
            {
                static assert(false, "Type " ~ typeof(member).stringof ~ "not supported");
            }
        }
    }

    // Copy RFC structure from D structure
    void copyFrom(RFC_STRUCTURE_HANDLE handle, in T value)
    {
        import std.traits : Unqual, isStaticArray;

        foreach(wstring memberName; __traits(allMembers, T))
        {
            alias member = helper!(__traits(getMember, value, memberName));

            static if (is(Unqual!(typeof(__traits(getMember, value, memberName))) == RFC_CHAR))
            {
                RfcSetChars(handle, memberName.ptr, &__traits(getMember, value, memberName), 1);
            }
            else static if (is(Unqual!(typeof(member)) == RFC_CHAR[]) || (isStaticArray!(typeof(member)) && is(Unqual!(typeof(member[0])) == RFC_CHAR)))
            {
                RfcSetString(handle, memberName.ptr, __traits(getMember, value, memberName).ptr, cast(uint)__traits(getMember, value, memberName).length);
            }
            else static if (is(Unqual!(typeof(member)) == RFC_BYTE))
            {
                RfcSetBytes(handle, memberName.ptr, &__traits(getMember, value, memberName), 1);
            }
            else static if (is(Unqual!(typeof(member)) == RFC_BYTE[]) || (isStaticArray!(typeof(member)) && is(Unqual!(typeof(member[0])) == RFC_BYTE)))
            {
                RfcSetBytes(handle, memberName.ptr, __traits(getMember, value, memberName).ptr, cast(uint)member.length);
            }
            else static if (is(Unqual!(typeof(member)) == RFC_INT))
            {
                RfcSetInt(handle, memberName.ptr, __traits(getMember, value, memberName));
            }
            else static if (is(Unqual!(typeof(member)) == RFC_INT1))
            {
                RfcSetInt1(handle, memberName.ptr, __traits(getMember, value, memberName));
            }
            else static if (is(Unqual!(typeof(member)) == RFC_INT2))
            {
                RfcSetInt2(handle, memberName.ptr, __traits(getMember, value, memberName));
            }
            else static if (is(Unqual!(typeof(member)) == RFC_INT8))
            {
                version (sapnwrfc_sdk_750)
                    RfcSetInt8(handle, memberName.ptr, __traits(getMember, value, memberName));
                else
                    static assert(false, "RFC_INT8 not supported");
            }
            else static if (is(Unqual!(typeof(member)) == RFC_FLOAT))
            {
                RfcSetFloat(handle, memberName.ptr, __traits(getMember, value, memberName));
            }
            else
            {
                static assert(false, "Type " ~ typeof(member).stringof ~ "not supported");
            }
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
