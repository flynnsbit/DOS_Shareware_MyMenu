const
  BYTE_NULL  = $0ff;
  WORD_NULL  = $0ffff;
  DWORD_NULL = $0ffffffff;

type
  tCHAR8x8  = array[char] of array[0..7] of Byte;
  tCHAR8x16 = array[char] of array[0..15] of Byte;

type
  tRGB = Record r,g,b: Byte end;
  tRGB_PALETTE = array[0..255] of tRGB;
