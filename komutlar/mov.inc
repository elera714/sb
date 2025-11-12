// 8E /r - MOV Sreg,r/m16** - Move r/m16 to segment register
else if(IslenenKomut = $8E) then
begin

  D11 := PSmallInt(@Bellek1MB[Adres + 1])^;
  D12 := (D11 shr 6) and %11;   // alt komut
  D13 := (D11 shr 3) and %111;  // hedef segment
  D14 := (D11 and %111);        // kaynak yazmaç
  if(D12 = %11) then
  begin

    case D13 of
      0: D15 := 10;
      1: D15 := 8;
      2: D15 := 11;
      3: D15 := 9;
      4: D15 := 12;
      5: D15 := 13;
      else Result := False;
    end;

    if(Result) then
    begin

      YZMC_DEGERSN[D15] := YZMC_DEGERSN[D14];
      YazmacDegistir(D15, YZMC_DEGERSN[D14]);
      IPDegeriniArtir(2);
    end;
  end else Result := False;
end
// B8+ rw - MOV r16,imm16 - Move imm16 to r16
else if(IslenenKomut >= $B8 + YZMC0_EAX) and (IslenenKomut <= $B8 + YZMC0_EDI) then
begin

  if(KomutModDegistir) then
  begin

    D41 := PLongInt(@Bellek1MB[Adres + 1])^;
    YazmacDegistir2(($04 shl 8) or (IslenenKomut - $B8), D41);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.8x', [Yazmaclar32[IslenenKomut - $B8], D41]); {$ENDIF}
    IPDegeriniArtir(1 + 4);
  end
  else
  begin

    D21 := PSmallInt(@Bellek1MB[Adres + 1])^;
    YazmacDegistir2(($03 shl 8) or (IslenenKomut - $B8), D21);
    {$IFDEF DEBUG} mmCikti.Lines.Add('mov %s,$%.4x', [Yazmaclar16[IslenenKomut - $B8], D21]); {$ENDIF}
    IPDegeriniArtir(1 + 2);
  end;
end
