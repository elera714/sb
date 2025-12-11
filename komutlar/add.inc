// 00 /r - ADD r/m8,r8 - Add r8 to r/m8
else if(Komut = $00) then
begin

  // 8 bitlik yazmaç ataması
  if((Komut2 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(Komut2 and %00000111)];           // hedef yazmaç (1. parametre)
    D42 := MYB8[(Komut2 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D41);
    D44 := YazmacDegerAl(D42);

    YazmacDegistir(D41, D44, True);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar8[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := False;
end
else if(Komut = $01) then
begin

  if((Komut2 and %11000000) = %11000000) then
  begin

    // 01 /r - ADD r/m32,r32 - Add r32 to r/m32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(Komut2 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB32[(Komut2 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir(D41, D44, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar32[D41 and $FF], Yazmaclar32[D42 and $FF]]); {$ENDIF}
    end
    else
    // 01 /r - ADD r/m16,r16 - Add r16 to r/m16
    begin

      D41 := MYB16[(Komut2 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB16[(Komut2 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir(D41, D44, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar16[D41 and $FF], Yazmaclar16[D42 and $FF]]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := False;
end
// 03 /r - ADD r16,r/m16 - Add r/m16 to r16
else if(Komut = $03) then
begin

  // yazmaç tanımlı bellek bölgesi ataması
  if((Komut2 and %11000000) = %00000000) then
  begin

    D41 := (Komut2 and %00000111);                  // kaynak yazmaç
    D42 := MYB16[(Komut2 and %00111000) shr 3];     // hedef yazmaç
    D43 := YazmacDegerAl(D42);

    // komut uzunluğu öndeğer = 2 byte
    D44 := 2;
    if(D41 = 6) then D44 := 4;

    D45 := Mod00Isle(D41);
    D43 := PWord(@Bellek144MB[D45])^;
    YazmacDegistir(D42, D43, True);

    {$IFDEF DEBUG}
      if(D41 = 6) then
        mmCikti.Lines.Add('add %s,[$%.4x]', [Yazmaclar16[D42 and $F], PWord(@Bellek144MB[IslenenAdres + 2])^])
      else mmCikti.Lines.Add('add %s,%s', [Yazmaclar16[D42 and $F], Bellekler00[D41]]);
    {$ENDIF}

    IPDegeriniArtir(D44);
  end;
end
// 04 ib - ADD AL,imm8 - Add imm8 to AL
else if(Komut = $04) then
begin

  YazmacDegistir(YZMC_AL, Komut2, True);
  {$IFDEF DEBUG} mmCikti.Lines.Add('add al,$%.2x', [Komut2]); {$ENDIF}
  IPDegeriniArtir(2);
end
else if(Komut = $05) then
begin

  // 05 id - ADD EAX,imm32 - Add imm32 to EAX
  if(KomutModDegistir) then
  begin

    D41 := PLongWord(@Bellek144MB[IslenenAdres + 1])^;
    YazmacDegistir(YZMC_EAX, D41, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('add eax,$%.8x', [D41]); {$ENDIF}

    IPDegeriniArtir(1 + 4);
  end
  // 05 iw - ADD AX,imm16 - Add imm16 to AX
  else
  begin

    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    YazmacDegistir(YZMC_AX, D21, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('add ax,$%.4x', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end;
end
// 81 /0 iw - ADD r/m16,imm16 - Add imm16 to r/m16
else if(Komut = $81) and ((Komut2 and %11111000) = %11000000) then
begin

  D41 := MYB16[Komut2 and %111];
  D42 := YazmacDegerAl(D41);
  D21 := PWord(@Bellek144MB[IslenenAdres + 2])^;

  YazmacDegistir(D41, D21, True);

  {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%d', [Yazmaclar16[D41 and $F], D21]); {$ENDIF}
  IPDegeriniArtir(2 + 2);
end
else if(Komut = $83) then
begin

  if((Komut2 and %11000000) = %11000000) then
  begin

    // 83 /0 ib - ADD r/m32,imm8 - Add sign-extended imm8 to r/m32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(Komut2 and %00000111)];          // hedef yazmaç
      D11 := PByte(@Bellek144MB[IslenenAdres + 2])^;
      YazmacDegistir(D41, D11, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,$%.2x', [Yazmaclar32[D41 and $FF], D11]); {$ENDIF}
    end
    else
    // 83 /0 ib - ADD r/m16,imm8 - Add sign-extended imm8 to r/m16
    begin

      D41 := MYB16[(Komut2 and %00000111)];          // hedef yazmaç
      D11 := PByte(@Bellek144MB[IslenenAdres + 2])^;
      YazmacDegistir(D41, D11, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,$%.2x', [Yazmaclar16[D41 and $FF], D11]); {$ENDIF}
    end;

    IPDegeriniArtir(3);

  end else Result := False;
end
