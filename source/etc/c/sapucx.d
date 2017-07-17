module etc.c.sapucx;

extern(C):
@nogc:

alias SAP_UC = wchar;
alias SAP_CHAR = wchar;

alias SAP_RAW = ubyte;
alias SAP_SRAW = byte;
alias SAP_USHORT = ushort;

alias SAP_UINT = uint;
alias SAP_INT = int;

alias SAP_SHORT = short;
enum SAP_SHORT_MIN = SAP_SHORT.min;
enum SAP_SHORT_MAX = SAP_SHORT.max;
enum SAP_SHORT_BYTES = SAP_SHORT.sizeof;
static assert(SAP_SHORT_BYTES == 2);

enum SAP_BOOL : ubyte
{
    FALSE = 0,
    TRUE = 1
}

alias SAP_DOUBLE = double;
enum SAP_DOUBLE_MIN = SAP_DOUBLE.min_normal;
enum SAP_DOUBLE_MAX = SAP_DOUBLE.max;

alias LINE_USING_PROC = void function(SAP_CHAR*, int);

alias intU = int;
alias intR = int;
alias unsigned_intU = uint;
alias unsigned_intR = uint;
alias shortU = short;
alias shortR = short;
alias unsigned_shortU = ushort;
alias unsigned_shortR = ushort;
alias longU = long;
alias longR = long;
alias unsigned_longU = ulong;
alias unsigned_longR = ulong;
alias size_tU = size_t;
alias size_tR = size_t;

enum SAP_DATE_LN = 8;
alias SAP_DATE = SAP_CHAR[SAP_DATE_LN];

enum SAP_TIME_LN = 6;
alias SAP_TIME = SAP_CHAR[SAP_TIME_LN];

alias SAP_BCD = SAP_RAW;

struct SAP_UUID
{
    SAP_UINT   a;
    SAP_USHORT b;
    SAP_USHORT c;
    SAP_RAW[8] d;
}

alias PLATFORM_MAX_T = void *;

union SAP_MAX_ALIGN_T
{
    long           align_1;
    double         align_2;
    void *         align_3;
    PLATFORM_MAX_T align_4;
}

union DecFloat16
{
    SAP_RAW[8] bytes;
    SAP_DOUBLE align_;
}

union DecFloat34
{
    SAP_RAW[16]     bytes;
    SAP_MAX_ALIGN_T align_;
}

enum DecFloat16RawLen = 8; 
enum DecFloat34RawLen = 16;

enum DecFloatRawLen
{ 
    DecFloat16RawLen = 8, 
    DecFloat34RawLen = 16,
}

alias DecFloat16Raw = SAP_RAW[DecFloatRawLen.DecFloat16RawLen];
alias DecFloat34Raw = SAP_RAW[DecFloatRawLen.DecFloat34RawLen];

enum DecFloatLen
{ 
    DecFloat16Len = 8,  
    DecFloat34Len = 16, 
}

enum DECF_16_MAX_STRLEN = 25;
enum DECF_34_MAX_STRLEN = 43;

alias DecFloat34Buff = SAP_UC[DECF_34_MAX_STRLEN]; 
alias DecFloat16Buff = SAP_UC[DECF_16_MAX_STRLEN]; 
