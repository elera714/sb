// 90 - NOP - No operation
else if(Komut = $90) then
begin

  {$IFDEF DEBUG} mmCikti.Lines.Add('nop'); {$ENDIF}
  IPDegeriniArtir;
end
