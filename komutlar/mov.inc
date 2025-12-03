// 88 /r - MOV r/m8,r8 - Move r8 to r/m8
else if(IslenenKomut = $88) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;

  // yazmaç tanımlı bellek bölgesi ataması
  if((D11 and %11000000) = %00000000) then
  begin

    D41 := (D11 and %00000111);                 // hedef yazmaç (1. parametre)
    D42 := MYB8[(D11 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D42);

    case D41 of
      0:
      begin
        D44 := YazmacDegerAl(YZMC_DS) * $10;
        D44 += YazmacDegerAl(YZMC_SI);
        D44 += YazmacDegerAl(YZMC_BX);
        PByte(@Bellek144MB[D44])^ := D43;
      end;
      1:
      begin
        D44 := YazmacDegerAl(YZMC_ES) * $10;
        D44 += YazmacDegerAl(YZMC_DI);
        D44 += YazmacDegerAl(YZMC_BX);
        PByte(@Bellek144MB[D44])^ := D43;
      end;
      2:
      begin
        D44 := YazmacDegerAl(YZMC_DS) * $10;
        D44 += YazmacDegerAl(YZMC_SI);
        D44 += YazmacDegerAl(YZMC_BP);
        PByte(@Bellek144MB[D44])^ := D43;
      end;
      3:
      begin
        D44 := YazmacDegerAl(YZMC_ES) * $10;
        D44 += YazmacDegerAl(YZMC_DI);
        D44 += YazmacDegerAl(YZMC_BP);
        PByte(@Bellek144MB[D44])^ := D43;
      end;
      4:
      begin
        D44 := YazmacDegerAl(YZMC_DS) * $10;
        D44 += YazmacDegerAl(YZMC_SI);
        PByte(@Bellek144MB[D44])^ := D43;
      end;
      5:
      begin
        D44 := YazmacDegerAl(YZMC_ES) * $10;
        D44 += YazmacDegerAl(YZMC_DI);
        PByte(@Bellek144MB[D44])^ := D43;
      end;
      7:
      begin
        D44 := YazmacDegerAl(YZMC_BX);
        PByte(@Bellek144MB[D44])^ := D43;
      end;
      else Result := False;
    end;

    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Bellekler10[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);
  end
  // 8 bitlik yazmaç ataması
  else if((D11 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(D11 and %00000111)];           // hedef yazmaç (1. parametre)
    D42 := MYB8[(D11 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D41);
    D44 := YazmacDegerAl(D42);

    YazmacDegistir(D41, D44);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar8[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := False;
end
else if(IslenenKomut = $89) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;

  if((D11 and %11000000) = %11000000) then
  begin

    // 89 /r - MOV r/m32,r32 - Move r32 to r/m32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(D11 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB32[(D11 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir(D41, D44);

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar32[D41 and $FF], Yazmaclar32[D42 and $FF]]); {$ENDIF}
    end
    else
    // 89 /r - MOV r/m16,r16 - Move r16 to r/m16
    begin

      D41 := MYB16[(D11 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB16[(D11 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir(D41, D44);

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar16[D41 and $FF], Yazmaclar16[D42 and $FF]]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := False;
end
// 8A /r - MOV r8,r/m8 - Move r/m8 to r8
else if(IslenenKomut = $8A) then
begin

  D11 := BirSonrakiKomut;

  // bellek bölgesi ataması
  if((D11 and %00000110) = %00000110) then
  begin

    D21 := PWord(@Bellek144MB[Adres + 2])^;
    D12 := PByte(@Bellek144MB[D21])^;

    D42 := MYB8[(D11 and %00111000) shr 3];     // hedef yazmaç
    YazmacDegistir(D42, D12);

    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,[$%.4x]', [Yazmaclar8[D42], D21]); {$ENDIF}
    IPDegeriniArtir(2 + 2);

  end else Result := False;
end
else if(IslenenKomut = $8B) then
begin

  D11 := BirSonrakiKomut;

  // bellek bölgesi ataması
  if((D11 and %00000110) = %00000110) then
  begin

    // 8B /r - MOV r32,r/m32 - Move r/m32 to r32
    {if(KomutModDegistir) then
    begin

      D41 := PLongWord(@Bellek144MB[Adres + 2])^;
      D42 := PLongWord(@Bellek144MB[D41])^;

      D43 := MYB32[(D11 and %00111000) shr 3];     // hedef yazmaç
      YazmacDegistir(D43, D42);

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,[$%.8x]', [Yazmaclar32[D43 and $FF], D41]); {$ENDIF}
      mmCikti.Lines.Add('mov %s,[$%.8x]', [Yazmaclar32[D43 and $FF], D41]);

      IPDegeriniArtir(2 + 4);
    end
    else bu değerler %00000101 [DI] olarak geliyor? }
    // 8B /r - MOV r16,r/m16 - Move r/m16 to r16
    begin

      D21 := PWord(@Bellek144MB[Adres + 2])^;
      D22 := PWord(@Bellek144MB[D21])^;

      D42 := MYB16[(D11 and %00111000) shr 3];     // hedef yazmaç
      YazmacDegistir(D42, D22);

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,[$%.4x]', [Yazmaclar16[D42 and $FF], D21]); {$ENDIF}

      IPDegeriniArtir(2 + 2);
    end;

  end else Result := False;
end
// 8E /r - MOV Sreg,r/m16** - Move r/m16 to segment register
else if(IslenenKomut = $8E) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;
  D12 := (D11 shr 6) and %11;   // alt komut
  D13 := (D11 shr 3) and %111;  // hedef segment
  if(D12 = %11) then
  begin

    case D13 of
      0: D21 := ($02 shl 8) or $0A;
      1: D21 := ($02 shl 8) or $08;
      2: D21 := ($02 shl 8) or $0B;
      3: D21 := ($02 shl 8) or $09;
      4: D21 := ($02 shl 8) or $0C;
      5: D21 := ($02 shl 8) or $0D;
      else Result := False;
    end;

    if(Result) then
    begin

      D22 := MYB16[D11 and %111];   // kaynak yazmaç
      D23 := YazmacDegerAl(D22);
      YazmacDegistir(D21, D23);
      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar16[D21 and $F], Yazmaclar16[D22 and $F]]); {$ENDIF}
      IPDegeriniArtir(2);
    end;
  end else Result := False;
end
// A0 - MOV AL,moffs8* - Move byte at (seg:offset) to AL
else if(IslenenKomut = $A0) then
begin

  D21 := PWord(@Bellek144MB[Adres + 1])^;
  YazmacDegistir(YZMC_AL, PByte(@Bellek144MB[D21])^ and $FF);
  {$IFDEF DEBUG} mmCikti.Lines.Add('mov al,[$%.4x]', [D21]); {$ENDIF}
  IPDegeriniArtir(1 + 2);
end
else if(IslenenKomut = $A1) then
begin

  // A1 - MOV EAX,moffs32* - Move doubleword at (seg:offset) to EAX
  if(KomutModDegistir) then
  begin

    D21 := PWord(@Bellek144MB[Adres + 1])^;
    YazmacDegistir(YZMC_EAX, PLongWord(@Bellek144MB[D21])^);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov eax,[$%.8x]', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end
  // A1 - MOV AX,moffs16* - Move word at (seg:offset) to AX
  else
  begin

    D21 := PWord(@Bellek144MB[Adres + 1])^;
    YazmacDegistir(YZMC_AX, PWord(@Bellek144MB[D21])^ and $FFFF);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov ax,[$%.4x]', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end;
end
// A2 - MOV moffs8*,AL - Move AL to (seg:offset)
else if(IslenenKomut = $A2) then
begin

  D21 := PWord(@Bellek144MB[Adres + 1])^;
  PByte(@Bellek144MB[D21])^ := Byte((YZMC_DEGERSN[YZMC0_EAX] and $FF));
  {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.4x],al', [D21]); {$ENDIF}
  IPDegeriniArtir(1 + 2);
end
else if(IslenenKomut = $A3) then
begin

  // A3 - MOV moffs32*,EAX - Move EAX to (seg:offset)
  if(KomutModDegistir) then
  begin

    D21 := PWord(@Bellek144MB[Adres + 1])^;
    PLongWord(@Bellek144MB[D21])^ := YZMC_DEGERSN[YZMC0_EAX];
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.8x],eax', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end
  // A3 - MOV moffs16*,AX - Move AX to (seg:offset)
  else
  begin

    D21 := PWord(@Bellek144MB[Adres + 1])^;
    PWord(@Bellek144MB[D21])^ := Word((YZMC_DEGERSN[YZMC0_EAX] and $FFFF));
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.4x],ax', [D21]); {$ENDIF}

    IPDegeriniArtir(1 + 2);
  end;
end
// B0+ rb - MOV r8,imm8 - Move imm8 to r8
{ TODO - mov     dl,1 çalışmıyor }
else if(IslenenKomut >= $B0 + YZMC0_EAX) and (IslenenKomut <= $B0 + YZMC0_EDI) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;
  D12 := IslenenKomut - $B0;
  D13 := D12;
  if(D12 > 3) then D13 := (D12 * $10) + (D12 - 4);
  YazmacDegistir(($01 shl 8) or D13, D11);
  {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.2x', [Yazmaclar8[D12], D11]); {$ENDIF}
  IPDegeriniArtir(1 + 1);
end
// B8+ rw - MOV r16,imm16 - Move imm16 to r16
else if(IslenenKomut >= $B8 + YZMC0_EAX) and (IslenenKomut <= $B8 + YZMC0_EDI) then
begin

  if(KomutModDegistir) then
  begin

    D41 := PLongWord(@Bellek144MB[Adres + 1])^;
    YazmacDegistir(($04 shl 8) or (IslenenKomut - $B8), D41);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.8x', [Yazmaclar32[IslenenKomut - $B8], D41]); {$ENDIF}
    IPDegeriniArtir(1 + 4);
  end
  else
  begin

    D21 := PWord(@Bellek144MB[Adres + 1])^;
    YazmacDegistir(($02 shl 8) or (IslenenKomut - $B8), D21);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.4x', [Yazmaclar16[IslenenKomut - $B8], D21]); {$ENDIF}
    IPDegeriniArtir(1 + 2);
  end;
end
// C6 /0 - MOV r/m8,imm8 - Move imm8 to r/m8
else if(IslenenKomut = $C6) then
begin

  D11 := BirSonrakiKomut;

  // bellek bölgesi ataması
  if((D11 and %00000110) = %00000110) then
  begin

    D21 := PWord(@Bellek144MB[Adres + 2])^;
    D11 := PByte(@Bellek144MB[Adres + 4])^;
    PByte(@Bellek144MB[D21])^ := D11;

    {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.2x],byte %d', [D21, D11]); {$ENDIF}
    IPDegeriniArtir(2 + 3);

  end else Result := False;
end
else if(IslenenKomut = $C7) then
begin

  D11 := BirSonrakiKomut;

  // bellek bölgesi ataması
  if((D11 and %00000110) = %00000110) then
  begin

    // C7 /0 - MOV r/m32,imm32 - Move imm32 to r/m32
    if(KomutModDegistir) then
    begin

      D21 := PWord(@Bellek144MB[Adres + 2])^;
      D41 := PLongWord(@Bellek144MB[Adres + 4])^;
      PLongWord(@Bellek144MB[D21])^ := D41;

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.8x],dword %d', [D21, D41]); {$ENDIF}
      IPDegeriniArtir(2 + 6);

      mmCikti.Lines.Add('mov [$%.8x],dword %d', [D21, D41]);
    end
    else
    // C7 /0 - MOV r/m16,imm16 - Move imm16 to r/m16
    begin

      D21 := PWord(@Bellek144MB[Adres + 2])^;
      D22 := PWord(@Bellek144MB[Adres + 4])^;
      PWord(@Bellek144MB[D21])^ := D22;

      {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.4x],word %d', [D21, D22]); {$ENDIF}
      IPDegeriniArtir(2 + 4);
    end;

  end else Result := False;
end
