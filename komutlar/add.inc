// 00 /r - ADD r/m8,r8 - Add r8 to r/m8
else if(IslenenKomut = $00) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;

  // 8 bitlik yazmaç ataması
  if((D11 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(D11 and %00000111)];           // hedef yazmaç (1. parametre)
    D42 := MYB8[(D11 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D41);
    D44 := YazmacDegerAl(D42);

    YazmacDegistir2(D41, D44, True);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar8[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := False;
end
else if(IslenenKomut = $01) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;

  if((D11 and %11000000) = %11000000) then
  begin

    // 01 /r - ADD r/m32,r32 - Add r32 to r/m32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(D11 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB32[(D11 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir2(D41, D44, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar32[D41 and $FF], Yazmaclar32[D42 and $FF]]); {$ENDIF}
    end
    else
    // 01 /r - ADD r/m16,r16 - Add r16 to r/m16
    begin

      D41 := MYB16[(D11 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB16[(D11 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir2(D41, D44, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar16[D41 and $FF], Yazmaclar16[D42 and $FF]]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := False;
end
