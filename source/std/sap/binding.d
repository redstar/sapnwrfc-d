// Written in the D programming language.

module std.sap.binding;

import etc.c.sapnwrfc;

import std.traits;
import std.conv : to;

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

class SAPException : Exception
{
    private immutable RFC_ERROR_INFO errorInfo;

    @safe pure nothrow this(in RFC_ERROR_INFO errorInfo,
                            string file = __FILE__,
                            size_t line = __LINE__)
    {
        super(null, file, line);
        this.errorInfo = errorInfo;
    }

    @property RFC_RC code()
    {
        return errorInfo.code;
    }

    @property wstring codeAsString()
    {
        auto rcmsg = RfcGetRcAsString(errorInfo.code);
        return cast(wstring)rcmsg[0 .. wcslen(rcmsg)];
    }

    @property RFC_ERROR_GROUP group()
    {
        return errorInfo.group;
    }

    @property wstring key()
    {
        return errorInfo.key[0 .. wcslen(errorInfo.key.ptr)];
    }

    @property wstring message()
    {
        return cast(wstring)errorInfo.message[0 .. wcslen(errorInfo.message.ptr)];
    }

    @property wstring abapMsgClass()
    {
        return cast(wstring)errorInfo.abapMsgClass[0 .. wcslen(errorInfo.abapMsgClass.ptr)];
    }

    @property wstring abapMsgType()
    {
        return cast(wstring)errorInfo.abapMsgType[0 .. wcslen(errorInfo.abapMsgType.ptr)];
    }

    // abapMsgNumber ?

    @property wstring abapMsgV1()
    {
        return cast(wstring)errorInfo.abapMsgV1[0 .. wcslen(errorInfo.abapMsgV1.ptr)];
    }

    @property wstring abapMsgV2()
    {
        return cast(wstring)errorInfo.abapMsgV2[0 .. wcslen(errorInfo.abapMsgV2.ptr)];
    }

    @property wstring abapMsgV3()
    {
        return cast(wstring)errorInfo.abapMsgV3[0 .. wcslen(errorInfo.abapMsgV3.ptr)];
    }

    @property wstring abapMsgV4()
    {
        return cast(wstring)errorInfo.abapMsgV4[0 .. wcslen(errorInfo.abapMsgV4.ptr)];
    }
}

private void enforce(in RFC_ERROR_INFO errorInfo,
                     string file = __FILE__, size_t line = __LINE__)
{
    if (errorInfo.code != RFC_RC.RFC_OK)
    {
        throw new SAPException(errorInfo, file, line);
    }
}

alias helper(alias T) = T;
private string generate()
{
    alias mod = helper!(mixin(moduleName!RFC_RC));

    alias STC = ParameterStorageClass;

    string code = "";
    foreach (memberName; __traits(allMembers, mod))
    {
    /*
        static if (memberName == "RFC_ON_PASSWORD_CHANGE")
        {
            pragma(msg, __traits(getMember, mod, memberName));
            pragma(msg, is(typeof(__traits(getMember, mod, memberName)) == function));
            pragma(msg, isFunctionPointer!(__traits(getMember, mod, memberName)));
        }
     */
        static if (is(typeof(__traits(getMember, mod, memberName)) == function))
        {
            alias member = helper!(__traits(getMember, mod, memberName));

            bool errorInfoSeen = false;
            foreach(idx, argName; ParameterIdentifierTuple!member)
                static if (is(ParameterTypeTuple!member[idx] == RFC_ERROR_INFO))
                    errorInfoSeen = true;

            if (errorInfoSeen)
            {
                bool hasReturn = !is(ReturnType!member == void) && !is(ReturnType!member == RFC_RC);
                string head = (hasReturn ? ReturnType!member.stringof : "void") ~ " " ~ memberName ~ "(";
                string src = "string file = __FILE__, size_t line = __LINE__) {\n"
                              "    RFC_ERROR_INFO errorInfo;\n"
                              "    " ~ (hasReturn ? "auto ret = " : "") ~ "etc.c.sapnwrfc." ~ memberName ~ "(";
                string tail = ");\n    enforce(errorInfo, file, line);\n" ~ (hasReturn ? "    return ret;\n" : "") ~ "}\n";

                immutable len = ParameterTypeTuple!member.length;
                foreach(idx, argName; ParameterIdentifierTuple!member)
                {
                    static if (is(ParameterTypeTuple!member[idx] == RFC_ERROR_INFO))
                    {
                        src ~= "errorInfo";
                    }
                    else
                    {
                        static if (ParameterStorageClassTuple!member[idx] == STC.ref_)
                            head ~= "ref ";
                        else static if (ParameterStorageClassTuple!member[idx] == STC.out_)
                            head ~= "out ";
                        // FIXME: Use AliasSeq
                        static if (is(ParameterTypeTuple!member[idx] == RFC_SERVER_FUNCTION))
                            head ~= "RFC_SERVER_FUNCTION";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_CHECK_TRANSACTION))
                            head ~= "RFC_ON_CHECK_TRANSACTION";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_COMMIT_TRANSACTION))
                            head ~= "RFC_ON_COMMIT_TRANSACTION";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_ROLLBACK_TRANSACTION))
                            head ~= "RFC_ON_ROLLBACK_TRANSACTION";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_CONFIRM_TRANSACTION))
                            head ~= "RFC_ON_CONFIRM_TRANSACTION";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_FUNC_DESC_CALLBACK))
                            head ~= "RFC_FUNC_DESC_CALLBACK";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_PM_CALLBACK))
                            head ~= "RFC_PM_CALLBACK";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_CHECK_UNIT))
                            head ~= "RFC_ON_CHECK_UNIT";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_COMMIT_UNIT))
                            head ~= "RFC_ON_COMMIT_UNIT";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_ROLLBACK_UNIT))
                            head ~= "RFC_ON_ROLLBACK_UNIT";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_CONFIRM_UNIT))
                            head ~= "RFC_ON_CONFIRM_UNIT";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_GET_UNIT_STATE))
                            head ~= "RFC_ON_GET_UNIT_STATE";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_PASSWORD_CHANGE))
                            head ~= "RFC_ON_PASSWORD_CHANGE";
                        else if (is(ParameterTypeTuple!member[idx] == RFC_ON_AUTHORIZATION_CHECK))
                            head ~= "RFC_ON_AUTHORIZATION_CHECK";
                        else
                            head ~= ParameterTypeTuple!member[idx].stringof;
                        head ~= " p" ~ to!string(idx) ~ ", ";
                        src ~= "p" ~ to!string(idx);
                    }
                    if (idx+1 < len) src ~= ", ";
                }

                if (errorInfoSeen) code ~= head ~ src ~ tail;
            }
        }
    }

    return code;
}

mixin(generate());

// Some manual bindings.
// FIXME: Create via reflection.

RFC_CONNECTION_HANDLE RfcOpenConnection(in RFC_CONNECTION_PARAMETER[] connectionParams)
{
    return RfcOpenConnection(connectionParams.ptr, cast(uint)connectionParams.length);
}

RFC_CONNECTION_HANDLE RfcRegisterServer(in RFC_CONNECTION_PARAMETER[] connectionParams)
{
    return RfcRegisterServer(connectionParams.ptr, cast(uint)connectionParams.length);
}

RFC_CONNECTION_HANDLE RfcStartServer(int argc, SAP_UC** argv, in RFC_CONNECTION_PARAMETER[] connectionParams)
{
    return RfcStartServer(argc, argv, connectionParams.ptr, cast(uint)connectionParams.length);
}

// Data container getter

void RfcGetChars(DATA_CONTAINER_HANDLE dataHandle, in wstring name, wchar[] buffer)
{
    RfcGetChars(dataHandle, std.utf.toUTF16z(name), buffer.ptr, cast(uint)buffer.length);
}

void RfcGetCharsByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, wchar[] buffer)
{
    RfcGetCharsByIndex(dataHandle, cast(uint)idx, buffer.ptr, cast(uint)buffer.length);
}

void RfcGetNum(DATA_CONTAINER_HANDLE dataHandle, in wstring name, wchar[] buffer)
{
    RfcGetNum(dataHandle, std.utf.toUTF16z(name), buffer.ptr, cast(uint)buffer.length);
}

void RfcGetNumByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, wchar[] buffer)
{
    RfcGetNumByIndex(dataHandle, cast(uint)idx, buffer.ptr, cast(uint)buffer.length);
}

void RfcGetBytes(DATA_CONTAINER_HANDLE dataHandle, in wstring name, ubyte[] buffer)
{
    RfcGetBytes(dataHandle, std.utf.toUTF16z(name), buffer.ptr, cast(uint)buffer.length);
}

void RfcGetBytesByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, ubyte[] buffer)
{
    RfcGetBytesByIndex(dataHandle, cast(uint)idx, buffer.ptr, cast(uint)buffer.length);
}

void RfcGetString(DATA_CONTAINER_HANDLE dataHandle, in wstring name, wchar[] buffer, out size_t length)
{
    uint len;
    RfcGetString(dataHandle, std.utf.toUTF16z(name), buffer.ptr, cast(uint)buffer.length, len);
    length = len;
}

void RfcGetStringByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, wchar[] buffer, out size_t length)
{
    uint len;
    RfcGetStringByIndex(dataHandle, cast(uint) idx, buffer.ptr, cast(uint)buffer.length, len);
    length = len;
}

size_t RfcGetStringLength(DATA_CONTAINER_HANDLE dataHandle, in wstring name)
{
    uint len;
    RfcGetStringLength(dataHandle, std.utf.toUTF16z(name), len);
    return len;
}

size_t RfcGetStringLengthByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index)
{
    uint len;
    RfcGetStringLengthByIndex(dataHandle, cast(uint)index, len);
    return len;
}

void RfcGetInt(DATA_CONTAINER_HANDLE dataHandle, in wstring name, out int value)
{
    RfcGetInt(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcGetIntByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, out int value)
{
    RfcGetIntByIndex(dataHandle, cast(uint)idx, value);
}

void RfcGetInt1(DATA_CONTAINER_HANDLE dataHandle, in wstring name, out ubyte value)
{
    RfcGetInt1(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcGetInt1ByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, out ubyte value)
{
    RfcGetInt1ByIndex(dataHandle, cast(uint)idx, value);
}

void RfcGetInt2(DATA_CONTAINER_HANDLE dataHandle, in wstring name, out short value)
{
    RfcGetInt2(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcGetInt2ByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, out short value)
{
    RfcGetInt2ByIndex(dataHandle, cast(uint)idx, value);
}

void RfcGetFloat(DATA_CONTAINER_HANDLE dataHandle, in wstring name, out double value)
{
    RfcGetFloat(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcGetFloatByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, out double value)
{
    RfcGetFloatByIndex(dataHandle, cast(uint)idx, value);
}

void RfcGetStructure(DATA_CONTAINER_HANDLE dataHandle, in wstring name, out RFC_STRUCTURE_HANDLE value)
{
    RfcGetStructure(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcGetStructureByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, out RFC_STRUCTURE_HANDLE value)
{
    RfcGetStructureByIndex(dataHandle, cast(uint)idx, value);
}

void RfcGetTable(DATA_CONTAINER_HANDLE dataHandle, in wstring name, out RFC_TABLE_HANDLE value)
{
    RfcGetTable(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcGetTableByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, out RFC_TABLE_HANDLE value)
{
    RfcGetTableByIndex(dataHandle, cast(uint)idx, value);
}

void RfcGetAbapObject(DATA_CONTAINER_HANDLE dataHandle, in wstring name, out RFC_ABAP_OBJECT_HANDLE value)
{
    RfcGetAbapObject(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcGetAbapObjectByIndex(DATA_CONTAINER_HANDLE dataHandle, in size_t idx, out RFC_ABAP_OBJECT_HANDLE value)
{
    RfcGetAbapObjectByIndex(dataHandle, cast(uint)idx, value);
}

// Data container setter

void RfcSetChars(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in wstring value)
{
    RfcSetChars(dataHandle, std.utf.toUTF16z(name), value.ptr, cast(uint)value.length);
}

void RfcSetCharsByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in wstring value)
{
    RfcSetCharsByIndex(dataHandle, cast(uint)index, value.ptr, cast(uint)value.length);
}

void RfcSetNum(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in wstring value)
{
    RfcSetNum(dataHandle, std.utf.toUTF16z(name), value.ptr, cast(uint)value.length);
}

void RfcSetNumByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in wstring value)
{
    RfcSetNumByIndex(dataHandle, cast(uint)index, value.ptr, cast(uint)value.length);
}

void RfcSetBytes(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in ubyte[] value)
{
    RfcSetBytes(dataHandle, std.utf.toUTF16z(name), value.ptr, cast(uint)value.length);
}

void RfcSetBytesByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in ubyte[] value)
{
    RfcSetBytesByIndex(dataHandle, cast(uint)index, value.ptr, cast(uint)value.length);
}

void RfcSetString(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in wstring value)
{
    RfcSetString(dataHandle, std.utf.toUTF16z(name), value.ptr, cast(uint)value.length);
}

void RfcSetStringByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in wstring value)
{
    RfcSetStringByIndex(dataHandle, cast(uint)index, value.ptr, cast(uint)value.length);
}

void RfcSetInt(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in int value)
{
    RfcSetInt(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcSetIntByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in int value)
{
    RfcSetIntByIndex(dataHandle, cast(uint)index, value);
}

void RfcSetInt1(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in ubyte value)
{
    RfcSetInt1(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcSetInt1ByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in ubyte value)
{
    RfcSetInt1ByIndex(dataHandle, cast(uint)index, value);
}

void RfcSetInt2(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in short value)
{
    RfcSetInt2(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcSetInt2ByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in short value)
{
    RfcSetInt2ByIndex(dataHandle, cast(uint)index, value);
}

void RfcSetFloat(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in double value)
{
    RfcSetFloat(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcSetFloatByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in double value)
{
    RfcSetFloatByIndex(dataHandle, cast(uint)index, value);
}

void RfcSetStructure(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in RFC_STRUCTURE_HANDLE value)
{
    RfcSetStructure(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcSetStructureByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in RFC_STRUCTURE_HANDLE value)
{
    RfcSetStructureByIndex(dataHandle, cast(uint)index, value);
}

void RfcSetTable(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in RFC_TABLE_HANDLE value)
{
    RfcSetTable(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcSetTableByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in RFC_TABLE_HANDLE value)
{
    RfcSetTableByIndex(dataHandle, cast(uint)index, value);
}

void RfcSetAbapObject(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in RFC_ABAP_OBJECT_HANDLE value)
{
    RfcSetAbapObject(dataHandle, std.utf.toUTF16z(name), value);
}

void RfcSetAbapObjectByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in RFC_ABAP_OBJECT_HANDLE value)
{
    RfcSetAbapObjectByIndex(dataHandle, cast(uint)index, value);
}
