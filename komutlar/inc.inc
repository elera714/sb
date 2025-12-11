// 40+ rw - INC r16 - Increment word register by 1
// 40+ rd - INC r32 - Increment doubleword register by 1
else if(Komut >= $40 + YZMC0_EAX) and (Komut <= $40 + YZMC0_EDI) then
begin

  if(KomutModDegistir) then
  begin

    YazmacDegistir(($04 shl 8) or (Komut - $40), 1, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('inc %s', [Yazmaclar32[Komut - $40]]); {$ENDIF}
  end
  else
  begin

    YazmacDegistir(($02 shl 8) or (Komut - $40), 1, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('inc %s', [Yazmaclar16[Komut - $40]]); {$ENDIF}
  end;

  IPDegeriniArtir;
end
// FE /0 - INC r/m8 - Increment r/m byte by 1
// FF /0 - INC r/m16 - Increment r/m word by 1              { TODO - kodlanacak }
// FF /0 - INC r/m32 - Increment r/m doubleword by 1        { TODO - kodlanacak }
else if(Komut = $FE) and ((Komut2 and %00111000) = %00000000) then
begin

  if((Komut2 and %11000000) = %11000000) then
  begin

    D41 := MYB8[Komut2 and %00000111];
    YazmacDegistir(D41, +1, True);

    if((D41 and $FF) >= $40) then D41 := (D41 shr 4) and $F else D41 := D41 and $F;

    {$IFDEF DEBUG} mmCikti.Lines.Add('inc %s', [Yazmaclar8[D41]]); {$ENDIF}
    IPDegeriniArtir(2);

  end else Result := False;
end
