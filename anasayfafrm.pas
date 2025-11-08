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
    procedure ValueListEditor1Click(Sender: TObject);
  private
    IslenenKomut: Byte;
    KomutModDegistir: Boolean;      // $66 öneki
    PortDeger: Integer;
    Port60: Integer;
    procedure Yorumla;
    function Isle(ACS, AIP: Integer): Boolean;
    procedure YazmacDegistir(AYazmacSN, ADeger: Integer; AArtir: Boolean = False);
    procedure YazmacDegistir2(AYazmacSN, ADeger: LongInt; AArtir: Boolean = False);
    procedure YazmaclariSifirla;
    procedure BellegeKopyala(AKaynak, AHedef: Pointer; AHedefBellekBaslangic,
      AUzunluk: Integer);
    function IOPortDegeriOku(AIOPortNo: Integer): Integer;
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

  PortDeger := 0;
  Port60 := 0;
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  // sanal bilgisayar çalışıyorsa, durdur
  if(SB_CALISIYOR) then btnCalistirClick(Self);

  SetLength(Bellek1MB, 0);
end;

procedure TfrmAnaSayfa.ValueListEditor1Click(Sender: TObject);
begin

  Port60 := 1;    // test amaçlı
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
  KomutModDegistir := False;

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

      // komut mod değiştirme işlemi gerçekleştirildikten sonra kapat
      if(KomutModDegistir) and (IslenenKomut <> $66) then KomutModDegistir := False;

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
var
  Adres: Integer;
  D11, D12,
  D13, D14,
  D15: ShortInt;        // işaretli 8 bit
  D21: SmallInt;        // işaretli 16 bit
  D41: LongInt;         // işaretli 32 bit

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

  IslenenKomut := Bellek1MB[Adres];

  // Operand-size override, 66H
  if(IslenenKomut = $66) then
  begin

    mmCikti.Lines.Add('ön ek - $66');
    IPDegeriniArtir;

    // işlemci komutunun 16/32 bit değişimini gerçekleştirir
    KomutModDegistir := True;
  end
  // E4 - ib IN AL,imm8 - Input byte from imm8 I/O port address into AL
  // E5 - ib IN AX,imm8 - Input byte from imm8 I/O port address into AX
  // E5 - ib IN EAX,imm8 - Input byte from imm8 I/O port address into EAX
  else if(IslenenKomut = $E4) or (IslenenKomut = $E5) then
  begin

    D11 := Bellek1MB[Adres + 1];

    if(IslenenKomut = $E4) then
    begin

      D12 := IOPortDegeriOku(D11);
      YazmacDegistir2(YZMC_AL, D12);
      mmCikti.Lines.Add('in al,$%.2x', [D11]);
      IPDegeriniArtir(2);
    end
    else if(IslenenKomut = $E5) then
    begin

      if(KomutModDegistir) then
      begin

        D41 := IOPortDegeriOku(D11);
        YazmacDegistir2(YZMC_EAX, D41);
        mmCikti.Lines.Add('in eax,$%.2x', [D11]);
        IPDegeriniArtir(2);
      end
      else
      begin

        D21 := IOPortDegeriOku(D11);
        YazmacDegistir2(YZMC_AX, D21);
        mmCikti.Lines.Add('in ax,$%.2x', [D11]);
        IPDegeriniArtir(2);
      end;
    end else Result := False;
  end
  // EC - IN AL,DX - Input byte from I/O port in DX into AL
  // ED - IN AX,DX - Input word from I/O port in DX into AX
  // ED - IN EAX,DX - Input doubleword from I/O port in DX into EAX
  else if(IslenenKomut = $EC) or (IslenenKomut = $ED) then
  begin

    if(IslenenKomut = $EC) then
    begin

      D11 := IOPortDegeriOku(YZMC_DEGERSN[YZMC16_DX]);
      YazmacDegistir2(YZMC_AL, D11);
      mmCikti.Lines.Add('in al,dx');
      IPDegeriniArtir;
    end
    else if(IslenenKomut = $ED) then
    begin

      if(KomutModDegistir) then
      begin

        D41 := IOPortDegeriOku(YZMC_DEGERSN[YZMC16_DX]);
        YazmacDegistir2(YZMC_EAX, D41);
        mmCikti.Lines.Add('in eax,dx');
        IPDegeriniArtir;
      end
      else
      begin

        D21 := IOPortDegeriOku(YZMC_DEGERSN[YZMC16_DX]);
        YazmacDegistir2(YZMC_AX, D21);
        mmCikti.Lines.Add('in ax,dx');
        IPDegeriniArtir;
      end;
    end else Result := False;
  end
  // 48+rw - DEC r16 - Decrement r16 by 1
  else if(IslenenKomut >= $48 + YZMC16_AX) and (IslenenKomut <= $48 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      YazmacDegistir(IslenenKomut - $48, -1, True);
      mmCikti.Lines.Add('$%.2x - dec', [IslenenKomut]);
      IPDegeriniArtir;          // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    end else Result := False;
  end
  // 40+ rw - INC r16 - Increment word register by 1
  else if(IslenenKomut >= $40 + YZMC16_AX) and (IslenenKomut <= $40 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      YazmacDegistir(IslenenKomut - $40, 1, True);
      mmCikti.Lines.Add('$%.2x - inc', [IslenenKomut]);
      IPDegeriniArtir;          // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    end else Result := False;
  end
  // EB cb - JMP rel8
  else if(IslenenKomut = $EB) then
  begin

    D11 := Bellek1MB[Adres + 1];
    mmCikti.Lines.Add('jmp (yakın) %.2d', [D11]);
    IPDegeriniArtir(2);
    IPDegeriniArtir(D11);       // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
  end
  // 8E /r - MOV Sreg,r/m16** - Move r/m16 to segment register
  else if(IslenenKomut = $8E) then
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
  else if(IslenenKomut >= $B8 + YZMC16_AX) and (IslenenKomut <= $B8 + YZMC16_DI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      D21 := PSmallInt(@Bellek1MB[Adres + 1])^;
      YazmacDegistir(IslenenKomut - $B8, D21);
      mmCikti.Lines.Add('$%.2x-$%.4x - mov', [IslenenKomut, D21]);
      IPDegeriniArtir(3);       // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    end else Result := False;
  end
  // nop komutu - tamamlandı
  else if(IslenenKomut = $90) then
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

procedure TfrmAnaSayfa.YazmacDegistir2(AYazmacSN, ADeger: LongInt; AArtir: Boolean = False);
var
  DegerSN: Integer;
  D11: ShortInt;        // işaretli 8 bit
  D21: SmallInt;        // işaretli 16 bit
  D31: LongInt;         // işaretli 32 bit
begin

  DegerSN := (AYazmacSN and $FF);

  case AYazmacSN of
    YZMC_AL:
    begin

      D11 := PShortInt(@YZMC_DEGERSN[DegerSN] + 0)^;
      if(AArtir) then
        D11 := D11 + (ADeger and $FF)
      else D11 := (ADeger and $FF);
      PShortInt(@YZMC_DEGERSN[DegerSN] + 0)^ := D11;
    end;
    YZMC_AH:
    begin

      D11 := PShortInt(@YZMC_DEGERSN[DegerSN] + 1)^;
      if(AArtir) then
        D11 := D11 + (ADeger and $FF)
      else D11 := (ADeger and $FF);
      PShortInt(@YZMC_DEGERSN[DegerSN] + 1)^ := D11;
    end;
    YZMC_AX:
    begin

      D21 := PSmallInt(@YZMC_DEGERSN[DegerSN] + 0)^;
      if(AArtir) then
        D21 := D21 + (ADeger and $FFFF)
      else D21 := (ADeger and $FFFF);
      PSmallInt(@YZMC_DEGERSN[DegerSN] + 0)^ := D21;
    end;
    YZMC_EAX:
    begin

      D31 := PLongInt(@YZMC_DEGERSN[DegerSN] + 0)^;
      if(AArtir) then
        D31 := D31 + ADeger
      else D31 := ADeger;
      PLongInt(@YZMC_DEGERSN[DegerSN] + 0)^ := D31;
    end;
  end;

  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[DegerSN]] := '$' + HexStr(YZMC_DEGERSN[DegerSN], 8);

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

function TfrmAnaSayfa.IOPortDegeriOku(AIOPortNo: Integer): Integer;
begin

  if(AIOPortNo = $60) then
  begin

    Result := Port60;
    Port60 := 0;
  end
  else
  begin

    Result := PortDeger;
    Inc(PortDeger);
  end;
end;

end.
