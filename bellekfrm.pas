unit bellekfrm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids;

type

  { TfrmBellek }

  TfrmBellek = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  frmBellek: TfrmBellek;

implementation

{$R *.lfm}

uses islevler;

procedure TfrmBellek.Button1Click(Sender: TObject);
var
  x, y: Integer;
  B1: PByte;
  Adres: LongInt;
begin

  Adres := StrToInt(Edit1.Text);

  B1 := @Bellek1MB[Adres];

  for y := 1 to 16 do
  begin

    for x := 1 to 16 do
    begin

      StringGrid1.Cells[x, y] := '$' + HexStr(B1^, 2);
      Inc(B1);
    end;
  end;
end;

end.
