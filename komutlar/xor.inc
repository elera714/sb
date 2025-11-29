// 30 /r - XOR r/m8,r8 - r/m8 XOR r8
else if(IslenenKomut = $30) then
begin

  D11 := BirSonrakiKomut;

  // yazmaç ataması
  if((D11 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(D11 and %00000111)];           // hedef yazmaç (1. parametre)
    D42 := MYB8[(D11 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D41);
    D44 := YazmacDegerAl(D42);

    YazmacDegistir2(D41, D43 xor D44);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('xor %s,%s', [Yazmaclar8[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := False;
end
else if(IslenenKomut = $31) then
begin

  D11 := BirSonrakiKomut;

  // yazmaç ataması
  if((D11 and %11000000) = %11000000) then
  begin

    // 31 /r - XOR r/m32,r32 - r/m32 XOR r32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(D11 and %00000111)];           // hedef yazmaç (1. parametre)
      D42 := MYB32[(D11 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir2(D41, D43 xor D44);

      {$IFDEF DEBUG} mmCikti.Lines.Add('xor %s,%s', [Yazmaclar32[D41 and $FF], Yazmaclar32[D42 and $FF]]); {$ENDIF}

      IPDegeriniArtir(2);
    end
    else
    // 31 /r - XOR r/m16,r16 - r/m16 XOR r16
    begin

      D41 := MYB16[(D11 and %00000111)];           // hedef yazmaç (1. parametre)
      D42 := MYB16[(D11 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir2(D41, D43 xor D44);

      {$IFDEF DEBUG} mmCikti.Lines.Add('xor %s,%s', [Yazmaclar16[D41 and $FF], Yazmaclar16[D42 and $FF]]); {$ENDIF}

      IPDegeriniArtir(2);
    end;

  end else Result := False;
end
