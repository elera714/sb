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

var
  ISLEMCI_CM: Integer = ICM_BIT16;

implementation

end.
