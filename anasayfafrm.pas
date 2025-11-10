unit anasayfafrm;

{$mode objfpc}{$H+}
{$DEFINE DEBUG}

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
    IslenenKomut: Byte;
    KomutModDegistir: Boolean;      // $66 öneki
    procedure Yorumla;
    function Isle(ACS, AIP: Integer): Boolean;
    procedure YazmacDegistir(AYazmacSN, ADeger: Integer; AArtir: Boolean = False);
    procedure YazmacDegistir2(AHedefYazmacSN, ADeger: LongInt; AArtir: Boolean = False);
    procedure YazmaclariSifirla;
    procedure BellegeKopyala(AKaynak, AHedef: Pointer; AHedefBellekBaslangic,
      AUzunluk: Integer);
    procedure IOPortOku(AHedefYazmacSN, AKaynakPortNo: Integer);
    procedure IOPortOku2(AHedefYazmacSN: Integer);
    procedure IOPortYaz(AHedefPortNo, AKaynakYazmacSN: Integer);
    procedure IOPortYaz2(AKaynakYazmacSN: Integer);
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
var
  i: Integer;
begin

  SetLength(Bellek1MB, 1 * 1024 * 1024);

  for i := 0 to 65535 do Portlar[i] := 0;
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

    {$IFDEF DEBUG} mmCikti.Lines.Clear; {$ENDIF}
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

  YZMC_DEGERSN[YZMC0_CS] := $07C0;
  YZMC_DEGERSN[YZMC0_EIP] := 0;

  repeat

    if(SB_CALISIYOR) then
    begin

      Islendi := Isle(YZMC_DEGERSN[YZMC0_CS], YZMC_DEGERSN[YZMC0_EIP]);

      YazmacDegistir(YZMC0_CS, YZMC_DEGERSN[YZMC0_CS]);
      YazmacDegistir(YZMC0_EIP, YZMC_DEGERSN[YZMC0_EIP]);

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

    Adres := (YZMC_DEGERSN[YZMC0_CS] * 16) + YZMC_DEGERSN[YZMC0_EIP];
    Komut := Bellek1MB[Adres];
    {$IFDEF DEBUG} mmCikti.Lines.Add('Yürütme iptal edildi. Hatalı komut: $%.2x', [Komut]); {$ENDIF}
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

  // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
  procedure IPDegeriniArtir(AArtir: Integer = 1);
  var
    IP: Integer;
  begin

    IP := YZMC_DEGERSN[YZMC0_EIP];
    IP += AArtir;
    YZMC_DEGERSN[YZMC0_EIP] := IP;
  end;
begin

  Result := True;

  Adres := (ACS * 16) + AIP;

  IslenenKomut := Bellek1MB[Adres];

  // Operand-size override, 66H
  if(IslenenKomut = $66) then
  begin

    {$IFDEF DEBUG} {mmCikti.Lines.Add('ön ek - $66');} {$ENDIF}
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

      IOPortOku(YZMC_AL, D11);
      {$IFDEF DEBUG} mmCikti.Lines.Add('in al,$%.2x', [D11 and $FF]); {$ENDIF}
      IPDegeriniArtir(2);
    end
    else if(IslenenKomut = $E5) then
    begin

      if(KomutModDegistir) then
      begin

        IOPortOku(YZMC_EAX, D11);
        {$IFDEF DEBUG} mmCikti.Lines.Add('in eax,$%.2x', [D11 and $FF]); {$ENDIF}
        IPDegeriniArtir(2);
      end
      else
      begin

        IOPortOku(YZMC_AX, D11);
        {$IFDEF DEBUG} mmCikti.Lines.Add('in ax,$%.2x', [D11 and $FF]); {$ENDIF}
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

      IOPortOku2(YZMC_AL);
      {$IFDEF DEBUG} mmCikti.Lines.Add('in al,dx'); {$ENDIF}
      IPDegeriniArtir;
    end
    else if(IslenenKomut = $ED) then
    begin

      if(KomutModDegistir) then
      begin

        IOPortOku2(YZMC_EAX);
        {$IFDEF DEBUG} mmCikti.Lines.Add('in eax,dx'); {$ENDIF}
        IPDegeriniArtir;
      end
      else
      begin

        IOPortOku2(YZMC_AX);
        {$IFDEF DEBUG} mmCikti.Lines.Add('in ax,dx'); {$ENDIF}
        IPDegeriniArtir;
      end;
    end else Result := False;
  end
  // E6 ib - OUT imm8, AL - Output byte in AL to I/O port address imm8
  // E7 ib - OUT imm8, AX - Output word in AX to I/O port address imm8
  // E7 ib - OUT imm8, EAX - Output doubleword in EAX to I/O port address imm8
  else if(IslenenKomut = $E6) or (IslenenKomut = $E7) then
  begin

    D11 := (Bellek1MB[Adres + 1] and $FF);

    if(IslenenKomut = $E6) then
    begin

      IOPortYaz(D11, YZMC_AL);
      {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,al', [D11 and $FF]); {$ENDIF}
      IPDegeriniArtir(2);
    end
    else if(IslenenKomut = $E7) then
    begin

      if(KomutModDegistir) then
      begin

        IOPortYaz(D11, YZMC_EAX);
        {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,eax', [D11 and $FF]); {$ENDIF}
        IPDegeriniArtir(2);
      end
      else
      begin

        IOPortYaz(D11, YZMC_AX);
        {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,ax', [D11 and $FF]); {$ENDIF}
        IPDegeriniArtir(2);
      end;
    end else Result := False;
  end
  // EE - OUT DX, AL - Output byte in AL to I/O port address in DX
  // EF - OUT DX, AX - Output word in AX to I/O port address in DX
  // EF - OUT DX, EAX - Output doubleword in EAX to I/O port address in DX  else if(IslenenKomut = $EC) or (IslenenKomut = $ED) then
  else if(IslenenKomut = $EE) or (IslenenKomut = $EF) then
  begin

    if(IslenenKomut = $EE) then
    begin

      IOPortYaz2(YZMC_AL);
      {$IFDEF DEBUG} mmCikti.Lines.Add('out dx,al'); {$ENDIF}
      IPDegeriniArtir;
    end
    else if(IslenenKomut = $EF) then
    begin

      if(KomutModDegistir) then
      begin

        IOPortYaz2(YZMC_EAX);
        {$IFDEF DEBUG} mmCikti.Lines.Add('out dx,eax'); {$ENDIF}
        IPDegeriniArtir;
      end
      else
      begin

        IOPortYaz2(YZMC_AX);
        {$IFDEF DEBUG} mmCikti.Lines.Add('out dx,ax'); {$ENDIF}
        IPDegeriniArtir;
      end;
    end else Result := False;
  end
  // 48+rw - DEC r16 - Decrement r16 by 1
  // 48+rd - DEC r32 - Decrement r32 by 1
  else if(IslenenKomut >= $48 + YZMC0_EAX) and (IslenenKomut <= $48 + YZMC0_EDI) then
  begin

    if(KomutModDegistir) then
    begin

      YazmacDegistir2(($04 shl 8) or (IslenenKomut - $48), -1, True);
      {$IFDEF DEBUG} mmCikti.Lines.Add('dec %s', [Yazmaclar32[IslenenKomut - $48]]); {$ENDIF}
      IPDegeriniArtir;
    end
    else
    begin

      YazmacDegistir2(($03 shl 8) or (IslenenKomut - $48), -1, True);
      {$IFDEF DEBUG} mmCikti.Lines.Add('dec %s', [Yazmaclar16[IslenenKomut - $48]]); {$ENDIF}
      IPDegeriniArtir;
    end;
  end
  // 40+ rw - INC r16 - Increment word register by 1
  // 40+ rd - INC r32 - Increment doubleword register by 1
  else if(IslenenKomut >= $40 + YZMC0_EAX) and (IslenenKomut <= $40 + YZMC0_EDI) then
  begin

    if(KomutModDegistir) then
    begin

      YazmacDegistir2(($04 shl 8) or (IslenenKomut - $40), 1, True);
      {$IFDEF DEBUG} mmCikti.Lines.Add('inc %s', [Yazmaclar32[IslenenKomut - $40]]); {$ENDIF}
      IPDegeriniArtir;
    end
    else
    begin

      YazmacDegistir2(($03 shl 8) or (IslenenKomut - $40), 1, True);
      {$IFDEF DEBUG} mmCikti.Lines.Add('inc %s', [Yazmaclar16[IslenenKomut - $40]]); {$ENDIF}
      IPDegeriniArtir;
    end;
  end
  // EB cb - JMP rel8
  else if(IslenenKomut = $EB) then
  begin

    D11 := Bellek1MB[Adres + 1];
    {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) %.2d', [D11]); {$ENDIF}
    IPDegeriniArtir(2);
    IPDegeriniArtir(D11);
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
        IPDegeriniArtir(2);
      end;
    end else Result := False;
  end
  // B8+ rw - MOV r16,imm16 - Move imm16 to r16
  else if(IslenenKomut >= $B8 + YZMC0_EAX) and (IslenenKomut <= $B8 + YZMC0_EDI) then
  begin

    if(ISLEMCI_CM = ICM_BIT16) then
    begin

      D21 := PSmallInt(@Bellek1MB[Adres + 1])^;
      YazmacDegistir(IslenenKomut - $B8, D21);
      {$IFDEF DEBUG} mmCikti.Lines.Add('$%.2x-$%.4x - mov', [IslenenKomut, D21]); {$ENDIF}
      IPDegeriniArtir(3);
    end else Result := False;
  end
  // nop komutu - tamamlandı
  else if(IslenenKomut = $90) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('nop'); {$ENDIF}
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

procedure TfrmAnaSayfa.YazmacDegistir2(AHedefYazmacSN, ADeger: LongInt; AArtir: Boolean = False);
var
  DegerSN: Integer;
  D11: ShortInt;        // işaretli 8 bit
  D21: SmallInt;        // işaretli 16 bit
  D31: LongInt;         // işaretli 32 bit
begin

  DegerSN := (AHedefYazmacSN and $FF);

  case AHedefYazmacSN of
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
    YZMC_AX, YZMC_CX, YZMC_DX, YZMC_BX, YZMC_SP, YZMC_BP, YZMC_SI, YZMC_DI:
    begin

      D21 := PSmallInt(@YZMC_DEGERSN[DegerSN] + 0)^;
      if(AArtir) then
        D21 := D21 + (ADeger and $FFFF)
      else D21 := (ADeger and $FFFF);
      PSmallInt(@YZMC_DEGERSN[DegerSN] + 0)^ := D21;
    end;
    YZMC_EAX, YZMC_ECX, YZMC_EDX, YZMC_EBX, YZMC_ESP, YZMC_EBP, YZMC_ESI, YZMC_EDI:
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

// AKaynakPortNo numaralı porttan belirtilen yazmaca değer okur
// AHedefYazmacSN = AKaynakPortNo numaralı porttan okunacak değerin yerleştirileceği yazmacın yazmaç sıra numarası
procedure TfrmAnaSayfa.IOPortOku(AHedefYazmacSN, AKaynakPortNo: Integer);
var
  KaynakPortNo,
  KaynakDeger: Integer;
begin

  KaynakPortNo := (AKaynakPortNo and $FFFF);
  KaynakDeger := Portlar[KaynakPortNo];

  case AHedefYazmacSN of
    YZMC_AL:
    begin
      KaynakDeger := (KaynakDeger and $FF);
      YazmacDegistir2(YZMC_AL, KaynakDeger);
    end;
    YZMC_AX:
    begin
      KaynakDeger := (KaynakDeger and $FFFF);
      YazmacDegistir2(YZMC_AX, KaynakDeger);
    end;
    YZMC_EAX:
    begin
      YazmacDegistir2(YZMC_EAX, KaynakDeger);
    end;
    else Exit;
  end;
end;

// DX portundan belirtilen yazmaca değer okur
// AHedefYazmacSN = DX portundan okunacak değerin yerleştirileceği yazmacın yazmaç sıra numarası
procedure TfrmAnaSayfa.IOPortOku2(AHedefYazmacSN: Integer);
var
  KaynakPort,
  KaynakDeger: Integer;
begin

  KaynakPort := YZMC_DEGERSN[YZMC0_EDX] and $FFFF;
  KaynakDeger := Portlar[KaynakPort];

  case AHedefYazmacSN of
    YZMC_AL:
    begin
      KaynakDeger := (KaynakDeger and $FF);
      YazmacDegistir2(YZMC_AL, KaynakDeger);
    end;
    YZMC_AX:
    begin
      KaynakDeger := (KaynakDeger and $FFFF);
      YazmacDegistir2(YZMC_AX, KaynakDeger);
    end;
    YZMC_EAX:
    begin
      YazmacDegistir2(YZMC_EAX, KaynakDeger);
    end;
    else Exit;
  end;
end;

// AHedefPortNo numaralı porta belirtilen yazmacın değerini yazar
// AKaynakYazmacSN = AHedefPortNo numaralı porta yazılacak yazmacın yazmaç sıra numarası
procedure TfrmAnaSayfa.IOPortYaz(AHedefPortNo, AKaynakYazmacSN: Integer);
var
  HedefPortNo,
  KaynakDeger: Integer;
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
procedure TfrmAnaSayfa.IOPortYaz2(AKaynakYazmacSN: Integer);
var
  HedefPortNo,
  KaynakDeger: Integer;
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
