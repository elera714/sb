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

implementation

{$R *.lfm}
uses islevler;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
begin

  SetLength(Bellek1MB, 1 * 1024 * 1024);
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  // sanal bilgisayar çalışıyorsa, durdur
  if(SB_CALISIYOR) then btnCalistirClick(Self);

  SetLength(Bellek1MB, 0);
end;

procedure TfrmAnaSayfa.btnCalistirClick(Sender: TObject);
var
  F: File of Byte;
  Bellek: array of Byte;
begin

  if not(SB_CALISIYOR) then
  begin

    YazmaclariSifirla;

    DosyaU := 0;

    mmCikti.Lines.Clear;
    sbDurum.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);
    sbDurum.Repaint;
    Application.ProcessMessages;

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

    SB_CALISIYOR := True;
    btnCalistir.Caption := 'Durdur';

    Yorumla;
  end
  else
  begin

    SB_CALISIYOR := False;
    btnCalistir.Caption := 'Çalıştır';
  end;
end;

procedure TfrmAnaSayfa.Yorumla;
var
  Islenen, Adres: Integer;
  HataVar, Islendi: Boolean;
  Komut: Byte;
begin

  Islenen := 0;
  HataVar := False;

  lblIskenenKomutSayisi.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);

  YZMC_DEGERSN[YZMC16_CS] := $07C0;
  YZMC_DEGERSN[YZMC16_EIP] := 0;

  repeat

    if(SB_CALISIYOR) then
    begin

      Islendi := Isle(YZMC_DEGERSN[YZMC16_CS], YZMC_DEGERSN[YZMC16_EIP]);

      YazmacDegistir(YZMC16_CS, YZMC_DEGERSN[YZMC16_CS]);
      YazmacDegistir(YZMC16_EIP, YZMC_DEGERSN[YZMC16_EIP]);

      if(Islendi) then
      begin

        Inc(Islenen);
      end else HataVar := True;

    end; // else DosyaIP := DosyaU + 1;

    Application.ProcessMessages;

  until (SB_CALISIYOR = False) or (HataVar = True);

  lblIskenenKomutSayisi.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);

  if(HataVar) then
  begin

    Adres := (YZMC_DEGERSN[YZMC16_CS] * 16) + YZMC_DEGERSN[YZMC16_EIP];
    Komut := Bellek1MB[Adres];
    mmCikti.Lines.Add('Yürütme iptal edildi. Hatalı komut: $%.2x', [Komut]);
  end;
end;

function TfrmAnaSayfa.Isle(ACS, AIP: Integer): Boolean;
type
  PSmallInt = ^SmallInt;
var
  Adres: Integer;
  Komut: Byte;
  D11, D12,
  D13, D14,
  D15: ShortInt;        // işaretli 8 bit
  D21: SmallInt;        // işaretli 16 bit

  procedure IPDegeriniArtir(AArtir: Integer = 1);
  var
    EIP: Integer;
  begin

    EIP := YZMC_DEGERSN[YZMC16_EIP];
    EIP += AArtir;
    YZMC_DEGERSN[YZMC16_EIP] := EIP;
  end;
begin

  Result := True;

  Adres := (ACS * 16) + AIP;

  Komut := Bellek1MB[Adres];

  // 40+ rw - INC r16 - Increment word register by 1
  if(Komut >= $40 + YZMC16_AX) and (Komut <= $40 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      YazmacDegistir(Komut - $40, 1, True);
      mmCikti.Lines.Add('$%.2x - inc', [Komut]);
      IPDegeriniArtir;          // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    end else Result := False;
  end
  // 48+rw - DEC r16 - Decrement r16 by 1
  else if(Komut >= $48 + YZMC16_AX) and (Komut <= $48 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      YazmacDegistir(Komut - $48, -1, True);
      mmCikti.Lines.Add('$%.2x - dec', [Komut]);
      IPDegeriniArtir;          // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    end else Result := False;
  end
  // 8E /r - MOV Sreg,r/m16** - Move r/m16 to segment register
  else if(Komut = $8E) then
  begin

    D11 := PSmallInt(@Bellek1MB[Adres + 1])^;
    D12 := (D11 shr 6) and %11;   // alt komut
    D13 := (D11 shr 3) and %111;  // hedef segment
    D14 := (D11 and %111);        // kaynak yazmaç
    if(D12 = %11) then
    begin

      case D13 of
        0: D15 := 10;
        1: D15 := 8;
        2: D15 := 11;
        3: D15 := 9;
        4: D15 := 12;
        5: D15 := 13;
        else Result := False;
      end;

      if(Result) then
      begin

        YZMC_DEGERSN[D15] := YZMC_DEGERSN[D14];
        YazmacDegistir(D15, YZMC_DEGERSN[D14]);
        IPDegeriniArtir(2);         // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
      end;
    end else Result := False;
  end
  // B8+ rw - MOV r16,imm16 - Move imm16 to r16
  else if(Komut >= $B8 + YZMC16_AX) and (Komut <= $B8 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      D21 := PSmallInt(@Bellek1MB[Adres + 1])^;
      YazmacDegistir(Komut - $B8, D21);
      mmCikti.Lines.Add('$%.2x-$%.4x - mov', [Komut, D21]);
      IPDegeriniArtir(3);       // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    end else Result := False;
  end
  // EB cb - JMP rel8
  else if(Komut = $EB) then
  begin

    D11 := Bellek1MB[Adres + 1];
    mmCikti.Lines.Add('jmp (yakın) %.2d', [D11]);
    IPDegeriniArtir(2);
    IPDegeriniArtir(D11);       // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
  end
  // nop komutu - tamamlandı
  else if(Komut = $90) then
  begin

    mmCikti.Lines.Add('nop');
    IPDegeriniArtir;
  end

  else Result := False;
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

  for i := 0 to 14 do YZMC_DEGERSN[i] := 0;

  for i := 1 to 15 do ValueListEditor1.Cells[1, i] := '$00000000';
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
