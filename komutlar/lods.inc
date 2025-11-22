// AC - LODS m8 - Load byte at address DS:(E)SI into AL
// AC - LODSB - Load byte at address DS:(E)SI into AL
else if(IslenenKomut = $AC) then
begin

  V41 := YZMC_DEGERSN[YZMC0_ESI] and $FFFF;
  V42 := (YZMC_DEGERSN[YZMC0_DS] * $10) + V41;
  V11 := PByte(@Bellek144MB[V42])^;
  YazmacDegistir2(YZMC_AL, V11);

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

    V41 := YZMC_DEGERSN[YZMC0_ESI];
    V42 := (YZMC_DEGERSN[YZMC0_DS] * $10) + V41;
    V41 := PLongWord(@Bellek144MB[V42])^;
    YazmacDegistir2(YZMC_EAX, V41);

    {$IFDEF DEBUG} mmCikti.Lines.Add('lodsd'); {$ENDIF}
  end
  // AD - LODS m16 - Load word at address DS:(E)SI into AX
  // AD - LODSW - Load word at address DS:(E)SI into AX
  else
  begin

    V41 := YZMC_DEGERSN[YZMC0_ESI] and $FFFF;
    V42 := (YZMC_DEGERSN[YZMC0_DS] * $10) + V41;
    V21 := PWord(@Bellek144MB[V42])^;
    YazmacDegistir2(YZMC_AX, V21);

    {$IFDEF DEBUG} mmCikti.Lines.Add('lodsw'); {$ENDIF}
  end;

  // df bayrağının durumuna göre (e)si yazmacını bir artır/eksilt
  if(GetBit(Bayraklar, BAYRAK_DF)) then
    YazmacDegistir2(YZMC_ESI, -1, True)
  else YazmacDegistir2(YZMC_ESI, +1, True);

  IPDegeriniArtir;
end
