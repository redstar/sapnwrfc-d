﻿// Written in the D programming language.

module sapnwrfc.binding;

import etc.c.sapnwrfc;

import std.meta;
import std.traits;
import std.conv : to;
import std.algorithm : endsWith, startsWith;
static import std.utf;

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
        return cast(wstring)rcmsg[0 .. strlenU16(rcmsg)];
    }

    @property RFC_ERROR_GROUP group()
    {
        return errorInfo.group;
    }

    @property wstring key()
    {
        return errorInfo.key[0 .. strlenU16(errorInfo.key.ptr)];
    }

    @property wstring message()
    {
        return cast(wstring)errorInfo.message[0 .. strlenU16(errorInfo.message.ptr)];
    }

    @property wstring abapMsgClass()
    {
        return cast(wstring)errorInfo.abapMsgClass[0 .. strlenU16(errorInfo.abapMsgClass.ptr)];
    }

    @property wstring abapMsgType()
    {
        return cast(wstring)errorInfo.abapMsgType[0 .. strlenU16(errorInfo.abapMsgType.ptr)];
    }

    // abapMsgNumber ?

    @property wstring abapMsgV1()
    {
        return cast(wstring)errorInfo.abapMsgV1[0 .. strlenU16(errorInfo.abapMsgV1.ptr)];
    }

    @property wstring abapMsgV2()
    {
        return cast(wstring)errorInfo.abapMsgV2[0 .. strlenU16(errorInfo.abapMsgV2.ptr)];
    }

    @property wstring abapMsgV3()
    {
        return cast(wstring)errorInfo.abapMsgV3[0 .. strlenU16(errorInfo.abapMsgV3.ptr)];
    }

    @property wstring abapMsgV4()
    {
        return cast(wstring)errorInfo.abapMsgV4[0 .. strlenU16(errorInfo.abapMsgV4.ptr)];
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
                string src = "string file = __FILE__, size_t line = __LINE__) {\n" ~
                              "    RFC_ERROR_INFO errorInfo;\n" ~
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
                        version(sapnwrfc_sdk_750)
                        {
                        alias Types = AliasSeq!(RFC_SERVER_ERROR_LISTENER, RFC_SERVER_STATE_CHANGE_LISTENER,
                                                RFC_SERVER_FUNCTION, RFC_ON_CHECK_TRANSACTION, RFC_ON_COMMIT_TRANSACTION, RFC_ON_ROLLBACK_TRANSACTION,
                                                RFC_ON_CONFIRM_TRANSACTION, RFC_FUNC_DESC_CALLBACK, RFC_PM_CALLBACK, RFC_ON_CHECK_UNIT, RFC_ON_COMMIT_UNIT,
                                                RFC_ON_ROLLBACK_UNIT, RFC_ON_CONFIRM_UNIT, RFC_ON_GET_UNIT_STATE, RFC_ON_PASSWORD_CHANGE, RFC_ON_AUTHORIZATION_CHECK);
                        alias Names = AliasSeq!("RFC_SERVER_ERROR_LISTENER", "RFC_SERVER_STATE_CHANGE_LISTENER",
                                                "RFC_SERVER_FUNCTION", "RFC_ON_CHECK_TRANSACTION", "RFC_ON_COMMIT_TRANSACTION", "RFC_ON_ROLLBACK_TRANSACTION",
                                                "RFC_ON_CONFIRM_TRANSACTION", "RFC_FUNC_DESC_CALLBACK", "RFC_PM_CALLBACK", "RFC_ON_CHECK_UNIT", "RFC_ON_COMMIT_UNIT",
                                                "RFC_ON_ROLLBACK_UNIT", "RFC_ON_CONFIRM_UNIT", "RFC_ON_GET_UNIT_STATE", "RFC_ON_PASSWORD_CHANGE", "RFC_ON_AUTHORIZATION_CHECK");
                        }
                        else
                        {
                        alias Types = AliasSeq!(RFC_SERVER_FUNCTION, RFC_ON_CHECK_TRANSACTION, RFC_ON_COMMIT_TRANSACTION, RFC_ON_ROLLBACK_TRANSACTION,
                                                RFC_ON_CONFIRM_TRANSACTION, RFC_FUNC_DESC_CALLBACK, RFC_PM_CALLBACK, RFC_ON_CHECK_UNIT, RFC_ON_COMMIT_UNIT,
                                                RFC_ON_ROLLBACK_UNIT, RFC_ON_CONFIRM_UNIT, RFC_ON_GET_UNIT_STATE, RFC_ON_PASSWORD_CHANGE, RFC_ON_AUTHORIZATION_CHECK);
                        alias Names = AliasSeq!("RFC_SERVER_FUNCTION", "RFC_ON_CHECK_TRANSACTION", "RFC_ON_COMMIT_TRANSACTION", "RFC_ON_ROLLBACK_TRANSACTION",
                                                "RFC_ON_CONFIRM_TRANSACTION", "RFC_FUNC_DESC_CALLBACK", "RFC_PM_CALLBACK", "RFC_ON_CHECK_UNIT", "RFC_ON_COMMIT_UNIT",
                                                "RFC_ON_ROLLBACK_UNIT", "RFC_ON_CONFIRM_UNIT", "RFC_ON_GET_UNIT_STATE", "RFC_ON_PASSWORD_CHANGE", "RFC_ON_AUTHORIZATION_CHECK");
                        }
                        static if (staticIndexOf!(ParameterTypeTuple!member[idx], Types) >= 0)
                            head ~= Names[staticIndexOf!(ParameterTypeTuple!member[idx], Types)];
                        else
                            head ~= ParameterTypeTuple!member[idx].stringof;
                        head ~= " p" ~ to!string(idx) ~ ", ";
                        src ~= "p" ~ to!string(idx);
                    }
                    if (idx+1 < len) src ~= ", ";
                }

                if (errorInfoSeen) code ~= head ~ src ~ tail;
            }

            // Special bindings for RfcGet*Count functions
            static if (is(ReturnType!member == RFC_RC) && ParameterTypeTuple!member.length == 3
                && memberName.startsWith("RfcGet") && memberName.endsWith("Count")
                && is(ParameterTypeTuple!member[1] == uint) && ParameterStorageClassTuple!member[1] == STC.out_
                && is(ParameterTypeTuple!member[2] == RFC_ERROR_INFO)
                )
            {
                string src = "size_t " ~ memberName ~ "(";
                src ~= ParameterTypeTuple!member[0].stringof;
                src ~= " handle)\n";
                src ~= "{ uint count; " ~ memberName ~ "(handle, count); return count; }\n";
                code ~= src;
            }


            // Special bindings for RfcGet*ByIndex functions
            static if (is(ReturnType!member == RFC_RC) && ParameterTypeTuple!member.length == 4
                && memberName.startsWith("RfcGet") && memberName.endsWith("ByIndex")
                && is(ParameterTypeTuple!member[1] == uint) && ParameterStorageClassTuple!member[2] == STC.out_
                && is(ParameterTypeTuple!member[3] == RFC_ERROR_INFO)
                )
            {
                string src = "void " ~ memberName ~ "(";
                src ~= ParameterTypeTuple!member[0].stringof;
                src ~= " handle, size_t idx, out ";
                src ~= ParameterTypeTuple!member[2].stringof;
                src ~= " value)\n";
                src ~= "{ " ~ memberName ~ "(handle, cast(uint) idx, value); }\n";
                code ~= src;
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

RFC_FUNCTION_DESC_HANDLE RfcGetFunctionDesc(RFC_CONNECTION_HANDLE rfcHandle, in wstring name)
{
    return RfcGetFunctionDesc(rfcHandle, std.utf.toUTF16z(name));
}

RFC_TYPE_DESC_HANDLE RfcGetTypeDesc(RFC_CONNECTION_HANDLE rfcHandle, in wstring name)
{
    return RfcGetTypeDesc(rfcHandle, std.utf.toUTF16z(name));
}

RFC_EXCEPTION_DESC RfcGetExceptionDescByIndex(RFC_FUNCTION_DESC_HANDLE rfcHandle, size_t idx)
{
    RFC_EXCEPTION_DESC desc;
    RfcGetExceptionDescByIndex(rfcHandle, cast(uint)idx, desc);
    return desc;
}

RFC_EXCEPTION_DESC RfcGetExceptionDescByName(RFC_FUNCTION_DESC_HANDLE rfcHandle, in wstring name)
{
    RFC_EXCEPTION_DESC desc;
    RfcGetExceptionDescByName(rfcHandle, std.utf.toUTF16z(name), desc);
    return desc;
}

RFC_FIELD_DESC RfcGetFieldDescByIndex(RFC_TYPE_DESC_HANDLE rfcHandle, size_t idx)
{
    RFC_FIELD_DESC desc;
    RfcGetFieldDescByIndex(rfcHandle, cast(uint)idx, desc);
    return desc;
}

RFC_FIELD_DESC RfcGetFieldDescByName(RFC_TYPE_DESC_HANDLE rfcHandle, in wstring name)
{
    RFC_FIELD_DESC desc;
    RfcGetFieldDescByName(rfcHandle, std.utf.toUTF16z(name), desc);
    return desc;
}

RFC_PARAMETER_DESC RfcGetParameterDescByIndex(RFC_FUNCTION_DESC_HANDLE rfcHandle, size_t idx)
{
    RFC_PARAMETER_DESC desc;
    RfcGetParameterDescByIndex(rfcHandle, cast(uint)idx, desc);
    return desc;
}

RFC_PARAMETER_DESC RfcGetParameterDescByName(RFC_FUNCTION_DESC_HANDLE rfcHandle, in wstring name)
{
    RFC_PARAMETER_DESC desc;
    RfcGetParameterDescByName(rfcHandle, std.utf.toUTF16z(name), desc);
    return desc;
}

void RfcMoveTo(RFC_TABLE_HANDLE handle, size_t index)
{
	RfcMoveTo(handle, cast(uint)index);
}

wstring RfcGetFunctionName(RFC_FUNCTION_DESC_HANDLE handle)
{
    RFC_ABAP_NAME name;
    RfcGetFunctionName(handle, name);
    return name[0..strlenU16(name.ptr)].idup;
}

wstring RfcGetTypeName(RFC_TYPE_DESC_HANDLE handle)
{
    RFC_ABAP_NAME name;
    RfcGetTypeName(handle, name);
    return name[0..strlenU16(name.ptr)].idup;
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

int RfcGetInt(DATA_CONTAINER_HANDLE dataHandle, in wstring name)
{
	int value;
    RfcGetInt(dataHandle, std.utf.toUTF16z(name), value);
    return value;
}

ubyte RfcGetInt1(DATA_CONTAINER_HANDLE dataHandle, in wstring name)
{
    ubyte value;
    RfcGetInt1(dataHandle, std.utf.toUTF16z(name), value);
    return value;
}

short RfcGetInt2(DATA_CONTAINER_HANDLE dataHandle, in wstring name)
{
    short value;
    RfcGetInt2(dataHandle, std.utf.toUTF16z(name), value);
    return value;
}

double RfcGetFloat(DATA_CONTAINER_HANDLE dataHandle, in wstring name)
{
    double value;
    RfcGetFloat(dataHandle, std.utf.toUTF16z(name), value);
    return value;
}

RFC_STRUCTURE_HANDLE RfcGetStructure(DATA_CONTAINER_HANDLE dataHandle, in const(wchar)* name)
{
    RFC_STRUCTURE_HANDLE value;
    RfcGetStructure(dataHandle, name, value);
    return value;
}

RFC_STRUCTURE_HANDLE RfcGetStructure(DATA_CONTAINER_HANDLE dataHandle, in wstring name)
{
    return RfcGetStructure(dataHandle, std.utf.toUTF16z(name));
}

RFC_TABLE_HANDLE RfcGetTable(DATA_CONTAINER_HANDLE dataHandle, in const(wchar)* name)
{
    RFC_TABLE_HANDLE value;
    RfcGetTable(dataHandle, name, value);
    return value;
}

RFC_TABLE_HANDLE RfcGetTable(DATA_CONTAINER_HANDLE dataHandle, in wstring name)
{
    return RfcGetTable(dataHandle, std.utf.toUTF16z(name));
}

RFC_ABAP_OBJECT_HANDLE RfcGetAbapObject(DATA_CONTAINER_HANDLE dataHandle, in const(wchar)* name)
{
    RFC_ABAP_OBJECT_HANDLE value;
    RfcGetAbapObject(dataHandle, name, value);
    return value;
}

RFC_ABAP_OBJECT_HANDLE RfcGetAbapObject(DATA_CONTAINER_HANDLE dataHandle, in wstring name)
{
    return RfcGetAbapObject(dataHandle, std.utf.toUTF16z(name));
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

void RfcSetString(DATA_CONTAINER_HANDLE dataHandle, const(SAP_UC)* name, const(SAP_UC)* value, size_t length)
{
	RfcSetString(dataHandle, name, value, cast(uint) length);
}

void RfcSetString(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in wstring value)
{
    RfcSetString(dataHandle, std.utf.toUTF16z(name), value.ptr, cast(uint)value.length);
}

void RfcSetStringByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, const(SAP_UC)* value, size_t length)
{
	RfcSetStringByIndex(dataHandle, cast(uint)index, value, cast(uint) length);
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
