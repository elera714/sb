unit anasayfafrm;

{$mode objfpc}{$H+}
{$DEFINE YAZMACLARI_GUNCELLE}
{$DEFINE DEBUG}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Grids, ValEdit;

type
  TIslemciSonuc = (isBirSonraki, isIslendi, isHata, isYenidenBaslat);

type
  TEkran = class(TThread)
  protected
    procedure Execute; override;
    procedure Yenile;
  public
    constructor Create(CreateSuspended : Boolean);
  end;

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
    pnlEkran: TPanel;
    pnlGovde: TPanel;
    Panel2: TPanel;
    pnlUst: TPanel;
    pnlYazmaclar: TPanel;
    sbDurum: TStatusBar;
    Splitter1: TSplitter;
    ValueListEditor1: TValueListEditor;
    procedure btnCalistirClick(Sender: TObject);
    procedure btnBellekClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    function Yorumla: TIslemciSonuc;
    function Isle(ACS, AIP: Integer): TIslemciSonuc;
    procedure YazmacDegistir(AHedefYazmacSN, ADeger: LongInt; AArtir: Boolean = False);
    procedure BayrakDegistir(AHedefBayrak: LongWord; AAktiflestir: Boolean = True);
    procedure BayraklariGuncelle(AHedefBayrak: LongWord = $FFFFFFFF);
    procedure YazmaclariSifirla;
    procedure BellegeKopyala(AKaynak, AHedef: Pointer; AHedefBellekBaslangic,
      AUzunluk: Integer);
    procedure IOPortOku(AHedefYazmacSN, AKaynakPortNo: Integer);
    procedure IOPortOku2(AHedefYazmacSN: Integer);
    procedure YiginaEkle(ADeger, ADegerUzunlugu: LongWord);
    procedure YiginaEkle2(AHedefYazmacSN: Integer);
    function YigindanAl(ADegerUzunlugu: LongWord): LongWord;
    function DosyaYukle(ADosyaAdi: string; AHedefBellekAdresi, ABaslangic,
      ABoyut: LongWord): string;
    procedure EkraniKartiniYukle;
  public

  end;

var
  frmAnaSayfa: TfrmAnaSayfa;
  DosyaU: Int64;
  Ekran : TEkran;

implementation

{$R *.lfm}
uses islevler, bellekfrm;

constructor TEkran.Create(CreateSuspended: Boolean);
begin

  inherited Create(CreateSuspended);
  FreeOnTerminate := True;
end;

procedure TEkran.Execute;
begin

  Synchronize(@Yenile);
  while (not Terminated) do
  begin

    Synchronize(@Yenile);
    Sleep(50);
  end;
end;

procedure TEkran.Yenile;
var
  x, y, i: Integer;
  Kar: Char;
  Renk: Byte;
begin

  frmAnaSayfa.pnlEkran.Canvas.Clear;
  i := $B8000;

  for y := 0 to 24 do
  begin

    for x := 0 to 79 do
    begin

      Kar := PChar(@Bellek144MB[i + 0])^;
      Renk := PByte(@Bellek144MB[i + 1])^;

      frmAnaSayfa.pnlEkran.Canvas.Brush.Color := RENKLER_YAZI[(Renk shr 4) and %1111];
      frmAnaSayfa.pnlEkran.Canvas.Font.Color := RENKLER_YAZI[Renk and %1111];
      frmAnaSayfa.pnlEkran.Canvas.TextOut(x * 8, y * 16, Kar);

      Inc(i, 2);
    end;
  end;
end;

procedure TfrmAnaSayfa.FormCreate(Sender: TObject);
var
  i: Integer;
begin

  SetLength(Bellek144MB, DISKET_BOYUT + ($7C0 * $10));

  for i := 0 to 65535 do Portlar[i] := 0;

  Ekran := TEkran.Create(True);
end;

procedure TfrmAnaSayfa.FormShow(Sender: TObject);
begin

  EkraniKartiniYukle;

  Ekran.Start;
end;

procedure TfrmAnaSayfa.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  Ekran.Terminate;
  Ekran.WaitFor;

  // sanal bilgisayar çalışıyorsa, durdur
  if(SB_CALISIYOR) then btnCalistirClick(Self);

  SetLength(Bellek144MB, 0);
end;

procedure TfrmAnaSayfa.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  BasilanTus := Key;
  BasilanTusSayisi := 1;
end;

procedure TfrmAnaSayfa.btnCalistirClick(Sender: TObject);
var
  Hata: string;
  IslemciSonuc: TIslemciSonuc;
label Ilklendir;
begin

Ilklendir:

  if not(SB_CALISIYOR) then
  begin

    EkraniKartiniYukle;
    YazmaclariSifirla;

    BasilanTusSayisi := 0;
    BasilanTus := 0;

    DosyaU := 0;
    FlpOkunanSektorSayisi := 0;

    mmCikti.Lines.Clear;
    sbDurum.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);
    sbDurum.Panels[2].Text := Format('Disket [%d]', [FlpOkunanSektorSayisi]);
    sbDurum.Repaint;
    Application.ProcessMessages;

    DisketImajDosyaAdi := cbIslenecekDosya.Text;

    // imaj dosyasını $7C0 adresine yükle
    Hata := DosyaYukle(DisketImajDosyaAdi, $07C0 * $10, 0, 512);

    if(Length(Hata) = 0) then
    begin

      sbDurum.Panels[0].Text := Format('Toplam Uzunluk: %d', [DosyaU]);

      SB_CALISIYOR := True;
      btnCalistir.Caption := 'Durdur';

      IslemciSonuc := Yorumla;
      if(IslemciSonuc = isYenidenBaslat) then
      begin

        SB_CALISIYOR := False;
        btnCalistir.Caption := 'Çalıştır';
        goto Ilklendir;
      end;

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

function TfrmAnaSayfa.Yorumla: TIslemciSonuc;
var
  Islenen, HataAdresi: Integer;
  HataVar: Boolean;
  IslemciSonuc: TIslemciSonuc;
begin

  Islenen := 0;
  HataVar := False;

  KomutModDegistir := False;
  BaskinSegment := 0;

  lblIskenenKomutSayisi.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);

  YZMC_DEGERSN[YZMC0_CS] := $07C0;
  YZMC_DEGERSN[YZMC0_EIP] := 0;

  repeat

    if(SB_CALISIYOR) then
    begin

      IslemciSonuc := Isle(YZMC_DEGERSN[YZMC0_CS], YZMC_DEGERSN[YZMC0_EIP]);

      YazmacDegistir(YZMC_CS, YZMC_DEGERSN[YZMC_CS and $FF]);
      YazmacDegistir(YZMC_IP, YZMC_DEGERSN[YZMC_IP and $FF]);

      if(IslemciSonuc = isIslendi) then
      begin

        Inc(Islenen);
        lblIskenenKomutSayisi.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);
        Application.ProcessMessages;

        // her komut sonrası ilgili değerleri öndeğerlerle yükle
        KomutModDegistir := False;
        BaskinSegment := 0;
      end
      else if(IslemciSonuc = isHata) then HataVar := True;

    end; // else DosyaIP := DosyaU + 1;

    Application.ProcessMessages;

  until (SB_CALISIYOR = False) or (HataVar = True) or (IslemciSonuc = isYenidenBaslat);

  if(HataVar) then
  begin

    HataAdresi := (YZMC_DEGERSN[YZMC0_CS] * $10) + YZMC_DEGERSN[YZMC0_EIP];
    Komut := Bellek144MB[HataAdresi];
    mmCikti.Lines.Add('Yürütme iptal edildi. Hatalı komut: $%.2x', [Komut]);

    SB_CALISIYOR := False;
    btnCalistir.Caption := 'Çalıştır';
  end;

  Result := IslemciSonuc;
end;

function TfrmAnaSayfa.Isle(ACS, AIP: Integer): TIslemciSonuc;
var
  D11, D12,
  D13, D14,
  D15, D16: Byte;       // işaretsiz 8 bit
  D21, D22,
  D23: Word;            // işaretsiz 16 bit
  D41, D42,
  D43, D44,
  D45: LongWord;        // işaretsiz 32 bit

  I11: ShortInt;
  I21: SmallInt;
  I41: LongInt;

  Esit,
  GostergeGuncelle: Boolean;
  i: Integer;

  // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
  procedure IPDegeriniArtir(AArtir: Integer = 1);
  var
    IP: LongWord;
  begin

    IP := YZMC_DEGERSN[YZMC0_EIP];
    IP += AArtir;
    YZMC_DEGERSN[YZMC0_EIP] := IP;

    Result := isIslendi;
  end;
begin

  Result := isHata;

  IslenenAdres := (ACS * $10) + AIP;

  Komut := Bellek144MB[IslenenAdres + 0];
  Komut2 := Bellek144MB[IslenenAdres + 1];

  // Operand-size override, 66H
  { TODO - önek değerinin tüm komutlardaki (operand) kullanımı yeniden ele alınacak }
  if(Komut = $66) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('önek - $66'); {$ENDIF}
    IPDegeriniArtir;

    // işlemci komutunun 16/32 bit değişimini gerçekleştirir
    KomutModDegistir := True;

    Exit(isBirSonraki);
  end
  // 2EH — CS segment override prefix.
  else if(Komut = $2E) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('cs:'); {$ENDIF}
    IPDegeriniArtir;
    BaskinSegment := YZMC_CS;
    Exit(isBirSonraki);
  end
  // 36H — SS segment override prefix.
  else if(Komut = $36) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('ss:'); {$ENDIF}
    IPDegeriniArtir;
    BaskinSegment := YZMC_SS;
    Exit(isBirSonraki);
  end
  // 3EH — DS segment override prefix.
  else if(Komut = $3E) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('ds:'); {$ENDIF}
    IPDegeriniArtir;
    BaskinSegment := YZMC_DS;
    Exit(isBirSonraki);
  end
  // 26H — ES segment override prefix.
  else if(Komut = $26) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('es:'); {$ENDIF}
    IPDegeriniArtir;
    BaskinSegment := YZMC_ES;
    Exit(isBirSonraki);
  end
  // 64H — FS segment override prefix.
  else if(Komut = $64) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('fs:'); {$ENDIF}
    IPDegeriniArtir;
    BaskinSegment := YZMC_FS;
    Exit(isBirSonraki);
  end
  // 65H — GS segment override prefix.
  else if(Komut = $65) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('gs:'); {$ENDIF}
    IPDegeriniArtir;
    BaskinSegment := YZMC_GS;
    Exit(isBirSonraki);
  end



  {$i komutlar\add.inc}
  {$i komutlar\and.inc}
  {$i komutlar\call.inc}
  {$i komutlar\clc.inc}
  {$i komutlar\cld.inc}
  {$i komutlar\cli.inc}
  {$i komutlar\cmp.inc}
  {$i komutlar\dec.inc}
  {$i komutlar\div.inc}
  {$i komutlar\imul.inc}
  {$i komutlar\in.inc}
  {$i komutlar\inc.inc}
  {$i komutlar\int.inc}
  {$i komutlar\iret.inc}
  {$i komutlar\jcc.inc}
  {$i komutlar\jmp.inc}
  {$i komutlar\lods.inc}
  {$i komutlar\loop.inc}
  {$i komutlar\lxs.inc}
  {$i komutlar\mov.inc}
  {$i komutlar\mul.inc}
  {$i komutlar\nop.inc}
  {$i komutlar\or.inc}
  {$i komutlar\out.inc}
  {$i komutlar\push.inc}
  {$i komutlar\pusha.inc}
  {$i komutlar\pushf.inc}
  {$i komutlar\pop.inc}
  {$i komutlar\popa.inc}
  {$i komutlar\popf.inc}
  {$i komutlar\rep.inc}
  {$i komutlar\ret.inc}
  {$i komutlar\stc.inc}
  {$i komutlar\std.inc}
  {$i komutlar\sti.inc}
  {$i komutlar\stos.inc}
  {$i komutlar\sxlr.inc}
  {$i komutlar\test.inc}
  {$i komutlar\xchg.inc}
  {$i komutlar\xor.inc}
end;

procedure TfrmAnaSayfa.YazmacDegistir(AHedefYazmacSN, ADeger: LongInt; AArtir: Boolean = False);
var
  DegerSN: LongWord;
  D11: Byte;            // işaretsiz 8 bit
  D21: Word;            // işaretsiz 16 bit
  D41: LongWord;        // işaretsiz 32 bit
begin

  DegerSN := (AHedefYazmacSN and $F);

  case AHedefYazmacSN of
    YZMC_AL, YZMC_CL, YZMC_DL, YZMC_BL:
    begin

      D11 := PByte(@YZMC_DEGERSN[DegerSN] + 0)^;
      if(AArtir) then
        D11 := D11 + (ADeger and $FF)
      else D11 := (ADeger and $FF);
      PByte(@YZMC_DEGERSN[DegerSN] + 0)^ := D11;
    end;
    YZMC_AH, YZMC_CH, YZMC_DH, YZMC_BH:
    begin

      D11 := PByte(@YZMC_DEGERSN[DegerSN] + 1)^;
      if(AArtir) then
        D11 := D11 + (ADeger and $FF)
      else D11 := (ADeger and $FF);
      PByte(@YZMC_DEGERSN[DegerSN] + 1)^ := D11;
    end;
    YZMC_AX, YZMC_CX, YZMC_DX, YZMC_BX, YZMC_SP, YZMC_BP, YZMC_SI, YZMC_DI,
    YZMC_CS, YZMC_DS, YZMC_ES, YZMC_SS, YZMC_FS, YZMC_GS, YZMC_IP:
    begin

      D21 := PWord(@YZMC_DEGERSN[DegerSN])^;
      if(AArtir) then
        D21 := D21 + (ADeger and $FFFF)
      else D21 := (ADeger and $FFFF);
      PWord(@YZMC_DEGERSN[DegerSN])^ := D21;
    end;
    YZMC_EAX, YZMC_ECX, YZMC_EDX, YZMC_EBX, YZMC_ESP, YZMC_EBP, YZMC_ESI, YZMC_EDI:
    begin

      D41 := PLongWord(@YZMC_DEGERSN[DegerSN])^;
      if(AArtir) then
        D41 := D41 + ADeger
      else D41 := ADeger;
      PLongWord(@YZMC_DEGERSN[DegerSN])^ := D41;
    end;
  end;

  {$IFDEF YAZMACLARI_GUNCELLE}
  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[DegerSN]] := '$' + HexStr(YZMC_DEGERSN[DegerSN], 8);
  {$ENDIF}

  Application.ProcessMessages;
end;

procedure TfrmAnaSayfa.BayrakDegistir(AHedefBayrak: LongWord; AAktiflestir: Boolean = True);
begin

  if(AAktiflestir) then
    SetBit(Bayraklar, AHedefBayrak)
  else ClearBit(Bayraklar, AHedefBayrak);

  BayraklariGuncelle(AHedefBayrak);
end;

procedure TfrmAnaSayfa.BayraklariGuncelle(AHedefBayrak: LongWord = $FFFFFFFF);
var
  V41: LongWord;         // işaretsiz 32 bit
begin

  // tüm bayrakları güncelle
  if(AHedefBayrak = $FFFFFFFF) then
  begin

    lblCF.Caption := Format('CF=%d', [(Bayraklar shr BAYRAK_CF) and 1]);
    lblPF.Caption := Format('PF=%d', [(Bayraklar shr BAYRAK_PF) and 1]);
    lblAF.Caption := Format('AF=%d', [(Bayraklar shr BAYRAK_AF) and 1]);
    lblZF.Caption := Format('ZF=%d', [(Bayraklar shr BAYRAK_ZF) and 1]);
    lblSF.Caption := Format('SF=%d', [(Bayraklar shr BAYRAK_SF) and 1]);
    lblTF.Caption := Format('TF=%d', [(Bayraklar shr BAYRAK_TF) and 1]);
    lblIF.Caption := Format('IF=%d', [(Bayraklar shr BAYRAK_IF) and 1]);
    lblDF.Caption := Format('DF=%d', [(Bayraklar shr BAYRAK_DF) and 1]);
    lblOF.Caption := Format('OF=%d', [(Bayraklar shr BAYRAK_OF) and 1]);
    //lblIOPL.Caption := Format('IOPL=%d', [V41]);  { TODO 2 bir olarak ayarlanacak}
    lblNT.Caption := Format('NT=%d', [(Bayraklar shr BAYRAK_NT) and 1]);
  end
  else
  // belirtilen bayrağı güncelle
  begin

    V41 := (Bayraklar shr AHedefBayrak) and 1;

    case AHedefBayrak of
      BAYRAK_CF: lblCF.Caption := Format('CF=%d', [V41]);
      BAYRAK_PF: lblPF.Caption := Format('PF=%d', [V41]);
      BAYRAK_AF: lblAF.Caption := Format('AF=%d', [V41]);
      BAYRAK_ZF: lblZF.Caption := Format('ZF=%d', [V41]);
      BAYRAK_SF: lblSF.Caption := Format('SF=%d', [V41]);
      BAYRAK_TF: lblTF.Caption := Format('TF=%d', [V41]);
      BAYRAK_IF: lblIF.Caption := Format('IF=%d', [V41]);
      BAYRAK_DF: lblDF.Caption := Format('DF=%d', [V41]);
      BAYRAK_OF: lblOF.Caption := Format('OF=%d', [V41]);
      //BAYRAK_IOPL: lblIOPL.Caption := Format('IOPL=%d', [V41]);  { TODO 2 bir olarak ayarlanacak}
      BAYRAK_NT: lblNT.Caption := Format('NT=%d', [V41]);
    end;
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
      YazmacDegistir(YZMC_AL, KaynakDeger);
    end;
    YZMC_AX:
    begin
      KaynakDeger := (KaynakDeger and $FFFF);
      YazmacDegistir(YZMC_AX, KaynakDeger);
    end;
    YZMC_EAX:
    begin
      YazmacDegistir(YZMC_EAX, KaynakDeger);
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
      YazmacDegistir(YZMC_AL, KaynakDeger);
    end;
    YZMC_AX:
    begin
      KaynakDeger := (KaynakDeger and $FFFF);
      YazmacDegistir(YZMC_AX, KaynakDeger);
    end;
    YZMC_EAX:
    begin
      YazmacDegistir(YZMC_EAX, KaynakDeger);
    end;
    else Exit;
  end;
end;

procedure TfrmAnaSayfa.YiginaEkle(ADeger, ADegerUzunlugu: LongWord);
var
  V41, V42: LongWord;   // işaretsiz 32 bit
begin

  V41 := YZMC_DEGERSN[YZMC0_SS];
  V42 := YZMC_DEGERSN[YZMC0_ESP];
  V42 -= ADegerUzunlugu;
  YZMC_DEGERSN[YZMC0_ESP] := V42;

  case ADegerUzunlugu of
    DU1: begin PByte(@Bellek144MB[(V41 * $10) + V42])^ := (ADeger and $FF); end;
    DU2: begin PWord(@Bellek144MB[(V41 * $10) + V42])^ := (ADeger and $FFFF); end;
    DU4: begin PLongWord(@Bellek144MB[(V41 * $10) + V42])^ := ADeger; end;
    else Exit;
  end;

  {$IFDEF YAZMACLARI_GUNCELLE}
  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[YZMC0_ESP]] := '$' + HexStr(YZMC_DEGERSN[YZMC0_ESP], 8);
  {$ENDIF}

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
    YZMC_AX, YZMC_CX, YZMC_DX, YZMC_BX, YZMC_SP, YZMC_BP, YZMC_SI, YZMC_DI,
    YZMC_CS, YZMC_DS, YZMC_ES, YZMC_SS, YZMC_FS, YZMC_GS:
    begin

      // esp değerini güncelle
      D41 := PLongWord(@YZMC_DEGERSN[YZMC0_SS] + 0)^;
      D42 := PLongWord(@YZMC_DEGERSN[YZMC0_ESP] + 0)^;
      D42 -= 2;
      PLongWord(@YZMC_DEGERSN[YZMC0_ESP] + 0)^ := D42;

      // yazmacın değerini yığına ekle
      case AHedefYazmacSN of
        YZMC_AX: D21 := PWord(@YZMC_DEGERSN[YZMC0_EAX] + 0)^;
        YZMC_CX: D21 := PWord(@YZMC_DEGERSN[YZMC0_ECX] + 0)^;
        YZMC_DX: D21 := PWord(@YZMC_DEGERSN[YZMC0_EDX] + 0)^;
        YZMC_BX: D21 := PWord(@YZMC_DEGERSN[YZMC0_EBX] + 0)^;
        // esp değeri yığına, yığın azaltılmadan önceki değeriyle itilir
        YZMC_SP: D21 := D42 + 2;
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
        YZMC_ESP: D43 := D42 + 4;
        YZMC_EBP: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_EBP] + 0)^;
        YZMC_ESI: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_ESI] + 0)^;
        YZMC_EDI: D43 := PLongWord(@YZMC_DEGERSN[YZMC0_EDI] + 0)^;
      end;

      PLongWord(@Bellek144MB[(D41 * $10) + D42])^ := D43;
    end;
  end;

  {$IFDEF YAZMACLARI_GUNCELLE}
  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[YZMC0_ESP]] := '$' + HexStr(YZMC_DEGERSN[YZMC0_ESP], 8);
  {$ENDIF}

  Application.ProcessMessages;
end;

function TfrmAnaSayfa.YigindanAl(ADegerUzunlugu: LongWord): LongWord;
var
  V41, V42: LongWord;   // işaretsiz 32 bit
begin

  V41 := YZMC_DEGERSN[YZMC0_SS];
  V42 := YZMC_DEGERSN[YZMC0_ESP];

  case ADegerUzunlugu of
    DU1: begin Result := PByte(@Bellek144MB[(V41 * $10) + V42])^; end;
    DU2: begin Result := PWord(@Bellek144MB[(V41 * $10) + V42])^; end;
    DU4: begin Result := PLongWord(@Bellek144MB[(V41 * $10) + V42])^; end;
    else Exit;
  end;

  V42 += ADegerUzunlugu;
  YZMC_DEGERSN[YZMC0_ESP] := V42;

  {$IFDEF YAZMACLARI_GUNCELLE}
  ValueListEditor1.Cells[1, 1 + YZMC_GORSELSN[YZMC0_ESP]] := '$' + HexStr(YZMC_DEGERSN[YZMC0_ESP], 8);
  {$ENDIF}

  Application.ProcessMessages;
end;

function TfrmAnaSayfa.DosyaYukle(ADosyaAdi: string; AHedefBellekAdresi, ABaslangic,
  ABoyut: LongWord): string;
var
  FS: TFileStream;
begin

  Application.ProcessMessages;

  Result := '';

  try
    FS := TFileStream.Create(ADosyaAdi, fmOpenRead);
    FS.Position := ABaslangic;
    DosyaU := FS.Size;

    if(DosyaU > ABoyut) then DosyaU := ABoyut;

    if(DosyaU <= DISKET_BOYUT) then
    begin

      FS.Read(Bellek144MB[AHedefBellekAdresi], ABoyut); //DosyaU);
      FlpOkunanSektorSayisi += (ABoyut div 512);
    end else Result := 'Hata: dosya 1.44MB''den büyük olamaz!';

    FS.Free;
  except
    on E: Exception do Result := E.Message;
  end;

  sbDurum.Panels[2].Text := Format('Disket [%d]', [FlpOkunanSektorSayisi]);
  Application.ProcessMessages;
end;

procedure TfrmAnaSayfa.EkraniKartiniYukle;
var
  x, y,
  i: Integer;

  procedure Yaz(ASatirNo: Integer; ADeger: string);
  var
    j: Integer;
  begin

    i := $B8000 + (ASatirNo * (80 * 2));

    for j := 1 to Length(ADeger) do
    begin

      PChar(@Bellek144MB[i + 0])^ := ADeger[j];
      PByte(@Bellek144MB[i + 1])^ := $0E;
      Inc(i, 2);
    end;
  end;
begin

  i := $B8000;

  for y := 0 to 24 do
  begin

    for x := 0 to 79 do
    begin

      PChar(@Bellek144MB[i + 0])^ := ' ';
      PByte(@Bellek144MB[i + 1])^ := $0F;
      Inc(i, 2);
    end;
  end;

  Yaz(0, ProgramAdi);
  Yaz(1, 'Surum: ' + SurumNo);
  Yaz(2, 'Kodlayan: ' + Kodlayan);

  GostergeX := 0;
  GostergeY := 4;
end;

end.
