// 8E /r - MOV Sreg,r/m16** - Move r/m16 to segment register
else if(IslenenKomut = $8E) then
begin

  V11 := PByte(@Bellek144MB[Adres + 1])^;
  V12 := (V11 shr 6) and %11;   // alt komut
  V13 := (V11 shr 3) and %111;  // hedef segment
  V14 := (V11 and %111);        // kaynak yazmaç
  if(V12 = %11) then
  begin

    case V13 of
      0: V15 := 10;
      1: V15 := 8;
      2: V15 := 11;
      3: V15 := 9;
      4: V15 := 12;
      5: V15 := 13;
      else Result := False;
    end;

    if(Result) then
    begin

      YZMC_DEGERSN[V15] := YZMC_DEGERSN[V14];
      YazmacDegistir(V15, YZMC_DEGERSN[V14]);
      {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,%s', [Yazmaclar16[V15], Yazmaclar16[V14]]); {$ENDIF}
      IPDegeriniArtir(2);
    end;
  end else Result := False;
end
// A2 - MOV moffs8*,AL - Move AL to (seg:offset)
else if(IslenenKomut = $A2) then
begin

  V21 := PWord(@Bellek144MB[Adres + 1])^;
  V41 := (YZMC_DEGERSN[YZMC0_DS] * $10) + V21;
  PByte(@Bellek144MB[V41])^ := Byte((YZMC_DEGERSN[YZMC0_EAX] and $FF));
  {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.4x],al', [V21]); {$ENDIF}
  IPDegeriniArtir(1 + 2);
end
else if(IslenenKomut = $A3) then
begin

  // A3 - MOV moffs32*,EAX - Move EAX to (seg:offset)
  if(KomutModDegistir) then
  begin

    V21 := PWord(@Bellek144MB[Adres + 1])^;
    V41 := (YZMC_DEGERSN[YZMC0_DS] * $10) + V21;
    PLongWord(@Bellek144MB[V41])^ := YZMC_DEGERSN[YZMC0_EAX];
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.8x],eax', [V21]); {$ENDIF}
  end
  // A3 - MOV moffs16*,AX - Move AX to (seg:offset)
  else
  begin

    V21 := PWord(@Bellek144MB[Adres + 1])^;
    V41 := (YZMC_DEGERSN[YZMC0_DS] * $10) + V21;
    PWord(@Bellek144MB[V41])^ := Word((YZMC_DEGERSN[YZMC0_EAX] and $FFFF));
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov [$%.4x],ax', [V21]); {$ENDIF}
  end;

  IPDegeriniArtir(1 + 2);
end
// B0+ rb - MOV r8,imm8 - Move imm8 to r8
else if(IslenenKomut >= $B0 + YZMC0_EAX) and (IslenenKomut <= $B0 + YZMC0_EDI) then
begin

  V11 := PByte(@Bellek144MB[Adres + 1])^;
  V12 := IslenenKomut - $B0;
  V13 := V12;
  if(V12 > 3) then V13 := (V12 * $10) + (V12 - 4);
  YazmacDegistir2(($01 shl 8) or V13, V11);
  {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.2x', [Yazmaclar8[V12], V11]); {$ENDIF}
  IPDegeriniArtir(1 + 1);
end
// B8+ rw - MOV r16,imm16 - Move imm16 to r16
else if(IslenenKomut >= $B8 + YZMC0_EAX) and (IslenenKomut <= $B8 + YZMC0_EDI) then
begin

  if(KomutModDegistir) then
  begin

    V41 := PLongWord(@Bellek144MB[Adres + 1])^;
    YazmacDegistir2(($04 shl 8) or (IslenenKomut - $B8), V41);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.8x', [Yazmaclar32[IslenenKomut - $B8], V41]); {$ENDIF}
    IPDegeriniArtir(1 + 4);
  end
  else
  begin

    V21 := PWord(@Bellek144MB[Adres + 1])^;
    YazmacDegistir2(($02 shl 8) or (IslenenKomut - $B8), V21);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.4x', [Yazmaclar16[IslenenKomut - $B8], V21]); {$ENDIF}
    IPDegeriniArtir(1 + 2);
  end;
end
