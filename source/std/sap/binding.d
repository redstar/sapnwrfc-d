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

void RfcGetString(DATA_CONTAINER_HANDLE dataHandle, in wstring name, wchar[] buffer, out size_t length)
{
    uint len;
    RfcGetString(dataHandle, std.utf.toUTF16z(name), buffer.ptr, cast(uint)buffer.length, len);
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

// Data container setter

void RfcSetChars(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in wstring value)
{
    RfcSetChars(dataHandle, std.utf.toUTF16z(name), value.ptr, cast(uint)value.length);
}

void RfcSetCharsByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in wstring value)
{
    RfcSetCharsByIndex(dataHandle, cast(uint)index, value.ptr, cast(uint)value.length);
}

void RfcSetString(DATA_CONTAINER_HANDLE dataHandle, in wstring name, in wstring value)
{
    RfcSetString(dataHandle, std.utf.toUTF16z(name), value.ptr, cast(uint)value.length);
}

void RfcSetStringByIndex(DATA_CONTAINER_HANDLE dataHandle, size_t index, in wstring value)
{
    RfcSetStringByIndex(dataHandle, cast(uint)index, value.ptr, cast(uint)value.length);
}
