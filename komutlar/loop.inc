// E2 cb - LOOP rel8 - Decrement count; jump short if count ≠ 0
else if(Komut = $E2) then
begin

  D41 := YazmacDegerAl(YZMC_CX);
  D41 := D41 - 1;
  YazmacDegistir(YZMC_CX, D41);

  if(D41 = 0) then
    BayrakDegistir(BAYRAK_ZF)
  else BayrakDegistir(BAYRAK_CF, False);

  {$IFDEF DEBUG} mmCikti.Lines.Add('loop %d', [ShortInt(Komut2)]); {$ENDIF}

  IPDegeriniArtir(1 + 1);

  if(D41 > 0) then IPDegeriniArtir(ShortInt(Komut2));
end
