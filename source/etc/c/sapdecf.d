module etc.d.sapdecf;

import etc.c.sapucx;

extern(C):
@nogc:

enum DECF_RETURN
{
    DECF_NOT_SUPPORTED = -2,
    DECF_WRONG_VERSION = -1,
    DECF_OK = 0,
    DECF_INEXACT = 1,
    DECF_UNDERFLOW = 2,
    DECF_OVERFLOW = 3,
    DECF_CONV_SYNTAX = 4,
    DECF_DIV_ZERO = 5,
    DECF_INVALID_OP = 6,
    DECF_NO_MEMORY = 7,
}

enum DecFRounding
{
	DECF_ROUND_CEILING = 0,
	DECF_ROUND_UP = 1,
	DECF_ROUND_HALF_UP = 2,
	DECF_ROUND_HALF_EVEN = 3,
	DECF_ROUND_HALF_DOWN = 4,
	DECF_ROUND_DOWN = 5,
	DECF_ROUND_FLOOR = 6,
	DECF_ROUND_MAX = 7,
}

version(LittleEndian)
{
//    immutable DecFloat16 DecFloat16NegInf = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8 };
//    immutable DecFloat34 DecFloat34NegInf = { 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0xf8 };
}
else
{
//    immutable DecFloat16 DecFloat16NegInf = { 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
//    immutable DecFloat34 DecFloat34NegInf = { 0xf8, 0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
}

void decf_mutex_lock();
void decf_mutex_unlock();
DECF_RETURN InitDecFloatLib();
DECF_RETURN DecFloat16ToString(DecFloat16, DecFloat16Buff*);
DECF_RETURN DecFloat34ToString(DecFloat34, DecFloat34Buff*);
DECF_RETURN StringToDecFloat16(const(SAP_UC)*, DecFloat16*);
DECF_RETURN StringToDecFloat34(const(SAP_UC)*, DecFloat34*);
DECF_RETURN DecFloat16ToDecFloat34(DecFloat34*, DecFloat16);
DECF_RETURN DecFloat34ToDecFloat16(DecFloat16*, DecFloat34);
DECF_RETURN DecFloat16ToDecFloat16Raw(DecFloat16Raw*, SAP_SHORT*, DecFloat16);
DECF_RETURN DecFloat16RawToDecFloat16(DecFloat16*, DecFloat16Raw, SAP_SHORT);
DECF_RETURN DecFloat34ToDecFloat34Raw(DecFloat34Raw*, SAP_SHORT*, DecFloat34);
DECF_RETURN DecFloat34RawToDecFloat34(DecFloat34*, DecFloat34Raw, SAP_SHORT);
DECF_RETURN DecFloat16ToDecFloat16RawDB(DecFloat16Raw*, SAP_SHORT*, DecFloat16);
DECF_RETURN DecFloat16RawToDecFloat16DB(DecFloat16*, DecFloat16Raw, SAP_SHORT);
DECF_RETURN DecFloat34ToDecFloat34RawDB(DecFloat34Raw*, SAP_SHORT*, DecFloat34);
DECF_RETURN DecFloat34RawToDecFloat34DB(DecFloat34*, DecFloat34Raw dfp34raw, SAP_SHORT);
DECF_RETURN NormDecFloat16ToDecFloat16Raw(DecFloat16Raw* dfp16raw_res, DecFloat16);
DECF_RETURN DecFloat16RawToNormDecFloat16(DecFloat16*, DecFloat16Raw);
DECF_RETURN NormDecFloat34ToDecFloat34Raw(DecFloat34Raw* dfp34raw_res, DecFloat34);
DECF_RETURN DecFloat34RawToNormDecFloat34(DecFloat34*, DecFloat34Raw dfp34raw);
DECF_RETURN DecFloat16ToSAP_INT(SAP_INT*, DecFloat16);
DECF_RETURN SAP_INTToDecFloat16(DecFloat16*, SAP_INT);
DECF_RETURN DecFloat34ToSAP_INT(SAP_INT*, DecFloat34);
DECF_RETURN SAP_INTToDecFloat34(DecFloat34*, SAP_INT);
DECF_RETURN DecFloat16ToSAP_DOUBLE(SAP_DOUBLE*, DecFloat16);
DECF_RETURN SAP_DOUBLEToDecFloat16(DecFloat16*, SAP_DOUBLE);
DECF_RETURN DecFloat34ToSAP_DOUBLE(SAP_DOUBLE*, DecFloat34);
DECF_RETURN SAP_DOUBLEToDecFloat34(DecFloat34*, SAP_DOUBLE);
DECF_RETURN DecFloat16ToBCD(SAP_RAW*, DecFloat16, intR, intR);
DECF_RETURN DecFloat16RoundForDEC(DecFloat16*, intR, intR);
SAP_INT DecFloat16CompareForDEC(DecFloat16, DecFloat16, intR, DECF_RETURN*);
DECF_RETURN BCDToDecFloat16(DecFloat16*, SAP_RAW*, intR, intR);
DECF_RETURN DecFloat34ToBCD(SAP_RAW*, DecFloat34, intR, intR);
DECF_RETURN DecFloat34RoundForDEC(DecFloat34*, intR, intR);
SAP_INT DecFloat34CompareForDEC(DecFloat34, DecFloat34, intR, DECF_RETURN*);
DECF_RETURN BCDToDecFloat34(DecFloat34*, SAP_RAW*, intR, intR);
DECF_RETURN DecFloat16_Add(DecFloat16*, DecFloat16, DecFloat16);
DECF_RETURN DecFloat34_Add(DecFloat34*, DecFloat34, DecFloat34);
DECF_RETURN DecFloat16_Sub(DecFloat16*, DecFloat16, DecFloat16);
DECF_RETURN DecFloat34_Sub(DecFloat34*, DecFloat34, DecFloat34);
DECF_RETURN DecFloat16_Mult(DecFloat16*, DecFloat16, DecFloat16);
DECF_RETURN DecFloat34_Mult(DecFloat34*, DecFloat34, DecFloat34);
DECF_RETURN DecFloat16_Div(DecFloat16*, DecFloat16, DecFloat16);
DECF_RETURN DecFloat34_Div(DecFloat34*, DecFloat34, DecFloat34);
DECF_RETURN DecFloat16_DIV(DecFloat16*, DecFloat16, DecFloat16);
DECF_RETURN DecFloat34_DIV(DecFloat34*, DecFloat34, DecFloat34);
DECF_RETURN DecFloat16_MOD(DecFloat16*, DecFloat16, DecFloat16);
DECF_RETURN DecFloat34_MOD(DecFloat34*, DecFloat34, DecFloat34);
SAP_BOOL DecFloat16_EQ(DecFloat16, DecFloat16, DECF_RETURN*);
SAP_BOOL DecFloat34_EQ(DecFloat34, DecFloat34, DECF_RETURN*);
SAP_BOOL DecFloat16_GT(DecFloat16, DecFloat16, DECF_RETURN*);
SAP_BOOL DecFloat34_GT(DecFloat34, DecFloat34, DECF_RETURN*);
SAP_BOOL DecFloat16_LT(DecFloat16, DecFloat16, DECF_RETURN*);
SAP_BOOL DecFloat34_LT(DecFloat34, DecFloat34, DECF_RETURN*);
SAP_INT DecFloat16Compare(DecFloat16, DecFloat16, DECF_RETURN*);
SAP_INT DecFloat34Compare(DecFloat34, DecFloat34, DECF_RETURN*);
DECF_RETURN DecFloat16RoundDec(DecFloat16*, SAP_INT, DecFRounding);
DECF_RETURN DecFloat16RoundPrec(DecFloat16*, SAP_INT, DecFRounding);
DECF_RETURN DecFloat34RoundDec(DecFloat34*, SAP_INT, DecFRounding);
DECF_RETURN DecFloat34RoundPrec(DecFloat34*, SAP_INT, DecFRounding);
DECF_RETURN DecFloat16RescaleDec(DecFloat16*, SAP_INT, DecFRounding);
DECF_RETURN DecFloat16RescalePrec(DecFloat16*, SAP_INT, DecFRounding);
DECF_RETURN DecFloat34RescaleDec(DecFloat34*, SAP_INT, DecFRounding);
DECF_RETURN DecFloat34RescalePrec(DecFloat34*, SAP_INT, DecFRounding);
SAP_BOOL DecFloat16IsInfinite(DecFloat16);
SAP_BOOL DecFloat34IsInfinite(DecFloat34);
SAP_BOOL DecFloat16IsFinite(DecFloat16);
SAP_BOOL DecFloat34IsFinite(DecFloat34);
SAP_BOOL DecFloat16IsNaN(DecFloat16);
SAP_BOOL DecFloat34IsNaN(DecFloat34);
DecFloat16* DecFloat16Zero(DecFloat16*);
DecFloat34* DecFloat34Zero(DecFloat34*);
DecFloat16 DecFloat16Ceil(DecFloat16, DECF_RETURN*);
DecFloat34 DecFloat34Ceil(DecFloat34, DECF_RETURN*);
DecFloat16 DecFloat16Floor(DecFloat16, DECF_RETURN*);
DecFloat34 DecFloat34Floor(DecFloat34, DECF_RETURN*);
DecFloat16 GetMinDecFloat16();
DecFloat34 GetMinDecFloat34();
DECF_RETURN DecFloat16GetExponent(SAP_INT*, DecFloat16);
DECF_RETURN DecFloat34GetExponent(SAP_INT*, DecFloat34);
DECF_RETURN DecFloat16GetNumOfDigits(SAP_INT*, DecFloat16);
DECF_RETURN DecFloat34GetNumOfDigits(SAP_INT*, DecFloat34);
DECF_RETURN DecFloat16ToDecFloat16Neutral(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat16NeutralToDecFloat16(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat34ToDecFloat34Neutral(DecFloat34*, DecFloat34);
DECF_RETURN DecFloat34NeutralToDecFloat34(DecFloat34*, DecFloat34);
DECF_RETURN DecFloat16Normalize(DecFloat16*);
DECF_RETURN DecFloat34Normalize(DecFloat34*);
DECF_RETURN DecFloat16ToNormDecFloat16(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat34ToNormDecFloat34(DecFloat34*, DecFloat34);
DECF_RETURN DecFloat16_Pow(DecFloat16*, DecFloat16, SAP_INT);
DECF_RETURN DecFloat34_Pow(DecFloat34*, DecFloat34, SAP_INT);
DECF_RETURN DecFloat16_fPow(DecFloat16*, DecFloat16, DecFloat16);
DECF_RETURN DecFloat34_fPow(DecFloat34*, DecFloat34, DecFloat34);
DECF_RETURN DecFloat16_Sqrt(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat34_Sqrt(DecFloat34*, DecFloat34);
DECF_RETURN DecFloat16_Exp(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat34_Exp(DecFloat34*, DecFloat34);
DECF_RETURN DecFloat16_Ln(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat34_Ln(DecFloat34*, DecFloat34);
DECF_RETURN DecFloat16_Log10(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat34_Log10(DecFloat34*, DecFloat34);
DECF_RETURN DecFloat16NextMinus(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat16NextPlus(DecFloat16*, DecFloat16);
DECF_RETURN DecFloat34NextMinus(DecFloat34*, DecFloat34);
DECF_RETURN DecFloat34NextPlus(DecFloat34*, DecFloat34);
