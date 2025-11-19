// F9 - STC - Set CF flag
else if(IslenenKomut = $F9) then
begin

  BayrakDegistir(BAYRAK_CF);
  {$IFDEF DEBUG} mmCikti.Lines.Add('stc', []); {$ENDIF}
  IPDegeriniArtir;
end
