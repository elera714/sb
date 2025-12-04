// F8 - CLC - Clear CF flag
else if(Komut = $F8) then
begin

  BayrakDegistir(BAYRAK_CF, False);
  {$IFDEF DEBUG} mmCikti.Lines.Add('clc', []); {$ENDIF}
  IPDegeriniArtir;
end
