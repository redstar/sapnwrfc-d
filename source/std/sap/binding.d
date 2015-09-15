﻿// Written in the D programming language.

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

private void enforce(in RFC_RC rc, in RFC_ERROR_INFO errorInfo,
                     string file = __FILE__, size_t line = __LINE__)
{
    if (rc != RFC_RC.RFC_OK)
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
            static if (!is(ReturnType!member == void) && is(ReturnType!member == RFC_RC))
            {
                string head = "void " ~ memberName ~ "(";
                string src = "string file = __FILE__, size_t line = __LINE__) {\n"
                              "    RFC_ERROR_INFO errorInfo;\n"
                              "    enforce(etc.c.sapnwrfc." ~ memberName ~ "(";
                string tail = "), errorInfo, file, line);\n}\n";

                bool errorInfoSeen = false;
                immutable len = ParameterTypeTuple!member.length;
                foreach(idx, argName; ParameterIdentifierTuple!member)
                {
                    static if (is(ParameterTypeTuple!member[idx] == RFC_ERROR_INFO))
                    {
                        errorInfoSeen = true;
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

//pragma(msg, generate());
mixin(generate());