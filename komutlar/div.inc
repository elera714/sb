// F6 /6 - DIV r/m8 - Unsigned divide AX by r/m8; AL ← Quotient, AH ← Remainder
else if(Komut = $F6) then
begin

  if((Komut2 and %11111000) = %11110000) then
  begin

    D41 := MYB8[Komut2 and %00000111];

    D21 := YazmacDegerAl(YZMC_AX);
    D22 := YazmacDegerAl(D41);
    D11 := D21 div D22;
    D12 := D21 mod D22;

    YazmacDegistir(YZMC_AL, D11);
    YazmacDegistir(YZMC_AH, D12);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('div %s', [Yazmaclar8[D41]]); {$ENDIF}
    IPDegeriniArtir(2);
  end;
end
// F7 /6 - DIV r/m16 - Unsigned divide DX:AX by r/m16; AX ← Quotient, DX ← Remainder
// F7 /6 - DIV r/m32 - Unsigned divide EDX:EAX by r/m32 doubleword; EAX ← Quotient, EDX ← Remainder
else if(Komut = $F7) and ((Komut2 and %11111000) = %00110000) then
begin

  D41 := (Komut2 and %00000111);                  // kaynak yazmaç
  D42 := Mod00Isle(D41);
  D43 := PWord(@Bellek144MB[D42])^;

  D44 := YazmacDegerAl(YZMC_DX);
  D45 := YazmacDegerAl(YZMC_AX);
  D44 := D44 shl 16;
  D44 := D44 or D45;

  D45 := D44 div D43;
  D44 := D44 mod D43;

  YazmacDegistir(YZMC_AX, D45);
  YazmacDegistir(YZMC_DX, D44);

  // komut uzunluğu öndeğer = 2 byte
  D44 := 2;
  if(D41 = 6) then D44 := 4;

  {$IFDEF DEBUG}
    if(D41 = 6) then
      mmCikti.Lines.Add('div [$%.4x]', [D43])
    else mmCikti.Lines.Add('div %s', [Bellekler00[D41]]);
  {$ENDIF}

  IPDegeriniArtir(D44);
end
else if(Komut = $F7) and ((Komut2 and %11111000) = %11110000) then
begin

  D41 := MYB16[Komut2 and %00000111];             // yazmaç
  D42 := YazmacDegerAl(D41);

  D44 := YazmacDegerAl(YZMC_DX);
  D45 := YazmacDegerAl(YZMC_AX);
  D44 := D44 shl 16;
  D44 := D44 or D45;

  D45 := D44 div D42;
  D44 := D44 mod D42;

  YazmacDegistir(YZMC_AX, D45);
  YazmacDegistir(YZMC_DX, D44);

  {$IFDEF DEBUG}
  mmCikti.Lines.Add('div %s', [Yazmaclar16[D41 and $FF]]);
  {$ENDIF}

  IPDegeriniArtir(2);
end
