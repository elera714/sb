// AA - STOS m8 - Store AL at address ES:(E)DI
// AA - STOSB - Store AL at address ES:(E)DI
else if(Komut = $AA) then
begin

  D41 := YZMC_DEGERSN[YZMC0_EDI] and $FFFF;
  D42 := (YZMC_DEGERSN[YZMC0_ES] * $10) + D41;
  D11 := YazmacDegerAl(YZMC_AL);
  PByte(@Bellek144MB[D42])^ := D11;

  // df bayrağının durumuna göre (e)si yazmacını bir artır/eksilt
  if(GetBit(Bayraklar, BAYRAK_DF)) then
    YazmacDegistir(YZMC_DI, -1, True)
  else YazmacDegistir(YZMC_DI, +1, True);

  {$IFDEF DEBUG} mmCikti.Lines.Add('stosb'); {$ENDIF}
  IPDegeriniArtir;
end
else if(Komut = $AB) then
begin

  // AB - STOS m32 - Store EAX at address ES:(E)DI
  // AB - STOSD - Store EAX at address ES:(E)DI
  if(KomutModDegistir) then
  begin

    D41 := YZMC_DEGERSN[YZMC0_EDI];
    D42 := (YZMC_DEGERSN[YZMC0_ES] * $10) + D41;
    D43 := YazmacDegerAl(YZMC_EAX);
    PLongWord(@Bellek144MB[D42])^ := D43;

    // df bayrağının durumuna göre (e)si yazmacını bir artır/eksilt
    if(GetBit(Bayraklar, BAYRAK_DF)) then
      YazmacDegistir(YZMC_EDI, -1, True)
    else YazmacDegistir(YZMC_EDI, +1, True);

    {$IFDEF DEBUG} mmCikti.Lines.Add('stosd'); {$ENDIF}
  end
  // AB - STOS - m16 Store AX at address ES:(E)DI
  // AB - STOSW - Store AX at address ES:(E)DI
  else
  begin

    D41 := YZMC_DEGERSN[YZMC0_EDI] and $FFFF;
    D42 := (YZMC_DEGERSN[YZMC0_ES] * $10) + D41;
    D21 := YazmacDegerAl(YZMC_AX);
    PWord(@Bellek144MB[D42])^ := D21;

    // df bayrağının durumuna göre (e)si yazmacını bir artır/eksilt
    if(GetBit(Bayraklar, BAYRAK_DF)) then
      YazmacDegistir(YZMC_DI, -1, True)
    else YazmacDegistir(YZMC_DI, +1, True);

    {$IFDEF DEBUG} mmCikti.Lines.Add('stosw'); {$ENDIF}
  end;

  IPDegeriniArtir;
end
