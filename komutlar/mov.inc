// 88 /r - MOV r/m8,r8 - Move r8 to r/m8
else if(Komut = $88) then
begin

  // yazmaç tanımlı bellek bölgesi ataması
  if((Komut2 and %11000000) = %00000000) then
  begin

    D41 := (Komut2 and %00000111);                 // hedef yazmaç (1. parametre)
    D42 := MYB8[(Komut2 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D42);

    // komut uzunluğu öndeğer = 2 byte
    D44 := 2;
    if(D41 = 6) then D44 := 4;

    D45 := Mod00Isle(D41);
    PByte(@Bellek144MB[D45])^ := D43;

    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG}
      if(D41 = 6) then
        mmCikti.Lines.Add('mov [$%.4x],%s', [PWord(@Bellek144MB[IslenenAdres + 2])^, Yazmaclar8[D42]])
      else mmCikti.Lines.Add('mov %s,%s', [Bellekler00[D41], Yazmaclar8[D42]]);
    {$ENDIF}

    IPDegeriniArtir(D44);
  end
  else if((Komut2 and %11000000) = %01000000) then
  begin

    D41 := (Komut2 and %00000111);                  // bellek bölgesi
    D42 := MYB8[(Komut2 and %00111000) shr 3];      // kaynak yazmaç
    D11 := YazmacDegerAl(D42);                      // hedef bölgeye aktarılacak değer

    D12 := PByte(@Bellek144MB[IslenenAdres + 2])^;

    D45 := Mod01Isle(D41) + ShortInt(D12);
    PByte(@Bellek144MB[D45])^ := D11;

    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s%d,%s', [Bellekler01[D41], ShortInt(D12), Yazmaclar8[D42 and $F]]); {$ENDIF}
    IPDegeriniArtir(2 + 1);
  end
  // 8 bitlik yazmaç ataması
  else if((Komut2 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(Komut2 and %00000111)];           // hedef yazmaç (1. parametre)
    D42 := MYB8[(Komut2 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D41);
    D44 := YazmacDegerAl(D42);

    YazmacDegistir(D41, D44);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar8[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);
  end;
end
else if(Komut = $89) then
begin

  // yazmaç tanımlı bellek bölgesi ataması
  if((Komut2 and %11000000) = %00000000) then
  begin

    D41 := (Komut2 and %00000111);                  // hedef yazmaç (1. parametre)
    D42 := MYB16[(Komut2 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D42);

    // komut uzunluğu öndeğer = 2 byte
    D44 := 2;
    if(D41 = 6) then D44 := 4;

    D45 := Mod00Isle(D41);
    PWord(@Bellek144MB[D45])^ := D43;

    {$IFDEF DEBUG}
      if(D41 = 6) then
        mmCikti.Lines.Add('mov [$%.4x],%s', [PWord(@Bellek144MB[IslenenAdres + 2])^, Yazmaclar16[D42 and $F]])
      else mmCikti.Lines.Add('mov %s,%s', [Bellekler00[D41], Yazmaclar16[D42 and $F]]);
    {$ENDIF}

    IPDegeriniArtir(D44);
  end
  else if((Komut2 and %11000000) = %01000000) then
  begin

    D41 := (Komut2 and %00000111);                  // bellek bölgesi
    D42 := MYB16[(Komut2 and %00111000) shr 3];     // kaynak yazmaç
    D21 := YazmacDegerAl(D42);                      // hedef bölgeye aktarılacak değer

    D11 := PByte(@Bellek144MB[IslenenAdres + 2])^;

    D45 := Mod01Isle(D41) + ShortInt(D11);
    PWord(@Bellek144MB[D45])^ := D21;

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s%d,%s', [Bellekler01[D41], ShortInt(D11), Yazmaclar16[D42 and $F]]); {$ENDIF}
    IPDegeriniArtir(2 + 1);
  end
  else if((Komut2 and %11000000) = %11000000) then
  begin

    // 89 /r - MOV r/m32,r32 - Move r32 to r/m32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(Komut2 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB32[(Komut2 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir(D41, D44);

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar32[D41 and $FF], Yazmaclar32[D42 and $FF]]); {$ENDIF}
    end
    else
    // 89 /r - MOV r/m16,r16 - Move r16 to r/m16
    begin

      D41 := MYB16[(Komut2 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB16[(Komut2 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir(D41, D44);

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar16[D41 and $FF], Yazmaclar16[D42 and $FF]]); {$ENDIF}
    end;

    IPDegeriniArtir(2);
  end;
end
// 8A /r - MOV r8,r/m8 - Move r/m8 to r8
else if(Komut = $8A) then
begin

  if((Komut2 and %11000000) = %00000000) then
  begin

    D41 := (Komut2 and %00000111);                  // kaynak bellek bölgesi
    D42 := MYB8[(Komut2 and %00111000) shr 3];      // hedef yazmaç

    // komut uzunluğu öndeğer = 2 byte
    D44 := 2;
    if(D41 = 6) then D44 := 4;

    D45 := Mod00Isle(D41);
    D11 := PByte(@Bellek144MB[D45])^;
    YazmacDegistir(D42, D11);

    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG}
      if(D41 = 6) then
        mmCikti.Lines.Add('mov %s,[$%.4x]', [Yazmaclar8[D42 and $F], PWord(@Bellek144MB[IslenenAdres + 2])^])
      else mmCikti.Lines.Add('mov %s,%s', [Yazmaclar8[D42 and $F], Bellekler00[D41]]);
    {$ENDIF}

    IPDegeriniArtir(D44);
  end
  else if((Komut2 and %11000000) = %01000000) then
  begin

    D41 := (Komut2 and %00000111);                  // bellek bölgesi
    D42 := MYB8[(Komut2 and %00111000) shr 3];      // hedef yazmaç

    D11 := PByte(@Bellek144MB[IslenenAdres + 2])^;

    D45 := Mod01Isle(D41) + ShortInt(D11);
    D12 := PByte(@Bellek144MB[D45])^;
    YazmacDegistir(D42, D12);

    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s%d', [Yazmaclar8[D42 and $F], Bellekler01[D41], D11]); {$ENDIF}

    IPDegeriniArtir(2 + 1);
  end
  else if((Komut2 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(Komut2 and %00000111)];            // kaynak yazmaç
    D42 := MYB8[(Komut2 and %00111000) shr 3];      // hedef yazmaç

    D11 := YazmacDegerAl(D41);
    YazmacDegistir(D42, D11);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG}
    mmCikti.Lines.Add('mov %s,%s', [Yazmaclar8[D42 and $F], Yazmaclar8[D41 and $F]]);
    {$ENDIF}

    IPDegeriniArtir(2);
  end;
end
else if(Komut = $8B) then
begin

  // bellek bölgesi ataması
  if((Komut2 and %11000000) = %00000000) then
  begin

    D41 := (Komut2 and %00000111);                  // kaynak yazmaç / bellek bölgesi
    D42 := MYB16[(Komut2 and %00111000) shr 3];     // hedef yazmaç

    // komut uzunluğu öndeğer = 2 byte
    D44 := 2;
    if(D41 = 6) then D44 := 4;

    D45 := Mod00Isle(D41);
    D43 := PWord(@Bellek144MB[D45])^;
    YazmacDegistir(D42, D43);

    {$IFDEF DEBUG}
      if(D41 = 6) then
        mmCikti.Lines.Add('mov %s,[$%.4x]', [Yazmaclar16[D42 and $F], PWord(@Bellek144MB[IslenenAdres + 2])^])
      else mmCikti.Lines.Add('mov %s,%s', [Yazmaclar16[D42 and $F], Bellekler00[D41]]);
    {$ENDIF}

    IPDegeriniArtir(D44);
  end
  // bellek bölgesi ataması
  else if((Komut2 and %11000000) = %01000000) then
  begin

    D41 := (Komut2 and %00000111);                  // bellek bölgesi
    D42 := MYB16[(Komut2 and %00111000) shr 3];     // hedef yazmaç

    D11 := PByte(@Bellek144MB[IslenenAdres + 2])^;

    D45 := Mod01Isle(D41) + ShortInt(D11);
    D21 := PWord(@Bellek144MB[D45])^;
    YazmacDegistir(D42, D21);

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s%d', [Yazmaclar16[D42 and $FF], Bellekler01[D41], D11]); {$ENDIF}

    IPDegeriniArtir(2 + 1);
  end;
end
// 8C /r - MOV r/m16,Sreg** - Move segment register to r/m16
else if(Komut = $8C) then
begin

  D11 := (Komut2 shr 3) and %111;     // kaynak yazmaç
  D12 := (Komut2 and %111);           // hedef segment

  D21 := SYZMC[D11];
  D22 := MYB16[D12];

  D23 := YazmacDegerAl(D21);
  YazmacDegistir(D22, D23);

  {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar16[D22 and $F], SYazmaclar[D11]]); {$ENDIF}
  IPDegeriniArtir(2);
end
// 8E /r - MOV Sreg,r/m16** - Move r/m16 to segment register
else if(Komut = $8E) then
begin

  D12 := (Komut2 shr 6) and %11;   // alt komut
  D13 := (Komut2 shr 3) and %111;  // hedef segment
  if(D12 = %11) then
  begin

    D21 := SYZMC[D13];
    if(D21 <> 0) then
    begin

      D22 := MYB16[Komut2 and %111];   // kaynak yazmaç
      D23 := YazmacDegerAl(D22);
      YazmacDegistir(D21, D23);
      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar16[D21 and $F], Yazmaclar16[D22 and $F]]); {$ENDIF}
      IPDegeriniArtir(2);
    end else Result := isHata;
  end else Result := isHata;
end
// A0 - MOV AL,moffs8* - Move byte at (seg:offset) to AL
else if(Komut = $A0) then
begin

  D41 := YazmacDegerAl(YZMC_DS);
  D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
  YazmacDegistir(YZMC_AL, PByte(@Bellek144MB[(D41 * $10) + D21])^ and $FF);
  {$IFDEF DEBUG} mmCikti.Lines.Add('mov al,[$%.4x]', [D21]); {$ENDIF}
  IPDegeriniArtir(1 + 2);
end
else if(Komut = $A1) then
begin

  // A1 - MOV EAX,moffs32* - Move doubleword at (seg:offset) to EAX
  if(KomutModDegistir) then
  begin

    D41 := YazmacDegerAl(YZMC_DS);
    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    YazmacDegistir(YZMC_EAX, PLongWord(@Bellek144MB[(D41 * $10) + D21])^);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov eax,[$%.8x]', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end
  // A1 - MOV AX,moffs16* - Move word at (seg:offset) to AX
  else
  begin

    D41 := YazmacDegerAl(YZMC_DS);
    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    YazmacDegistir(YZMC_AX, PWord(@Bellek144MB[(D41 * $10) + D21])^ and $FFFF);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov ax,[$%.4x]', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end;
end
// A2 - MOV moffs8*,AL - Move AL to (seg:offset)
else if(Komut = $A2) then
begin

  D41 := YazmacDegerAl(YZMC_DS);
  D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
  PByte(@Bellek144MB[(D41 * $10) + D21])^ := Byte((YZMC_DEGERSN[YZMC0_EAX] and $FF));
  {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.4x],al', [D21]); {$ENDIF}
  IPDegeriniArtir(1 + 2);
end
else if(Komut = $A3) then
begin

  // A3 - MOV moffs32*,EAX - Move EAX to (seg:offset)
  if(KomutModDegistir) then
  begin

    D41 := YazmacDegerAl(YZMC_DS);
    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    PLongWord(@Bellek144MB[(D41 * $10) + D21])^ := YZMC_DEGERSN[YZMC0_EAX];
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.8x],eax', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end
  // A3 - MOV moffs16*,AX - Move AX to (seg:offset)
  else
  begin

    D41 := YazmacDegerAl(YZMC_DS);
    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    PWord(@Bellek144MB[(D41 * $10) + D21])^ := Word((YZMC_DEGERSN[YZMC0_EAX] and $FFFF));
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.4x],ax', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end;
end
// B0+ rb - MOV r8,imm8 - Move imm8 to r8
{ TODO - mov     dl,1 çalışmıyor }
else if(Komut >= $B0 + YZMC0_EAX) and (Komut <= $B0 + YZMC0_EDI) then
begin

  D12 := Komut - $B0;
  D13 := D12;
  if(D12 > 3) then D13 := (D12 * $10) + (D12 - 4);
  YazmacDegistir(($01 shl 8) or D13, Komut2);
  {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.2x', [Yazmaclar8[D12], Komut2]); {$ENDIF}
  IPDegeriniArtir(1 + 1);
end
// B8+ rw - MOV r16,imm16 - Move imm16 to r16
else if(Komut >= $B8 + YZMC0_EAX) and (Komut <= $B8 + YZMC0_EDI) then
begin

  if(KomutModDegistir) then
  begin

    D41 := PLongWord(@Bellek144MB[IslenenAdres + 1])^;
    YazmacDegistir(($04 shl 8) or (Komut - $B8), D41);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.8x', [Yazmaclar32[Komut - $B8], D41]); {$ENDIF}
    IPDegeriniArtir(1 + 4);
  end
  else
  begin

    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    YazmacDegistir(($02 shl 8) or (Komut - $B8), D21);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.4x', [Yazmaclar16[Komut - $B8], D21]); {$ENDIF}
    IPDegeriniArtir(1 + 2);
  end;
end
// C6 /0 - MOV r/m8,imm8 - Move imm8 to r/m8
else if(Komut = $C6) then
begin

  // bellek bölgesi ataması
  if((Komut2 and %11111000) = %00000000) then
  begin

    D41 := (Komut2 and %00000111);                  // kaynak yazmaç / bellek bölgesi

    // komut uzunluğu öndeğer = 2 byte
    D44 := 3;
    if(D41 = 6) then
    begin

      D44 := 5;
      D21 := PWord(@Bellek144MB[IslenenAdres + 2])^;    // okunacak bellek adresi
      D11 := PByte(@Bellek144MB[IslenenAdres + 4])^;    // yerleştirilecek değer
    end else D11 := PByte(@Bellek144MB[IslenenAdres + 2])^;

    D45 := Mod00Isle(D41);
    PByte(@Bellek144MB[D45])^ := D11;

    {$IFDEF DEBUG}
      if(D41 = 6) then
        mmCikti.Lines.Add('mov [$%.4x],b %d', [D21, D11])
      else mmCikti.Lines.Add('mov %s,b %d', [Bellekler00[D41], D11]);
    {$ENDIF}

    IPDegeriniArtir(D44);
  end
  else if((Komut2 and %11111000) = %01000000) then
  begin

    D41 := (Komut2 and %00000111);                    // kaynak yazmaç / bellek bölgesi

    D11 := PByte(@Bellek144MB[IslenenAdres + 2])^;    // kaynak yazmaca eklenecek ek değer (disp8)
    D12 := PByte(@Bellek144MB[IslenenAdres + 3])^;    // yerleştirilecek değer

    D45 := Mod00Isle(D41) + ShortInt(D12);
    PByte(@Bellek144MB[D45])^ := D11;

    {$IFDEF DEBUG}
    mmCikti.Lines.Add('mov %s%.d,%.2x', [Bellekler01[D41], ShortInt(D11), D12]);
    {$ENDIF}

    IPDegeriniArtir(2 + 2);
  end
end
else if(Komut = $C7) then
begin

  // bellek bölgesi ataması
  if((Komut2 and %00000110) = %00000110) then
  begin

    // C7 /0 - MOV r/m32,imm32 - Move imm32 to r/m32
    if(KomutModDegistir) then
    begin

      D41 := YazmacDegerAl(YZMC_DS);
      D21 := PWord(@Bellek144MB[IslenenAdres + 2])^;
      D41 := PLongWord(@Bellek144MB[IslenenAdres + 4])^;
      PLongWord(@Bellek144MB[(D41 * $10) + D21])^ := D41;

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.8x],dw %d', [D21, D41]); {$ENDIF}
      IPDegeriniArtir(2 + 6);
    end
    else
    // C7 /0 - MOV r/m16,imm16 - Move imm16 to r/m16
    begin

      D41 := YazmacDegerAl(YZMC_DS);
      D21 := PWord(@Bellek144MB[IslenenAdres + 2])^;
      D22 := PWord(@Bellek144MB[IslenenAdres + 4])^;
      PWord(@Bellek144MB[(D41 * $10) + D21])^ := D22;

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.4x],w %d', [D21, D22]); {$ENDIF}
      IPDegeriniArtir(2 + 4);
    end;
  end;
end
