unit bellekfrm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids;

type

  { TfrmBellek }

  TfrmBellek = class(TForm)
    btnYenile: TButton;
    btnArtir: TButton;
    btnAzalt: TButton;
    edtAdres: TEdit;
    lblAdres: TLabel;
    pnlUst: TPanel;
    sgBellek: TStringGrid;
    procedure btnYenileClick(Sender: TObject);
    procedure btnArtirClick(Sender: TObject);
    procedure btnAzaltClick(Sender: TObject);
    procedure edtAdresKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
  public
    BellekAdresi: LongInt;
    Goruntule: Boolean;
  end;

var
  frmBellek: TfrmBellek;

implementation

{$R *.lfm}
uses islevler, LCLType;

procedure TfrmBellek.FormShow(Sender: TObject);
begin

  if not(Goruntule) then BellekAdresi := 0;

  edtAdres.Text := '$' + HexStr(BellekAdresi, 8);

  btnYenileClick(Self);
end;

procedure TfrmBellek.btnYenileClick(Sender: TObject);
var
  x, y, i: LongWord;
  B1: PByte;
begin

  BellekAdresi := StrToInt(edtAdres.Text);
  edtAdres.Text := '$' + HexStr(BellekAdresi, 8);

  i := BellekAdresi;
  for y := 1 to 16 do
  begin

    sgBellek.Cells[0, y] := '$' + HexStr(i, 8);
    Inc(i, $10);
  end;

  B1 := @Bellek144MB[BellekAdresi];

  for y := 1 to 16 do
  begin

    for x := 1 to 16 do
    begin

      sgBellek.Cells[x, y] := '$' + HexStr(B1^, 2);
      Inc(B1);
    end;
  end;
end;

procedure TfrmBellek.btnArtirClick(Sender: TObject);
begin

  BellekAdresi += 256;

  if(BellekAdresi > (DISKET_BOYUT - 256)) then BellekAdresi -= 256;

  edtAdres.Text := '$' + HexStr(BellekAdresi, 8);

  btnYenileClick(Self);
end;

procedure TfrmBellek.btnAzaltClick(Sender: TObject);
begin

  BellekAdresi -= 256;

  if(BellekAdresi < 0) then BellekAdresi := 0;

  edtAdres.Text := '$' + HexStr(BellekAdresi, 8);

  btnYenileClick(Self);
end;

procedure TfrmBellek.edtAdresKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if(Key = VK_RETURN) then btnYenileClick(Self);
end;

end.
