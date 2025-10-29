unit anasayfafrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
  private
    procedure Yorumla;
    function Isle(AAdres: Integer): Boolean;
  public

  end;

var
  Form1: TForm1;
  Bellek: array of Byte;
  DosyaU: Int64;
  DosyaIP, IP: Integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  F: File of Byte;
begin

  IP := 0;

  DosyaU := 0;
  SetLength(Bellek, DosyaU);

  Memo1.Lines.Clear;
  StatusBar1.SimpleText := Format('Toplam Uzunluk: %d', [DosyaU]);
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

  StatusBar1.SimpleText := Format('Toplam Uzunluk: %d', [DosyaU]);

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

    Label2.Caption := Format('Komut İşaretçisi: $%.4x', [$7C00 + DosyaIP]);

    if(Islendi) then
    begin

      Inc(Islenen);
    end
    else
    begin

      Memo1.Lines.Add('$%.2x - İşlenemedi!', [Deger]);
      HataVar := True;
    end;

    Application.ProcessMessages;

  until (DosyaIP >= DosyaU) or (HataVar = True);

  Label1.Caption := Format('İşlenen Komut Sayısı: %d', [Islenen]);

  if(HataVar) then
  begin

    Memo1.Lines.Add('Yürütme iptal edildi. Hatalı komut: $%.2x', [Deger]);
  end;
end;

function TForm1.Isle(AAdres: Integer): Boolean;
var
  Deger, D2: Byte;
begin

  Deger := Bellek[AAdres];

  // EB cb JMP rel8
  if(Deger = $EB) then
  begin

    D2 := Bellek[AAdres + 1];
    Memo1.Lines.Add('$%.2x-$%.2x - jmp', [Deger, D2]);
    Inc(DosyaIP, 2);
    Inc(DosyaIP, D2);     // komuttan itibaren belirtilen değer kadar atlama gerçekleştir
    Result := True;
  end
  // nop komutu - tamamlandı
  else if(Deger = $90) then
  begin

    Memo1.Lines.Add('$%.2x - nop', [Deger]);
    Inc(DosyaIP, 1);
    Result := True;
  end
  else
  begin

    Result := False;
  end;
end;

end.
