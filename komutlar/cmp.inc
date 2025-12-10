// 3C ib - CMP AL, imm8 - Compare imm8 with AL
else if(Komut = $3C) then
begin

  D11 := YazmacDegerAl(YZMC_AL);

  I11 := ShortInt(D11) - ShortInt(Komut2);
  if(I11 = 0) then
    BayrakDegistir(BAYRAK_ZF)
  else BayrakDegistir(BAYRAK_ZF, False);

  if(I11 < 0) then
    BayrakDegistir(BAYRAK_SF)
  else BayrakDegistir(BAYRAK_SF, False);

  {$IFDEF DEBUG} mmCikti.Lines.Add('cmp al,%d', [ShortInt(Komut2)]); {$ENDIF}

  IPDegeriniArtir(2);
end
else if(Komut = $3D) then
begin

  // 3D id - CMP EAX, imm32 - Compare imm32 with EAX
  if(KomutModDegistir) then
  begin

    D41 := PLongWord(@Bellek144MB[IslenenAdres + 1])^;

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

    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;

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
// 80 /7 ib - CMP r/m8, imm8 - Compare imm8 with r/m8
else if(Komut = $80) then
begin

  if((Komut2 and %11111000) = %11111000) then
  begin

    D21 := MYB8[(Komut2 and %00000111)];          // hedef yazmaç
    D11 := YazmacDegerAl(D21);
    D12 := PByte(@Bellek144MB[IslenenAdres + 2])^;

    I21 := ShortInt(D11) - ShortInt(D12);

    if(I21 = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, False);

    if(I21 < 0) then
      BayrakDegistir(BAYRAK_CF)
    else BayrakDegistir(BAYRAK_CF, False);

    if((D21 and $FF) >= $40) then D21 := (D21 shr 4) and $F else D21 := D21 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('cmp %s,$%.2x', [Yazmaclar8[D21], D12]); {$ENDIF}

    IPDegeriniArtir(2 + 1);
  end
end
else if(Komut = $81) and ((Komut2 and %11111000) = %11111000) then
begin

  // 81 /7 id - CMP r/m32,imm32 - Compare imm32 with r/m32
  if(KomutModDegistir) then
  begin

    D41 := MYB32[(Komut2 and %00000111)];          // hedef yazmaç
    D42 := YazmacDegerAl(D41);
    D43 := PLongWord(@Bellek144MB[IslenenAdres + 2])^;

    I41 := SmallInt(D42) - SmallInt(D43);

    if(I41 = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, False);

    if(I41 < 0) then
      BayrakDegistir(BAYRAK_CF)
    else BayrakDegistir(BAYRAK_CF, False);

    {$IFDEF DEBUG} mmCikti.Lines.Add('cmp %s,$%.8x', [Yazmaclar32[D41 and $FF], D43]); {$ENDIF}

    IPDegeriniArtir(2 + 4);
  end
  else
  // 81 /7 iw - CMP r/m16, imm16 - Compare imm16 with r/m16
  begin

    D41 := MYB16[(Komut2 and %00000111)];          // hedef yazmaç
    D21 := YazmacDegerAl(D41);
    D22 := PWord(@Bellek144MB[IslenenAdres + 2])^;

    I21 := SmallInt(D21) - SmallInt(D22);

    if(I21 = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, False);

    if(I21 < 0) then
      BayrakDegistir(BAYRAK_CF)
    else BayrakDegistir(BAYRAK_CF, False);

    {$IFDEF DEBUG} mmCikti.Lines.Add('cmp %s,$%.4x', [Yazmaclar16[D41 and $FF], D22]); {$ENDIF}

    IPDegeriniArtir(2 + 2);
  end;
end
