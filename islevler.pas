unit islevler;

{$mode ObjFPC}{$H+}

interface

uses Classes, SysUtils;

type
  PShortInt = ^ShortInt;        // işaretli 8 bit
  PSmallInt = ^SmallInt;        // işaretli 16 bit
  PLongInt = ^LongInt;          // işaretli 32 bit

const
  // işlemci çalışma modları
  ICM_BIT16   = 1;
  ICM_BIT32   = 2;
  ICM_BIT64   = 3;

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

const
  // yazmaç değerlerinin form üzerindeki sıra numaraları
  YZMC_GORSELSN: array of Integer = (0, 3, 1, 2, 6, 7, 5, 4, 8, 9, 10, 11, 12, 13, 14);

var
  YZMC_DEGERSN: array of Integer = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

const
  Yazmaclar16: array[YZMC0_EAX..YZMC0_EDI] of string =
    ('ax', 'cx', 'dx', 'bx', 'sp', 'bp', 'si', 'di');
  Yazmaclar32: array[YZMC0_EAX..YZMC0_EDI] of string =
    ('eax', 'ecx', 'edx', 'ebx', 'esp', 'ebp', 'esi', 'edi');

var
  ISLEMCI_CM: Integer = ICM_BIT16;
  SB_CALISIYOR: Boolean = False;        // sanal bilgisayar çalışıyor mu?

var
  Portlar: array[0..65535] of Integer;

implementation

end.
