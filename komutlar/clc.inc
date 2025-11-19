// F8 - CLC - Clear CF flag
else if(IslenenKomut = $F8) then
begin

  BayrakDegistir(BAYRAK_CF, True);
  {$IFDEF DEBUG} mmCikti.Lines.Add('clc', []); {$ENDIF}
  IPDegeriniArtir;
end
