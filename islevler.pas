unit islevler;

{$mode ObjFPC}{$H+}

interface

uses Classes, SysUtils;

const
  // 2 kafa, 80 iz, 18 sektör, her sektörde 512 byte
  DISKET_BOYUT = LongWord((2 * 80 * 18) * 512);

type
  PByte = ^Byte;                // işaretli 8 bit
  PWord = ^Word;                // işaretli 16 bit
  PLongWord = ^LongWord;        // işaretli 32 bit

  PShortInt = ^ShortInt;        // işaretli 8 bit
  PSmallInt = ^SmallInt;        // işaretli 16 bit
  PLongInt = ^LongInt;          // işaretli 32 bit

const
  // veri uzunlukları
  VU1         = 1;
  VU2         = 2;
  VU4         = 4;
  VU8         = 8;

  // işlemci çalışma modları
  ICM_BIT16   = VU2;
  ICM_BIT32   = VU4;
  ICM_BIT64   = VU8;

const
  // yazmaç sıra numaraları
  YZMC0_EAX   = $00;
  YZMC0_ECX   = $01;
  YZMC0_EDX   = $02;
  YZMC0_EBX   = $03;
  YZMC0_ESP   = $04;
  YZMC0_EBP   = $05;
  YZMC0_ESI   = $06;
  YZMC0_EDI   = $07;
  YZMC0_CS    = $08;
  YZMC0_DS    = $09;
  YZMC0_ES    = $0A;
  YZMC0_SS    = $0B;
  YZMC0_FS    = $0C;
  YZMC0_GS    = $0D;
  YZMC0_EIP   = $0E;

  // 8 bit yazmaçlar - alt 8 bit
  YZMC_AL     = ($01 shl 8) or YZMC0_EAX;
  YZMC_CL     = ($01 shl 8) or YZMC0_ECX;
  YZMC_DL     = ($01 shl 8) or YZMC0_EDX;
  YZMC_BL     = ($01 shl 8) or YZMC0_EBX;

  // 8 bit yazmaçlar - üst 8 bit
  YZMC_AH     = ($02 shl 8) or YZMC0_EAX;
  YZMC_CH     = ($02 shl 8) or YZMC0_ECX;
  YZMC_DH     = ($02 shl 8) or YZMC0_EDX;
  YZMC_BH     = ($02 shl 8) or YZMC0_EBX;

  // 16 bit yazmaçlar
  YZMC_AX     = ($03 shl 8) or YZMC0_EAX;
  YZMC_CX     = ($03 shl 8) or YZMC0_ECX;
  YZMC_DX     = ($03 shl 8) or YZMC0_EDX;
  YZMC_BX     = ($03 shl 8) or YZMC0_EBX;
  YZMC_SP     = ($03 shl 8) or YZMC0_ESP;
  YZMC_BP     = ($03 shl 8) or YZMC0_EBP;
  YZMC_SI     = ($03 shl 8) or YZMC0_ESI;
  YZMC_DI     = ($03 shl 8) or YZMC0_EDI;
  YZMC_CS     = ($03 shl 8) or YZMC0_CS;
  YZMC_DS     = ($03 shl 8) or YZMC0_DS;
  YZMC_ES     = ($03 shl 8) or YZMC0_ES;
  YZMC_SS     = ($03 shl 8) or YZMC0_SS;
  YZMC_FS     = ($03 shl 8) or YZMC0_FS;
  YZMC_GS     = ($03 shl 8) or YZMC0_GS;
  YZMC_IP     = ($03 shl 8) or YZMC0_EIP;

  // 32 bit yazmaçlar
  YZMC_EAX    = ($04 shl 8) or YZMC0_EAX;
  YZMC_ECX    = ($04 shl 8) or YZMC0_ECX;
  YZMC_EDX    = ($04 shl 8) or YZMC0_EDX;
  YZMC_EBX    = ($04 shl 8) or YZMC0_EBX;
  YZMC_ESP    = ($04 shl 8) or YZMC0_ESP;
  YZMC_EBP    = ($04 shl 8) or YZMC0_EBP;
  YZMC_ESI    = ($04 shl 8) or YZMC0_ESI;
  YZMC_EDI    = ($04 shl 8) or YZMC0_EDI;

var
  YZMC_DEGERSN: array[0..14] of Integer =
    {eax ecx edx ebx esp ebp esi edi cs  ds  es  ss  fs  gs  eip}
    (0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0);

const
  // yazmaç değerlerinin form üzerindeki sıra numaraları
  YZMC_GORSELSN: array[0..14] of Integer =
    {eax ecx edx ebx esp ebp esi edi cs  ds  es  ss  fs  gs  eip}
    (0,  2,  3,  1,  7,  6,  4,  5,  8,  9,  10, 11, 12, 13, 14);

const
  Yazmaclar16: array[YZMC0_EAX..YZMC0_EDI] of string =
    ('ax', 'cx', 'dx', 'bx', 'sp', 'bp', 'si', 'di');
  Yazmaclar32: array[YZMC0_EAX..YZMC0_EDI] of string =
    ('eax', 'ecx', 'edx', 'ebx', 'esp', 'ebp', 'esi', 'edi');

var
  ISLEMCI_CM: Integer = ICM_BIT16;
  SB_CALISIYOR: Boolean = False;        // sanal bilgisayar çalışıyor mu?

var
  Bellek144MB: array of Byte;
  Portlar: array[0..65535] of Integer;

implementation

end.
