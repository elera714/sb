// FB - STI - Set interrupt flag; external, maskable interrupts enabled at the end of the next instruction
else if(Komut = $FB) then
begin

  BayrakDegistir(BAYRAK_IF);
  {$IFDEF DEBUG} mmCikti.Lines.Add('sti', []); {$ENDIF}
  IPDegeriniArtir;
end
