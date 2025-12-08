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
