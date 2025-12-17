// D1 /5 - SHR r/m16,1 - Unsigned divide r/m16 by 2, once
else if(Komut = $D1) then
begin

  if((Komut2 and %11101000) = %11101000) then
  begin

    D41 := MYB16[Komut2 and %111];
    D21 := YazmacDegerAl(D41);

    BayrakDegistir(BAYRAK_CF, (D21 and 1) = 1);

    D21 := D21 shr 1;
    YazmacDegistir(D41, D21);

    {$IFDEF DEBUG} mmCikti.Lines.Add('shr %s,1', [Yazmaclar16[D41 and $F]]); {$ENDIF}
    IPDegeriniArtir(2);
  end;
end
// C1 /5 ib - SHR r/m16,imm8 - Unsigned divide r/m16 by 2, imm8 times
else if(Komut = $C1) then
begin

  if((Komut2 and %11101000) = %11101000) then
  begin

    D41 := MYB16[Komut2 and %111];
    D21 := YazmacDegerAl(D41);
    D11 := PByte(@Bellek144MB[IslenenAdres + 2])^;

    D22 := D21 shr D11-1;
    BayrakDegistir(BAYRAK_CF, (D22 and 1) = 1);

    D21 := D21 shr D11;
    YazmacDegistir(D41, D21);

    {$IFDEF DEBUG} mmCikti.Lines.Add('shr %s,%.2x', [Yazmaclar16[D41 and $F], D11]); {$ENDIF}
    IPDegeriniArtir(2 + 1);
  end;
end
