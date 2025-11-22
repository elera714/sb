unit anasayfafrm;

{$mode objfpc}{$H+}
{$DEFINE DEBUG}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Grids, ValEdit;

type

  { TfrmAnaSayfa }

  TfrmAnaSayfa = class(TForm)
    btnCalistir: TButton;
    btnBellek: TButton;
    cbIslenecekDosya: TComboBox;
    lblCF: TLabel;
    lblIOPL: TLabel;
    lblNT: TLabel;
    lblPF: TLabel;
    lblAF: TLabel;
    lblZF: TLabel;
    lblSF: TLabel;
    lblTF: TLabel;
    lblIF: TLabel;
    lblDF: TLabel;
    lblOF: TLabel;
    lblIskenenKomutSayisi: TLabel;
    lblIslenecekDosya: TLabel;
    mmCikti: TMemo;
    Panel2: TPanel;
    pnlUst: TPanel;
    pnlYazmaclar: TPanel;
    sbDurum: TStatusBar;
    ValueListEditor1: TValueListEditor;
    procedure btnCalistirClick(Sender: TObject);
    procedure btnBellekClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    IslenenKomut: Byte;
    KomutModDegistir: Boolean;      // $66 öneki
    procedure Yorumla;
    function Isle(ACS, AIP: Integer): Boolean;
    procedure YazmacDegistir(AYazmacSN, ADeger: Integer; AArtir: Boolean = False);
    procedure YazmacDegistir2(AHedefYazmacSN, ADeger: LongInt; AArtir: Boolean = False);
    procedure BayrakDegistir(AHedefBayrak: LongWord; ASifirla: Boolean = False);
    procedure YazmaclariSifirla;
    procedure BellegeKopyala(AKaynak, AHedef: Pointer; AHedefBellekBaslangic,
      AUzunluk: Integer);
    procedure IOPortOku(AHedefYazmacSN, AKaynakPortNo: Integer);
    procedure IOPortOku2(AHedefYazmacSN: Integer);
    procedure IOPortYaz(AHedefPortNo, AKaynakYazmacSN: Integer);
    procedure IOPortYaz2(AKaynakYazmacSN: Integer);
    procedure YiginaEkle(ADeger, AVeriUzunlugu: LongWord);
    procedure YiginaEkle2(AHedefYazmacSN: Integer);
    function YigindanAl(AVeriUzunlugu: LongWord): LongWord;
  public

  end;

var
  frmAnaSayfa: TfrmAnaSayfa;
  DosyaU: Int64;

implementation

{$R *.lfm}
uses islevler, bellekfrm;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
var
  i: Integer;
begin

  SetLength(Bellek144MB, DISKET_BOYUT + ($7C0 * $10));

  for i := 0 to 65535 do Portlar[i] := 0;
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  // sanal bilgisayar çalışıyorsa, durdur
  if(SB_CALISIYOR) then btnCalistirClick(Self);

  SetLength(Bellek144MB, 0);
end;

procedure TfrmAnaSayfa.btnCalistirClick(Sender: TObject);
var
  FileStream: TFileStream;
  Hata: string;
begin

  if not(SB_CALISIYOR) then
  begin

    YazmaclariSifirla;

    Hata := '';
    DosyaU := 0;

    {$IFDEF DEBUG} mmCikti.Lines.Clear; {$ENDIF}
    sbDurum.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);
    sbDurum.Repaint;
    Application.ProcessMessages;

    try
      FileStream := TFileStream.Create(cbIslenecekDosya.Text, fmOpenRead);
      FileStream.Position := 0;
      DosyaU := FileStream.Size;

      if(DosyaU <= DISKET_BOYUT) then
        FileStream.Read(Bellek144MB[$07C0 * $10], DosyaU)
      else Hata := 'dosya 1.44MB''den büyük olamaz!';

      FileStream.Free;
    except
      on E: Exception do Hata := E.Message;
    end;

    if(Length(Hata) = 0) then
    begin

      sbDurum.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);

      SB_CALISIYOR := True;
      btnCalistir.Caption := 'Durdur';

      Yorumla;
    end else ShowMessage('Hata: ' + Hata);
  end
  else
  begin

    SB_CALISIYOR := False;
    btnCalistir.Caption := 'Çalıştır';
  end;
end;

procedure TfrmAnaSayfa.btnBellekClick(Sender: TObject);
begin

  frmBellek.Goruntule := True;
  frmBellek.BellekAdresi := (YZMC_DEGERSN[YZMC0_CS] * $10) + YZMC_DEGERSN[YZMC0_EIP];
  frmBellek.Show;
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
        lblIskenenKomutSayisi.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);
        Application.ProcessMessages;

      end else HataVar := True;

      // komut mod değiştirme işlemi gerçekleştirildikten sonra kapat
      if(KomutModDegistir) and (IslenenKomut <> $66) then KomutModDegistir := False;

    end; // else DosyaIP := DosyaU + 1;

    Application.ProcessMessages;

  until (SB_CALISIYOR = False) or (HataVar = True);

  if(HataVar) then
  begin

    Adres := (YZMC_DEGERSN[YZMC0_CS] * $10) + YZMC_DEGERSN[YZMC0_EIP];
    Komut := Bellek144MB[Adres];
    {$IFDEF DEBUG} mmCikti.Lines.Add('Yürütme iptal edildi. Hatalı komut: $%.2x', [Komut]); {$ENDIF}

    SB_CALISIYOR := False;
    btnCalistir.Caption := 'Çalıştır';
  end;
end;

function TfrmAnaSayfa.Isle(ACS, AIP: Integer): Boolean;
var
  Adres: Integer;
  V11, V12,
  V13, V14,
  V15: Byte;            // işaretsiz 8 bit
  V21: Word;            // işaretsiz 16 bit
  V41, V42: LongWord;   // işaretsiz 32 bit

  {TODO - aşağıdaki değişkenler yukarıdakilerle değiştirilecek}
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

  Adres := (ACS * $10) + AIP;

  IslenenKomut := Bellek144MB[Adres];

  // Operand-size override, 66H
  if(IslenenKomut = $66) then
  begin

    {$IFDEF DEBUG} {mmCikti.Lines.Add('ön ek - $66');} {$ENDIF}
    IPDegeriniArtir;

    // işlemci komutunun 16/32 bit değişimini gerçekleştirir
    KomutModDegistir := True;
  end
  // E8 cw - CALL rel16 - Call near, relative, displacement relative to next instruction
  // E8 cd - CALL rel32 - Call near, relative, displacement relative to next instruction
  else if(IslenenKomut = $E8) then
  begin

    V21 := PWord(@Bellek144MB[Adres + 1])^;
    {$IFDEF DEBUG} mmCikti.Lines.Add('call (yakın) %.4d', [SmallInt(V21)]); {$ENDIF}
    YiginaEkle(YZMC_DEGERSN[YZMC0_EIP] + 3, VU2);
    IPDegeriniArtir(3);
    IPDegeriniArtir(SmallInt(V21));
  end
  // C3 - RET - Near return to calling procedure
  // CB - RET - Far return to calling procedure
  else if(IslenenKomut = $C3) then
  begin

    V21 := YigindanAl(VU2);
    {$IFDEF DEBUG} mmCikti.Lines.Add('ret (yakın) %.4d', [SmallInt(V21)]); {$ENDIF}
    YZMC_DEGERSN[YZMC0_EIP] := V21;
  end
  {$i komutlar\clc.inc}
  {$i komutlar\dec.inc}
  {$i komutlar\in.inc}
  {$i komutlar\inc.inc}
  {$i komutlar\jmp.inc}
  {$i komutlar\lods.inc}
  {$i komutlar\mov.inc}
  {$i komutlar\nop.inc}
  {$i komutlar\out.inc}
  {$i komutlar\push.inc}
  {$i komutlar\stc.inc}
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
  D41: LongInt;         // işaretli 32 bit
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

      D41 := PLongInt(@YZMC_DEGERSN[DegerSN] + 0)^;
      if(AArtir) then
        D41 := D41 + ADeger
      else D41 := ADeger;
      PLongInt(@YZMC_DEGERSN[DegerSN] + 0)^ := D41;
    end;
  end;

  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[DegerSN]] := '$' + HexStr(YZMC_DEGERSN[DegerSN], 8);

  Application.ProcessMessages;
end;

procedure TfrmAnaSayfa.BayrakDegistir(AHedefBayrak: LongWord; ASifirla: Boolean = False);
var
  D41: LongWord;         // işaretsiz 32 bit
begin

  if(ASifirla) then
    ClearBit(Bayraklar, AHedefBayrak)
  else SetBit(Bayraklar, AHedefBayrak);

  D41 := (Bayraklar shr AHedefBayrak) and 1;

  case AHedefBayrak of
    BAYRAK_CF: lblCF.Caption := Format('CF=%d', [D41]);
    BAYRAK_PF: lblPF.Caption := Format('PF=%d', [D41]);
    BAYRAK_AF: lblAF.Caption := Format('AF=%d', [D41]);
    BAYRAK_ZF: lblZF.Caption := Format('ZF=%d', [D41]);
    BAYRAK_SF: lblSF.Caption := Format('SF=%d', [D41]);
    BAYRAK_TF: lblTF.Caption := Format('TF=%d', [D41]);
    BAYRAK_IF: lblIF.Caption := Format('IF=%d', [D41]);
    BAYRAK_DF: lblDF.Caption := Format('DF=%d', [D41]);
    BAYRAK_OF: lblOF.Caption := Format('OF=%d', [D41]);
    //BAYRAK_IOPL: lblIOPL.Caption := Format('IOPL=%d', [D41]);  { TODO 2 bir olarak ayarlanacak}
    BAYRAK_NT: lblNT.Caption := Format('NT=%d', [D41]);
  end;

  Application.ProcessMessages;
end;

procedure TfrmAnaSayfa.YazmaclariSifirla;
var
  i: Integer;
begin

  Bayraklar := 0;

  for i := 0 to 14 do YZMC_DEGERSN[i] := 0;

  for i := 1 to 15 do ValueListEditor1.Cells[1, i] := '$00000000';

  lblCF.Caption := 'CF=0';
  lblPF.Caption := 'PF=0';
  lblAF.Caption := 'AF=0';
  lblZF.Caption := 'ZF=0';
  lblSF.Caption := 'SF=0';
  lblTF.Caption := 'TF=0';
  lblIF.Caption := 'IF=0';
  lblDF.Caption := 'DF=0';
  lblOF.Caption := 'OF=0';
  lblIOPL.Caption := 'IOPL=0';
  lblNT.Caption := 'NT=0';
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

procedure TfrmAnaSayfa.YiginaEkle(ADeger, AVeriUzunlugu: LongWord);
var
  V41, V42: LongWord;   // işaretsiz 32 bit
begin

  V41 := YZMC_DEGERSN[YZMC0_SS];
  V42 := YZMC_DEGERSN[YZMC0_ESP];
  V42 -= AVeriUzunlugu;
  YZMC_DEGERSN[YZMC0_ESP] := V42;

  case AVeriUzunlugu of
    VU1: begin PByte(@Bellek144MB[(V41 * $10) + V42])^ := (ADeger and $FF); end;
    VU2: begin PWord(@Bellek144MB[(V41 * $10) + V42])^ := (ADeger and $FFFF); end;
    VU4: begin PLongWord(@Bellek144MB[(V41 * $10) + V42])^ := ADeger; end;
    else Exit;
  end;

  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[YZMC0_ESP]] := '$' + HexStr(YZMC_DEGERSN[YZMC0_ESP], 8);

  Application.ProcessMessages;
end;

procedure TfrmAnaSayfa.YiginaEkle2(AHedefYazmacSN: Integer);
var
  D11: Byte;              // işaretsiz 8 bit
  D21: Word;              // işaretsiz 16 bit
  D41, D42,
  D43: LongWord;          // işaretsiz 32 bit
begin

  case AHedefYazmacSN of
    YZMC_AL:
    begin

      {D11 := PShortInt(@YZMC_DEGERSN[DegerSN] + 0)^;
      PShortInt(@YZMC_DEGERSN[DegerSN] + 0)^ := D11;}
    end;
    YZMC_AH:
    begin

      {D11 := PShortInt(@YZMC_DEGERSN[DegerSN] + 1)^;
      PShortInt(@YZMC_DEGERSN[DegerSN] + 1)^ := D11;}
    end;
    YZMC_AX, YZMC_CX, YZMC_DX, YZMC_BX, YZMC_SP, YZMC_BP, YZMC_SI, YZMC_DI,
    YZMC_CS, YZMC_DS, YZMC_ES, YZMC_SS, YZMC_FS, YZMC_GS:
    begin

      D41 := PLongWord(@YZMC_DEGERSN[YZMC0_SS] + 0)^;
      D42 := PLongWord(@YZMC_DEGERSN[YZMC0_ESP] + 0)^;
      D42 -= 2;
      PLongWord(@YZMC_DEGERSN[YZMC0_ESP] + 0)^ := D42;

      case AHedefYazmacSN of
        YZMC_AX: D21 := PWord(@YZMC_DEGERSN[YZMC0_EAX] + 0)^;
        YZMC_CX: D21 := PWord(@YZMC_DEGERSN[YZMC0_ECX] + 0)^;
        YZMC_DX: D21 := PWord(@YZMC_DEGERSN[YZMC0_EDX] + 0)^;
        YZMC_BX: D21 := PWord(@YZMC_DEGERSN[YZMC0_EBX] + 0)^;
        YZMC_SP: D21 := PWord(@YZMC_DEGERSN[YZMC0_ESP] + 0)^;
        YZMC_BP: D21 := PWord(@YZMC_DEGERSN[YZMC0_EBP] + 0)^;
        YZMC_SI: D21 := PWord(@YZMC_DEGERSN[YZMC0_ESI] + 0)^;
        YZMC_DI: D21 := PWord(@YZMC_DEGERSN[YZMC0_EDI] + 0)^;
        YZMC_CS: D21 := PWord(@YZMC_DEGERSN[YZMC0_CS] + 0)^;
        YZMC_DS: D21 := PWord(@YZMC_DEGERSN[YZMC0_DS] + 0)^;
        YZMC_ES: D21 := PWord(@YZMC_DEGERSN[YZMC0_ES] + 0)^;
        YZMC_SS: D21 := PWord(@YZMC_DEGERSN[YZMC0_SS] + 0)^;
        YZMC_FS: D21 := PWord(@YZMC_DEGERSN[YZMC0_FS] + 0)^;
        YZMC_GS: D21 := PWord(@YZMC_DEGERSN[YZMC0_GS] + 0)^;
      end;

      PWord(@Bellek144MB[(D41 * $10) + D42])^ := D21;
    end;
    YZMC_EAX, YZMC_ECX, YZMC_EDX, YZMC_EBX, YZMC_ESP, YZMC_EBP, YZMC_ESI, YZMC_EDI:
    begin

      D41 := PLongWord(@YZMC_DEGERSN[YZMC0_SS] + 0)^;
      D42 := PLongWord(@YZMC_DEGERSN[YZMC0_ESP] + 0)^;
      D42 -= 4;
      PLongWord(@YZMC_DEGERSN[YZMC0_ESP] + 0)^ := D42;

      case AHedefYazmacSN of
        YZMC_EAX: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_EAX] + 0)^;
        YZMC_ECX: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_ECX] + 0)^;
        YZMC_EDX: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_EDX] + 0)^;
        YZMC_EBX: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_EBX] + 0)^;
        // esp değeri yığına, yığın azaltılmadan önceki değeriyle itilir
        YZMC_ESP: begin D43 := PLongWord(@YZMC_DEGERSN[YZMC0_ESP] + 0)^; D43 += 4; end;
        YZMC_EBP: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_EBP] + 0)^;
        YZMC_ESI: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_ESI] + 0)^;
        YZMC_EDI: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_EDI] + 0)^;
      end;

      PLongWord(@Bellek144MB[(D41 * $10) + D42])^ := D43;
    end;
  end;

  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[YZMC0_ESP]] := '$' + HexStr(YZMC_DEGERSN[YZMC0_ESP], 8);

  Application.ProcessMessages;
end;

function TfrmAnaSayfa.YigindanAl(AVeriUzunlugu: LongWord): LongWord;
var
  V41, V42: LongWord;   // işaretsiz 32 bit
begin

  V41 := YZMC_DEGERSN[YZMC0_SS];
  V42 := YZMC_DEGERSN[YZMC0_ESP];

  case AVeriUzunlugu of
    VU1: begin Result := PByte(@Bellek144MB[(V41 * $10) + V42])^; end;
    VU2: begin Result := PWord(@Bellek144MB[(V41 * $10) + V42])^; end;
    VU4: begin Result := PLongWord(@Bellek144MB[(V41 * $10) + V42])^; end;
    else Exit;
  end;

  V42 += AVeriUzunlugu;
  YZMC_DEGERSN[YZMC0_ESP] := V42;

  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[YZMC0_ESP]] := '$' + HexStr(YZMC_DEGERSN[YZMC0_ESP], 8);

  Application.ProcessMessages;
end;

end.
