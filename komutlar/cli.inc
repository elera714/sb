// FA - CLI - Clear interrupt flag; interrupts disabled when interrupt flag cleared
else if(Komut = $FA) then
begin

  BayrakDegistir(BAYRAK_IF, False);
  {$IFDEF DEBUG} mmCikti.Lines.Add('cli', []); {$ENDIF}
  IPDegeriniArtir;
end
