module etc.c.sapnwrfc;

extern(C):

alias SAP_RAW = ubyte;
alias SAP_SRAW = byte;
alias SAP_USHORT = ushort;

alias SAP_UC = wchar;

alias RFC_CHAR = SAP_UC;
alias RFC_NUM = RFC_CHAR;
alias RFC_BYTE = SAP_RAW;
alias RFC_BCD = SAP_RAW;
alias RFC_INT1 = SAP_RAW;
alias RFC_INT2 = short;
alias RFC_INT = int;
alias RFC_INT8 = long;
alias RFC_FLOAT = double;
alias RFC_DATE = RFC_CHAR[8];
alias RFC_TIME = RFC_CHAR[6];
// FIXME
//alias RFC_DECF16 = DecFloat16;
//alias RFC_DECF34 = DecFloat34;
alias RFC_UTCLONG = RFC_INT8;
alias RFC_UTCSECOND = RFC_INT8;
alias RFC_UTCMINUTE = RFC_INT8;
alias RFC_DTDAY = int;
alias RFC_DTWEEK = int;
alias RFC_DTMONTH = int;
alias RFC_TSECOND = int;
alias RFC_TMINUTE = short;
alias RFC_CDAY = short;

// 77
enum RFC_TID_LN = 24;
enum RFC_UNITID_LN = 32;
alias RFC_TID = SAP_UC[RFC_TID_LN+1];
alias RFC_UNITID = SAP_UC[RFC_UNITID_LN+1];

enum RFCTYPE
{
    RFCTYPE_CHAR = 0,
    RFCTYPE_DATE = 1,
    RFCTYPE_BCD = 2,
    RFCTYPE_TIME = 3,
    RFCTYPE_BYTE = 4,
    RFCTYPE_TABLE = 5,
    RFCTYPE_NUM = 6,
    RFCTYPE_FLOAT = 7,
    RFCTYPE_INT = 8,
    RFCTYPE_INT2 = 9,
    RFCTYPE_INT1 = 10,
    RFCTYPE_NULL = 14,
    RFCTYPE_ABAPOBJECT = 16,
    RFCTYPE_STRUCTURE = 17,
    RFCTYPE_DECF16 = 23,
    RFCTYPE_DECF34 = 24,
    RFCTYPE_XMLDATA = 28,
    RFCTYPE_STRING = 29,
    RFCTYPE_XSTRING = 30,
    RFCTYPE_INT8,
    RFCTYPE_UTCLONG,
    RFCTYPE_UTCSECOND,
    RFCTYPE_UTCMINUTE,
    RFCTYPE_DTDAY,
    RFCTYPE_DTWEEK,
    RFCTYPE_DTMONTH,
    RFCTYPE_TSECOND,
    RFCTYPE_TMINUTE,
    RFCTYPE_CDAY,
    RFCTYPE_BOX,
    RFCTYPE_GENERIC_BOX,
    _RFCTYPE_max_value,
}

enum RFC_RC
{
    RFC_OK,
    RFC_COMMUNICATION_FAILURE,
    RFC_LOGON_FAILURE,
    RFC_ABAP_RUNTIME_FAILURE,
    RFC_ABAP_MESSAGE,
    RFC_ABAP_EXCEPTION,
    RFC_CLOSED,
    RFC_CANCELED,
    RFC_TIMEOUT,
    RFC_MEMORY_INSUFFICIENT,
    RFC_VERSION_MISMATCH,
    RFC_INVALID_PROTOCOL,
    RFC_SERIALIZATION_FAILURE,
    RFC_INVALID_HANDLE,
    RFC_RETRY,
    RFC_EXTERNAL_FAILURE,
    RFC_EXECUTED,
    RFC_NOT_FOUND,
    RFC_NOT_SUPPORTED,
    RFC_ILLEGAL_STATE,
    RFC_INVALID_PARAMETER,
    RFC_CODEPAGE_CONVERSION_FAILURE,
    RFC_CONVERSION_FAILURE,
    RFC_BUFFER_TOO_SMALL,
    RFC_TABLE_MOVE_BOF,
    RFC_TABLE_MOVE_EOF,
    RFC_START_SAPGUI_FAILURE,
    RFC_ABAP_CLASS_EXCEPTION,
    RFC_UNKNOWN_ERROR,
    RFC_AUTHORIZATION_FAILURE,
    _RFC_RC_max_value,
}

enum RFC_ERROR_GROUP
{
    OK,
    ABAP_APPLICATION_FAILURE,
    ABAP_RUNTIME_FAILURE,
    LOGON_FAILURE,
    COMMUNICATION_FAILURE,
    EXTERNAL_RUNTIME_FAILURE,
    EXTERNAL_APPLICATION_FAILURE,
    EXTERNAL_AUTHORIZATION_FAILURE,
}

struct RFC_ERROR_INFO
{
    RFC_RC code;
    RFC_ERROR_GROUP group;
    SAP_UC key[128];
    SAP_UC message[512];
    SAP_UC abapMsgClass[20+1];
    SAP_UC abapMsgType[1+1];
    RFC_NUM abapMsgNumber[3 + 1];
    SAP_UC abapMsgV1[50+1];
    SAP_UC abapMsgV2[50+1];
    SAP_UC abapMsgV3[50+1];
    SAP_UC abapMsgV4[50+1];
}

struct RFC_ATTRIBUTES
{
    SAP_UC dest[64+1];
    SAP_UC host[100+1];
    SAP_UC partnerHost[100+1];
    SAP_UC sysNumber[2+1];
    SAP_UC sysId[8+1];
    SAP_UC client[3+1];
    SAP_UC user[12+1];
    SAP_UC language[2+1];
    SAP_UC trace[1+1];
    SAP_UC isoLanguage[2+1];
    SAP_UC codepage[4+1];
    SAP_UC partnerCodepage[4+1];
    SAP_UC rfcRole[1+1];
    SAP_UC type[1+1];
    SAP_UC partnerType[1+1];
    SAP_UC rel[4+1];
    SAP_UC partnerRel[4+1];
    SAP_UC kernelRel[4+1];
    SAP_UC cpicConvId[8 + 1];
    SAP_UC progName[128+1];
    SAP_UC partnerBytesPerChar[1+1];
    SAP_UC partnerSystemCodepage[4 + 1];
    SAP_UC reserved[79];
}
alias P_RFC_ATTRIBUTES = RFC_ATTRIBUTES*;

// 250
struct RFC_SECURITY_ATTRIBUTES
{
    SAP_UC *functionName;
    SAP_UC *sysId;
    SAP_UC *client;
    SAP_UC *user;
    SAP_UC *progName;
    SAP_UC *sncName;
    SAP_UC *ssoTicket;
}
alias P_RFC_SECURITY_ATTRIBUTES = RFC_SECURITY_ATTRIBUTES*;

struct RFC_UNIT_ATTRIBUTES
{
    short kernelTrace;
    short satTrace;
    short unitHistory;
    short lock;
    short noCommitCheck;
    SAP_UC user[12+1];
    SAP_UC client[3+1];
    SAP_UC tCode[20+1];
    SAP_UC program[40+1];
    SAP_UC hostname[40+1];
    RFC_DATE sendingDate;
    RFC_TIME sendingTime;
}

struct RFC_UNIT_IDENTIFIER
{
    SAP_UC unitType;
    RFC_UNITID unitID;
}

enum RFC_UNIT_STATE
{
    RFC_UNIT_NOT_FOUND,
    RFC_UNIT_IN_PROCESS,
    RFC_UNIT_COMMITTED,
    RFC_UNIT_ROLLED_BACK,
    RFC_UNIT_CONFIRMED,
}

alias RFC_ABAP_NAME = RFC_CHAR[30+1];
alias RFC_PARAMETER_DEFVALUE = RFC_CHAR[30+1];
alias RFC_PARAMETER_TEXT = RFC_CHAR[79+1];

enum RFC_CALL_TYPE
{
    RFC_SYNCHRONOUS,
    RFC_TRANSACTIONAL,
    RFC_QUEUED,
    RFC_BACKGROUND_UNIT,
}

struct RFC_SERVER_CONTEXT
{
    RFC_CALL_TYPE type;
    RFC_TID tid;
    RFC_UNIT_IDENTIFIER* unitIdentifier;
    RFC_UNIT_ATTRIBUTES* unitAttributes;
}

struct _RFC_TYPE_DESC_HANDLE
{
    void* handle;
}
alias RFC_TYPE_DESC_HANDLE = _RFC_TYPE_DESC_HANDLE*;

struct _RFC_FUNCTION_DESC_HANDLE
{
    void* handle;
}
alias RFC_FUNCTION_DESC_HANDLE = _RFC_FUNCTION_DESC_HANDLE*;

struct _RFC_CLASS_DESC_HANDLE
{
    void* handle;
}
alias RFC_CLASS_DESC_HANDLE = _RFC_CLASS_DESC_HANDLE*;

struct RFC_DATA_CONTAINER
{
    void* handle;
}
alias DATA_CONTAINER_HANDLE = RFC_DATA_CONTAINER*;

alias RFC_STRUCTURE_HANDLE = DATA_CONTAINER_HANDLE;
alias RFC_FUNCTION_HANDLE = DATA_CONTAINER_HANDLE;
alias RFC_TABLE_HANDLE = DATA_CONTAINER_HANDLE;
alias RFC_ABAP_OBJECT_HANDLE = DATA_CONTAINER_HANDLE;

struct _RFC_CONNECTION_HANDLE
{
    void* handle;
}
alias RFC_CONNECTION_HANDLE = _RFC_CONNECTION_HANDLE*;

struct _RFC_TRANSACTION_HANDLE
{
    void* handle;
}
alias RFC_TRANSACTION_HANDLE = _RFC_TRANSACTION_HANDLE*;

struct _RFC_UNIT_HANDLE
{
    void* handle;
}
alias RFC_UNIT_HANDLE = _RFC_UNIT_HANDLE*;

struct RFC_CONNECTION_PARAMETER
{
    SAP_UC* name;
    SAP_UC* value;
}
alias P_RFC_CONNECTION_PARAMETER = RFC_CONNECTION_PARAMETER*;

struct RFC_FIELD_DESC
{
    RFC_ABAP_NAME name;
    RFCTYPE type;
    uint nucLength;
    uint nucOffset;
    uint ucLength;
    uint ucOffset;
    uint decimals;
    RFC_TYPE_DESC_HANDLE typeDescHandle;
    void* extendedDescription;
}
alias P_RFC_FIELD_DESC = RFC_FIELD_DESC*;

enum RFC_DIRECTION
{
    RFC_IMPORT = 0x01,
    RFC_EXPORT = 0x02,
    RFC_CHANGING = RFC_IMPORT | RFC_EXPORT,
    RFC_TABLES = 0x04 | RFC_CHANGING,
}

struct RFC_PARAMETER_DESC
{
    RFC_ABAP_NAME name;
    RFCTYPE type;
    RFC_DIRECTION direction;
    uint nucLength;
    uint ucLength;
    uint decimals;
    RFC_TYPE_DESC_HANDLE typeDescHandle;
    RFC_PARAMETER_DEFVALUE defaultValue;
    RFC_PARAMETER_TEXT parameterText;
    RFC_BYTE optional;
    void* extendedDescription;
}
alias P_RFC_PARAMETER_DESC = RFC_PARAMETER_DESC*;

struct RFC_EXCEPTION_DESC
{
    SAP_UC key[128];
    SAP_UC message[512];
}
RFC_EXCEPTION_DESC* P__RFC_EXCEPTION_DESC;

enum RFC_CLASS_ATTRIBUTE_TYPE
{
    RFC_CLASS_ATTRIBUTE_INSTANCE,
    RFC_CLASS_ATTRIBUTE_CLASS,
    RFC_CLASS_ATTRIBUTE_CONSTANT,
}

alias RFC_CLASS_ATTRIBUTE_DEFVALUE = RFC_CHAR[30+1];
alias RFC_CLASS_NAME = RFC_CHAR[30+1];
alias  RFC_CLASS_ATTRIBUTE_DESCRIPTION = RFC_CHAR[511+1];

struct RFC_CLASS_ATTRIBUTE_DESC
{
    RFC_ABAP_NAME name;
    RFCTYPE type;
    uint nucLength;
    uint ucLength;
    uint decimals;
    RFC_TYPE_DESC_HANDLE typeDescHandle;
    RFC_CLASS_ATTRIBUTE_DEFVALUE defaultValue;
    RFC_CLASS_NAME declaringClass;
    RFC_CLASS_ATTRIBUTE_DESCRIPTION description;
    uint isReadOnly;
    RFC_CLASS_ATTRIBUTE_TYPE attributeType;
    void* extendedDescription;
}
alias P_RFC_CLASS_ATTRIBUTE_DESC = RFC_CLASS_ATTRIBUTE_DESC*;

alias RFC_SERVER_FUNCTION = RFC_RC function(RFC_CONNECTION_HANDLE, RFC_FUNCTION_HANDLE, out RFC_ERROR_INFO);
alias RFC_ON_CHECK_TRANSACTION = RFC_RC function(RFC_CONNECTION_HANDLE, SAP_UC*);
alias RFC_ON_COMMIT_TRANSACTION = RFC_RC function(RFC_CONNECTION_HANDLE, SAP_UC*);
alias RFC_ON_ROLLBACK_TRANSACTION = RFC_RC function(RFC_CONNECTION_HANDLE, SAP_UC*);
alias RFC_ON_CONFIRM_TRANSACTION = RFC_RC function(RFC_CONNECTION_HANDLE, SAP_UC*);
alias RFC_FUNC_DESC_CALLBACK = RFC_RC function(SAP_UC*, RFC_ATTRIBUTES, RFC_FUNCTION_DESC_HANDLE*);
alias RFC_PM_CALLBACK = RFC_RC function(RFC_CONNECTION_HANDLE, SAP_UC*, SAP_RAW *, size_t, size_t *); 
alias RFC_ON_CHECK_UNIT = RFC_RC function(RFC_CONNECTION_HANDLE, RFC_UNIT_IDENTIFIER*);
alias RFC_ON_COMMIT_UNIT = RFC_RC function(RFC_CONNECTION_HANDLE, RFC_UNIT_IDENTIFIER*);
alias RFC_ON_ROLLBACK_UNIT = RFC_RC function(RFC_CONNECTION_HANDLE, RFC_UNIT_IDENTIFIER*);
alias RFC_ON_CONFIRM_UNIT = RFC_RC function(RFC_CONNECTION_HANDLE, RFC_UNIT_IDENTIFIER*);
alias RFC_ON_GET_UNIT_STATE = RFC_RC function(RFC_CONNECTION_HANDLE, RFC_UNIT_IDENTIFIER*, RFC_UNIT_STATE*);
alias RFC_ON_PASSWORD_CHANGE = RFC_RC function(SAP_UC*, SAP_UC*, SAP_UC*, SAP_UC*, uint, SAP_UC*, uint, out RFC_ERROR_INFO);
alias RFC_ON_AUTHORIZATION_CHECK = RFC_RC function(RFC_CONNECTION_HANDLE, RFC_SECURITY_ATTRIBUTES*, out RFC_ERROR_INFO); 

RFC_RC RfcInit();
SAP_UC* RfcGetVersion(out uint, out uint, out uint);
RFC_RC RfcSetIniPath(SAP_UC* pathName, out RFC_ERROR_INFO);
RFC_RC RfcReloadIniFile(out RFC_ERROR_INFO);
RFC_RC RfcSetTraceLevel(RFC_CONNECTION_HANDLE, SAP_UC*, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetTraceEncoding(SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcSetTraceDir(SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcSetTraceType(SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcSetCpicTraceLevel(uint, out RFC_ERROR_INFO);
RFC_RC RfcUTF8ToSAPUC(RFC_BYTE*, uint, SAP_UC*, uint*, uint*, out RFC_ERROR_INFO);
RFC_RC RfcSAPUCToUTF8(SAP_UC*, uint, RFC_BYTE*, uint*, uint*, out RFC_ERROR_INFO);
SAP_UC* RfcGetRcAsString(RFC_RC);
SAP_UC* RfcGetTypeAsString(RFCTYPE);
SAP_UC* RfcGetDirectionAsString(RFC_DIRECTION);
RFC_RC RfcLanguageIsoToSap(SAP_UC*, SAP_UC*, out RFC_ERROR_INFO);

// 912
RFC_CONNECTION_HANDLE RfcOpenConnection(RFC_CONNECTION_PARAMETER*, uint, out RFC_ERROR_INFO);
RFC_CONNECTION_HANDLE RfcRegisterServer(RFC_CONNECTION_PARAMETER*, uint, out RFC_ERROR_INFO);
RFC_CONNECTION_HANDLE RfcStartServer(int, SAP_UC**, RFC_CONNECTION_PARAMETER*, uint, out RFC_ERROR_INFO);
RFC_RC RfcCloseConnection(RFC_CONNECTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcIsConnectionHandleValid(RFC_CONNECTION_HANDLE, int*, out RFC_ERROR_INFO);
RFC_RC RfcResetServerContext(RFC_CONNECTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcPing(RFC_CONNECTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcGetConnectionAttributes(RFC_CONNECTION_HANDLE, RFC_ATTRIBUTES*, out RFC_ERROR_INFO);
RFC_RC RfcGetServerContext(RFC_CONNECTION_HANDLE, RFC_SERVER_CONTEXT*, out RFC_ERROR_INFO);
RFC_RC RfcGetPartnerSSOTicket(RFC_CONNECTION_HANDLE, SAP_UC*, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetPartnerSNCName(RFC_CONNECTION_HANDLE, SAP_UC*, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetPartnerSNCKey(RFC_CONNECTION_HANDLE, SAP_RAW*, uint*, out RFC_ERROR_INFO);
RFC_RC RfcSNCNameToKey(SAP_UC*, SAP_UC*, SAP_RAW *, uint*, out RFC_ERROR_INFO);
RFC_RC RfcSNCKeyToName(SAP_UC*, SAP_RAW*, uint, SAP_UC*, uint, out RFC_ERROR_INFO);
RFC_RC RfcListenAndDispatch (RFC_CONNECTION_HANDLE, int, out RFC_ERROR_INFO);
RFC_RC RfcInvoke(RFC_CONNECTION_HANDLE, RFC_FUNCTION_HANDLE, out RFC_ERROR_INFO);

RFC_RC RfcGetTransactionID(RFC_CONNECTION_HANDLE, RFC_TID, out RFC_ERROR_INFO);
RFC_TRANSACTION_HANDLE RfcCreateTransaction(RFC_CONNECTION_HANDLE, RFC_TID, SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcInvokeInTransaction(RFC_TRANSACTION_HANDLE, RFC_FUNCTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSubmitTransaction(RFC_TRANSACTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcConfirmTransaction(RFC_TRANSACTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcDestroyTransaction(RFC_TRANSACTION_HANDLE, out RFC_ERROR_INFO);

RFC_RC RfcGetUnitID(RFC_CONNECTION_HANDLE, RFC_UNITID, out RFC_ERROR_INFO);
RFC_UNIT_HANDLE RfcCreateUnit(RFC_CONNECTION_HANDLE, RFC_UNITID, SAP_UC* /*[]*/, uint, RFC_UNIT_ATTRIBUTES*, RFC_UNIT_IDENTIFIER*, out RFC_ERROR_INFO);
RFC_RC RfcInvokeInUnit(RFC_UNIT_HANDLE, RFC_FUNCTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSubmitUnit(RFC_UNIT_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcConfirmUnit(RFC_CONNECTION_HANDLE, RFC_UNIT_IDENTIFIER*, out RFC_ERROR_INFO);
RFC_RC RfcDestroyUnit(RFC_UNIT_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcGetUnitState(RFC_CONNECTION_HANDLE, RFC_UNIT_IDENTIFIER*, RFC_UNIT_STATE*, out RFC_ERROR_INFO);
RFC_RC RfcInstallServerFunction(SAP_UC*, RFC_FUNCTION_DESC_HANDLE, RFC_SERVER_FUNCTION, out RFC_ERROR_INFO);
RFC_RC RfcInstallGenericServerFunction(RFC_SERVER_FUNCTION, RFC_FUNC_DESC_CALLBACK, out RFC_ERROR_INFO);
RFC_RC RfcInstallTransactionHandlers (SAP_UC, RFC_ON_CHECK_TRANSACTION, RFC_ON_COMMIT_TRANSACTION, RFC_ON_ROLLBACK_TRANSACTION, RFC_ON_CONFIRM_TRANSACTION, out RFC_ERROR_INFO);
RFC_RC RfcInstallBgRfcHandlers (SAP_UC*, RFC_ON_CHECK_UNIT, RFC_ON_COMMIT_UNIT, RFC_ON_ROLLBACK_UNIT, RFC_ON_CONFIRM_UNIT, RFC_ON_GET_UNIT_STATE, out RFC_ERROR_INFO);
RFC_RC RfcInstallPassportManager (RFC_PM_CALLBACK, RFC_PM_CALLBACK, RFC_PM_CALLBACK, RFC_PM_CALLBACK, out RFC_ERROR_INFO);
RFC_RC RfcInstallPasswordChangeHandler(RFC_ON_PASSWORD_CHANGE, out RFC_ERROR_INFO);
RFC_RC RfcInstallAuthorizationCheckHandler(RFC_ON_AUTHORIZATION_CHECK, out RFC_ERROR_INFO);

RFC_FUNCTION_HANDLE RfcCreateFunction(RFC_FUNCTION_DESC_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcDestroyFunction(RFC_FUNCTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSetParameterActive(RFC_FUNCTION_HANDLE, SAP_UC*, int, out RFC_ERROR_INFO);
RFC_RC RfcIsParameterActive(RFC_FUNCTION_HANDLE, SAP_UC*, int*, out RFC_ERROR_INFO);
RFC_STRUCTURE_HANDLE RfcCreateStructure(RFC_TYPE_DESC_HANDLE, out RFC_ERROR_INFO);
RFC_STRUCTURE_HANDLE RfcCloneStructure(RFC_STRUCTURE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcDestroyStructure(RFC_STRUCTURE_HANDLE, out RFC_ERROR_INFO);
RFC_TABLE_HANDLE RfcCreateTable(RFC_TYPE_DESC_HANDLE, out RFC_ERROR_INFO);
RFC_TABLE_HANDLE RfcCloneTable(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcDestroyTable(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_STRUCTURE_HANDLE RfcGetCurrentRow(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_STRUCTURE_HANDLE RfcAppendNewRow(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcAppendNewRows(RFC_TABLE_HANDLE, uint, out RFC_ERROR_INFO);
RFC_STRUCTURE_HANDLE RfcInsertNewRow(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcAppendRow(RFC_TABLE_HANDLE, RFC_STRUCTURE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcInsertRow(RFC_TABLE_HANDLE, RFC_STRUCTURE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcDeleteCurrentRow(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcDeleteAllRows(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcMoveToFirstRow(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcMoveToLastRow(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcMoveToNextRow(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcMoveToPreviousRow(RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcMoveTo(RFC_TABLE_HANDLE, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetRowCount(RFC_TABLE_HANDLE, uint*, out RFC_ERROR_INFO);
RFC_ABAP_OBJECT_HANDLE RfcCreateAbapObject(RFC_CLASS_DESC_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcDestroyAbapObject(RFC_ABAP_OBJECT_HANDLE, RFC_ERROR_INFO);

RFC_RC RfcGetChars(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_CHAR *, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetCharsByIndex(DATA_CONTAINER_HANDLE, uint, RFC_CHAR*, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetNum(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_NUM*, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetNumByIndex(DATA_CONTAINER_HANDLE, uint, RFC_NUM*, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetDate(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_DATE, out RFC_ERROR_INFO);
RFC_RC RfcGetDateByIndex(DATA_CONTAINER_HANDLE, uint, RFC_DATE, out RFC_ERROR_INFO);
RFC_RC RfcGetTime(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_TIME, out RFC_ERROR_INFO);
RFC_RC RfcGetTimeByIndex(DATA_CONTAINER_HANDLE, uint, RFC_TIME, out RFC_ERROR_INFO);
RFC_RC RfcGetString(DATA_CONTAINER_HANDLE, SAP_UC*, SAP_UC*, uint, out uint, out RFC_ERROR_INFO);
RFC_RC RfcGetStringByIndex(DATA_CONTAINER_HANDLE, uint, SAP_UC*, uint, out uint, out RFC_ERROR_INFO);
RFC_RC RfcGetBytes(DATA_CONTAINER_HANDLE, SAP_UC*, SAP_RAW*, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetBytesByIndex(DATA_CONTAINER_HANDLE, uint, SAP_RAW*, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetXString(DATA_CONTAINER_HANDLE, SAP_UC*, SAP_RAW*, uint, uint*, out RFC_ERROR_INFO);
RFC_RC RfcGetXStringByIndex(DATA_CONTAINER_HANDLE, uint, SAP_RAW*, uint, uint*, out RFC_ERROR_INFO);
RFC_RC RfcGetInt(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_INT, out RFC_ERROR_INFO);
RFC_RC RfcGetIntByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_INT, out RFC_ERROR_INFO);
RFC_RC RfcGetInt1(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_INT1, out RFC_ERROR_INFO);
RFC_RC RfcGetInt1ByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_INT1, out RFC_ERROR_INFO);
RFC_RC RfcGetInt2(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_INT2, out RFC_ERROR_INFO);
RFC_RC RfcGetInt2ByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_INT2, out RFC_ERROR_INFO);
RFC_RC RfcGetFloat(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_FLOAT, out RFC_ERROR_INFO);
RFC_RC RfcGetFloatByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_FLOAT, out RFC_ERROR_INFO);
// FIXME
//RFC_RC RfcGetDecF16(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_DECF16, out RFC_ERROR_INFO);
//RFC_RC RfcGetDecF16ByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_DECF16, out RFC_ERROR_INFO);
//RFC_RC RfcGetDecF34(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_DECF34, out RFC_ERROR_INFO);
//RFC_RC RfcGetDecF34ByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_DECF34, out RFC_ERROR_INFO);
RFC_RC RfcGetStructure(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_STRUCTURE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcGetStructureByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_STRUCTURE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcGetTable(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcGetTableByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcGetAbapObject(DATA_CONTAINER_HANDLE, SAP_UC*, out RFC_ABAP_OBJECT_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcGetAbapObjectByIndex(DATA_CONTAINER_HANDLE, uint, out RFC_ABAP_OBJECT_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcGetStringLength(DATA_CONTAINER_HANDLE, SAP_UC*, out uint, out RFC_ERROR_INFO);
RFC_RC RfcGetStringLengthByIndex(DATA_CONTAINER_HANDLE, uint, out uint, out RFC_ERROR_INFO);

RFC_RC RfcSetChars(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_CHAR *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetCharsByIndex(DATA_CONTAINER_HANDLE, uint, RFC_CHAR *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetNum(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_NUM *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetNumByIndex(DATA_CONTAINER_HANDLE, uint, RFC_NUM *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetString(DATA_CONTAINER_HANDLE, SAP_UC*, SAP_UC *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetStringByIndex(DATA_CONTAINER_HANDLE, uint, SAP_UC *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetDate(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_DATE, out RFC_ERROR_INFO);
RFC_RC RfcSetDateByIndex(DATA_CONTAINER_HANDLE, uint, RFC_DATE, out RFC_ERROR_INFO);
RFC_RC RfcSetTime(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_TIME, out RFC_ERROR_INFO);
RFC_RC RfcSetTimeByIndex(DATA_CONTAINER_HANDLE, uint, RFC_TIME, out RFC_ERROR_INFO);
RFC_RC RfcSetBytes(DATA_CONTAINER_HANDLE, SAP_UC*, SAP_RAW *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetBytesByIndex(DATA_CONTAINER_HANDLE, uint, SAP_RAW *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetXString(DATA_CONTAINER_HANDLE, SAP_UC*, SAP_RAW *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetXStringByIndex(DATA_CONTAINER_HANDLE, uint, SAP_RAW *, uint, out RFC_ERROR_INFO);
RFC_RC RfcSetInt(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_INT, out RFC_ERROR_INFO);
RFC_RC RfcSetIntByIndex(DATA_CONTAINER_HANDLE, uint, RFC_INT, out RFC_ERROR_INFO);
RFC_RC RfcSetInt1(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_INT1, out RFC_ERROR_INFO);
RFC_RC RfcSetInt1ByIndex(DATA_CONTAINER_HANDLE, uint, RFC_INT1, out RFC_ERROR_INFO);
RFC_RC RfcSetInt2(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_INT2, out RFC_ERROR_INFO);
RFC_RC RfcSetInt2ByIndex(DATA_CONTAINER_HANDLE, uint, RFC_INT2, out RFC_ERROR_INFO);
RFC_RC RfcSetFloat(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_FLOAT, out RFC_ERROR_INFO);
RFC_RC RfcSetFloatByIndex(DATA_CONTAINER_HANDLE, uint, RFC_FLOAT, out RFC_ERROR_INFO);
// RFC_RC RfcSetDecF16(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_DECF16, out RFC_ERROR_INFO);
// RFC_RC RfcSetDecF16ByIndex(DATA_CONTAINER_HANDLE, uint, RFC_DECF16, out RFC_ERROR_INFO);
// RFC_RC RfcSetDecF34(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_DECF34, out RFC_ERROR_INFO);
// RFC_RC RfcSetDecF34ByIndex(DATA_CONTAINER_HANDLE, uint, RFC_DECF34, out RFC_ERROR_INFO);
RFC_RC RfcSetStructure(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_STRUCTURE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSetStructureByIndex(DATA_CONTAINER_HANDLE, uint, RFC_STRUCTURE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSetTable(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSetTableByIndex(DATA_CONTAINER_HANDLE, uint, RFC_TABLE_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSetAbapObject(DATA_CONTAINER_HANDLE, SAP_UC*, RFC_ABAP_OBJECT_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSetAbapObjectByIndex(DATA_CONTAINER_HANDLE, uint, RFC_ABAP_OBJECT_HANDLE, out RFC_ERROR_INFO);
RFC_ABAP_OBJECT_HANDLE RfcGetAbapClassException(RFC_FUNCTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcSetAbapClassException(RFC_FUNCTION_HANDLE, RFC_ABAP_OBJECT_HANDLE, SAP_UC*,  out RFC_ERROR_INFO);
RFC_FUNCTION_DESC_HANDLE RfcDescribeFunction(RFC_FUNCTION_HANDLE, out RFC_ERROR_INFO);
RFC_TYPE_DESC_HANDLE RfcDescribeType(DATA_CONTAINER_HANDLE, out RFC_ERROR_INFO);

RFC_FUNCTION_DESC_HANDLE RfcGetFunctionDesc(RFC_CONNECTION_HANDLE, SAP_UC*, out RFC_ERROR_INFO);
RFC_FUNCTION_DESC_HANDLE RfcGetCachedFunctionDesc(SAP_UC*, SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcAddFunctionDesc(SAP_UC*, RFC_FUNCTION_DESC_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcRemoveFunctionDesc(SAP_UC*, SAP_UC*, out RFC_ERROR_INFO);
RFC_TYPE_DESC_HANDLE RfcGetTypeDesc(RFC_CONNECTION_HANDLE, SAP_UC*, out RFC_ERROR_INFO);
RFC_TYPE_DESC_HANDLE RfcGetCachedTypeDesc(SAP_UC*, SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcAddTypeDesc(SAP_UC*, RFC_TYPE_DESC_HANDLE, out RFC_ERROR_INFO*);
RFC_RC RfcRemoveTypeDesc(SAP_UC*, SAP_UC*, out RFC_ERROR_INFO);
RFC_CLASS_DESC_HANDLE RfcGetClassDesc(RFC_CONNECTION_HANDLE, SAP_UC*, out RFC_ERROR_INFO);
RFC_CLASS_DESC_HANDLE RfcGetCachedClassDesc(SAP_UC*, SAP_UC*, out RFC_ERROR_INFO);
RFC_CLASS_DESC_HANDLE RfcDescribeAbapObject(RFC_ABAP_OBJECT_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcAddClassDesc(SAP_UC*, RFC_CLASS_DESC_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcRemoveClassDesc(SAP_UC*, SAP_UC*, out RFC_ERROR_INFO);
RFC_TYPE_DESC_HANDLE RfcCreateTypeDesc(SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcAddTypeField(RFC_TYPE_DESC_HANDLE, RFC_FIELD_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcSetTypeLength(RFC_TYPE_DESC_HANDLE, uint, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetTypeName(RFC_TYPE_DESC_HANDLE, RFC_ABAP_NAME, out RFC_ERROR_INFO);
RFC_RC RfcGetFieldCount(RFC_TYPE_DESC_HANDLE, uint*, out RFC_ERROR_INFO);
RFC_RC RfcGetFieldDescByIndex(RFC_TYPE_DESC_HANDLE, uint, RFC_FIELD_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetFieldDescByName(RFC_TYPE_DESC_HANDLE, SAP_UC*, RFC_FIELD_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetTypeLength(RFC_TYPE_DESC_HANDLE, uint*, uint*, out RFC_ERROR_INFO);
RFC_RC RfcDestroyTypeDesc(RFC_TYPE_DESC_HANDLE, out RFC_ERROR_INFO);

RFC_FUNCTION_DESC_HANDLE RfcCreateFunctionDesc(SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcGetFunctionName(RFC_FUNCTION_DESC_HANDLE, RFC_ABAP_NAME, out RFC_ERROR_INFO);
RFC_RC RfcAddParameter(RFC_FUNCTION_DESC_HANDLE, RFC_PARAMETER_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetParameterCount(RFC_FUNCTION_DESC_HANDLE, uint*, out RFC_ERROR_INFO);
RFC_RC RfcGetParameterDescByIndex(RFC_FUNCTION_DESC_HANDLE, uint, RFC_PARAMETER_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetParameterDescByName(RFC_FUNCTION_DESC_HANDLE, SAP_UC*, RFC_PARAMETER_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcAddException(RFC_FUNCTION_DESC_HANDLE, RFC_EXCEPTION_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetExceptionCount(RFC_FUNCTION_DESC_HANDLE, uint*, out RFC_ERROR_INFO);
RFC_RC RfcGetExceptionDescByIndex(RFC_FUNCTION_DESC_HANDLE, uint, RFC_EXCEPTION_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetExceptionDescByName(RFC_FUNCTION_DESC_HANDLE, SAP_UC*, RFC_EXCEPTION_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcEnableBASXML(RFC_FUNCTION_DESC_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcIsBASXMLSupported(RFC_FUNCTION_DESC_HANDLE, int*, out RFC_ERROR_INFO);
RFC_RC RfcDestroyFunctionDesc(RFC_FUNCTION_DESC_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcEnableAbapClassException(RFC_FUNCTION_HANDLE, RFC_CONNECTION_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcIsAbapClassExceptionEnabled(RFC_FUNCTION_HANDLE, int*, out RFC_ERROR_INFO);

RFC_CLASS_DESC_HANDLE RfcCreateClassDesc(SAP_UC*, out RFC_ERROR_INFO);
RFC_RC RfcGetClassName(RFC_CLASS_DESC_HANDLE, RFC_ABAP_NAME, out RFC_ERROR_INFO);
RFC_RC RfcAddClassAttribute(RFC_CLASS_DESC_HANDLE, RFC_CLASS_ATTRIBUTE_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetClassAttributesCount(RFC_CLASS_DESC_HANDLE, uint*, out RFC_ERROR_INFO);
RFC_RC RfcGetClassAttributeDescByIndex(RFC_CLASS_DESC_HANDLE, uint, RFC_CLASS_ATTRIBUTE_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetClassAttributeDescByName(RFC_CLASS_DESC_HANDLE, SAP_UC*, RFC_CLASS_ATTRIBUTE_DESC*, out RFC_ERROR_INFO);
RFC_RC RfcGetParentClassByIndex(RFC_CLASS_DESC_HANDLE, RFC_CLASS_NAME, uint, out RFC_ERROR_INFO);
RFC_RC RfcGetParentClassesCount(RFC_CLASS_DESC_HANDLE, uint*, out RFC_ERROR_INFO);
RFC_RC RfcAddParentClass(RFC_CLASS_DESC_HANDLE, RFC_CLASS_NAME, out RFC_ERROR_INFO);
RFC_RC RfcGetImplementedInterfaceByIndex(RFC_CLASS_DESC_HANDLE, uint, RFC_CLASS_NAME, out RFC_ERROR_INFO);
RFC_RC RfcGetImplementedInterfacesCount(RFC_CLASS_DESC_HANDLE, uint*, out RFC_ERROR_INFO);
RFC_RC RfcAddImplementedInterface(RFC_CLASS_DESC_HANDLE, RFC_CLASS_NAME, out RFC_ERROR_INFO);
RFC_RC RfcDestroyClassDesc(RFC_CLASS_DESC_HANDLE, out RFC_ERROR_INFO);

alias	RFC_METADATA_QUERY_RESULT_HANDLE = void*;

struct RFC_METADATA_QUERY_RESULT_ENTRY
{
    RFC_ABAP_NAME name;
    SAP_UC errorMessage[512];
}

enum RFC_METADATA_OBJ_TYPE
{
    RFC_METADATA_FUNCTION,
    RFC_METADATA_TYPE,
    RFC_METADATA_CLASS
}
	
RFC_METADATA_QUERY_RESULT_HANDLE RfcCreateMetadataQueryResult(out RFC_ERROR_INFO);
RFC_RC RfcDestroyMetadataQueryResult(RFC_METADATA_QUERY_RESULT_HANDLE, out RFC_ERROR_INFO);
RFC_RC RfcDescribeMetadataQueryResult(RFC_METADATA_QUERY_RESULT_HANDLE, RFC_METADATA_OBJ_TYPE, uint*, uint*, out RFC_ERROR_INFO);
RFC_RC RfcGetMetadataQueryFailedEntry(RFC_METADATA_QUERY_RESULT_HANDLE, RFC_METADATA_OBJ_TYPE, uint, RFC_METADATA_QUERY_RESULT_ENTRY*, out RFC_ERROR_INFO);
RFC_RC RfcGetMetadataQuerySucceededEntry(RFC_METADATA_QUERY_RESULT_HANDLE, RFC_METADATA_OBJ_TYPE, uint, RFC_ABAP_NAME, out RFC_ERROR_INFO);
RFC_RC RfcMetadataBatchQuery(RFC_CONNECTION_HANDLE, SAP_UC**, uint, SAP_UC**, uint, SAP_UC**, uint, RFC_METADATA_QUERY_RESULT_HANDLE, out RFC_ERROR_INFO);
