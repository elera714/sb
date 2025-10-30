unit islevler;

{$mode ObjFPC}{$H+}

interface

uses Classes, SysUtils;

const
  // işlemci çalışma modları
  ICM_BIT16   = 1;
  ICM_BIT32   = 2;
  ICM_BIT64   = 3;

const
  YZMC16_AX   = 0;
  YZMC16_CX   = 1;
  YZMC16_DX   = 2;
  YZMC16_BX   = 3;
  YZMC16_SP   = 4;
  YZMC16_BP   = 5;
  YZMC16_SI   = 6;
  YZMC16_DI   = 7;

  YZMC16_CS   = 8;
  YZMC16_DS   = 9;
  YZMC16_ES   = 10;
  YZMC16_SS   = 11;
  YZMC16_FS   = 12;
  YZMC16_GS   = 13;

  YZMC16_EIP  = 14;

const
  // yazmaç değerlerinin form üzerindeki sıra numaraları
  YZMC_GORSELSN: array of Integer = (0, 2, 3, 1, 7, 6, 4, 5, 8, 9, 10, 11, 12, 13, 14);

var
  YZMC_DEGERSN: array of Integer = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

var
  ISLEMCI_CM: Integer = ICM_BIT16;
  ISLEMCI_CALISIYOR: Boolean = False;

implementation

end.
