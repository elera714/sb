unit anasayfafrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Grids, ValEdit;

type
  TfrmAnaSayfa = class(TForm)
    btnCalistir: TButton;
    edtIslenecekDosya: TEdit;
    lblIskenenKomutSayisi: TLabel;
    lblIslenecekDosya: TLabel;
    mmCikti: TMemo;
    pnlUst: TPanel;
    pnlYazmaclar: TPanel;
    sbDurum: TStatusBar;
    ValueListEditor1: TValueListEditor;
    procedure btnCalistirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    procedure Yorumla;
    function Isle(ACS, AIP: Integer): Boolean;
    procedure YazmacDegistir(AYazmacSN, ADeger: Integer; AArtir: Boolean = False);
    procedure YazmaclariSifirla;
    procedure BellegeKopyala(AKaynak, AHedef: Pointer; AHedefBellekBaslangic,
      AUzunluk: Integer);
  public

  end;

var
  frmAnaSayfa: TfrmAnaSayfa;
  Bellek1MB: array of Byte;
  DosyaU: Int64;
  DosyaIP, IP: Integer;

implementation

{$R *.lfm}
uses islevler;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
begin

  SetLength(Bellek1MB, 1 * 1024 * 1024);
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  SetLength(Bellek1MB, 0);
end;

procedure TfrmAnaSayfa.btnCalistirClick(Sender: TObject);
var
  F: File of Byte;
  Bellek: array of Byte;
begin

  if not(ISLEMCI_CALISIYOR) then
  begin

    YazmaclariSifirla;

    IP := 0;

    DosyaU := 0;

    mmCikti.Lines.Clear;
    sbDurum.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);
    sbDurum.Repaint;
    Application.ProcessMessages;

    //AssignFile(F, 'disket_fat12.bin');
    AssignFile(F, edtIslenecekDosya.Text);
    {$I-} Reset(F); {$I+}

    if(IOResult = 0) then
    begin

      DosyaU := FileSize(F);

      SetLength(Bellek, DosyaU);
      BlockRead(F, Bellek[0], DosyaU);
      BellegeKopyala(@Bellek[0], @Bellek1MB[0], $07C0 * 16, DosyaU);
      SetLength(Bellek, 0);

      CloseFile(F);
    end;

    sbDurum.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);

    ISLEMCI_CALISIYOR := True;
    btnCalistir.Caption := 'Durdur';

    Yorumla;
  end
  else
  begin

    ISLEMCI_CALISIYOR := False;
    btnCalistir.Caption := 'Çalıştır';
  end;
end;

procedure TfrmAnaSayfa.Yorumla;
var
  Islenen: Integer;
  HataVar, Islendi: Boolean;
  Deger: Byte;
begin

  Islenen := 0;
  HataVar := False;

  lblIskenenKomutSayisi.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);

  DosyaIP := 0;

  YZMC_DEGERSN[YZMC16_CS] := $07C0;

  repeat

    if(ISLEMCI_CALISIYOR) then
    begin

      YZMC_DEGERSN[YZMC16_EIP] := DosyaIP;

      Deger := Bellek1MB[DosyaIP];
      Islendi := Isle(YZMC_DEGERSN[YZMC16_CS], YZMC_DEGERSN[YZMC16_EIP]);

      //YazmacDegistir(YZMC16_CS, $07C0);
      YazmacDegistir(YZMC16_EIP, DosyaIP);

      if(Islendi) then
      begin

        Inc(Islenen);
      end else HataVar := True;

      Application.ProcessMessages;

    end else DosyaIP := DosyaU + 1;

  until (DosyaIP >= DosyaU) or (HataVar = True);

  lblIskenenKomutSayisi.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);

  if(HataVar) then
  begin

    mmCikti.Lines.Add('Yürütme iptal edildi. Hatalı komut: $%.2x', [Deger]);
  end;
end;

function TfrmAnaSayfa.Isle(ACS, AIP: Integer): Boolean;
type
  PSmallInt = ^SmallInt;
var
  Adres: Integer;
  Komut: Byte;
  D1: ShortInt;     // işaretli 8 bit
  D2: SmallInt;     // işaretli 16 bit
begin

  Adres := (ACS * 16) + AIP;

  Komut := Bellek1MB[Adres];

  // 40+ rw - INC r16 - Increment word register by 1
  if(Komut >= $40 + YZMC16_AX) and (Komut <= $40 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      YazmacDegistir(Komut - $40, 1, True);
      mmCikti.Lines.Add('$%.2x - inc', [Komut]);
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
      mmCikti.Lines.Add('$%.2x - dec', [Komut]);
      Inc(DosyaIP, 1);     // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
      Result := True;
    end else Result := False;
  end
  // B8+ rw - MOV r16,imm16 - Move imm16 to r16
  else if(Komut >= $B8 + YZMC16_AX) and (Komut <= $B8 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      D2 := PSmallInt(@Bellek1MB[Adres + 1])^;
      YazmacDegistir(Komut - $B8, D2);
      mmCikti.Lines.Add('$%.2x-$%.4x - mov', [Komut, D2]);
      Inc(DosyaIP, 3);     // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
      Result := True;
    end else Result := False;
  end
  // EB cb - JMP rel8
  else if(Komut = $EB) then
  begin

    D1 := Bellek1MB[Adres + 1];
    mmCikti.Lines.Add('$%.2x-$%.2x - jmp', [Komut, D1]);
    Inc(DosyaIP, 2);
    Inc(DosyaIP, D1);     // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    Result := True;
  end
  // nop komutu - tamamlandı
  else if(Komut = $90) then
  begin

    mmCikti.Lines.Add('$%.2x - nop', [Komut]);
    Inc(DosyaIP, 1);
    Result := True;
  end
  else
  begin

    Result := False;
  end;
end;

procedure TfrmAnaSayfa.YazmacDegistir(AYazmacSN, ADeger: Integer; AArtir: Boolean = False);
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

procedure TfrmAnaSayfa.YazmaclariSifirla;
var
  i: Integer;
begin

  for i := 1 to 15 do
    ValueListEditor1.Cells[1, i] := '$00000000';
end;

procedure TfrmAnaSayfa.BellegeKopyala(AKaynak, AHedef: Pointer; AHedefBellekBaslangic,
  AUzunluk: Integer);
var
  A, B: PChar;
  i: Integer;
begin

{  A := PChar(AKaynak);
  B := PChar(AHedef); // + ABellekBaslangic);
  Move(A, B, AUzunluk);

  Exit;

}

  A := PChar(AKaynak);
  B := PChar(AHedef + AHedefBellekBaslangic);

  for i := 0 to AUzunluk - 1 do
  begin
    B^ := A^;
    Inc(A);
    Inc(B);
  end;
end;

end.
