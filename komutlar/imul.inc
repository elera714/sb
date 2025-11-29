// 6B /r ib - IMUL r16,imm8 - word register ← word register ∗ sign-extended immediate byte
else if(IslenenKomut = $6B) then
begin

  D11 := BirSonrakiKomut;

  // yazmaç ataması
  if((D11 and %11000000) = %11000000) then
  begin

    D41 := MYB16[(D11 and %00000111)];          // çarpma işlemi yapılacak yazmaç
    D42 := YazmacDegerAl(D41);
    D11 := PByte(@Bellek144MB[Adres + 2])^;

    YazmacDegistir2(D41, D42 * D11);

    {$IFDEF DEBUG} mmCikti.Lines.Add('imul %s,%d', [Yazmaclar16[D41 and $FF], D11]); {$ENDIF}
    IPDegeriniArtir(1 + 2);

  end else Result := False;
end
else if(IslenenKomut = $69) then
begin

  D11 := BirSonrakiKomut;

  // yazmaç ataması
  if((D11 and %11000000) = %11000000) then
  begin

    // 69 /r id - IMUL r32,imm32 - doubleword register ← r/m32 ∗ immediate doubleword
    if(KomutModDegistir) then
    begin

      D41 := MYB16[(D11 and %00000111)];          // çarpma işlemi yapılacak yazmaç
      D42 := YazmacDegerAl(D41);
      D43 := PLongWord(@Bellek144MB[Adres + 2])^;

      YazmacDegistir2(D41, D42 * D43);

      {$IFDEF DEBUG} mmCikti.Lines.Add('imul %s,%d', [Yazmaclar32[D41 and $FF], D43]); {$ENDIF}
      IPDegeriniArtir(1 + 5);
    end
    else
    // 69 /r iw - IMUL r16,imm16 - word register ← r/m16 ∗ immediate word
    begin

      D41 := MYB16[(D11 and %00000111)];          // çarpma işlemi yapılacak yazmaç
      D42 := YazmacDegerAl(D41);
      D21 := PWord(@Bellek144MB[Adres + 2])^;

      YazmacDegistir2(D41, D42 * D21);

      {$IFDEF DEBUG} mmCikti.Lines.Add('imul %s,%d', [Yazmaclar16[D41 and $FF], D21]); {$ENDIF}
      IPDegeriniArtir(1 + 3);
    end;

  end else Result := False;
end
