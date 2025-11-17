unit bellekfrm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids;

type
  TfrmBellek = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
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

uses islevler;

procedure TfrmBellek.FormShow(Sender: TObject);
begin

  if not(Goruntule) then BellekAdresi := 0;

  Edit1.Text := '$' + HexStr(BellekAdresi, 8);

  Button1Click(Self);
end;

procedure TfrmBellek.Button1Click(Sender: TObject);
var
  x, y, i: LongWord;
  B1: PByte;
begin

  BellekAdresi := StrToInt(Edit1.Text);
  Edit1.Text := '$' + HexStr(BellekAdresi, 8);

  i := BellekAdresi;
  for y := 1 to 16 do
  begin

    StringGrid1.Cells[0, y] := '$' + HexStr(i, 8);
    Inc(i, $10);
  end;

  B1 := @Bellek144MB[BellekAdresi];

  for y := 1 to 16 do
  begin

    for x := 1 to 16 do
    begin

      StringGrid1.Cells[x, y] := '$' + HexStr(B1^, 2);
      Inc(B1);
    end;
  end;
end;

procedure TfrmBellek.Button2Click(Sender: TObject);
begin

  BellekAdresi += 256;

  if(BellekAdresi > (DISKET_BOYUT - 256)) then BellekAdresi -= 256;

  Edit1.Text := '$' + HexStr(BellekAdresi, 8);

  Button1Click(Self);
end;

procedure TfrmBellek.Button3Click(Sender: TObject);
begin

  BellekAdresi -= 256;

  if(BellekAdresi < 0) then BellekAdresi := 0;

  Edit1.Text := '$' + HexStr(BellekAdresi, 8);

  Button1Click(Self);
end;

end.
