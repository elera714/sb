// F3 A4 - REP MOVS m8,m8 - Move (E)CX bytes from DS:[(E)SI] to ES:[(E)DI]
else if(Komut = $F3) and (Komut2 = $A4) then
begin

  D21 := YazmacDegerAl(YZMC_CX);
  D41 := (YZMC_DEGERSN[YZMC_DS and $F] * $10) + YZMC_DEGERSN[YZMC_SI and $F];
  D42 := (YZMC_DEGERSN[YZMC_ES and $F] * $10) + YZMC_DEGERSN[YZMC_DI and $F];

  for i := 1 to D21 do
  begin

    PByte(@Bellek144MB[D42])^ := PByte(@Bellek144MB[D41])^;
    Inc(D41);
    Inc(D42);
  end;

  {$IFDEF DEBUG} mmCikti.Lines.Add('rep movsb', []); {$ENDIF}

  IPDegeriniArtir(2);
end
// F3 A5 - REP MOVS m16,m16 - Move (E)CX words from DS:[(E)SI] to ES:[(E)DI]
else if(Komut = $F3) and (Komut2 = $A5) then
begin

  D21 := YazmacDegerAl(YZMC_CX);
  D41 := (YZMC_DEGERSN[YZMC_DS and $F] * $10) + YZMC_DEGERSN[YZMC_SI and $F];
  D42 := (YZMC_DEGERSN[YZMC_ES and $F] * $10) + YZMC_DEGERSN[YZMC_DI and $F];

  for i := 1 to D21 do
  begin

    PWord(@Bellek144MB[D42])^ := PWord(@Bellek144MB[D41])^;
    Inc(D41, 2);
    Inc(D42, 2);
  end;

  {$IFDEF DEBUG} mmCikti.Lines.Add('rep movsw', []); {$ENDIF}

  IPDegeriniArtir(2);
end
// F3 A6 - REPE CMPS m8,m8 - Find nonmatching bytes in ES:[(E)DI] and DS:[(E)SI]
else if(Komut = $F3) and (Komut2 = $A6) then
begin

  D21 := YazmacDegerAl(YZMC_CX);
  D41 := (YZMC_DEGERSN[YZMC_DS and $F] * $10) + YZMC_DEGERSN[YZMC_SI and $F];
  D42 := (YZMC_DEGERSN[YZMC_ES and $F] * $10) + YZMC_DEGERSN[YZMC_DI and $F];

  Esit := True;
  for i := 1 to D21 do
  begin

    if(PByte(@Bellek144MB[D41])^ <> PByte(@Bellek144MB[D42])^) then
    begin

      Esit := False;
      Break;
    end;

    Inc(D41);
    Inc(D42);
  end;

  if(Esit) then
    BayrakDegistir(BAYRAK_ZF)
  else BayrakDegistir(BAYRAK_ZF, False);

  {$IFDEF DEBUG} mmCikti.Lines.Add('repe cmpsb', []); {$ENDIF}

  IPDegeriniArtir(2);
end
