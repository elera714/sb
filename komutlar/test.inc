// 84 /r - TEST r/m8,r8 - AND r8 with r/m8; set SF, ZF, PF according to result
{ TODO - diğer etkilenen bayraklar da aşağıdaki kodlara eklenecek }
else if(IslenenKomut = $84) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;

  // 8 bitlik yazmaç karşılaştırmaları
  if((D11 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(D11 and %00000111)];           // hedef yazmaç (1. parametre)
    D42 := MYB8[(D11 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D41);
    D44 := YazmacDegerAl(D42);

    if((D43 and D44) = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, False);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('test %s,%s', [Yazmaclar8[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := False;
end
else if(IslenenKomut = $85) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;

  if((D11 and %11000000) = %11000000) then
  begin

    // 85 /r - TEST r/m32,r32 - AND r32 with r/m32; set SF, ZF, PF according to result
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(D11 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB32[(D11 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      if((D43 and D44) = 0) then
        BayrakDegistir(BAYRAK_ZF)
      else BayrakDegistir(BAYRAK_ZF, False);

      {$IFDEF DEBUG} mmCikti.Lines.Add('test %s,%s', [Yazmaclar32[D41 and $FF], Yazmaclar32[D42 and $FF]]); {$ENDIF}
    end
    else
    // 85 /r - TEST r/m16,r16 - AND r16 with r/m16; set SF, ZF, PF according to result
    begin

      D41 := MYB16[(D11 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB16[(D11 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      if((D43 and D44) = 0) then
        BayrakDegistir(BAYRAK_ZF)
      else BayrakDegistir(BAYRAK_ZF, False);

      {$IFDEF DEBUG} mmCikti.Lines.Add('test %s,%s', [Yazmaclar16[D41 and $FF], Yazmaclar16[D42 and $FF]]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := False;
end
