// 08 /r - OR r/m8,r8 - r/m8 OR r8
else if(Komut = $08) then
begin

  // 8 bitlik yazmaç işlemi
  if((Komut2 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(Komut2 and %00000111)];           // hedef yazmaç (1. parametre)
    D42 := MYB8[(Komut2 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D41);
    D44 := YazmacDegerAl(D42);

    YazmacDegistir(D41, D43 or D44);

    if((D43 or D44) = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, False);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('or %s,%s', [Yazmaclar8[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := isHata;
end
else if(Komut = $09) then
begin

  if((Komut2 and %11000000) = %11000000) then
  begin

    // 09 /r - OR r/m32,r32 - r/m32 OR r32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(Komut2 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB32[(Komut2 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      if((D43 or D44) = 0) then
        BayrakDegistir(BAYRAK_ZF)
      else BayrakDegistir(BAYRAK_ZF, False);

      {$IFDEF DEBUG} mmCikti.Lines.Add('or %s,%s', [Yazmaclar32[D41 and $FF], Yazmaclar32[D42 and $FF]]); {$ENDIF}
    end
    else
    // 09 /r - OR r/m16,r16 - r/m16 OR r16
    begin

      D41 := MYB16[(Komut2 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB16[(Komut2 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      if((D43 or D44) = 0) then
        BayrakDegistir(BAYRAK_ZF)
      else BayrakDegistir(BAYRAK_ZF, False);

      {$IFDEF DEBUG} mmCikti.Lines.Add('or %s,%s', [Yazmaclar16[D41 and $FF], Yazmaclar16[D42 and $FF]]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := isHata;
end
