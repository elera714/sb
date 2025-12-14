// 48+rw - DEC r16 - Decrement r16 by 1
// 48+rd - DEC r32 - Decrement r32 by 1
else if(Komut >= $48 + YZMC0_EAX) and (Komut <= $48 + YZMC0_EDI) then
begin

  if(KomutModDegistir) then
  begin

    YazmacDegistir(($04 shl 8) or (Komut - $48), -1, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('dec %s', [Yazmaclar32[Komut - $48]]); {$ENDIF}
  end
  else
  begin

    YazmacDegistir(($02 shl 8) or (Komut - $48), -1, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('dec %s', [Yazmaclar16[Komut - $48]]); {$ENDIF}
  end;

  IPDegeriniArtir;
end
// FE /1 - DEC r/m8 - Decrement r/m8 by 1
else if(Komut = $FE) and ((Komut2 and %00111000) = %00001000) then
begin

  if((Komut2 and %00001110) = %00001110) then
  begin

    D21 := PWord(@Bellek144MB[IslenenAdres + 2])^;
    D11 := PByte(@Bellek144MB[D21])^;
    D11 := D11 - 1;
    PByte(@Bellek144MB[D21])^ := D11;

    if(D11 = 0) then
      BayrakDegistir(BAYRAK_ZF)
    else BayrakDegistir(BAYRAK_ZF, False);

    {$IFDEF DEBUG} mmCikti.Lines.Add('dec [$%.2x]', [D21]); {$ENDIF}
    IPDegeriniArtir(2 + 2);

  end;
end
