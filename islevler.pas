unit islevler;

{$mode ObjFPC}{$H+}

interface

uses Classes, SysUtils, Graphics;

const
  ProgramAdi: string = 'Sanal Bilgisayar';
  SurumNo: string = '0.0.1';
  Kodlayan: string = 'Fatih KILIC';

const
  // 2 kafa, 80 iz, 18 sektör, her sektörde 512 byte
  DISKET_BOYUT = LongWord((2 * 80 * 18) * 512);

const
  RENKLER_YAZI: array[0..15] of LongWord = (
    clBlack, clBlue, clGreen, clAqua, clRed, clFuchsia, $00004B96, $00D3D3D3,
    $00636363, $00FFD590, $0088E788, $00FFFFE0, $002B4BEE, $00FF80FF, clYellow, clWhite);

type
  PByte = ^Byte;                // işaretli 8 bit
  PWord = ^Word;                // işaretli 16 bit
  PLongWord = ^LongWord;        // işaretli 32 bit

  PShortInt = ^ShortInt;        // işaretli 8 bit
  PSmallInt = ^SmallInt;        // işaretli 16 bit
  PLongInt = ^LongInt;          // işaretli 32 bit

const
  // değişken veri uzunlukları
  DU1         = 1;
  DU2         = 2;
  DU4         = 4;
  DU8         = 8;

  // işlemci çalışma modları
  ICM_BIT16   = DU2;
  ICM_BIT32   = DU4;
  ICM_BIT64   = DU8;

const
  // yazmaç sıra numaraları
  { TODO - tablodaki yazmaçlara göre yeniden değer atanacak
    Instruction Set Reference Manual - tablo 2.1, 2.2, 2.3 değerlerine  }
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

  // 8 bit yazmaçlar
  YZMC_AL     = ($01 shl 8) or $00;
  YZMC_CL     = ($01 shl 8) or $01;
  YZMC_DL     = ($01 shl 8) or $02;
  YZMC_BL     = ($01 shl 8) or $03;
  YZMC_AH     = ($01 shl 8) or ($40 or $0);
  YZMC_CH     = ($01 shl 8) or ($50 or $1);
  YZMC_DH     = ($01 shl 8) or ($60 or $2);
  YZMC_BH     = ($01 shl 8) or ($70 or $3);

  // 16 bit yazmaçlar
  YZMC_AX     = ($02 shl 8) or $00;
  YZMC_CX     = ($02 shl 8) or $01;
  YZMC_DX     = ($02 shl 8) or $02;
  YZMC_BX     = ($02 shl 8) or $03;
  YZMC_SP     = ($02 shl 8) or $04;
  YZMC_BP     = ($02 shl 8) or $05;
  YZMC_SI     = ($02 shl 8) or $06;
  YZMC_DI     = ($02 shl 8) or $07;

  YZMC_CS     = ($02 shl 8) or $08;
  YZMC_DS     = ($02 shl 8) or $09;
  YZMC_ES     = ($02 shl 8) or $0A;
  YZMC_SS     = ($02 shl 8) or $0B;
  YZMC_FS     = ($02 shl 8) or $0C;
  YZMC_GS     = ($02 shl 8) or $0D;
  YZMC_IP     = ($02 shl 8) or $0E;

  // 32 bit yazmaçlar
  YZMC_EAX    = ($04 shl 8) or $00;
  YZMC_ECX    = ($04 shl 8) or $01;
  YZMC_EDX    = ($04 shl 8) or $02;
  YZMC_EBX    = ($04 shl 8) or $03;
  YZMC_ESP    = ($04 shl 8) or $04;
  YZMC_EBP    = ($04 shl 8) or $05;
  YZMC_ESI    = ($04 shl 8) or $06;
  YZMC_EDI    = ($04 shl 8) or $07;

var
  YZMC_DEGERSN: array[0..14] of LongWord =
    {eax ecx edx ebx esp ebp esi edi cs  ds  es  ss  fs  gs  eip}
    (0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0);

const
  // yazmaç değerlerinin form üzerindeki sıra numaraları
  YZMC_GORSELSN: array[0..14] of LongWord =
    {eax ecx edx ebx esp ebp esi edi cs  ds  es  ss  fs  gs  eip}
    (0,  2,  3,  1,  7,  6,  4,  5,  8,  9,  10, 11, 12, 13, 14);

const
  // Yazmaclar8, Instruction Set Reference Manual - tablo 2.1, 2.2, 2.3 değerlerine
  // yapılandırılmıştır
  Yazmaclar8: array[0..7] of string =
    ('al', 'cl', 'dl', 'bl', 'ah', 'dh', 'ch', 'bh');

  Yazmaclar16: array[YZMC0_EAX..YZMC0_EIP] of string =
    ('ax', 'cx', 'dx', 'bx', 'sp', 'bp', 'si', 'di',
     'cs', 'ds', 'es', 'ss', 'fs', 'gs', 'ip');
  Yazmaclar32: array[YZMC0_EAX..YZMC0_EIP] of string =
    ('eax', 'ecx', 'edx', 'ebx', 'esp', 'ebp', 'esi', 'edi',
     'cs', 'ds', 'es', 'ss', 'fs', 'gs', 'eip');

  // bellek atamaları, tablo 1, mod 0
  Bellekler10: array[0..7] of string =
    ('[bx+si]', '[bx+di]', '[bp+si]', '[bp+di]', '[si]', '[di]', '[disp16]', 'bx');


var
  ISLEMCI_CM: Integer = ICM_BIT16;
  SB_CALISIYOR: Boolean = False;              // sanal bilgisayar çalışıyor mu?
  BiosYuklendi: Boolean;

const
  BAYRAK_CF     = 0;
  BAYRAK_A1     = 1;      // her zaman 1
  BAYRAK_PF     = 2;
  BAYRAK_A2     = 3;      // her zaman 0
  BAYRAK_AF     = 4;
  BAYRAK_A3     = 5;      // her zaman 0
  BAYRAK_ZF     = 6;
  BAYRAK_SF     = 7;
  BAYRAK_TF     = 8;
  BAYRAK_IF     = 9;
  BAYRAK_DF     = 10;
  BAYRAK_OF     = 11;
  BAYRAK_IOPL   = {12ve}13;
  BAYRAK_NT     = 14;
  BAYRAK_A4     = 15;     // her zaman 0

const
  // mod yazmaç (register) bellek (memory) değerleri
  // Instruction Set Reference Manual - tablo 2.1, 2.2, 2.3 değerleri
  // yazmaç değerleri
  MYB8  : array[0..7] of LongWord = (YZMC_AL, YZMC_CL, YZMC_DL, YZMC_BL,
    YZMC_AH, YZMC_CH, YZMC_DH, YZMC_BH);
  MYB16 : array[0..7] of LongWord = (YZMC_AX, YZMC_CX, YZMC_DX, YZMC_BX,
    YZMC_SP, YZMC_BP, YZMC_SI, YZMC_DI);
  MYB32 : array[0..7] of LongWord = (YZMC_EAX, YZMC_ECX, YZMC_EDX, YZMC_EBX,
    YZMC_ESP, YZMC_EBP, YZMC_ESI, YZMC_EDI);

var
  Bellek144MB: array of Byte;
  Portlar: array[0..65535] of Integer;
  Bayraklar: LongWord = 0;                    // işlemci bayrakları (flags)

procedure ClearBit(var Value: LongWord; Index: Byte);
function GetBit(Value: LongWord; Index: Byte): Boolean;
procedure SetBit(var Value: LongWord; Index: Byte);
function YazmacDegerAl(AYazmac: LongWord): LongWord;
procedure IOPortYaz(AHedefPortNo, AKaynakYazmacSN: LongWord);
procedure IOPortYaz2(AKaynakYazmacSN: LongWord);

implementation

procedure ClearBit(var Value: LongWord; Index: Byte);
begin

  Value := Value and ((LongWord(1) shl Index) xor High(LongWord));
end;

function GetBit(Value: LongWord; Index: Byte): Boolean;
begin

  Result := ((Value shr Index) and 1) = 1;
end;

procedure SetBit(var Value: LongWord; Index: Byte);
begin

  Value:=  Value or (LongWord(1) shl Index);
end;

function YazmacDegerAl(AYazmac: LongWord): LongWord;
var
  DegerSN: LongWord;
  D11: Byte;        // işaretsiz 8 bit
  D21: Word;        // işaretsiz 16 bit
  D41: LongWord;    // işaretsiz 32 bit
begin

  DegerSN := (AYazmac and $FF);

  // yazmaç 16 bitlik değerin üst kısmı olan AH, BH vb. bir yazmaç ise
  if(DegerSN >= $40) then DegerSN := DegerSN and %1111;

  case AYazmac of
    YZMC_AL, YZMC_CL, YZMC_DL, YZMC_BL:
    begin

      D11 := PByte(@YZMC_DEGERSN[DegerSN] + 0)^;
      Result := (D11 and $FF);
    end;
    YZMC_AH, YZMC_CH, YZMC_DH, YZMC_BH:
    begin

      D11 := PByte(@YZMC_DEGERSN[DegerSN] + 1)^;
      Result := (D11 and $FF);
    end;
    YZMC_AX, YZMC_CX, YZMC_DX, YZMC_BX, YZMC_SP, YZMC_BP, YZMC_SI, YZMC_DI,
    YZMC_CS, YZMC_DS, YZMC_ES, YZMC_SS, YZMC_FS, YZMC_GS, YZMC_IP:
    begin

      D21 := PWord(@YZMC_DEGERSN[DegerSN] + 0)^;
      Result := (D21 and $FFFF);
    end;
    YZMC_EAX, YZMC_ECX, YZMC_EDX, YZMC_EBX, YZMC_ESP, YZMC_EBP, YZMC_ESI, YZMC_EDI:
    begin

      D41 := PLongWord(@YZMC_DEGERSN[DegerSN] + 0)^;
      Result := D41;
    end;
  end;
end;

// AHedefPortNo numaralı porta belirtilen yazmacın değerini yazar
// AKaynakYazmacSN = AHedefPortNo numaralı porta yazılacak yazmacın yazmaç sıra numarası
procedure IOPortYaz(AHedefPortNo, AKaynakYazmacSN: LongWord);
var
  HedefPortNo,
  KaynakDeger: LongWord;
begin

  KaynakDeger := YZMC_DEGERSN[YZMC0_EAX];
  HedefPortNo := (AHedefPortNo and $FFFF);

  case AKaynakYazmacSN of
    YZMC_AL:
    begin
      KaynakDeger := (KaynakDeger and $FF);
      Portlar[HedefPortNo] := KaynakDeger;
    end;
    YZMC_AX:
    begin
      KaynakDeger := (KaynakDeger and $FFFF);
      Portlar[HedefPortNo] := KaynakDeger;
    end;
    YZMC_EAX:
    begin
      Portlar[HedefPortNo] := KaynakDeger;
    end;
    else Exit;
  end;
end;

// DX portuna belirtilen yazmacın değerini yazar
// AKaynakYazmacSN = DX portuna yazılacak yazmacın yazmaç sıra numarası
procedure IOPortYaz2(AKaynakYazmacSN: LongWord);
var
  HedefPortNo,
  KaynakDeger: LongWord;
begin

  KaynakDeger := YZMC_DEGERSN[YZMC0_EAX];
  HedefPortNo := YZMC_DEGERSN[YZMC0_EDX] and $FFFF;

  case AKaynakYazmacSN of
    YZMC_AL:
    begin
      KaynakDeger := (KaynakDeger and $FF);
      Portlar[HedefPortNo] := KaynakDeger;
    end;
    YZMC_AX:
    begin
      KaynakDeger := (KaynakDeger and $FFFF);
      Portlar[HedefPortNo] := KaynakDeger;
    end;
    YZMC_EAX:
    begin
      Portlar[HedefPortNo] := KaynakDeger;
    end;
    else Exit;
  end;
end;

end.
