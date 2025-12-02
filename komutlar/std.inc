// FD - STD - Set DF flag
else if(IslenenKomut = $FD) then
begin

  BayrakDegistir(BAYRAK_DF);
  {$IFDEF DEBUG} mmCikti.Lines.Add('std', []); {$ENDIF}
  IPDegeriniArtir;
end
