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
    Label2: TLabel;
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

  YazmaclariSifirla;

  IP := 0;

  DosyaU := 0;
  SetLength(Bellek, DosyaU);

  Memo1.Lines.Clear;
  StatusBar1.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);
  StatusBar1.Repaint;
  Application.ProcessMessages;

  AssignFile(F, 'disket_fat12.bin');
  {$I-} Reset(F); {$I+}

  if(IOResult = 0) then
  begin

    DosyaU := FileSize(F);

    SetLength(Bellek, DosyaU);

    BlockRead(F, Bellek[0], DosyaU);

    CloseFile(F);
  end;

  StatusBar1.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);

  Yorumla;
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

    Deger := Bellek[DosyaIP];
    Islendi := Isle(DosyaIP);

    Label2.Caption := Format('Komut İşaretçisi: $07C0:$%.4x', [DosyaIP]);

    if(Islendi) then
    begin

      Inc(Islenen);
    end else HataVar := True;

    Application.ProcessMessages;

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

  // B8+ rw - MOV r16,imm16 - Move imm16 to r16
  if(Komut >= $B8 + YZMC16_AX) and (Komut <= $B8 + YZMC16_DI) then
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
  i: Integer;
begin

  i := StrToInt(ValueListEditor1.Cells[1, 1 + AYazmacSN]);
  if(AArtir) then
    i := i + ADeger
  else i := ADeger;
  ValueListEditor1.Cells[1, 1 + AYazmacSN] := '$' + HexStr(i, 8);
end;

procedure TForm1.YazmaclariSifirla;
var
  i: Integer;
begin

  for i := YZMC16_AX to YZMC16_DI do
    ValueListEditor1.Cells[1, 1 + i] := '$00000000';
end;

end.
