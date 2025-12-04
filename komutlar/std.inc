// FD - STD - Set DF flag
else if(Komut = $FD) then
begin

  BayrakDegistir(BAYRAK_DF);
  {$IFDEF DEBUG} mmCikti.Lines.Add('std', []); {$ENDIF}
  IPDegeriniArtir;
end
