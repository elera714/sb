// 48+rw - DEC r16 - Decrement r16 by 1
// 48+rd - DEC r32 - Decrement r32 by 1
else if(IslenenKomut >= $48 + YZMC0_EAX) and (IslenenKomut <= $48 + YZMC0_EDI) then
begin

  if(KomutModDegistir) then
  begin

    YazmacDegistir2(($04 shl 8) or (IslenenKomut - $48), -1, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('dec %s', [Yazmaclar32[IslenenKomut - $48]]); {$ENDIF}
  end
  else
  begin

    YazmacDegistir2(($03 shl 8) or (IslenenKomut - $48), -1, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('dec %s', [Yazmaclar16[IslenenKomut - $48]]); {$ENDIF}
  end;

  IPDegeriniArtir;
end
