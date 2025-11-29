// 3C ib - CMP AL, imm8 - Compare imm8 with AL
else if(IslenenKomut = $3C) then
begin

  D11 := YazmacDegerAl(YZMC_AL);

  I11 := ShortInt(D11) - ShortInt(BirSonrakiKomut);
  if(I11 = 0) then
    BayrakDegistir(BAYRAK_ZF)
  else BayrakDegistir(BAYRAK_ZF, False);

  if(I11 < 0) then
    BayrakDegistir(BAYRAK_SF)
  else BayrakDegistir(BAYRAK_SF, False);

  {$IFDEF DEBUG} mmCikti.Lines.Add('cmp al,%d', [ShortInt(BirSonrakiKomut)]); {$ENDIF}

  IPDegeriniArtir(2);
end
else if(IslenenKomut = $3D) then
begin

  // 3D id - CMP EAX, imm32 - Compare imm32 with EAX
  if(KomutModDegistir) then
  begin

    D41 := PLongWord(@Bellek144MB[Adres + 1])^;

    D42 := YazmacDegerAl(YZMC_EAX);

    I41 := ShortInt(D42) - ShortInt(D41);
    if(I41 = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, False);

    if(I41 < 0) then
      BayrakDegistir(BAYRAK_SF)
    else BayrakDegistir(BAYRAK_SF, False);

    {$IFDEF DEBUG} mmCikti.Lines.Add('cmp eax,%d', [SmallInt(D41)]); {$ENDIF}

    IPDegeriniArtir(1 + 4);
  end
  else
  // 3D iw - CMP AX, imm16 - Compare imm16 with AX
  begin

    D21 := PWord(@Bellek144MB[Adres + 1])^;

    D22 := YazmacDegerAl(YZMC_AX);

    I21 := ShortInt(D22) - ShortInt(D21);
    if(I21 = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, False);

    if(I21 < 0) then
      BayrakDegistir(BAYRAK_SF)
    else BayrakDegistir(BAYRAK_SF, False);

    {$IFDEF DEBUG} mmCikti.Lines.Add('cmp ax,%d', [SmallInt(D21)]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end;
end
