// 84 /r - TEST r/m8,r8 - AND r8 with r/m8; set SF, ZF, PF according to result
{ TODO - diğer etkilenen bayraklar da aşağıdaki kodlara eklenecek }
else if(IslenenKomut = $84) then
begin

  V11 := PByte(@Bellek144MB[Adres + 1])^;

  // 8 bitlik yazmaç karşılaştırmaları
  if((V11 and %11000000) = %11000000) then
  begin

    V41 := MYB8[(V11 and %00000111)];           // hedef yazmaç (1. parametre)
    V42 := MYB8[(V11 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    V43 := YazmacDegerAl(V41);
    V44 := YazmacDegerAl(V42);

    if((V43 and V44) = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, True);

    if((V41 and $FF) >= $40) then V41 := (V41 shr 4) and $F else V41 := V41 and $F;
    if((V42 and $FF) >= $40) then V42 := (V42 shr 4) and $F else V42 := V42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('test %s,%s', [Yazmaclar8[V41], Yazmaclar8[V42]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := False;
end
else if(IslenenKomut = $85) then
begin

  V11 := PByte(@Bellek144MB[Adres + 1])^;

  // 16 bitlik yazmaç karşılaştırmaları
  if((V11 and %11000000) = %11000000) then
  begin

    // 85 /r - TEST r/m32,r32 - AND r32 with r/m32; set SF, ZF, PF according to result
    if(KomutModDegistir) then
    begin

      V41 := MYB32[(V11 and %00000111)];          // hedef yazmaç (1. parametre)
      V42 := MYB32[(V11 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      V43 := YazmacDegerAl(V41);
      V44 := YazmacDegerAl(V42);

      if((V43 and V44) = 0) then
        BayrakDegistir(BAYRAK_ZF)
      else BayrakDegistir(BAYRAK_ZF, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('test %s,%s', [Yazmaclar32[V41 and $FF], Yazmaclar32[V42 and $FF]]); {$ENDIF}
    end
    else
    // 85 /r - TEST r/m16,r16 - AND r16 with r/m16; set SF, ZF, PF according to result
    begin

      V41 := MYB16[(V11 and %00000111)];          // hedef yazmaç (1. parametre)
      V42 := MYB16[(V11 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      V43 := YazmacDegerAl(V41);
      V44 := YazmacDegerAl(V42);

      if((V43 and V44) = 0) then
        BayrakDegistir(BAYRAK_ZF)
      else BayrakDegistir(BAYRAK_ZF, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('test %s,%s', [Yazmaclar16[V41 and $FF], Yazmaclar16[V42 and $FF]]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := False;
end
