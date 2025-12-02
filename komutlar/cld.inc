// FC - CLD - Clear DF flag
else if(IslenenKomut = $FC) then
begin

  BayrakDegistir(BAYRAK_DF, False);
  {$IFDEF DEBUG} mmCikti.Lines.Add('cld', []); {$ENDIF}
  IPDegeriniArtir;
end
