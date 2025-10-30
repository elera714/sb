unit anasayfafrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Grids, ValEdit;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    ValueListEditor1: TValueListEditor;
    procedure Button1Click(Sender: TObject);
  private
    procedure Yorumla;
    function Isle(AAdres: Integer): Boolean;
    procedure YazmacDegistir(AYazmacSN, ADeger: Integer; AArtir: Boolean = False);
    procedure YazmaclariSifirla;
  public

  end;

var
  Form1: TForm1;
  Bellek: array of Byte;
  DosyaU: Int64;
  DosyaIP, IP: Integer;

implementation

{$R *.lfm}
uses islevler;

procedure TForm1.Button1Click(Sender: TObject);
var
  F: File of Byte;
begin

  if not(ISLEMCI_CALISIYOR) then
  begin

    YazmaclariSifirla;

    IP := 0;

    DosyaU := 0;
    SetLength(Bellek, DosyaU);

    Memo1.Lines.Clear;
    StatusBar1.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);
    StatusBar1.Repaint;
    Application.ProcessMessages;

    //AssignFile(F, 'disket_fat12.bin');
    AssignFile(F, 'yazmaçlar.bin');
    {$I-} Reset(F); {$I+}

    if(IOResult = 0) then
    begin

      DosyaU := FileSize(F);

      SetLength(Bellek, DosyaU);

      BlockRead(F, Bellek[0], DosyaU);

      CloseFile(F);
    end;

    StatusBar1.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);

    ISLEMCI_CALISIYOR := True;
    Button1.Caption := 'Durdur';

    Yorumla;
  end
  else
  begin

    ISLEMCI_CALISIYOR := False;
    Button1.Caption := 'Çalıştır';
  end;
end;

procedure TForm1.Yorumla;
var
  Islenen: Integer;
  HataVar, Islendi: Boolean;
  Deger: Byte;
begin

  Islenen := 0;
  HataVar := False;

  Label1.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);

  DosyaIP := 0;

  repeat

    if(ISLEMCI_CALISIYOR) then
    begin

      Deger := Bellek[DosyaIP];
      Islendi := Isle(DosyaIP);

      YazmacDegistir(YZMC16_CS, $07C0);
      YazmacDegistir(YZMC16_EIP, DosyaIP);

      if(Islendi) then
      begin

        Inc(Islenen);
      end else HataVar := True;

      Application.ProcessMessages;

    end else DosyaIP := DosyaU + 1;

  until (DosyaIP >= DosyaU) or (HataVar = True);

  Label1.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);

  if(HataVar) then
  begin

    Memo1.Lines.Add('Yürütme iptal edildi. Hatalı komut: $%.2x', [Deger]);
  end;
end;

function TForm1.Isle(AAdres: Integer): Boolean;
type
  PSmallInt = ^SmallInt;
var
  Komut: Byte;
  D1: ShortInt;     // işaretli 8 bit
  D2: SmallInt;     // işaretli 16 bit
begin

  Komut := Bellek[AAdres];

  // 40+ rw - INC r16 - Increment word register by 1
  if(Komut >= $40 + YZMC16_AX) and (Komut <= $40 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      YazmacDegistir(Komut - $40, 1, True);
      Memo1.Lines.Add('$%.2x - inc', [Komut]);
      Inc(DosyaIP, 1);     // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
      Result := True;
    end else Result := False;
  end
  // 48+rw - DEC r16 - Decrement r16 by 1
  else if(Komut >= $48 + YZMC16_AX) and (Komut <= $48 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      YazmacDegistir(Komut - $48, -1, True);
      Memo1.Lines.Add('$%.2x - dec', [Komut]);
      Inc(DosyaIP, 1);     // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
      Result := True;
    end else Result := False;
  end
  // B8+ rw - MOV r16,imm16 - Move imm16 to r16
  else if(Komut >= $B8 + YZMC16_AX) and (Komut <= $B8 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      D2 := PSmallInt(@Bellek[AAdres + 1])^;
      YazmacDegistir(Komut - $B8, D2);
      Memo1.Lines.Add('$%.2x-$%.4x - mov', [Komut, D2]);
      Inc(DosyaIP, 3);     // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
      Result := True;
    end else Result := False;
  end
  // EB cb - JMP rel8
  else if(Komut = $EB) then
  begin

    D1 := Bellek[AAdres + 1];
    Memo1.Lines.Add('$%.2x-$%.2x - jmp', [Komut, D1]);
    Inc(DosyaIP, 2);
    Inc(DosyaIP, D1);     // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    Result := True;
  end
  // nop komutu - tamamlandı
  else if(Komut = $90) then
  begin

    Memo1.Lines.Add('$%.2x - nop', [Komut]);
    Inc(DosyaIP, 1);
    Result := True;
  end
  else
  begin

    Result := False;
  end;
end;

procedure TForm1.YazmacDegistir(AYazmacSN, ADeger: Integer; AArtir: Boolean = False);
var
  i, j: Integer;
begin

  i := YZMC_DEGERSN[AYazmacSN];
  case ISLEMCI_CM of
    ICM_BIT16:
    begin

      j := i and $FFFF;
      if(AArtir) then
        j := j + ADeger
      else j := ADeger;
      j := j and $FFFF;

      i := i and $FFFF0000;
      i := i or j;
    end else i := -1; { TODO - 32/64 bit kodlama yapılacak }
  end;
  YZMC_DEGERSN[AYazmacSN] := i;

  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[AYazmacSN]] := '$' + HexStr(i, 8);

  Application.ProcessMessages;
end;

procedure TForm1.YazmaclariSifirla;
var
  i: Integer;
begin

  for i := 1 to 15 do
    ValueListEditor1.Cells[1, i] := '$00000000';
end;

end.
