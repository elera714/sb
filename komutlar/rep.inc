// F3 A6 - REPE CMPS m8,m8 - Find nonmatching bytes in ES:[(E)DI] and DS:[(E)SI]
else if(Komut = $F3) and (Komut2 = $A6) then
begin

  D21 := YazmacDegerAl(YZMC_CX);
  D41 := (YZMC_DEGERSN[YZMC_DS and $F] * $10) + YZMC_DEGERSN[YZMC_SI and $F];
  D42 := (YZMC_DEGERSN[YZMC_ES and $F] * $10) + YZMC_DEGERSN[YZMC_DI and $F];

  Esit := True;
  for i := 1 to D21 do
  begin

    if(PChar(@Bellek144MB[D41])^ <> PChar(@Bellek144MB[D42])^) then
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
