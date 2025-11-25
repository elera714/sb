// AC - LODS m8 - Load byte at address DS:(E)SI into AL
// AC - LODSB - Load byte at address DS:(E)SI into AL
else if(IslenenKomut = $AC) then
begin

  D41 := YZMC_DEGERSN[YZMC0_ESI] and $FFFF;
  D42 := (YZMC_DEGERSN[YZMC0_DS] * $10) + D41;
  D11 := PByte(@Bellek144MB[D42])^;
  YazmacDegistir2(YZMC_AL, D11);

  // df bayrağının durumuna göre (e)si yazmacını bir artır/eksilt
  if(GetBit(Bayraklar, BAYRAK_DF)) then
    YazmacDegistir2(YZMC_ESI, -1, True)
  else YazmacDegistir2(YZMC_ESI, +1, True);

  {$IFDEF DEBUG} mmCikti.Lines.Add('lodsb'); {$ENDIF}
  IPDegeriniArtir;
end
else if(IslenenKomut = $AD) then
begin

  // AD - LODS m32 - Load doubleword at address DS:(E)SI into EAX
  // AD - LODSD - Load doubleword at address DS:(E)SI into EAX
  if(KomutModDegistir) then
  begin

    D41 := YZMC_DEGERSN[YZMC0_ESI];
    D42 := (YZMC_DEGERSN[YZMC0_DS] * $10) + D41;
    D41 := PLongWord(@Bellek144MB[D42])^;
    YazmacDegistir2(YZMC_EAX, D41);

    {$IFDEF DEBUG} mmCikti.Lines.Add('lodsd'); {$ENDIF}
  end
  // AD - LODS m16 - Load word at address DS:(E)SI into AX
  // AD - LODSW - Load word at address DS:(E)SI into AX
  else
  begin

    D41 := YZMC_DEGERSN[YZMC0_ESI] and $FFFF;
    D42 := (YZMC_DEGERSN[YZMC0_DS] * $10) + D41;
    D21 := PWord(@Bellek144MB[D42])^;
    YazmacDegistir2(YZMC_AX, D21);

    {$IFDEF DEBUG} mmCikti.Lines.Add('lodsw'); {$ENDIF}
  end;

  // df bayrağının durumuna göre (e)si yazmacını bir artır/eksilt
  if(GetBit(Bayraklar, BAYRAK_DF)) then
    YazmacDegistir2(YZMC_ESI, -1, True)
  else YazmacDegistir2(YZMC_ESI, +1, True);

  IPDegeriniArtir;
end
