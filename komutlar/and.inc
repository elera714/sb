// 24 ib - AND AL,imm8 - AL AND imm8
else if(Komut = $24) then
begin

  D21 := YazmacDegerAl(YZMC_AL);
  D21 := D21 and Komut2;
  YazmacDegistir(YZMC_AL, D21);
  {$IFDEF DEBUG} mmCikti.Lines.Add('and al,$%.2x', [Komut2]); {$ENDIF}
  IPDegeriniArtir(2);
end
else if(Komut = $25) then
begin

  // 25 id - AND EAX,imm32 - EAX AND imm32  else if(Komut = $E4) or (Komut = $E5) then
  if(KomutModDegistir) then
  begin

    D41 := YazmacDegerAl(YZMC_EAX);
    D42 := PLongWord(@Bellek144MB[IslenenAdres + 1])^;
    D41 := D41 and D42;
    YazmacDegistir(YZMC_EAX, D41);
    {$IFDEF DEBUG} mmCikti.Lines.Add('and eax,$%.8x', [D42]); {$ENDIF}
    IPDegeriniArtir(1 + 4);
  end
  else
  // 25 iw - AND AX,imm16 - AX AND imm16
  begin

    D21 := YazmacDegerAl(YZMC_AX);
    D22 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    D21 := D21 and D22;
    YazmacDegistir(YZMC_AX, D21);
    {$IFDEF DEBUG} mmCikti.Lines.Add('and ax,$%.4x', [D22]); {$ENDIF}
    IPDegeriniArtir(1 + 2);
  end;
end
