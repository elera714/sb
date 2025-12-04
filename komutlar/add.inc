// 00 /r - ADD r/m8,r8 - Add r8 to r/m8
else if(Komut = $00) then
begin

  // 8 bitlik yazmaç ataması
  if((Komut2 and %11000000) = %11000000) then
  begin

    D41 := MYB8[(Komut2 and %00000111)];           // hedef yazmaç (1. parametre)
    D42 := MYB8[(Komut2 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
    D43 := YazmacDegerAl(D41);
    D44 := YazmacDegerAl(D42);

    YazmacDegistir(D41, D44, True);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;
    if((D42 and $FF) >= $40) then D42 := (D42 shr 4) and $F else D42 := D42 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar8[D41], Yazmaclar8[D42]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := False;
end
else if(Komut = $01) then
begin

  if((Komut2 and %11000000) = %11000000) then
  begin

    // 01 /r - ADD r/m32,r32 - Add r32 to r/m32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(Komut2 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB32[(Komut2 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir(D41, D44, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar32[D41 and $FF], Yazmaclar32[D42 and $FF]]); {$ENDIF}
    end
    else
    // 01 /r - ADD r/m16,r16 - Add r16 to r/m16
    begin

      D41 := MYB16[(Komut2 and %00000111)];          // hedef yazmaç (1. parametre)
      D42 := MYB16[(Komut2 and %00111000) shr 3];    // kaynak yazmaç (2. parametre)
      D43 := YazmacDegerAl(D41);
      D44 := YazmacDegerAl(D42);

      YazmacDegistir(D41, D44, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,%s', [Yazmaclar16[D41 and $FF], Yazmaclar16[D42 and $FF]]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := False;
end
else if(Komut = $83) then
begin

  if((Komut2 and %11000000) = %11000000) then
  begin

    // 83 /0 ib - ADD r/m32,imm8 - Add sign-extended imm8 to r/m32
    if(KomutModDegistir) then
    begin

      D41 := MYB32[(Komut2 and %00000111)];          // hedef yazmaç
      D11 := PByte(@Bellek144MB[Adres + 2])^;
      YazmacDegistir(D41, D11, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,$%.2x', [Yazmaclar32[D41 and $FF], D11]); {$ENDIF}
    end
    else
    // 83 /0 ib - ADD r/m16,imm8 - Add sign-extended imm8 to r/m16
    begin

      D41 := MYB16[(Komut2 and %00000111)];          // hedef yazmaç
      D11 := PByte(@Bellek144MB[Adres + 2])^;
      YazmacDegistir(D41, D11, True);

      {$IFDEF DEBUG} mmCikti.Lines.Add('add %s,$%.2x', [Yazmaclar16[D41 and $FF], D11]); {$ENDIF}
    end;

    IPDegeriniArtir(3);

  end else Result := False;
end
