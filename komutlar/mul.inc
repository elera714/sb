// F7 /4 - MUL r/m16 - Unsigned multiply (DX:AX ← AX ∗ r/m16)
else if(Komut = $F7) and ((Komut2 and %11111000) = %00100000) then
begin

  D41 := (Komut2 and %00000111);                  // kaynak yazmaç
  D42 := Mod00Isle(D41);
  D43 := PWord(@Bellek144MB[D42])^;

  D44 := YazmacDegerAl(YZMC_AX) and $FFFF;
  D45 := D44 * D43;

  YazmacDegistir(YZMC_AX, D45 and $FFFF);
  D45 := D45 shr 16;

  if(D45 > 0) then
  begin

    YazmacDegistir(YZMC_DX, D45);
    BayrakDegistir(BAYRAK_CF);
    BayrakDegistir(BAYRAK_OF);
  end
  else
  begin

    YazmacDegistir(YZMC_DX, 0);
    BayrakDegistir(BAYRAK_CF, False);
    BayrakDegistir(BAYRAK_OF, False);
  end;

  // komut uzunluğu öndeğer = 2 byte
  D44 := 2;
  if(D41 = 6) then D44 := 4;

  {$IFDEF DEBUG}
  if(D41 = 6) then
    mmCikti.Lines.Add('mul [$%.4x]', [PWord(@Bellek144MB[IslenenAdres + 2])^])
  else mmCikti.Lines.Add('mul %s', [Bellekler00[D41]]);
  {$ENDIF}

  IPDegeriniArtir(D44);
end
// F7 /4 - MUL r/m16 - Unsigned multiply (DX:AX ← AX ∗ r/m16)
else if(Komut = $F7) and ((Komut2 and %11111000) = %11100000) then
begin

  D41 := MYB16[Komut2 and %00000111];             // yazmaç
  D42 := YazmacDegerAl(D41);

  D43 := YazmacDegerAl(YZMC_AX) and $FFFF;
  D43 := D42 * D43;

  YazmacDegistir(YZMC_AX, D43 and $FFFF);
  D43 := D43 shr 16;

  if(D43 > 0) then
  begin

    YazmacDegistir(YZMC_DX, D45);
    BayrakDegistir(BAYRAK_CF);
    BayrakDegistir(BAYRAK_OF);
  end
  else
  begin

    YazmacDegistir(YZMC_DX, 0);
    BayrakDegistir(BAYRAK_CF, False);
    BayrakDegistir(BAYRAK_OF, False);
  end;

  {$IFDEF DEBUG}
  mmCikti.Lines.Add('mul %s', [Yazmaclar16[D41 and $FF]]);
  {$ENDIF}

  IPDegeriniArtir(2);
end
